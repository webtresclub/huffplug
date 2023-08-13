// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2, Vm} from "forge-std/Test.sol";
import {compile} from "./Deploy.sol";
import {TokenRenderer} from "src/TokenRenderer.sol";
import {ButtplugPlugger} from "src/ButtplugPlugger.sol";
import {IHuffplug} from "src/IHuffplug.sol";
import {ButtplugMinterDeployer} from "src/ButtplugMinterDeployer.sol";

import {compile} from "./Deploy.sol";

using {compile} for Vm;

contract E2ETest is Test {
    address public user = makeAddr("user");
    bytes32 constant MERKLE_ROOT = 0x51496785f4dd04d525b568df7fa6f1057799bc21f7e76c26ee77d2f569b40601;
    address public owner = 0xC0FFEc688113B2C5f503dFEAF43548E73C7eCCB3;
    ButtplugPlugger public minter;
    TokenRenderer renderer;
    ButtplugMinterDeployer public constant minterDeployer =
        ButtplugMinterDeployer(0x000000F002814Ca3E2E52C85e31725d34C7BbC9e);
    IHuffplug public huffplug = IHuffplug(0x0000420188cF40067F2c57C241E220aa8d0FbD20);

    address constant DEPLOYER2 = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    function setUp() public {
        vm.startPrank(owner);

        renderer = new TokenRenderer("https://huffplug.com/");

        /**
         * cast create2 --init-code-hash=83d871c3c14c2f979d930465a1930cb87612fae756e8319f55cbb121d7adb864 --starts-with=000000 
         * Starting to generate deterministic contract address...
         * Successfully found contract address in 5 seconds.
         * Address: 0x000000F002814Ca3E2E52C85e31725d34C7BbC9e
         * Salt: 5866685229191895302462901240024600712162703593069861072571419143317109544739
         */
        // ButtplugMinterDeployer = console2.logBytes(type(ButtplugMinterDeployer).creationCode);

        bytes32 _saltDeploy = 0x0cf86d195cd709d108775a94762ef380b6906bbc3bc4d19bafe7fed28c571723;
        (bool success,) = DEPLOYER2.call(bytes.concat(_saltDeploy, type(ButtplugMinterDeployer).creationCode));
        require(success, "deploy failed");

        minter = ButtplugPlugger(minterDeployer.predictMinter());

        bytes memory bytecode = vm.compile(address(renderer), minterDeployer.predictMinter());
        // send owner to the constructor
        bytecode = bytes.concat(bytecode, abi.encode(owner));

        console2.logBytes32(keccak256(bytecode));

        /**
         * collection deploy
         * cast create2 --init-code-hash=b5a6bf8cee8db57afb5fc16e18fd6091b3433b4e6b9ef4cbb1c0a256602a3364 --starts-with=0000420
         * Starting to generate deterministic contract address...
         * Successfully found contract address in 7 seconds.
         * Address: 0x0000420188cF40067F2c57C241E220aa8d0FbD20
         * Salt: 70310812461401063697493324544841387947876119037228570018073487686563564114941
         */
        _saltDeploy = 0x9b7282746aa564875a825b9f618a9761be3f696f328f11f6f9bbb3953bbc53fd;
        (success,) = DEPLOYER2.call(bytes.concat(_saltDeploy, bytecode));
        require(success, "deploy failed");

        minterDeployer.deployMinter(
            bytes.concat(type(ButtplugPlugger).creationCode, abi.encode(address(huffplug)), abi.encode(MERKLE_ROOT))
        );

        vm.stopPrank();
    }

    function testBytecodeInit() public {
        assertEq(
            keccak256(type(ButtplugMinterDeployer).creationCode),
            0x83d871c3c14c2f979d930465a1930cb87612fae756e8319f55cbb121d7adb864,
            "init hash of deployer minter mismatch"
        );

        bytes memory bytecode = vm.compile(address(renderer), minterDeployer.predictMinter());
        // send owner to the constructor
        bytecode = bytes.concat(bytecode, abi.encode(owner));

        assertEq(
            keccak256(bytecode),
            0xb5a6bf8cee8db57afb5fc16e18fd6091b3433b4e6b9ef4cbb1c0a256602a3364,
            "init hash of collection mismatch"
        );
    }

    function testExpectedOwner() public {
        assertEq(minterDeployer.owner(), owner);
        assertEq(minterDeployer.predictMinter(), 0x47A68C343A9c35c6b397D997E7C15a6B4FA4787F);
    }

    function testMintMerkle() public {
        assertEq(minter.minted(), 0);
        bytes32[] memory roots = new bytes32[](6);
        roots[0] = 0x000000000000000000000000ee081f9fea22c5b578aa9ab1b4fc16e4335f5d2b;
        roots[1] = 0xa3a47908ac03234744670fa693ee11af0774d84b1cec2d2edbcb2e77b7bdd37b;
        roots[2] = 0x37b41dcb9d4ad8085237134780b7b724bc29b68c1d3a279d148f539f787684e7;
        roots[3] = 0xc8f17160e0889a52c573378d6a8f22b32e6f19f793f6ca3955fb95865a047777;
        roots[4] = 0xd61e2cc2664ae8ce0b12c5102373373dafd85bcb94ecc4e3981e1d24b304f80a;
        roots[5] = 0x17fac14873233024352b293cc1b7b04296f09870d377591aef743942c10c67a1;

        address user1 = 0xe7292962e48c18e04Bd26aB2AcCA00Ef794E8171;

        vm.prank(user1);
        (bool sucess,) = address(minter).call(abi.encodeWithSignature("mintWithMerkle(bytes32[])", roots));
        require(sucess, "mint cant fail");
    }
}
