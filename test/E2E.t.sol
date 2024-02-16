// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2, Vm} from "forge-std/Test.sol";
import {IHuffplug} from "src/IHuffplug.sol";

import {compile} from "./Deploy.sol";

using {compile} for Vm;

contract E2ETest is Test {
    bytes32 constant MERKLE_ROOT = 0x51496785f4dd04d525b568df7fa6f1057799bc21f7e76c26ee77d2f569b40601;
    string baseUrl = "ipfs://bafybeieqnhc5kxnaypnmypaga7r7oxbsh2bhac7ugrsk264yr3o5o7raxq/";
    string contractURI = "ipfs://.../collection.json";

    address public user = makeAddr("user");
    bytes32 SALT_SLOT = bytes32(uint256(0x031337));

    address public owner = 0xC0FFEc688113B2C5f503dFEAF43548E73C7eCCB3;
    IHuffplug public huffplug;

    address constant DEPLOYER2 = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    function setUp() public {
        vm.createSelectFork("https://ethereum-goerli.publicnode.com");
        vm.startPrank(owner);

        bytes memory bytecode = bytes.concat(vm.compile(MERKLE_ROOT), abi.encode(owner));

        assertEq(
            keccak256(bytecode),
            0x9f5460cbff1c6a0693c3325ed044bb5b897f1bce3d1602afc6a8877a0722b5bb,
            "huffplug init hash mismatch"
        );

        bytes32 _saltDeploy = 0xeb732dab20d493614785447e7c20a4fb61eb3c8f9a34bbe8c54706ae559c32e1;
        (bool success, bytes memory ret) = DEPLOYER2.call(bytes.concat(_saltDeploy, bytecode));
        require(success, "deploy failed");
        address deployedAddress;
        assembly {
            deployedAddress := mload(add(ret, 20))
        }
        assertEq(0x0000420538CD5AbfBC7Db219B6A1d125f5892Ab0, deployedAddress, "deployed address mismatch");
        huffplug = IHuffplug(deployedAddress);

        /**
         * collection deploy
         * cast create2 --init-code-hash=0x9f5460cbff1c6a0693c3325ed044bb5b897f1bce3d1602afc6a8877a0722b5bb --starts-with=0000420
         * Starting to generate deterministic contract address...
         * Successfully found contract address in 12 seconds.
         * Address: 0x0000420538CD5AbfBC7Db219B6A1d125f5892Ab0
         * Salt: 0xeb732dab20d493614785447e7c20a4fb61eb3c8f9a34bbe8c54706ae559c32e1 (106497022021711043029220004038284374156722325275420376612357709141809064325857)
         */
        vm.stopPrank();
    }

    function testExpectedOwner() public {
        assertEq(huffplug.owner(), owner);
    }

    function testMintMerkle() public {
        assertEq(huffplug.totalMinted(), 0);
        bytes32[] memory roots = new bytes32[](6);
        roots[0] = 0x000000000000000000000000ee081f9fea22c5b578aa9ab1b4fc16e4335f5d2b;
        roots[1] = 0xa3a47908ac03234744670fa693ee11af0774d84b1cec2d2edbcb2e77b7bdd37b;
        roots[2] = 0x37b41dcb9d4ad8085237134780b7b724bc29b68c1d3a279d148f539f787684e7;
        roots[3] = 0xc8f17160e0889a52c573378d6a8f22b32e6f19f793f6ca3955fb95865a047777;
        roots[4] = 0xd61e2cc2664ae8ce0b12c5102373373dafd85bcb94ecc4e3981e1d24b304f80a;
        roots[5] = 0x17fac14873233024352b293cc1b7b04296f09870d377591aef743942c10c67a1;

        address user1 = 0xe7292962e48c18e04Bd26aB2AcCA00Ef794E8171;

        bytes32 initialSalt = huffplug.salt();

        vm.prank(user1);
        huffplug.mintWithMerkle(roots);
        assertEq(huffplug.totalMinted(), 1);

        assertTrue(huffplug.salt() == initialSalt, "salt shouldnt change after mint via merkle");
    }

    function testMine() public {
        vm.store(address(huffplug), SALT_SLOT, /* slot of salt in ButtplugPlugger */ keccak256("salt"));
        assertEq(huffplug.salt(), keccak256("salt"));

        uint256 nonce = 271021;

        vm.expectRevert();
        huffplug.mint(nonce);

        assertEq(huffplug.totalMinted(), 0);
        vm.prank(user);
        huffplug.mint(nonce);
        assertEq(huffplug.totalMinted(), 1);

        assertTrue(huffplug.salt() != keccak256("salt"), "salt should change after mint");
    }
}
