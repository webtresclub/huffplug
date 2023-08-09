
const fs = require('fs');
const { MerkleTree } = require('merkletreejs');
const {keccak256, isAddress} = require('viem');

const whitelisted = String(fs.readFileSync('./whitelist.txt')).split("\n").map(x => x.trim()).filter(isAddress);

const padBuffer = (addr) => {
  return Buffer.from(addr.substr(2).padStart(32*2, 0), 'hex')
}

const leaves = whitelisted.map(account => padBuffer(account))
const tree = new MerkleTree(leaves, keccak256, { sort: true })
const merkleRoot = tree.getHexRoot()

console.log({merkleRoot});


console.log(tree.toString())


const proofs = whitelisted.map(wallet => {
  return {
    wallet,
    proof: tree.getHexProof(padBuffer(wallet))
  }
});

console.log(proofs);


  /*
const leaves = ['a', 'b', 'c'].map(x => SHA256(x))
const tree = new MerkleTree(leaves, SHA256)
const root = tree.getRoot().toString('hex')
*/