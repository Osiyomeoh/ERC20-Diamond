// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./libraries/LibDiamond.sol";

contract MerkleFacet {
    bytes32 public merkleRoot;
    mapping(address => bool) public claimed;

    event Claimed(address indexed claimer, uint256 tokenId);

    function setMerkleRoot(bytes32 _merkleRoot) external {
        require(msg.sender == LibDiamond.contractOwner(), "Only owner can set merkle root");
        merkleRoot = _merkleRoot;
    }

    function claim(bytes32[] calldata _merkleProof) external {
        require(!claimed[msg.sender], "Address has already claimed");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Invalid merkle proof");

        claimed[msg.sender] = true;

        // Call the mint function from ERC721Facet
        (bool success, ) = address(this).delegatecall(
            abi.encodeWithSignature("mint(address)", msg.sender)
        );
        require(success, "Minting failed");

        emit Claimed(msg.sender, LibDiamond.totalMinted());
    }
}