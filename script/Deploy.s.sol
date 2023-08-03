// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, Vm} from "forge-std/Test.sol";
import {Script, console2} from "forge-std/Script.sol";
import {compile, create} from "huff-runner/Deploy.sol";

using { compile } for Vm;
using { create } for bytes;

contract HuffDeployScript is Script {
    function run() public returns(address deployment) {
        vm.broadcast();
        deployment = vm.compile("src/Huffplug.huff").create({value: 0});
    }
}
