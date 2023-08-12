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

    string baseUrl = "ipfs://bafybeia7h7n6osru3b4mvivjb3h2fkonvmotobvboqw3k3v4pvyv5oyzse/";

    function setUp() public {
        TokenRenderer renderer = new TokenRenderer(baseUrl);

        bytes memory bytecode = vm.compile(address(renderer), minter);

        // send owner to the constructor, owner is only for opensea main page admin
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
            string memory expected = string.concat(baseUrl, LibString.toString(id), ".json");
            assertEq(huffplug.tokenURI(id), expected);
        }
    }

    function testMintLimits() public {
        vm.startPrank(minter);
        huffplug.plug(user, 1);
        assertEq(huffplug.ownerOf(1), user);

        huffplug.plug(user, 2);
        assertEq(huffplug.ownerOf(2), user);

        huffplug.plug(user, 1024);
        assertEq(huffplug.ownerOf(1024), user);

        vm.stopPrank();
    }

    function testMint() public {
        vm.expectRevert("ONLY_MINTER");
        huffplug.plug(user, 3);

        vm.startPrank(minter);
        huffplug.plug(user, 3);
        assertEq(huffplug.ownerOf(3), user);

        // cant mint more than once
        vm.expectRevert();
        huffplug.plug(makeAddr("otherUser"), 3);

        // cant mint more than once
        vm.expectRevert();
        huffplug.plug(user, 3);

        vm.stopPrank();
    }

    function testMintFuzz(address to, uint256 tokenId) public {
        tokenId = bound(tokenId, 1, 1024);
        vm.startPrank(minter);
        if (to == address(0)) {
            vm.expectRevert();
            huffplug.plug(to, tokenId);
        } else {
            huffplug.plug(to, tokenId);
            assertEq(huffplug.ownerOf(tokenId), to);
        }
        vm.stopPrank();
    }

    function testMetadata() public {
        assertEq(huffplug.symbol(), "UwU");
        assertEq(huffplug.name(), "Buttpluggy");
        assertEq(huffplug.totalSupply(), 1024);
    }

    function testTokenUri() public {
        assertEq(huffplug.tokenURI(3), string.concat(baseUrl, "3.json"));
        assertEq(huffplug.tokenURI(10), string.concat(baseUrl, "10.json"));
        vm.expectRevert();
        huffplug.tokenURI(0);

        vm.expectRevert();
        huffplug.tokenURI(1025);

        assertEq(huffplug.tokenURI(1024), string.concat(baseUrl, "1024.json"));
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
