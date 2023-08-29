// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

// @dev this is base on the solady implementation
// https://github.com/Vectorized/solady/blob/main/src/auth/Ownable.sol

abstract contract Ownable {
    address public owner;

    /// @dev The caller is not authorized to call the function.
    error Unauthorized();

    constructor() {
        owner = msg.sender;
    }

    /// @dev Marks a function as only callable by the owner.
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /// @dev Throws if the sender is not the owner.
    function _checkOwner() internal view {
        if (msg.sender != owner) {
            revert Unauthorized();
        }
    }

    function transferOwnership(address newOwner) external payable onlyOwner() {
        owner = newOwner;
    }
} 