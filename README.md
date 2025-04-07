# HealthChain NFT Project

This project is part of the HealthChain platform, implementing NFT functionality for medical records and documents.

## Features

- Create and mint NFTs from files
- Store files on IPFS using Pinata
- Smart contract integration with Ethereum
- Time-based access control for NFTs

## Setup

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables in `.env`:
```
PINATA_API_KEY=your_pinata_api_key
PINATA_SECRET_KEY=your_pinata_secret_key
ETHEREUM_PRIVATE_KEY=your_ethereum_private_key
GANACHE_URL=http://127.0.0.1:7545
CONTRACT_ADDRESS=your_contract_address
```

3. Start the development server:
```bash
npm run start:dev
```

## API Endpoints

### Create NFT
- **POST** `/nft/create`
- **Body**: 
  - `file`: File to convert to NFT
  - `recipientAddress`: Ethereum address of the recipient

## Smart Contracts

The project includes the following smart contracts:
- `FileNFT.sol`: Main NFT contract for file tokenization
- Additional contracts for access control and time-based permissions

## Technologies Used

- NestJS
- Ethereum/Solidity
- IPFS/Pinata
- TypeScript
- Hardhat
