// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, Vm} from "forge-std/Test.sol";
import {TokenRenderer} from "src/TokenRenderer.sol";
import {LibString} from "solmate/utils/LibString.sol";


contract RendererTest is Test {
    TokenRenderer renderer1;
    TokenRenderer renderer2;

    function setUp() public {
      renderer1 = new TokenRenderer("https://huffplug1.com/");
      renderer2 = new TokenRenderer("https://huffplug2.com/");
    }

    function testRenderer1(uint256 tokenId) public {
        if (tokenId == 0 || tokenId > 1024) {
            vm.expectRevert();
            renderer1.tokenURI(tokenId);
        } else {
          string memory expected = string.concat("https://huffplug1.com/", LibString.toString(tokenId), ".json");
          assertEq(renderer1.tokenURI(tokenId), expected);
        }
    }

    function testRenderer2(uint256 tokenId) public {
        if (tokenId == 0 || tokenId > 1024) {
            vm.expectRevert();
            renderer2.tokenURI(tokenId);
        } else {
          string memory expected = string.concat("https://huffplug2.com/", LibString.toString(tokenId), ".json");
          assertEq(renderer2.tokenURI(tokenId), expected);
        }
    }
}
