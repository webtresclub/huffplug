// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, Vm} from "forge-std/Test.sol";
import {Script, console2} from "forge-std/Script.sol";
import {TokenRenderer} from "src/TokenRenderer.sol";
import {ButtplugPlugger} from "src/ButtplugPlugger.sol";
import {IHuffplug} from "src/IHuffplug.sol";
import {ButtplugMinterDeployer} from "src/ButtplugMinterDeployer.sol";

import {compile} from "../test/Deploy.sol";

using {compile} for Vm;

contract HuffDeployScript is Script {
    address constant DEPLOYER2 = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
    ButtplugPlugger constant minter = ButtplugPlugger(0x19a7d5AD3093a0B48540fA3d6AF94cBe2E322952);
    ButtplugMinterDeployer constant minterDeployer = ButtplugMinterDeployer(0x0000007D2D8949677385798D3d1d3a297a4A4E45);
    IHuffplug constant huffplug = IHuffplug(0x0000420446baDc42e95A4EF6b300706cfFFDf61B);

    address constant owner = 0xC0FFEc688113B2C5f503dFEAF43548E73C7eCCB3;

    function run() public returns (address _renderer, address _minterButtplug, address _huffplug) {
        require(tx.origin == owner, "deployer should be 0xC0FFE");
        vm.startBroadcast();

        TokenRenderer renderer = new TokenRenderer("https://huffplug.com/");

        bytes32 _saltDeploy = 0x67499ee1f2b9bf8eec6a25f7b48783eb8c86d517451b113c6c7d59b4cc44b59d;
        (bool success,) = DEPLOYER2.call(bytes.concat(_saltDeploy, type(ButtplugMinterDeployer).creationCode));
        require(success, "minterDeployer deploy failed");

        require(minterDeployer.owner() == owner);

        bytes memory bytecode = vm.compile(address(renderer), minterDeployer.predictMinter());
        // send owner to the constructor
        bytecode = bytes.concat(bytecode, abi.encode(owner));

        _saltDeploy = 0x3a44b9d82a83d7d24bd8630bfa84a8e7d09d20b48db69911891d835af337e201;
        (success,) = DEPLOYER2.call(bytes.concat(_saltDeploy, bytecode));
        require(success, "deploy failed");

        minterDeployer.deployMinter(
            bytes.concat(
                type(ButtplugPlugger).creationCode,
                abi.encode(address(huffplug)),
                abi.encode(0x51496785f4dd04d525b568df7fa6f1057799bc21f7e76c26ee77d2f569b40601)
            )
        );

        vm.stopBroadcast();
        _renderer = address(renderer);
        _minterButtplug = address(minter);
        _huffplug = address(huffplug);
    }
}
