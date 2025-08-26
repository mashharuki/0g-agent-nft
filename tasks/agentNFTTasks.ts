// scripts/tasks/agentNFTTasks.ts
// AgentNFTコントラクトの各機能を呼び出すためのHardhatタスク例
import { task } from "hardhat/config";

// 1. mint
// npx hardhat agentNFT:mint --proofs <proofs> --descriptions <desc> --to <address>
task("agentNFT:mint", "Mint AgentNFT token")
  .addParam("proofs", "Proofs array (JSON string)")
  .addParam("descriptions", "Descriptions array (JSON string)")
  .addOptionalParam("to", "Recipient address")
  .setAction(async ({ proofs, descriptions, to }, hre) => {
    const [deployer] = await hre.ethers.getSigners();
    const contract = await hre.ethers.getContract("AgentNFT");
    const tx = await contract.mint(
      JSON.parse(proofs),
      JSON.parse(descriptions),
      to || deployer.address,
      { from: deployer.address }
    );
    console.log("Minted tokenId:", tx.value.toString());
  });

// 2. update
// npx hardhat agentNFT:update --tokenid <id> --proofs <proofs>
task("agentNFT:update", "Update AgentNFT token data")
  .addParam("tokenid", "Token ID")
  .addParam("proofs", "Proofs array (JSON string)")
  .setAction(async ({ tokenid, proofs }, hre) => {
    const [deployer] = await hre.ethers.getSigners();
    const contract = await hre.ethers.getContract("AgentNFT");
    await contract.update(tokenid, JSON.parse(proofs));
    console.log("Updated tokenId:", tokenid);
  });

// 3. transfer
// npx hardhat agentNFT:transfer --to <address> --tokenid <id> --proofs <proofs>
task("agentNFT:transfer", "Transfer AgentNFT token with proofs")
  .addParam("to", "Recipient address")
  .addParam("tokenid", "Token ID")
  .addParam("proofs", "Proofs array (JSON string)")
  .setAction(async ({ to, tokenid, proofs }, hre) => {
    const [deployer] = await hre.ethers.getSigners();
    const contract = await hre.ethers.getContract("AgentNFT");
    await contract.transfer(to, tokenid, JSON.parse(proofs));
    console.log("Transferred tokenId:", tokenid, "to", to);
  });

// 4. clone
// npx hardhat agentNFT:clone --to <address> --tokenid <id> --proofs <proofs>
task("agentNFT:clone", "Clone AgentNFT token with proofs")
  .addParam("to", "Recipient address")
  .addParam("tokenid", "Token ID")
  .addParam("proofs", "Proofs array (JSON string)")
  .setAction(async ({ to, tokenid, proofs }, hre) => {
    const [deployer] = await hre.ethers.getSigners();
    const contract = await hre.ethers.getContract("AgentNFT");
    const tx = await contract.clone(to, tokenid, JSON.parse(proofs));
    console.log("Cloned tokenId:", tokenid, "to", to, "newTokenId:", tx.value.toString());
  });

// 5. authorizeUsage
// npx hardhat agentNFT:authorize --tokenid <id> --user <address>
task("agentNFT:authorize", "Authorize usage for AgentNFT token")
  .addParam("tokenid", "Token ID")
  .addParam("user", "User address")
  .setAction(async ({ tokenid, user }, hre) => {
    const [deployer] = await hre.ethers.getSigners();
    const contract = await hre.ethers.getContract("AgentNFT");
    await contract.authorizeUsage(tokenid, user);
    console.log("Authorized usage for tokenId:", tokenid, "user:", user);
  });

// 6. ownerOf
// npx hardhat agentNFT:ownerOf --tokenid <id>
task("agentNFT:ownerOf", "Get owner of AgentNFT token")
  .addParam("tokenid", "Token ID")
  .setAction(async ({ tokenid }, hre) => {
    const contract = await hre.ethers.getContract("AgentNFT");
    const owner = await contract.ownerOf(tokenid);
    console.log("Owner of tokenId:", tokenid, owner);
  });

// 7. authorizedUsersOf
// npx hardhat agentNFT:authorizedUsersOf --tokenid <id>
task("agentNFT:authorizedUsersOf", "Get authorized users of AgentNFT token")
  .addParam("tokenid", "Token ID")
  .setAction(async ({ tokenid }, hre) => {
    const contract = await hre.ethers.getContract("AgentNFT");
    const users = await contract.authorizedUsersOf(tokenid);
    console.log("Authorized users of tokenId:", tokenid, users);
  });

// 8. dataHashesOf
// npx hardhat agentNFT:dataHashesOf --tokenid <id>
task("agentNFT:dataHashesOf", "Get data hashes of AgentNFT token")
  .addParam("tokenid", "Token ID")
  .setAction(async ({ tokenid }, hre) => {
    const contract = await hre.ethers.getContract("AgentNFT");
    const hashes = await contract.dataHashesOf(tokenid);
    console.log("Data hashes of tokenId:", tokenid, hashes);
  });

// 9. dataDescriptionsOf
// npx hardhat agentNFT:dataDescriptionsOf --tokenid <id>
task("agentNFT:dataDescriptionsOf", "Get data descriptions of AgentNFT token")
  .addParam("tokenid", "Token ID")
  .setAction(async ({ tokenid }, hre) => {
    const contract = await hre.ethers.getContract("AgentNFT");
    const desc = await contract.dataDescriptionsOf(tokenid);
    console.log("Data descriptions of tokenId:", tokenid, desc);
  });

// 10. tokenURI
// npx hardhat agentNFT:tokenURI --tokenid <id>
task("agentNFT:tokenURI", "Get tokenURI of AgentNFT token")
  .addParam("tokenid", "Token ID")
  .setAction(async ({ tokenid }, hre) => {
    const contract = await hre.ethers.getContract("AgentNFT");
    const uri = await contract.tokenURI(tokenid);
    console.log("TokenURI of tokenId:", tokenid, uri);
  });

// 必要に応じて他の関数も追加可能です。
