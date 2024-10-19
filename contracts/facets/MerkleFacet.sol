// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/LibDiamond.sol";

contract MerkleFacet {
    bytes32 public merkleRoot;
    mapping(address => bool) public claimed;
    uint256 public totalMinted;

    event Claimed(address indexed claimer, uint256 tokenId);

    function setMerkleRoot(bytes32 _merkleRoot) external {
        require(msg.sender == LibDiamond.contractOwner(), "Only owner can set merkle root");
        merkleRoot = _merkleRoot;
    }

    function claim(bytes32[] calldata _merkleProof) external {
        require(!claimed[msg.sender], "Address has already claimed");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(verify(_merkleProof, merkleRoot, leaf), "Invalid merkle proof");

        claimed[msg.sender] = true;

        // Call the mint function from ERC721Facet
        (bool success, ) = address(this).delegatecall(
            abi.encodeWithSignature("mint(address)", msg.sender)
        );
        require(success, "Minting failed");

        totalMinted++;
        emit Claimed(msg.sender, totalMinted);
    }

    // Custom Merkle proof verification function
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash == root;
    }
}