import { ethers } from "hardhat";
import { expect } from "chai";
import { AgentNFT__factory } from "../typechain-types/factories/AgentNFT__factory";
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";

describe("AgentNFT", function () {
  let contractOwner: SignerWithAddress;
  let alice: SignerWithAddress;
  let bob: SignerWithAddress;

  beforeEach(async function () {
    [contractOwner, alice, bob] = await ethers.getSigners();
    console.log("contractOwner:", contractOwner.address);
    console.log("alice:", alice.address);
    console.log("bob:", bob.address);
  });

  describe("Mint", function () {
    it("Should mint a new token with valid proofs", async function () {
      const agentNFT = AgentNFT__factory.connect(process.env.ZG_NFT_CONTRACT_ADDRESS || "", alice);
      const proofs = [ethers.hexlify('0xd0862f05b39d287f3eaeb679d402dfc09f372b66b8d43467d01dc9d5cd88f9bd'), ethers.hexlify('0x140346975f3677e7530e8285141fc30ea48c926e77d1b3983841454fd33fda76')];
      console.log("proofs:", proofs);
      
      const newTokenId = await agentNFT.mint.staticCall(proofs, ["eliza_character", "eliza_memory"]);
      const tx = await agentNFT.connect(alice).mint(proofs, ["eliza_character", "eliza_memory"]);
      await tx.wait();
      console.log("Created a new token with id", newTokenId.toString(), "for alice with address", alice.address);

      expect(await agentNFT.ownerOf(newTokenId)).to.equal(alice.address);

      const dataHashes = await agentNFT.dataHashesOf(newTokenId);
      console.log("dataHashes behind the token[", newTokenId.toString(), "]:", dataHashes);
    });
  });

  describe("TransferPublic", function () {
    it("Should transfer token to another address", async function () {
      // mint a token for alice
      const proofs = [ethers.randomBytes(32)];
      const agentNFT = AgentNFT__factory.connect(process.env.ZG_NFT_CONTRACT_ADDRESS || "", alice);
      const tokenId = await agentNFT.connect(alice).mint.staticCall(proofs, ["anything"]);
      const tx = await agentNFT.connect(alice).mint(proofs, ["anything"]);
      await tx.wait();
      console.log("Created a new token with id", tokenId.toString(), "for alice with address", alice.address);

      await agentNFT.connect(alice).transferPublic(bob.address, tokenId);

      expect(await agentNFT.ownerOf(tokenId)).to.equal(bob.address);
    });
  });

  describe("ClonePublic", function () {
    it("Should mint a new token for another address with the same data", async function () {
      // mint a token for alice
      const proofs = [ethers.randomBytes(32)];
      const agentNFT = AgentNFT__factory.connect(process.env.ZG_NFT_CONTRACT_ADDRESS || "", alice);
      const tokenId = await agentNFT.connect(alice).mint.staticCall(proofs, ["anything"]);
      let tx = await agentNFT.connect(alice).mint(proofs, ["anything"]);
      await tx.wait();
      console.log("Created a new token with id", tokenId.toString(), "for alice with address", alice.address);

      const newTokenId = await agentNFT.connect(alice).clonePublic.staticCall(bob.address, tokenId);
      tx = await agentNFT.connect(alice).clonePublic(bob.address, tokenId);
      await tx.wait();
      console.log("Clone a new token with id", newTokenId.toString(), "for bob with address", bob.address);
      expect(await agentNFT.ownerOf(tokenId)).to.equal(alice.address);
      expect(await agentNFT.ownerOf(newTokenId)).to.equal(bob.address);
    });
  });
});