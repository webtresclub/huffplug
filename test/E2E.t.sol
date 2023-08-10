// SPDX-License-Identifier: UNLICENSED
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
    address public owner = makeAddr("owner");
    address public deployerEOA = 0xC0FFEc688113B2C5f503dFEAF43548E73C7eCCB3;
    ButtplugPlugger public minter = ButtplugPlugger(0x91c99cAFB00845C73eb0A71Dde7bfc549e5fe554);
    ButtplugMinterDeployer public minterDeployer = ButtplugMinterDeployer(0x0000001EE6ADD04e20226DE96C6d57825821cf58);
    IHuffplug public huffplug = IHuffplug(0x000042028Fc04d015D20BFB303Ee39261FC865A5);

    address constant DEPLOYER2 = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    function setUp() public {
        vm.startPrank(deployerEOA);

        TokenRenderer renderer = new TokenRenderer("https://huffplug.com/");

        /**
         * console2.logBytes(type(ButtplugMinterDeployer).creationCode);
         * console2.logBytes32(keccak256(type(ButtplugMinterDeployer).creationCode));
         * cast create2 --init-code-hash=b250ca61b8fe0f6d8223a1b336388e9a7f5155614e2265a1b0f0c7bec7622179 --starts-with=000000
         * Starting to generate deterministic contract address...
         * Successfully found contract address in 17 seconds.
         * Address: 0x0000001EE6ADD04e20226DE96C6d57825821cf58
         * Salt: 85252038616239719252596687305625315715513520398962752394603742732381148177996
         */
        // ButtplugMinterDeployer = console2.logBytes(type(ButtplugMinterDeployer).creationCode);
        minterDeployer = new ButtplugMinterDeployer();

        bytes32 _saltDeploy =
            bytes32(uint256(85252038616239719252596687305625315715513520398962752394603742732381148177996));
        (bool success,) = DEPLOYER2.call(bytes.concat(_saltDeploy, type(ButtplugMinterDeployer).creationCode));
        require(success, "deploy failed");

        assertEq(minterDeployer.owner(), deployerEOA);

        bytes memory bytecode = vm.compile(address(renderer), minterDeployer.predictMinter());
        // send owner to the constructor
        bytecode = bytes.concat(bytecode, abi.encode(owner));

        // console2.log("init hash");
        // console2.logBytes32(keccak256(bytecode));
        assertEq(
            keccak256(bytecode),
            0xd8be2a9a4ce95a7e91398e430a499b95c54e7f0cea33e5167cbdbf8d299cdd55,
            "init hash of collection mismatch"
        );
        /**
         * collection deploy 
         * cast create2 --init-code-hash=d8be2a9a4ce95a7e91398e430a499b95c54e7f0cea33e5167cbdbf8d299cdd55 --starts-with=0000420
         * Starting to generate deterministic contract address...
         * Successfully found contract address in 25 seconds.
         * Address: 0x000042028Fc04d015D20BFB303Ee39261FC865A5
         * Salt: 4739761059210677759287527462018206704666165100019620570296814331404442323372
         */
        _saltDeploy = bytes32(uint256(4739761059210677759287527462018206704666165100019620570296814331404442323372));
        (success,) = DEPLOYER2.call(bytes.concat(_saltDeploy, bytecode));
        require(success, "deploy failed");

        minterDeployer.deployMinter(
            bytes.concat(
                type(ButtplugPlugger).creationCode,
                abi.encode(address(huffplug)),
                abi.encode(0x51496785f4dd04d525b568df7fa6f1057799bc21f7e76c26ee77d2f569b40601)
            )
        );

        vm.stopPrank();
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
