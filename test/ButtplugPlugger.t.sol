// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {ButtplugPlugger} from "src/ButtplugPlugger.sol";

import {IHuffplug} from "src/IHuffplug.sol";

contract ButtplugPluggerTest is Test {
    ButtplugPlugger public plugger;
    address public mockHuffplug;
    address public user = makeAddr("user");
    address public owner = makeAddr("owner");
    address public minter = makeAddr("minter");

    function setUp() public {
        
        mockHuffplug = address(new MockHuffplug());
        bytes32 merkleRoot = 0xab4c70ed72087150127cabad413b988ac94a154af200dad730246f0e33ebaed6;
        plugger = new ButtplugPlugger(mockHuffplug, merkleRoot);
    }

    function testMintMerckle() public {
        
        bytes32[] memory roots = new bytes32[](4);
        roots[0] = 0x000000000000000000000000fa14c6aaa1ab119f8963d6f521ae7664d632842b;
        roots[1] = 0x000000000000000000000000fd0e1f2fc10f7e43dcf80b1f17f0e4435e858035;
        roots[2] = 0x55a4a359c5c92c1f3c9dfc10a7209b60677e454a6878473e7661b04b08f25acd;
        roots[3] = 0xa8df132df2d9dc18699d7605abf4f2f19ad7e2fef7a46679a5cb44cc440a393f;


        
        vm.prank(0xe7292962e48c18e04Bd26aB2AcCA00Ef794E8171);
        (bool sucess, ) = address(plugger).call(abi.encodeWithSignature("mintWithMerkle(bytes32[])", roots));
        require(sucess);
    }

}

contract MockHuffplug {
    event Mint(address to, uint256 tokenId);
    function plug(address to, uint256 tokenId) external {
        emit Mint(to, tokenId);
    }

}


/*

└─ ab4c70ed72087150127cabad413b988ac94a154af200dad730246f0e33ebaed6
   ├─ a8df132df2d9dc18699d7605abf4f2f19ad7e2fef7a46679a5cb44cc440a393f
   │  ├─ e07e54a91e7fed964c5b63c31db7fecdc2dd8c1e403f59f2dc499b80d5bab014
   │  │  ├─ 184837727e4cb04c791b6d0bd233f5243bf654cd52cbb77ed417ad2cbae34d8f
   │  │  │  ├─ 00000000000000000000000038c40ead3d0fe7959eb9dfe8337b3c4929884d2c
   │  │  │  └─ 0000000000000000000000006317f6925640be65cfd36cf36051bb495da28359
   │  │  └─ dd376f13149d779ec7ca5ea1d3e01867fead722115854f1d6e3c64d77562a674
   │  │     ├─ 00000000000000000000000063b365a1ad15354f7338e95ba56e004c0d657c3e
   │  │     └─ 00000000000000000000000064b51b755330e8c3bca0563670c751c3902eee0d
   │  └─ 28725660227d57a198eedc1e29e7cb42ac1cc1147f91b157905e0d756c923518
   │     ├─ cc7bce4e3a0cff1ee6ae26430f8db4af3f3a9dc878f1edaa8860b16da2cd380f
   │     │  ├─ 000000000000000000000000673437d956065fa0dc416c4a519cc5c37f6ad389
   │     │  └─ 0000000000000000000000006e414fd1468f7258cbb898ff1efb4124bddc47fc
   │     └─ 2dc6babcd41e65079f7ba43232f56475a28e14d7b93a4d0c64bb88603e7ed839
   │        ├─ 0000000000000000000000008c3a198929e8796a09f017d11b56f684679a4721
   │        └─ 000000000000000000000000a2bae33c8ec8268d88f9917dc11aa857df692303
   └─ 0117255f50bf10ae1efe44f07cb4fd382fad994c35d39803f5b55e3cb1f05ec0
      ├─ 55a4a359c5c92c1f3c9dfc10a7209b60677e454a6878473e7661b04b08f25acd
      │  ├─ de630617aa107198e09534c74e4b5fe6d1f29f397f1c6aa48745cd79c7d9c5a1
      │  │  ├─ 000000000000000000000000b688cd6b039081521a01e779833c3b20cf8d7949
      │  │  └─ 000000000000000000000000ba910716fd4b6b4447aea613993898eeb63844ad
      │  └─ ded162136ca0073735bee32d2726d12d33f6c1df0877febd86bc3594ee6b6f9f
      │     ├─ 000000000000000000000000d5b128d8d3cc9528c8d230a2f03336cafbd11753
      │     └─ 000000000000000000000000dd3d4ace64b8b20b24d385a2abe0702bb512c689
      └─ f9f569e07fb2b4eb31e548b994285f915e35877601b186cbef218c3f7ed41523
         ├─ 9052c75b2e27e14d57e25ab3136a58afcf7963955560fdbb6cbb394a3dae9724
         │  ├─ 000000000000000000000000e7292962e48c18e04bd26ab2acca00ef794e8171
         │  └─ 000000000000000000000000fa14c6aaa1ab119f8963d6f521ae7664d632842b
         └─ 000000000000000000000000fd0e1f2fc10f7e43dcf80b1f17f0e4435e858035
            └─ 000000000000000000000000fd0e1f2fc10f7e43dcf80b1f17f0e4435e858035

{
  whitelisted: [
    '0xe7292962e48c18e04bd26ab2acca00ef794e8171',
    '0x8c3a198929e8796a09f017d11b56f684679a4721',
    '0x6317f6925640be65cfd36cf36051bb495da28359',
    '0xd5b128d8d3cc9528c8d230a2f03336cafbd11753',
    '0x673437d956065fa0dc416c4a519cc5c37f6ad389',
    '0xa2bae33c8ec8268d88f9917dc11aa857df692303',
    '0xba910716fd4b6b4447aea613993898eeb63844ad',
    '0x6e414fd1468f7258cbb898ff1efb4124bddc47fc',
    '0xb688cd6b039081521a01e779833c3b20cf8d7949',
    '0x38c40ead3d0fe7959eb9dfe8337b3c4929884d2c',
    '0xdd3d4ace64b8b20b24d385a2abe0702bb512c689',
    '0xfa14c6aaa1ab119f8963d6f521ae7664d632842b',
    '0xfd0e1f2fc10f7e43dcf80b1f17f0e4435e858035',
    '0x63b365a1ad15354f7338e95ba56e004c0d657c3e',
    '0x64b51b755330e8c3bca0563670c751c3902eee0d'
  ]
}
{
  merkleRoot: '0xab4c70ed72087150127cabad413b988ac94a154af200dad730246f0e33ebaed6'
}
*/

