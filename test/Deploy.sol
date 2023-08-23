pragma solidity ^0.8.13;

import {Vm} from "forge-std/Vm.sol";

function compile(Vm vm, address tokenRenderer, bytes32 merkleRoot) returns (bytes memory) {
    string[] memory cmd = new string[](9);
    cmd[0] = "huffc";
    cmd[1] = "-e";
    cmd[2] = "shanghai";
    cmd[3] = "--bytecode";
    cmd[4] = "src/Huffplug.huff";
    cmd[5] = "--optimize";
    cmd[6] = "-c";
    cmd[7] = string.concat("TOKEN_RENDERER=", bytesToString(abi.encodePacked(tokenRenderer)));
    cmd[8] = string.concat("MERKLE_ROOT=", bytesToString(abi.encode(merkleRoot)));
    
    return vm.ffi(cmd);
}

function bytes32ToString(bytes32 x) pure returns (string memory) {
    string memory result;
    for (uint256 j = 0; j < x.length; j++) {
        result = string.concat(result, string(abi.encodePacked(uint8(x[j]) % 26 + 97)));
    }
    return result;
}

function bytesToString(bytes memory data) pure returns (string memory) {
    bytes memory alphabet = "0123456789abcdef";

    bytes memory str = new bytes(2 + data.length * 2);
    str[0] = "0";
    str[1] = "x";
    for (uint256 i = 0; i < data.length; i++) {
        str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
        str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
    }
    return string(str);
}
