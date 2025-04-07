import { ethers } from "hardhat";

async function main() {
  console.log("Deploying NFTTimeAccess contract...");

  // Get signer (deployer)
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  // Deploy NFTTimeAccess with deployer as initial owner
  const NFTTimeAccess = await ethers.getContractFactory("NFTTimeAccess");
  const nftTimeAccess = await NFTTimeAccess.deploy(deployer.address);

  await nftTimeAccess.waitForDeployment();
  const deployedAddress = await nftTimeAccess.getAddress();

  console.log("NFTTimeAccess deployed to:", deployedAddress);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 