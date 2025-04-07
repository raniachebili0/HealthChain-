# File to NFT Converter

This project allows you to convert any file into an NFT using NestJS, Solidity, and IPFS (NFT.Storage).

## Prerequisites

- Node.js (v14 or higher)
- Ganache (for local blockchain)
- MetaMask (for interacting with the blockchain)

## Setup

1. Install dependencies:
```bash
npm install
```

2. Start Ganache and make sure it's running on http://127.0.0.1:8545

3. Deploy the smart contract:
   - Compile the contract in the `contracts` directory
   - Deploy it to Ganache using the provided private key
   - Update the contract address in `src/nft/nft.service.ts`

4. Start the NestJS application:
```bash
npm run start:dev
```

## Usage

The application exposes a single endpoint:

### Create NFT
```bash
POST http://localhost:3000/nft/create
Content-Type: multipart/form-data

file: <your-file>
recipientAddress: <ethereum-address>
```

This endpoint will:
1. Upload your file to IPFS using NFT.Storage
2. Create an NFT on the Ganache blockchain
3. Return the token ID and IPFS URL

## Environment Variables

The following environment variables are used:
- NFT_STORAGE_TOKEN: Your NFT.Storage API token
- GANACHE_PRIVATE_KEY: Your Ganache account private key

## Security Notes

- Never commit your private keys or API tokens
- The provided private key is for development only
- In production, use environment variables for sensitive data 