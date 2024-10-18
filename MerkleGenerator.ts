import { MerkleTree } from 'merkletreejs';
import keccak256 from 'keccak256';
import fs from 'fs';

// Sample data - replace with your actual data
const addresses = [
  '0x1234567890123456789012345678901234567890',
  '0x0987654321098765432109876543210987654321',
  // Add more addresses as needed
];

// Create leaf nodes
const leafNodes = addresses.map(addr => keccak256(addr));

// Create Merkle Tree
const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });

// Get root
const rootHash = merkleTree.getRoot().toString('hex');

// Generate proofs for each address
const proofs = addresses.map(addr => merkleTree.getHexProof(keccak256(addr)));

// Create the output object
const output = {
  root: rootHash,
  proofs: Object.fromEntries(addresses.map((addr, i) => [addr, proofs[i]]))
};

// Write to file
fs.writeFileSync('merkle_tree_data.json', JSON.stringify(output, null, 2));

console.log('Merkle tree data written to merkle_tree_data.json');