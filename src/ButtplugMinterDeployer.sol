// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {CREATE3} from "solmate/utils/CREATE3.sol";

contract ButtplugMinterDeployer {
    address public immutable owner = 0xC0FFEc688113B2C5f503dFEAF43548E73C7eCCB3;

    function deployMinter(bytes memory bytecode) external {
        require(msg.sender == owner, "!owner");
        // H4X0RZ
        CREATE3.deploy(bytes32(uint256(31337)), bytecode, 0);
    }

    function predictMinter() external view returns (address addr) {
        // H4X0RZ
        return CREATE3.getDeployed(bytes32(uint256(31337)));
    }
}
