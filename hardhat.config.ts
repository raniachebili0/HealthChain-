import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";

dotenv.config();

// Get private key from env and remove 0x prefix if present
const privateKey = process.env.ETHEREUM_PRIVATE_KEY || "";
const formattedPrivateKey = privateKey.startsWith('0x') ? privateKey.substring(2) : privateKey;

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    localhost: {
      url: "http://127.0.0.1:7545",
      accounts: [formattedPrivateKey]
    },
    ganache: {
      url: process.env.GANACHE_URL || "http://127.0.0.1:7545",
      accounts: [formattedPrivateKey]
    }
  },
};

export default config; 