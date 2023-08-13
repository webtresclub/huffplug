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
    ButtplugPlugger constant minter = ButtplugPlugger(0x47A68C343A9c35c6b397D997E7C15a6B4FA4787F);
    ButtplugMinterDeployer constant minterDeployer = ButtplugMinterDeployer(0x000000F002814Ca3E2E52C85e31725d34C7BbC9e);
    IHuffplug constant huffplug = IHuffplug(0x0000420188cF40067F2c57C241E220aa8d0FbD20);

    address constant owner = 0xC0FFEc688113B2C5f503dFEAF43548E73C7eCCB3;

    function run() public returns (address _renderer, address _minterButtplug, address _huffplug) {
        require(tx.origin == owner, "deployer should be 0xC0FFE");
        vm.startBroadcast();

        TokenRenderer renderer = new TokenRenderer("ipfs://bafybeia7h7n6osru3b4mvivjb3h2fkonvmotobvboqw3k3v4pvyv5oyzse/");

        bytes32 _saltDeploy = 0x0cf86d195cd709d108775a94762ef380b6906bbc3bc4d19bafe7fed28c571723;
        (bool success,) = DEPLOYER2.call(bytes.concat(_saltDeploy, type(ButtplugMinterDeployer).creationCode));
        require(success, "minterDeployer deploy failed");

        require(minterDeployer.owner() == owner);

        bytes memory bytecode = vm.compile(address(renderer), minterDeployer.predictMinter());
        // send owner to the constructor
        bytecode = bytes.concat(bytecode, abi.encode(owner));

        _saltDeploy = 0x9b7282746aa564875a825b9f618a9761be3f696f328f11f6f9bbb3953bbc53fd;
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
