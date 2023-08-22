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
    
    bytes32 SALT_SLOT = bytes32(uint256(0x01));
    bytes32 TOTAL_MINTED_SLOT = bytes32(uint256(0x02));

    address public user = makeAddr("user");
    address public owner = makeAddr("owner");
    address public minter = makeAddr("minter");

    string baseUrl = "ipfs://bafybeia7h7n6osru3b4mvivjb3h2fkonvmotobvboqw3k3v4pvyv5oyzse/";

    function setUp() public {
        vm.warp(1000000);
        TokenRenderer renderer = new TokenRenderer(baseUrl);

        bytes memory bytecode = vm.compile(address(renderer), 0x51496785f4dd04d525b568df7fa6f1057799bc21f7e76c26ee77d2f569b40601);

        // send owner to the constructor, owner is only for opensea main page admin
        bytecode = bytes.concat(bytecode, abi.encode(owner));

        address deployed;
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        vm.label(deployed, "huffplug");
        huffplug = IHuffplug(deployed);
    }

    function testDifficulty() public {
        assertEq(huffplug.totalMinted(), 0, "total minted should be 0");
        assertEq(huffplug.currentDifficulty(), 5, "difficulty should be 5");
        
        vm.store(address(huffplug), TOTAL_MINTED_SLOT, /* slot of totalminted */ bytes32(uint256(10)));
        assertEq(huffplug.totalMinted(), 10, "total minted should be 10");
        assertEq(huffplug.currentDifficulty(), 8);
        vm.store(address(huffplug), TOTAL_MINTED_SLOT, /* slot of totalminted */ bytes32(uint256(0)));
    
        assertEq(huffplug.currentDifficulty(), 5, "difficulty should be 5");
        
        vm.store(address(huffplug), TOTAL_MINTED_SLOT, bytes32(uint256(2)));
        assertEq(huffplug.currentDifficulty(), 6, "difficulty should be 6");
        
        vm.store(address(huffplug), TOTAL_MINTED_SLOT, bytes32(uint256(20)));
        assertEq(huffplug.currentDifficulty(), 9, "difficulty should be 9");
        
        uint256 start = block.timestamp;
        // if there are no new mint the difficulty shoud decay after some time
        vm.warp(start + 1 days);
        assertEq(huffplug.currentDifficulty(), 9, "difficulty should be 9");
        
        vm.warp(start + 4 days);
        assertEq(huffplug.currentDifficulty(), 9, "difficulty should be 9");
        vm.warp(start + 5 days);
        assertEq(huffplug.currentDifficulty(), 8, "difficulty should be 8");
        
        vm.warp(start + 12 days);
        assertEq(huffplug.currentDifficulty(), 7, "difficulty should be 7");
        vm.warp(start + 17 days);
        assertEq(huffplug.currentDifficulty(), 6, "difficulty should be 6");
        vm.warp(start + 20 days);
        assertEq(huffplug.currentDifficulty(), 5, "difficulty should be 5");
        vm.warp(start + 300 days);
        assertEq(huffplug.currentDifficulty(), 5, "difficulty should be 5");

        vm.warp(start + 1 days);
        vm.store(address(huffplug), TOTAL_MINTED_SLOT, /* slot of totalminted */ bytes32(uint256(1000)));
        assertEq(huffplug.currentDifficulty(), 32, "difficulty should be 32");
    }

    function testTotalMinted() public {
        assertEq(huffplug.totalMinted(), 0);
        vm.store(address(huffplug), TOTAL_MINTED_SLOT, /* slot of totalminted */ bytes32(uint256(10)));
        assertEq(huffplug.totalMinted(), 10);
    }

    function testMint() public {
        vm.store(address(huffplug), SALT_SLOT, /* slot of salt in ButtplugPlugger */ keccak256("salt"));

        assertEq(huffplug.salt(), keccak256("salt"));

        uint256 nonce = 271021;

        vm.expectRevert();
        huffplug.mint(nonce);

        assertEq(huffplug.totalMinted(), 0);
        
        vm.prank(user);
        huffplug.mint(nonce);
        assertEq(huffplug.totalMinted(), 1);

        assertEq(huffplug.balanceOf(user), 1);
        assertEq(huffplug.ownerOf(478), user);
        
        assertNotEq(huffplug.salt(), keccak256("salt"));
    }

    function testMintReverts() public {
        uint256 nonce = 271021;
        vm.store(address(huffplug), TOTAL_MINTED_SLOT, /* slot of totalminted */ bytes32(uint256(1023)));
        vm.store(address(huffplug), SALT_SLOT, /* slot of salt in ButtplugPlugger */ keccak256("salt"));

        assertEq(huffplug.totalMinted(), 1023);
        assertEq(huffplug.currentDifficulty(), 32);
        
        vm.expectRevert("WRONG_SALT");
        vm.prank(user);
        huffplug.mint(nonce);
        
        assertEq(huffplug.totalMinted(), 1023);
        
        vm.warp(block.timestamp + 1024 days);
        assertEq(huffplug.currentDifficulty(), 5);

        vm.prank(user);
        huffplug.mint(nonce);

        vm.expectRevert("No more UwU");
        huffplug.mint(nonce);

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
