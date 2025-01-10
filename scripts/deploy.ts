import { ethers } from "hardhat";

async function main() {
  // 1. deploy TEEVerifier
  console.log("Deploying TEE Verifier...");
  const TEEVerifier = await ethers.getContractFactory("TEEVerifier");
  const teeVerifier = await TEEVerifier.deploy("0x0000000000000000000000000000000000000000" /* attestation contract address */);
  await teeVerifier.waitForDeployment();
  console.log("TEEVerifier deployed to:", teeVerifier.target);

  // 2. deploy AgentNFT
  console.log("Deploying Agent NFT...");
  const AgentNFT = await ethers.getContractFactory("AgentNFT");
  const nftName = process.env.ZG_NFT_NAME || "0G Agent NFT";
  const nftSymbol = process.env.ZG_NFT_SYMBOL || "A0GIA";
  const chainURL = process.env.ZG_RPC_URL || "https://evmrpc-testnet.0g.ai";
  const indexerURL = process.env.ZG_INDEXER_URL || "https://indexer-storage-testnet-turbo.0g.ai";
  const nft = await AgentNFT.deploy(nftName, nftSymbol, teeVerifier.target, chainURL, indexerURL);
  await nft.waitForDeployment();
  console.log("AgentNFT deployed to:", nft.target);

  // 3. verify deployment
  const verifierAddress = await nft.verifier();
  console.log("Verifier address:", verifierAddress);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});