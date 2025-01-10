// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IERC7857.sol";
import "./interfaces/IERC7857Metadata.sol";
import "./interfaces/IERC7857DataVerifier.sol";
import "./Utils.sol";

contract AgentNFT is IERC7857, IERC7857Metadata {
   struct TokenData {
       address owner;
       string[] dataDescriptions;
       bytes32[] dataHashes;
       address[] authorizedUsers;
   }
   
   IERC7857DataVerifier private immutable _verifier;
   mapping(uint256 => TokenData) private _tokens;
   uint256 private _nextTokenId;

   string private _name;
   string private _symbol;
   address private immutable _owner;
   string private _chainURL;
   string private _indexerURL;
   
   constructor(
       string memory name_,
       string memory symbol_,
       address verifierAddr,
       string memory chainURL_,
       string memory indexerURL_
   ) {
       require(verifierAddr != address(0), "Zero address");
       _verifier = IERC7857DataVerifier(verifierAddr);
       _name = name_;
       _symbol = symbol_;
       _chainURL = chainURL_;
       _indexerURL = indexerURL_;
       _owner = msg.sender;
   }

   function name() external view returns (string memory) {
       return _name;
   }

   function symbol() external view returns (string memory) {
       return _symbol;
   }


   function update(
       uint256 tokenId,
       bytes[] calldata proofs
   ) external {
       TokenData storage token = _tokens[tokenId];
       require(token.owner == msg.sender, "Not owner");
       
       OwnershipProofOutput[] memory proofOupt = _verifier.verifyOwnership(proofs);
       bytes32[] memory newDataHashes = new bytes32[](proofOupt.length);

       for (uint i = 0; i < proofOupt.length; i++) {
           require(
               proofOupt[i].isValid,
               string(abi.encodePacked(
                    "Invalid ownership proof at index ",
                    i,
                    " with data hash ",
                    proofOupt[i].dataHash
                ))
           );
           newDataHashes[i] = proofOupt[i].dataHash;
       }

       bytes32[] memory oldDataHashes = token.dataHashes;
       token.dataHashes = newDataHashes;

       emit Updated(tokenId, oldDataHashes, newDataHashes);
   }
   
   function dataHashesOf(uint256 tokenId) public view returns (bytes32[] memory) {
       TokenData storage token = _tokens[tokenId];
       require(token.owner != address(0), "Token not exist");
       return token.dataHashes;
   }

   function dataDescriptionsOf(uint256 tokenId) public view returns (string[] memory) {
       TokenData storage token = _tokens[tokenId];
       require(token.owner != address(0), "Token not exist");
       return token.dataDescriptions;
   }

   function tokenURI(uint256 tokenId) external view returns (string memory) {
       require(_exists(tokenId), "Token does not exist");
       bytes32[] memory dataHashes = dataHashesOf(tokenId);
       
       string memory result = string(abi.encodePacked(
           "chainURL: ", _chainURL, "\n",
           "indexerURL: ", _indexerURL, "\n"
       ));
       return result;
   }

   function verifier() external view returns (IERC7857DataVerifier) {
       return _verifier;
   }
   
   function mint(bytes[] calldata proofs, string[] calldata dataDescriptions) 
       external 
       payable 
       returns (uint256 tokenId) 
   {
       require(dataDescriptions.length == proofs.length, "Descriptions and proofs length mismatch");

       OwnershipProofOutput[] memory proofOupt = _verifier.verifyOwnership(proofs);
       bytes32[] memory dataHashes = new bytes32[](proofOupt.length);

       for (uint i = 0; i < proofOupt.length; i++) {
           require(
               proofOupt[i].isValid,
               string(abi.encodePacked(
                    "Invalid ownership proof at index ",
                    i,
                    " with data hash ",
                    proofOupt[i].dataHash
                ))
           );
           dataHashes[i] = proofOupt[i].dataHash;
       }

       tokenId = _nextTokenId++;
       _tokens[tokenId] = TokenData({
           owner: msg.sender,
           dataHashes: dataHashes,
           dataDescriptions: dataDescriptions,
           authorizedUsers: new address[](0)
       });
       
       emit Minted(tokenId, msg.sender, dataHashes, dataDescriptions);
   }

   function transfer(
       address to,
       uint256 tokenId,
       bytes calldata proof
   ) external {
       require(to != address(0), "Zero address");
       
       TokenData storage token = _tokens[tokenId];
       require(token.owner == msg.sender, "Not owner");
       
       TransferValidityProofOutput memory proofOupt = _verifier.verifyTransferValidity(proof);
       bytes32[] memory oldDataHashes = proofOupt.oldDataHashes;
       bytes32[] memory newDataHashes = proofOupt.newDataHashes;
       bytes32[] memory tokenDataHashes = token.dataHashes;
       bytes memory pubKey = proofOupt.pubKey;
       bytes memory sealedKey = proofOupt.sealedKey;
       
       require(
           proofOupt.isValid 
           && Utils.isEqual(oldDataHashes, tokenDataHashes)
           && Utils.pubKeyToAddress(pubKey) == to,
           "Invalid transfer validity proof"
       );

       token.owner = to;
       token.dataHashes = newDataHashes;

       emit Transferred(tokenId, msg.sender, to);
       emit PublishedSealedKey(to, tokenId, sealedKey);
   }

   function transferPublic(
       address to,
       uint256 tokenId
   ) external {
       require(to != address(0), "Zero address");
       require(_tokens[tokenId].owner == msg.sender, "Not owner");
       _tokens[tokenId].owner = to;
       emit Transferred(tokenId, msg.sender, to);
   }

   function clone(
       address to,
       uint256 tokenId,
       bytes calldata proof
   ) external payable returns (uint256) {
       require(to != address(0), "Zero address");
       
       require(_tokens[tokenId].owner == msg.sender, "Not owner");
       
       TransferValidityProofOutput memory proofOupt = _verifier.verifyTransferValidity(proof);
       bytes32[] memory oldDataHashes = proofOupt.oldDataHashes;
       bytes32[] memory newDataHashes = proofOupt.newDataHashes;
       bytes32[] memory tokenDataHashes = _tokens[tokenId].dataHashes;
       bytes memory pubKey = proofOupt.pubKey;  
       bytes memory sealedKey = proofOupt.sealedKey;
       
       require(
           proofOupt.isValid 
           && Utils.isEqual(oldDataHashes, tokenDataHashes)
           && Utils.pubKeyToAddress(pubKey) == to,
           "Invalid transfer validity proof"
       );

       uint256 newTokenId = _nextTokenId++;
       _tokens[newTokenId] = TokenData({
           owner: to,
           dataHashes: newDataHashes,
           dataDescriptions: _tokens[tokenId].dataDescriptions,
           authorizedUsers: new address[](0)
       });

       emit Cloned(tokenId, newTokenId, msg.sender, to);
       emit PublishedSealedKey(to, newTokenId, sealedKey);
       return newTokenId;
   }

   function clonePublic(
       address to,
       uint256 tokenId
   ) external payable returns (uint256) {
       require(to != address(0), "Zero address");
       require(_tokens[tokenId].owner == msg.sender, "Not owner");
       
       uint256 newTokenId = _nextTokenId++;
       _tokens[newTokenId] = TokenData({
           owner: to,
           dataHashes: _tokens[tokenId].dataHashes,
           dataDescriptions: _tokens[tokenId].dataDescriptions,
           authorizedUsers: new address[](0)
       });
       emit Cloned(tokenId, newTokenId, msg.sender, to);
       return newTokenId;
   }

   function authorizeUsage(uint256 tokenId, address user) external {
       require(_tokens[tokenId].owner == msg.sender, "Not owner");
       _tokens[tokenId].authorizedUsers.push(user);
       emit AuthorizedUsage(tokenId, user);
   }

   function ownerOf(uint256 tokenId) external view returns (address) {
       TokenData storage token = _tokens[tokenId];
       require(token.owner != address(0), "Token not exist");
       return token.owner;
   }

   function authorizedUsersOf(uint256 tokenId) external view returns (address[] memory) {
       TokenData storage token = _tokens[tokenId];
       require(token.owner != address(0), "Token not exist");
       return token.authorizedUsers;
   }

   // Internal helper functions
   function _exists(uint256 tokenId) internal view returns (bool) {
       return _tokens[tokenId].owner != address(0);
   }
}