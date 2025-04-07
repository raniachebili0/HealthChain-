import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ethers } from 'ethers';

const NFT_TIME_ACCESS_ABI = [
  "function grantAccess(address nftContract, uint256 tokenId, address user, uint256 durationInSeconds) external",
  "function revokeAccess(address nftContract, uint256 tokenId, address user) external",
  "function hasAccess(address nftContract, uint256 tokenId, address user) public view returns (bool)",
  "function getAccessGrant(address nftContract, uint256 tokenId, address user) external view returns (uint256 startTime, uint256 endTime, bool isActive)",
  "event AccessGranted(address indexed nftContract, uint256 indexed tokenId, address indexed user, uint256 startTime, uint256 endTime)",
  "event AccessRevoked(address indexed nftContract, uint256 indexed tokenId, address indexed user)",
  "event AccessUsed(address indexed nftContract, uint256 indexed tokenId, address indexed user)"
];

@Injectable()
export class NftAccessService {
  private readonly logger = new Logger(NftAccessService.name);
  private contract: ethers.Contract;
  private wallet: ethers.Wallet;
  private provider: ethers.JsonRpcProvider;

  constructor(private configService: ConfigService) {
    const ganacheUrl = this.configService.get<string>('GANACHE_URL', 'http://127.0.0.1:7545');
    this.provider = new ethers.JsonRpcProvider(ganacheUrl);
    
    const privateKey = this.configService.get<string>('ETHEREUM_PRIVATE_KEY');
    if (!privateKey) {
      throw new Error('ETHEREUM_PRIVATE_KEY environment variable is not set');
    }
    this.wallet = new ethers.Wallet(privateKey, this.provider);

    const accessContractAddress = this.configService.get<string>('ACCESS_CONTRACT_ADDRESS');
    if (!accessContractAddress) {
      throw new Error('ACCESS_CONTRACT_ADDRESS environment variable is not set');
    }

    this.contract = new ethers.Contract(accessContractAddress, NFT_TIME_ACCESS_ABI, this.wallet);
  }

  async grantAccess(
    nftContract: string,
    tokenId: number,
    userAddress: string,
    durationInHours: number
  ) {
    try {
      this.logger.debug(`Granting access to token ${tokenId} for user ${userAddress}`);
      
      // Convert hours to seconds, ensuring we have at least 60 seconds (1 minute) as minimum
      const durationInSeconds = Math.max(60, Math.floor(durationInHours * 3600));
      this.logger.debug(`Duration in seconds: ${durationInSeconds}`);
      
      // Get estimated gas limit for the transaction with a buffer
      const gasLimit = await this.contract.grantAccess.estimateGas(
        nftContract,
        tokenId,
        userAddress,
        durationInSeconds
      ).then(estimate => {
        // Add 50% buffer to the gas estimate
        return Math.floor(Number(estimate) * 1.5);
      }).catch(() => {
        // If estimation fails, use a high default value
        return 500000; // Default high gas limit
      });
      
      this.logger.debug(`Estimated gas limit: ${gasLimit}`);

      // Send transaction with specified gas limit
      const tx = await this.contract.grantAccess(
        nftContract,
        tokenId,
        userAddress,
        durationInSeconds,
        { 
          gasLimit,
          gasPrice: ethers.parseUnits('20', 'gwei') // Set an appropriate gas price
        }
      );

      this.logger.debug(`Transaction sent: ${tx.hash}`);
      
      // Wait for transaction to be mined
      const receipt = await tx.wait();
      this.logger.debug(`Transaction mined: ${receipt.hash}`);
      
      // Create current timestamp for fallback
      const currentTime = Math.floor(Date.now() / 1000);
      const endTime = currentTime + durationInSeconds;

      // Event might not be detected correctly, so we'll use a fallback approach
      return {
        nftContract,
        tokenId,
        user: userAddress,
        startTime: new Date(currentTime * 1000).toISOString(),
        endTime: new Date(endTime * 1000).toISOString(),
        durationSeconds: durationInSeconds,
        transactionHash: receipt.hash,
        status: 'success'
      };
    } catch (error) {
      this.logger.error('Failed to grant access:', error);
      throw new Error(`Failed to grant access: ${error.message}`);
    }
  }

  async revokeAccess(
    nftContract: string,
    tokenId: number,
    userAddress: string
  ) {
    try {
      this.logger.debug(`Revoking access to token ${tokenId} for user ${userAddress}`);
      
      // Get estimated gas limit for the transaction with a buffer
      const gasLimit = await this.contract.revokeAccess.estimateGas(
        nftContract,
        tokenId,
        userAddress
      ).then(estimate => {
        // Add 50% buffer to the gas estimate
        return Math.floor(Number(estimate) * 1.5);
      }).catch(() => {
        // If estimation fails, use a high default value
        return 300000; // Default high gas limit
      });
      
      this.logger.debug(`Estimated gas limit for revoke: ${gasLimit}`);
      
      const tx = await this.contract.revokeAccess(
        nftContract,
        tokenId,
        userAddress,
        { 
          gasLimit,
          gasPrice: ethers.parseUnits('20', 'gwei') // Set an appropriate gas price
        }
      );

      this.logger.debug(`Revoke transaction sent: ${tx.hash}`);
      const receipt = await tx.wait();
      
      return {
        nftContract,
        tokenId,
        user: userAddress,
        transactionHash: receipt.hash,
        status: 'success'
      };
    } catch (error) {
      this.logger.error('Failed to revoke access:', error);
      throw new Error(`Failed to revoke access: ${error.message}`);
    }
  }

  async checkAccess(
    nftContract: string,
    tokenId: number,
    userAddress: string
  ) {
    try {
      this.logger.debug(`Checking access to token ${tokenId} for user ${userAddress}`);
      
      // Get blockchain-based access state
      const hasAccessOnChain = await this.contract.hasAccess(
        nftContract,
        tokenId,
        userAddress
      );

      const grant = await this.contract.getAccessGrant(
        nftContract,
        tokenId,
        userAddress
      );

      // Also check against real-world time since blockchain time might not be updated
      const currentTimestamp = Math.floor(Date.now() / 1000);
      const startTime = Number(grant.startTime);
      const endTime = Number(grant.endTime);
      
      // Calculate if access is valid based on real-world time
      const isTimeValid = startTime <= currentTimestamp && currentTimestamp <= endTime;
      
      // Access is valid only if both blockchain says it's valid AND real-world time is valid
      const hasAccess = hasAccessOnChain && isTimeValid && grant.isActive;
      
      this.logger.debug(`Access check: blockchain says ${hasAccessOnChain}, real-world time valid: ${isTimeValid}, overall: ${hasAccess}`);

      return {
        nftContract,
        tokenId,
        user: userAddress,
        hasAccess,
        startTime: startTime > 0 ? new Date(startTime * 1000).toISOString() : null,
        endTime: endTime > 0 ? new Date(endTime * 1000).toISOString() : null,
        isActive: grant.isActive,
        currentTime: new Date(currentTimestamp * 1000).toISOString(),
        timeRemaining: endTime > currentTimestamp ? Math.floor((endTime - currentTimestamp) / 60) + ' minutes' : 'Expired'
      };
    } catch (error) {
      this.logger.error('Failed to check access:', error);
      throw new Error(`Failed to check access: ${error.message}`);
    }
  }
} 