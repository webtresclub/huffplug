// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, Vm} from "forge-std/Test.sol";
import {compile} from "./Deploy.sol";
import {TokenRenderer} from "src/TokenRenderer.sol";
import {LibString} from "solmate/utils/LibString.sol";

import {IHuffplug} from "src/IHuffplug.sol";

using {compile} for Vm;

contract ButtplugTest is Test {
    IHuffplug public huffplug;

    address public user = makeAddr("user");
    address public owner = makeAddr("owner");
    address public minter = makeAddr("minter");

    function setUp() public {
        TokenRenderer renderer = new TokenRenderer("https://huffplug.com/");

        bytes memory bytecode = vm.compile(address(renderer), minter);

        // send owner to the constructor

        bytecode = bytes.concat(bytecode, abi.encode(owner));

        address deployed;
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        vm.label(deployed, "huffplug");
        huffplug = IHuffplug(deployed);
    }

    function testRendererFuzz(uint256 id) public {
        if (id == 0 || id > 1024) {
            vm.expectRevert();
            huffplug.tokenURI(id);
        } else {
            string memory expected = string.concat("https://huffplug.com/", LibString.toString(id), ".json");
            assertEq(huffplug.tokenURI(id), expected);
        }
    }

    function testMintLimits() public {
        vm.startPrank(minter);
        huffplug.mint(user, 1);
        assertEq(huffplug.ownerOf(1), user);

        huffplug.mint(user, 2);
        assertEq(huffplug.ownerOf(2), user);

        huffplug.mint(user, 1024);
        assertEq(huffplug.ownerOf(1024), user);

        // token id 1025 should not be mintable
        vm.expectRevert("INVALID_TOKEN_ID");
        huffplug.mint(user, 1025);

        // token id 0 should not be mintable
        vm.expectRevert("INVALID_TOKEN_ID");
        huffplug.mint(user, 0);
        vm.stopPrank();
    }

    function testMint() public {
        vm.expectRevert("ONLY_MINTER");
        huffplug.mint(user, 3);

        vm.startPrank(minter);
        huffplug.mint(user, 3);
        assertEq(huffplug.ownerOf(3), user);

        // cant mint more than once
        vm.expectRevert();
        huffplug.mint(makeAddr("otherUser"), 3);

        // cant mint more than once
        vm.expectRevert();
        huffplug.mint(user, 3);

        vm.stopPrank();
    }

    function testMintFuzz(address to, uint256 tokenId) public {
        vm.startPrank(minter);
        if (tokenId == 0 || tokenId > 1024) {
            vm.expectRevert("INVALID_TOKEN_ID");
            huffplug.mint(to, tokenId);
        } else if (to == address(0)) {
            vm.expectRevert();
            huffplug.mint(to, tokenId);
        } else {
            huffplug.mint(to, tokenId);
            assertEq(huffplug.ownerOf(tokenId), to);
        }
        vm.stopPrank();
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

    function testOwner() public {
        assertEq(huffplug.owner(), owner);
    }

    function testSetOwner(address new_owner) public {
        vm.assume(new_owner != owner);

        vm.prank(new_owner);
        vm.expectRevert();
        huffplug.setOwner(new_owner);
        assertEq(owner, huffplug.owner());

        vm.prank(owner);
        huffplug.setOwner(new_owner);
        assertEq(new_owner, huffplug.owner());
    }
}
