// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, Vm} from "forge-std/Test.sol";
import {compile} from "./Deploy.sol";
import {LibString} from "solmate/utils/LibString.sol";

import {IHuffplug} from "src/IHuffplug.sol";

using {compile} for Vm;

contract GasbenchTest is Test {
    IHuffplug public huffplug;

    bytes32 SALT_SLOT = bytes32(uint256(0x02));
    bytes32 TOTAL_MINTED_SLOT = bytes32(uint256(0x03));

    address public user = makeAddr("user");
    address public owner = makeAddr("owner");

    string baseUrl = "ipfs://bafybeia7h7n6osru3b4mvivjb3h2fkonvmotobvboqw3k3v4pvyv5oyzse/";
    string contractURI = "ipfs://CONTRACTURI/";

    uint256 constant COLLECTION_START = 1000000;
    bytes32 constant MERKLE_HASH = 0x51496785f4dd04d525b568df7fa6f1057799bc21f7e76c26ee77d2f569b40601;

    function setUp() public {
        vm.warp(COLLECTION_START);
        bytes memory bytecode = vm.compile(COLLECTION_START, MERKLE_HASH);

        // send owner to the constructor, owner is only for opensea main page admin
        bytecode = bytes.concat(bytecode, abi.encode(owner));

        address deployed;
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        vm.label(deployed, "huffplug");
        huffplug = IHuffplug(deployed);
        huffplug.setUri(baseUrl);
    }

    function testDeploy() public {
        vm.pauseGasMetering();
        bytes memory bytecode = vm.compile(COLLECTION_START, MERKLE_HASH);

        // send owner to the constructor, owner is only for opensea main page admin
        bytecode = bytes.concat(bytecode, abi.encode(owner));

        IHuffplug deployed;
        vm.resumeGasMetering();
        
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        deployed.setUri(baseUrl);
    }

    function testMint() public {
        vm.pauseGasMetering();
        vm.store(address(huffplug), SALT_SLOT, /* slot of salt in ButtplugPlugger */ keccak256("salt"));

        assertEq(huffplug.salt(), keccak256("salt"));

        uint256 nonce = 271021;

        vm.prank(user);
        vm.resumeGasMetering();

        huffplug.mint(nonce);

        vm.pauseGasMetering();
        assertEq(huffplug.totalMinted(), 1);
        vm.resumeGasMetering();
    }

    function testMintMerkle() public {
        vm.pauseGasMetering();
        bytes32[] memory roots = new bytes32[](6);
        roots[0] = 0x000000000000000000000000ee081f9fea22c5b578aa9ab1b4fc16e4335f5d2b;
        roots[1] = 0xa3a47908ac03234744670fa693ee11af0774d84b1cec2d2edbcb2e77b7bdd37b;
        roots[2] = 0x37b41dcb9d4ad8085237134780b7b724bc29b68c1d3a279d148f539f787684e7;
        roots[3] = 0xc8f17160e0889a52c573378d6a8f22b32e6f19f793f6ca3955fb95865a047777;
        roots[4] = 0xd61e2cc2664ae8ce0b12c5102373373dafd85bcb94ecc4e3981e1d24b304f80a;
        roots[5] = 0x17fac14873233024352b293cc1b7b04296f09870d377591aef743942c10c67a1;

        address user1 = 0xe7292962e48c18e04Bd26aB2AcCA00Ef794E8171;

        vm.prank(user1);
        vm.resumeGasMetering();

        huffplug.mintWithMerkle(roots);

        vm.pauseGasMetering();
        assertTrue(huffplug.claimed(user1), "user1 should have claimed");
        vm.resumeGasMetering();
    }
}
