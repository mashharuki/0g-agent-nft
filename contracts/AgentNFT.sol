// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IERC7844.sol";
import "./interfaces/IERC7844Metadata.sol";
import "./interfaces/IERC7844DataVerifier.sol";

contract AgentNFT is IERC7844, IERC7844Metadata {
   struct TokenData {
       address owner;
       bytes32[] dataHashes;
       address[] authorizedUsers;
   }
   
   IERC7844DataVerifier private immutable _verifier;
   mapping(uint256 => TokenData) private _tokens;
   uint256 private _nextTokenId;

   string private _name;
   string private _symbol;
   string private _storageURL;
   address private immutable _owner;
   
   constructor(
       string memory name_,
       string memory symbol_,
       address verifierAddr,
       string memory storageURL_
   ) {
       require(verifierAddr != address(0), "Zero address");
       _verifier = IERC7844DataVerifier(verifierAddr);
       _name = name_;
       _symbol = symbol_;
       _storageURL = storageURL_;
       _owner = msg.sender;
   }

   function name() external view returns (string memory) {
       return _name;
   }

   function symbol() external view returns (string memory) {
       return _symbol;
   }

   function config() external view returns (string memory) {
       return _storageURL;
   }

   function setConfig(string memory storageURL) external {
       require(msg.sender == _owner, "Not owner");
       _storageURL = storageURL;
   }

   function tokenURI(uint256 tokenId) external view returns (string memory) {
       require(_exists(tokenId), "Token does not exist");
       return string(abi.encodePacked(_storageURL));
   }

   function update(
       uint256 tokenId,
       bytes calldata proof
   ) external {
       TokenData storage token = _tokens[tokenId];
       require(token.owner == msg.sender, "Not owner");
       
       OwnershipProofOutput memory proofOupt = _verifier.verifyOwnership(proof);
       bytes32[] memory newDataHashes = proofOupt.dataHashes;
       require(
           proofOupt.isValid,
           "Invalid ownership proof"
       );

       bytes32[] memory oldDataHashes = token.dataHashes;
       token.dataHashes = newDataHashes;

       emit Updated(tokenId, oldDataHashes, newDataHashes);
   }
   
   function dataHashesOf(uint256 tokenId) external view returns (bytes32[] memory) {
       TokenData storage token = _tokens[tokenId];
       require(token.owner != address(0), "Token not exist");
       return token.dataHashes;
   }

   function verifier() external view returns (IERC7844DataVerifier) {
       return _verifier;
   }
   
   function mint(bytes calldata proof) 
       external 
       payable 
       returns (uint256 tokenId) 
   {
       OwnershipProofOutput memory proofOupt = _verifier.verifyOwnership(proof);
       bytes32[] memory dataHashes = proofOupt.dataHashes;
       require(
           proofOupt.isValid,
           "Invalid ownership proof"
       );

       tokenId = _nextTokenId++;
       _tokens[tokenId] = TokenData({
           owner: msg.sender,
           dataHashes: dataHashes,
           authorizedUsers: new address[](0)
       });
       
       emit Minted(tokenId, msg.sender, dataHashes);
   }

   function transfer(
       address to,
       uint256 tokenId,
       bytes calldata proof
   ) external {
       require(to != address(0), "Zero address");
       
       TokenData storage token = _tokens[tokenId];
       require(token.owner == msg.sender, "Not owner");
       
       AvailabilityProofOutput memory proofOupt = _verifier.verifyAvailable(proof);
       bytes32[] memory oldDataHashes = proofOupt.oldDataHashes;
       bytes32[] memory newDataHashes = proofOupt.newDataHashes;
       bytes32[] memory tokenDataHashes = token.dataHashes;
       bytes memory pubKey = proofOupt.pubKey;
       bytes memory sealedKey = proofOupt.sealedKey;
       
       require(
           proofOupt.isValid 
           && _isEqual(oldDataHashes, tokenDataHashes)
           && _pubKeyToAddress(pubKey) == to,
           "Invalid availability proof"
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
       
       AvailabilityProofOutput memory proofOupt = _verifier.verifyAvailable(proof);
       bytes32[] memory oldDataHashes = proofOupt.oldDataHashes;
       bytes32[] memory newDataHashes = proofOupt.newDataHashes;
       bytes32[] memory tokenDataHashes = _tokens[tokenId].dataHashes;
       bytes memory pubKey = proofOupt.pubKey;  
       bytes memory sealedKey = proofOupt.sealedKey;
       
       require(
           proofOupt.isValid 
           && _isEqual(oldDataHashes, tokenDataHashes)
           && _pubKeyToAddress(pubKey) == to,
           "Invalid availability proof"
       );

       uint256 newTokenId = _nextTokenId++;
       _tokens[newTokenId] = TokenData({
           owner: to,
           dataHashes: newDataHashes,
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

   function _toString(uint256 value) internal pure returns (string memory) {
       if (value == 0) {
           return "0";
       }
       uint256 temp = value;
       uint256 digits;
       while (temp != 0) {
           digits++;
           temp /= 10;
       }
       bytes memory buffer = new bytes(digits);
       while (value != 0) {
           digits -= 1;
           buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
           value /= 10;
       }
       return string(buffer);
   }

   function _isEqual(bytes32[] memory arr1, bytes32[] memory arr2) private pure returns (bool) {
        if (arr1.length != arr2.length) {
            return false;
        }
        for (uint i = 0; i < arr1.length; i++) {
            if (arr1[i] != arr2[i]) {
                return false;
            }
        }
        return true;
    }

    function _pubKeyToAddress(bytes memory pubKey) private pure returns (address) {
        require(pubKey.length == 64, "Invalid public key length");
        bytes32 hash = keccak256(pubKey);
        return address(uint160(uint256(hash)));
    }
}