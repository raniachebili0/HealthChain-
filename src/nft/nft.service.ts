import { Injectable, Logger } from '@nestjs/common';
import { ethers } from 'ethers';
import { ConfigService } from '@nestjs/config';
import * as FormData from 'form-data';
import fetch from 'node-fetch';
import * as fs from 'fs';
import * as path from 'path';

// Contract ABI - this should match your deployed contract
const CONTRACT_ABI = [
  "function mintNFT(address recipient, string memory tokenURI) public returns (uint256)",
  "event Transfer(address indexed from, address indexed to, uint256 indexed tokenId)"
];

interface MulterFile {
  buffer: Buffer;
  originalname: string;
  mimetype: string;
  size: number;
}

@Injectable()
export class NftService {
  private readonly logger = new Logger(NftService.name);
  private readonly pinataApiKey: string;
  private readonly pinataSecretKey: string;
  private contract: ethers.Contract;
  private wallet: ethers.Wallet;

  constructor(private configService: ConfigService) {
    // Initialize Pinata credentials
    this.pinataApiKey = this.configService.get<string>('PINATA_API_KEY');
    this.pinataSecretKey = this.configService.get<string>('PINATA_SECRET_KEY');
    
    if (!this.pinataApiKey || !this.pinataSecretKey) {
      throw new Error('Pinata API credentials are not set in environment variables');
    }

    // Initialize Ganache provider
    const ganacheUrl = this.configService.get<string>('GANACHE_URL', 'http://127.0.0.1:7545');
    const provider = new ethers.JsonRpcProvider(ganacheUrl);
    
    // Initialize wallet with private key from environment
    const privateKey = this.configService.get<string>('ETHEREUM_PRIVATE_KEY');
    if (!privateKey) {
      throw new Error('ETHEREUM_PRIVATE_KEY environment variable is not set');
    }
    this.wallet = new ethers.Wallet(privateKey, provider);

    // Get contract address from environment
    const contractAddress = this.configService.get<string>('CONTRACT_ADDRESS');
    if (!contractAddress) {
      throw new Error('CONTRACT_ADDRESS environment variable is not set');
    }

    // Initialize contract
    this.contract = new ethers.Contract(contractAddress, CONTRACT_ABI, this.wallet);
  }

  private async saveBufferToTempFile(buffer: Buffer, filename: string): Promise<string> {
    const tempDir = path.join(process.cwd(), 'temp');
    if (!fs.existsSync(tempDir)) {
      fs.mkdirSync(tempDir);
    }
    const tempFilePath = path.join(tempDir, filename);
    fs.writeFileSync(tempFilePath, buffer);
    return tempFilePath;
  }

  private async cleanupTempFile(filePath: string): Promise<void> {
    try {
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    } catch (error) {
      this.logger.warn(`Failed to cleanup temp file: ${error.message}`);
    }
  }

  async uploadFileToIPFS(file: MulterFile): Promise<string> {
    let tempFilePath: string | null = null;
    try {
      this.logger.debug('Starting file upload to IPFS via Pinata...');

      // Save buffer to temp file
      tempFilePath = await this.saveBufferToTempFile(file.buffer, file.originalname);

      // Create form data with proper instantiation
      const formData = new (FormData as any)();
      
      // Add file from disk
      formData.append('file', fs.createReadStream(tempFilePath), {
        filename: file.originalname,
        contentType: file.mimetype
      });

      // Add pinata metadata
      const metadata = {
        name: `NFT-${file.originalname}`,
        keyvalues: {
          description: 'NFT created via minting service',
          type: file.mimetype,
          size: file.size,
          timestamp: new Date().toISOString()
        }
      };
      formData.append('pinataMetadata', JSON.stringify(metadata));

      // Add pinata options for better IPFS configuration
      const pinataOptions = {
        cidVersion: 1,
        wrapWithDirectory: false
      };
      formData.append('pinataOptions', JSON.stringify(pinataOptions));

      // Upload to Pinata
      const response = await fetch('https://api.pinata.cloud/pinning/pinFileToIPFS', {
        method: 'POST',
        headers: {
          'pinata_api_key': this.pinataApiKey,
          'pinata_secret_api_key': this.pinataSecretKey,
          ...formData.getHeaders()
        },
        body: formData
      });

      if (!response.ok) {
        const errorText = await response.text();
        this.logger.error(`Pinata API error: ${errorText}`);
        throw new Error(`Failed to upload to Pinata: ${response.statusText}`);
      }

      const result = await response.json();
      if (!result.IpfsHash) {
        throw new Error('No IPFS hash received from Pinata');
      }

      const url = `ipfs://${result.IpfsHash}`;
      this.logger.debug(`File uploaded to IPFS via Pinata with URL: ${url}`);
      return url;
    } catch (error) {
      this.logger.error('Failed to upload file to IPFS:', error);
      throw new Error(`Failed to upload file to IPFS: ${error.message}`);
    } finally {
      // Cleanup temp file
      if (tempFilePath) {
        await this.cleanupTempFile(tempFilePath);
      }
    }
  }

  async createNFT(file: MulterFile, recipientAddress: string): Promise<{ tokenId: number; ipfsUrl: string }> {
    try {
      this.logger.debug(`Received request to create NFT for address: ${recipientAddress}`);
      
      if (!recipientAddress) {
        throw new Error('Recipient address is required');
      }

      // Validate recipient address
      if (!ethers.isAddress(recipientAddress)) {
        throw new Error(`Invalid recipient address format: ${recipientAddress}`);
      }

      // Upload file to IPFS
      const ipfsUrl = await this.uploadFileToIPFS(file);
      this.logger.debug(`File uploaded to IPFS: ${ipfsUrl}`);

      // Create NFT on the blockchain
      this.logger.debug(`Minting NFT for ${recipientAddress} with URI ${ipfsUrl}`);
      const tx = await this.contract.mintNFT(recipientAddress, ipfsUrl);
      
      // Wait for transaction confirmation and get receipt
      this.logger.debug('Waiting for transaction confirmation...');
      const receipt = await tx.wait();
      
      // Get the token ID from the logs
      const transferEvent = receipt.logs.find(
        (log: any) => {
          try {
            const parsedLog = this.contract.interface.parseLog(log);
            return parsedLog?.name === 'Transfer';
          } catch {
            return false;
          }
        }
      );

      if (!transferEvent) {
        throw new Error('Transfer event not found in transaction logs');
      }

      // Parse the event data
      const parsedEvent = this.contract.interface.parseLog(transferEvent);
      const tokenId = parsedEvent.args[2]; // tokenId is the third argument in Transfer event

      this.logger.debug(`NFT minted successfully with token ID: ${tokenId}`);

      return {
        tokenId: tokenId.toString(),
        ipfsUrl,
      };
    } catch (error) {
      this.logger.error(`Failed to create NFT: ${error.message}`);
      throw new Error(`Failed to create NFT: ${error.message}`);
    }
  }
} 