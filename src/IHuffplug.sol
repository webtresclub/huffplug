// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC721} from "forge-std/interfaces/IERC721.sol";

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}

interface IOwnable is IERC721 {
    function owner() external view returns (address);
    function setOwner(address new_owner) external;

    event OwnerUpdated(address indexed user, address indexed newOwner);
}

interface IHuffplug is IERC721Metadata, IOwnable {
    // extra for minting
    function mint(address who, uint256 tokenid) external;

    // total token supply
    function totalSupply() external view returns (uint256);
}
