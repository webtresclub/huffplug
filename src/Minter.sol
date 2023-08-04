// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Minter {
    // make this a constant
    address immutable buttpluggy;
    
    bytes32 public hash;
    mapping(address => bool) public claimed;

    constructor(address _buttpluggy) {
        buttpluggy = _buttpluggy;
    }

    function mint(bytes32 salt) external {
        bytes32 random = keccak256(abi.encode(
            msg.sender,
            hash,
            salt
        ));

        // chequear que msg.sender tenga el salt correcto
        // calcular id
        // update hash
        IMinteable(buttpluggy).mint(msg.sender, uint256(random) % 1024 + 1);
    }

    function mintWithMerkle() external {
        // chequear que msg.sender este en el merkle
        require(!claimed[msg.sender], "already claimed");
        claimed[msg.sender] = true;

        IMinteable(buttpluggy).mint(msg.sender, uint256(
            keccak256(abi.encode(msg.sender,hash))   
        ) % 1024 + 1);
    }
}

interface IMinteable {
      // extra for minting
    function mint(address who, uint256 tokenid) external;
}