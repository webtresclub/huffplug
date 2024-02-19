// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, Vm} from "forge-std/Test.sol";
import {Script, console2} from "forge-std/Script.sol";
import {IHuffplug} from "src/IHuffplug.sol";

import {compile} from "../test/Deploy.sol";

using {compile} for Vm;

contract HuffDeployScript is Script {
    IHuffplug huffplug = IHuffplug(0x1837F678b81F5a1C1BDC17A6FeABA430F3aF7346);

    bytes32 constant MERKLE_ROOT = 0x51496785f4dd04d525b568df7fa6f1057799bc21f7e76c26ee77d2f569b40601;
    string baseUrl = "ipfs://bafybeieqnhc5kxnaypnmypaga7r7oxbsh2bhac7ugrsk264yr3o5o7raxq/";
    string contractURI = "https://buttplug-homepage.vercel.app/contract-metadata.json";

    address constant owner = 0xC0FFEc688113B2C5f503dFEAF43548E73C7eCCB3;
    bytes32 constant _saltDeploy = 0xeb732dab20d493614785447e7c20a4fb61eb3c8f9a34bbe8c54706ae559c32e1;

    function run() public returns (address _huffplug) {
        require(tx.origin == owner, "deployer should be 0xC0FFE");
        vm.startBroadcast();


        bytes memory bytecode = bytes.concat(vm.compile(MERKLE_ROOT), abi.encode(owner));
        // send owner to the constructor

        (bool success, bytes memory ret) = CREATE2_FACTORY.call(bytes.concat(_saltDeploy, bytecode));
        require(success, "deploy failed");
        address deployedAddress;
        assembly {
            deployedAddress := mload(add(ret, 20))
        }

        require(0x0000420538CD5AbfBC7Db219B6A1d125f5892Ab0 == deployedAddress, "deployed address mismatch");
        huffplug = IHuffplug(deployedAddress);

        huffplug.setUri(baseUrl);
        huffplug.setContractUri(contractURI);

        vm.stopBroadcast();
        require(huffplug.owner() == owner, "owner mismatch");

        _huffplug = address(huffplug);
    }
}
