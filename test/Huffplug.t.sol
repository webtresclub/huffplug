// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, Vm} from "forge-std/Test.sol";
import {compile, create} from "huff-runner/Deploy.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";
import {TokenRenderer} from "src/TokenRenderer.sol";

using { compile } for Vm;
using { create } for bytes;

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 _tokenId) external view returns (string memory);

    // extra for minting
    function mint(address who, uint256 tokenid) external;
}

contract CounterTest is Test {
    IERC721Metadata public huffplug;

    function setUp() public {
        TokenRenderer renderer = new TokenRenderer("https://huffplug.com/");
        huffplug = IERC721Metadata(vm.compile("src/Huffplug.huff").create({value: 0}));
    }

    function testRenderer() public {
        TokenRenderer renderer = new TokenRenderer("https://huffplug.com/");
        assertEq(renderer.tokenURI(3), "https://huffplug.com/3.json");
    }

    function testMint() public {
        huffplug.mint(address(0x01), 3);
        assertEq(huffplug.ownerOf(3), address(0x01));
    }

    function testMetadata() public {
        assertEq(huffplug.symbol(), "UwU");
        assertEq(huffplug.name(), "Buttpluggy");
    }

    function testTokenUri() public {
        assertEq(huffplug.tokenURI(3), "https://huffplug.com/3.json");
        assertEq(huffplug.tokenURI(10), "https://huffplug.com/10.json");
        vm.expectRevert();
        huffplug.tokenURI(0);

        vm.expectRevert();
        huffplug.tokenURI(1025);

        assertEq(huffplug.tokenURI(1024), "https://huffplug.com/1024.json");
    }
}
