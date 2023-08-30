// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, Vm} from "forge-std/Test.sol";

interface IMetadata {
    function setUri(string memory) external;
    function getUri() external view returns (string memory);
    function tokenURI(uint256) external view returns (string memory);
}
contract MetadataTest is Test {
    IMetadata metadata;
    
    function compile() internal returns (bytes memory) {
        string[] memory cmd = new string[](6);
        cmd[0] = "huffc";
        cmd[1] = "-e";
        cmd[2] = "shanghai";
        cmd[3] = "--bytecode";
        cmd[4] = "src/Metadata.huff";
        cmd[5] = "--optimize";
        
        return vm.ffi(cmd);
    }

    function setUp() public {
        address deployed;
        bytes memory bytecode = compile();
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        metadata = IMetadata(deployed);
    }

    function testRenderer1() public {
        assertEq("0333", metadata.tokenURI(333));


        string memory expected = "ipfs://bafybeia7h7n6osru3b4mvivjb3h2fkonvmotobvboqw3k3v4pvyv5oyzse/";
        metadata.setUri(expected);


        assertEq(metadata.getUri(), expected);

//console2.log("reads", reads.length);
//console2.log("writes", writes.length);
console2.log("t", metadata.getUri());
console2.log("t", metadata.tokenURI(333));
        metadata.setUri("");
console2.log("t", metadata.tokenURI(333));

    }
}


/*
0x3f62dec5b8b67ab667ad08e83a2c3ba1db7fdb4ab8dc3a33c057c4fddec8d3dd
0x3f62dec5b8b67ab667ad08e83a2c3ba1db7fdb4ab8dc3a33c057c4fddec8d3fd
0x3f62dec5b8b67ab667ad08e83a2c3ba1db7fdb4ab8dc3a33c057c4fddec8d41d
0x3f62dec5b8b67ab667ad08e83a2c3ba1db7fdb4ab8dc3a33c057c4fddec8d43d
0x3f62dec5b8b67ab667ad08e83a2c3ba1db7fdb4ab8dc3a33c057c4fddec8d45d


0x3f62dec5b8b67ab667ad08e83a2c3ba1db7fdb4ab8dc3a33c057c4fddec8d3dd
0x3f62dec5b8b67ab667ad08e83a2c3ba1db7fdb4ab8dc3a33c057c4fddec8d41d
0x3f62dec5b8b67ab667ad08e83a2c3ba1db7fdb4ab8dc3a33c057c4fddec8d41d
*/