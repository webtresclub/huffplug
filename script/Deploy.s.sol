// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, Vm} from "forge-std/Test.sol";
import {Script, console2} from "forge-std/Script.sol";
import {TokenRenderer} from "src/TokenRenderer.sol";
import {IHuffplug} from "src/IHuffplug.sol";

import {compile} from "../test/Deploy.sol";

using {compile} for Vm;

contract HuffDeployScript is Script {
    address constant DEPLOYER2 = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
    IHuffplug constant huffplug = IHuffplug(0xC27a5a9193ab37f646F21C120110315Baa26806A);

    bytes32 constant MERKLE_ROOT = 0x51496785f4dd04d525b568df7fa6f1057799bc21f7e76c26ee77d2f569b40601;

    address constant owner = 0xC0FFEc688113B2C5f503dFEAF43548E73C7eCCB3;

    function run() public returns (address _renderer, address _huffplug) {
        require(tx.origin == owner, "deployer should be 0xC0FFE");
        vm.startBroadcast();

        TokenRenderer renderer = new TokenRenderer("ipfs://bafybeibtkqysjtgxmcegh7rjnpi3hbfn4chy3yxuav4jbiawwvutxerw64/", "uri"); // @TODO upload contract uro to ipfs
        bytes32 _saltDeploy = 0x09286b392f541f94d0afab741157bd9f766292f732021a1be9ad86bc28b1be42;

        bytes memory bytecode = vm.compile(address(renderer), MERKLE_ROOT);
        // send owner to the constructor

        _saltDeploy = 0xcfbbb05e4e07ccd909806657fd780c32d4c4c76931df8394e91d2aa76fc351d1;
        (bool success, bytes memory ret) = DEPLOYER2.call(bytes.concat(_saltDeploy, bytecode));
        require(success, "deploy failed");
        address deployedAddress;
        assembly {
            deployedAddress := mload(add(ret,20))
        } 

        vm.stopBroadcast();
        require(address(huffplug) == deployedAddress, "deployed address mismatch");
        require(huffplug.owner() == owner, "owner mismatch");
        _renderer = address(renderer);
        _huffplug = address(huffplug);
    }
}
