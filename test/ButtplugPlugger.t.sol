// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {ButtplugPlugger} from "src/ButtplugPlugger.sol";

import {IHuffplug} from "src/IHuffplug.sol";

contract ButtplugPluggerTest is Test {
    ButtplugPlugger public plugger;
    address public mockHuffplug;

    address public user = makeAddr("user");

    function setUp() public {
        mockHuffplug = address(new MockHuffplug());
        bytes32 merkleRoot = 0x51496785f4dd04d525b568df7fa6f1057799bc21f7e76c26ee77d2f569b40601;
        plugger = new ButtplugPlugger(mockHuffplug, merkleRoot);

        // mock salt
        vm.store(address(plugger), 0x00, /* slot of salt in ButtplugPlugger */ keccak256("salt"));
        assertEq(plugger.salt(), keccak256("salt"));
    }


    function testMintMerkle() public {
        assertEq(plugger.minted(), 0);
        bytes32[] memory roots = new bytes32[](6);
        roots[0] = 0x000000000000000000000000ee081f9fea22c5b578aa9ab1b4fc16e4335f5d2b;
        roots[1] = 0xa3a47908ac03234744670fa693ee11af0774d84b1cec2d2edbcb2e77b7bdd37b;
        roots[2] = 0x37b41dcb9d4ad8085237134780b7b724bc29b68c1d3a279d148f539f787684e7;
        roots[3] = 0xc8f17160e0889a52c573378d6a8f22b32e6f19f793f6ca3955fb95865a047777;
        roots[4] = 0xd61e2cc2664ae8ce0b12c5102373373dafd85bcb94ecc4e3981e1d24b304f80a;
        roots[5] = 0x17fac14873233024352b293cc1b7b04296f09870d377591aef743942c10c67a1;

        address user1 = 0xe7292962e48c18e04Bd26aB2AcCA00Ef794E8171;

        vm.prank(user1);
        (bool sucess,) = address(plugger).call(abi.encodeWithSignature("mintWithMerkle(bytes32[])", roots));
        require(sucess, "mint cant fail");

        assertEq(MockHuffplug(mockHuffplug).lastMintTo(), user1);
        // @dev hard to predict the next mint id
        assertNotEq(MockHuffplug(mockHuffplug).lastMintId(), 0);

        vm.prank(user1);
        (sucess,) = address(plugger).call(abi.encodeWithSignature("mintWithMerkle(bytes32[])", roots));
        require(!sucess, "mint should fail");

        assertEq(plugger.minted(), 1);

        // @dev after minting with merkle salt should NOT be changed
        assertEq(plugger.salt(), keccak256("salt"));

        address user2 = 0xBa910716Fd4b6b4447AeA613993898eeB63844Ad;

        roots = new bytes32[](8);
        roots[0] = 0x000000000000000000000000bbe7c97e93647652bd76afe4edb40af9bb5ff4da;
        roots[1] = 0x7b875b84c4396d7d349231f7a20640fe55e50326f18f663d53509a05e1df1984;
        roots[2] = 0x928bb96acc89d83761f3900b115d8bdbcd413151f39da608e558902bf128fe9e;
        roots[3] = 0xe4061ce29bf346faba11b18d137d58a90e2743a6c11ad85414108946026d66e6;
        roots[4] = 0x8d88fcc5b0daffe3312a3e92b40dacd2c8a875d0a6bdf0091e4ecc226006fe67;
        roots[5] = 0xc51614c1fe3ae718d12708408de048a36001d567b70b0d5df08ebf9f74a93e1c;
        roots[6] = 0xddbd87db45817c0a681ec7cdee793c2410b735a39f1be91ed8834874259e8c01;
        roots[7] = 0xfbbbfd743cceb9d2bdc8602f027333f04f9078b3684a73c5c33fb8d79e5baed5;

        vm.prank(user2);
        (sucess,) = address(plugger).call(abi.encodeWithSignature("mintWithMerkle(bytes32[])", roots));
        require(sucess, "mint cant fail");

        address user3 = 0x673437D956065Fa0dc416c4A519CC5c37f6AD389;
        roots[0] = 0x0000000000000000000000006666ec43deb25910121dd544e89301a86165fa6b;
        roots[1] = 0x31e85a3621abd6389b837e72024a8e2e97a34ad7d669b4f2c6d769747b089fa6;
        roots[2] = 0x85da31bd83f18a50b924a96880222d70f2899ec83143aa8fdd97dc0c70f9b809;
        roots[3] = 0x18610d990ae73613d1d1e5d6b7dff0beffb091df917a2b589fb91e8de43e13e2;
        roots[4] = 0xc58f6e1b828a1b25a219d212596904a829dc6209c1f922036949ed75bdfae350;
        roots[5] = 0xf7f97a6790805d13b9b30da262c4bc167c5f4ce84fdfd8e31f8adbd9c24aa5c3;
        roots[6] = 0x352f1d855d1a93eb69ad310d832a1f4bdf1de4320c08eb9d12cc6710334670d2;
        roots[7] = 0xfbbbfd743cceb9d2bdc8602f027333f04f9078b3684a73c5c33fb8d79e5baed5;
        vm.prank(user3);
        (sucess,) = address(plugger).call(abi.encodeWithSignature("mintWithMerkle(bytes32[])", roots));
        require(sucess, "mint cant fail");

        assertEq(plugger.minted(), 3, "buttplugs minted should be 3");
    }


}

contract MockHuffplug {
    event Mint(address to, uint256 tokenId);

    address public lastMintTo;
    uint256 public lastMintId;

    function plug(address to, uint256 tokenId) external {
        lastMintTo = to;
        lastMintId = tokenId;
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

[
  {
    wallet: '0xe7292962e48c18e04bd26ab2acca00ef794e8171',
    proof: [
      '0x000000000000000000000000fa14c6aaa1ab119f8963d6f521ae7664d632842b',
      '0x000000000000000000000000fd0e1f2fc10f7e43dcf80b1f17f0e4435e858035',
      '0x55a4a359c5c92c1f3c9dfc10a7209b60677e454a6878473e7661b04b08f25acd',
      '0xa8df132df2d9dc18699d7605abf4f2f19ad7e2fef7a46679a5cb44cc440a393f'
    ]
  },
  {
    wallet: '0x8c3a198929e8796a09f017d11b56f684679a4721',
    proof: [
      '0x000000000000000000000000a2bae33c8ec8268d88f9917dc11aa857df692303',
      '0xcc7bce4e3a0cff1ee6ae26430f8db4af3f3a9dc878f1edaa8860b16da2cd380f',
      '0xe07e54a91e7fed964c5b63c31db7fecdc2dd8c1e403f59f2dc499b80d5bab014',
      '0x0117255f50bf10ae1efe44f07cb4fd382fad994c35d39803f5b55e3cb1f05ec0'
    ]
  },
  {
    wallet: '0x6317f6925640be65cfd36cf36051bb495da28359',
    proof: [
      '0x00000000000000000000000038c40ead3d0fe7959eb9dfe8337b3c4929884d2c',
      '0xdd376f13149d779ec7ca5ea1d3e01867fead722115854f1d6e3c64d77562a674',
      '0x28725660227d57a198eedc1e29e7cb42ac1cc1147f91b157905e0d756c923518',
      '0x0117255f50bf10ae1efe44f07cb4fd382fad994c35d39803f5b55e3cb1f05ec0'
    ]
  },
  {
    wallet: '0xd5b128d8d3cc9528c8d230a2f03336cafbd11753',
    proof: [
      '0x000000000000000000000000dd3d4ace64b8b20b24d385a2abe0702bb512c689',
      '0xde630617aa107198e09534c74e4b5fe6d1f29f397f1c6aa48745cd79c7d9c5a1',
      '0xf9f569e07fb2b4eb31e548b994285f915e35877601b186cbef218c3f7ed41523',
      '0xa8df132df2d9dc18699d7605abf4f2f19ad7e2fef7a46679a5cb44cc440a393f'
    ]
  },
  {
    wallet: '0x673437d956065fa0dc416c4a519cc5c37f6ad389',
    proof: [
      '0x0000000000000000000000006e414fd1468f7258cbb898ff1efb4124bddc47fc',
      '0x2dc6babcd41e65079f7ba43232f56475a28e14d7b93a4d0c64bb88603e7ed839',
      '0xe07e54a91e7fed964c5b63c31db7fecdc2dd8c1e403f59f2dc499b80d5bab014',
      '0x0117255f50bf10ae1efe44f07cb4fd382fad994c35d39803f5b55e3cb1f05ec0'
    ]
  },
  {
    wallet: '0xa2bae33c8ec8268d88f9917dc11aa857df692303',
    proof: [
      '0x0000000000000000000000008c3a198929e8796a09f017d11b56f684679a4721',
      '0xcc7bce4e3a0cff1ee6ae26430f8db4af3f3a9dc878f1edaa8860b16da2cd380f',
      '0xe07e54a91e7fed964c5b63c31db7fecdc2dd8c1e403f59f2dc499b80d5bab014',
      '0x0117255f50bf10ae1efe44f07cb4fd382fad994c35d39803f5b55e3cb1f05ec0'
    ]
  },
  {
    wallet: '0xba910716fd4b6b4447aea613993898eeb63844ad',
    proof: [
      '0x000000000000000000000000b688cd6b039081521a01e779833c3b20cf8d7949',
      '0xded162136ca0073735bee32d2726d12d33f6c1df0877febd86bc3594ee6b6f9f',
      '0xf9f569e07fb2b4eb31e548b994285f915e35877601b186cbef218c3f7ed41523',
      '0xa8df132df2d9dc18699d7605abf4f2f19ad7e2fef7a46679a5cb44cc440a393f'
    ]
  },
  {
    wallet: '0x6e414fd1468f7258cbb898ff1efb4124bddc47fc',
    proof: [
      '0x000000000000000000000000673437d956065fa0dc416c4a519cc5c37f6ad389',
      '0x2dc6babcd41e65079f7ba43232f56475a28e14d7b93a4d0c64bb88603e7ed839',
      '0xe07e54a91e7fed964c5b63c31db7fecdc2dd8c1e403f59f2dc499b80d5bab014',
      '0x0117255f50bf10ae1efe44f07cb4fd382fad994c35d39803f5b55e3cb1f05ec0'
    ]
  },
  {
    wallet: '0xb688cd6b039081521a01e779833c3b20cf8d7949',
    proof: [
      '0x000000000000000000000000ba910716fd4b6b4447aea613993898eeb63844ad',
      '0xded162136ca0073735bee32d2726d12d33f6c1df0877febd86bc3594ee6b6f9f',
      '0xf9f569e07fb2b4eb31e548b994285f915e35877601b186cbef218c3f7ed41523',
      '0xa8df132df2d9dc18699d7605abf4f2f19ad7e2fef7a46679a5cb44cc440a393f'
    ]
  },
  {
    wallet: '0x38c40ead3d0fe7959eb9dfe8337b3c4929884d2c',
    proof: [
      '0x0000000000000000000000006317f6925640be65cfd36cf36051bb495da28359',
      '0xdd376f13149d779ec7ca5ea1d3e01867fead722115854f1d6e3c64d77562a674',
      '0x28725660227d57a198eedc1e29e7cb42ac1cc1147f91b157905e0d756c923518',
      '0x0117255f50bf10ae1efe44f07cb4fd382fad994c35d39803f5b55e3cb1f05ec0'
    ]
  },
  {
    wallet: '0xdd3d4ace64b8b20b24d385a2abe0702bb512c689',
    proof: [
      '0x000000000000000000000000d5b128d8d3cc9528c8d230a2f03336cafbd11753',
      '0xde630617aa107198e09534c74e4b5fe6d1f29f397f1c6aa48745cd79c7d9c5a1',
      '0xf9f569e07fb2b4eb31e548b994285f915e35877601b186cbef218c3f7ed41523',
      '0xa8df132df2d9dc18699d7605abf4f2f19ad7e2fef7a46679a5cb44cc440a393f'
    ]
  },
  {
    wallet: '0xfa14c6aaa1ab119f8963d6f521ae7664d632842b',
    proof: [
      '0x000000000000000000000000e7292962e48c18e04bd26ab2acca00ef794e8171',
      '0x000000000000000000000000fd0e1f2fc10f7e43dcf80b1f17f0e4435e858035',
      '0x55a4a359c5c92c1f3c9dfc10a7209b60677e454a6878473e7661b04b08f25acd',
      '0xa8df132df2d9dc18699d7605abf4f2f19ad7e2fef7a46679a5cb44cc440a393f'
    ]
  },
  {
    wallet: '0xfd0e1f2fc10f7e43dcf80b1f17f0e4435e858035',
    proof: [
      '0x9052c75b2e27e14d57e25ab3136a58afcf7963955560fdbb6cbb394a3dae9724',
      '0x55a4a359c5c92c1f3c9dfc10a7209b60677e454a6878473e7661b04b08f25acd',
      '0xa8df132df2d9dc18699d7605abf4f2f19ad7e2fef7a46679a5cb44cc440a393f'
    ]
  },
  {
    wallet: '0x63b365a1ad15354f7338e95ba56e004c0d657c3e',
    proof: [
      '0x00000000000000000000000064b51b755330e8c3bca0563670c751c3902eee0d',
      '0x184837727e4cb04c791b6d0bd233f5243bf654cd52cbb77ed417ad2cbae34d8f',
      '0x28725660227d57a198eedc1e29e7cb42ac1cc1147f91b157905e0d756c923518',
      '0x0117255f50bf10ae1efe44f07cb4fd382fad994c35d39803f5b55e3cb1f05ec0'
    ]
  },
  {
    wallet: '0x64b51b755330e8c3bca0563670c751c3902eee0d',
    proof: [
      '0x00000000000000000000000063b365a1ad15354f7338e95ba56e004c0d657c3e',
      '0x184837727e4cb04c791b6d0bd233f5243bf654cd52cbb77ed417ad2cbae34d8f',
      '0x28725660227d57a198eedc1e29e7cb42ac1cc1147f91b157905e0d756c923518',
      '0x0117255f50bf10ae1efe44f07cb4fd382fad994c35d39803f5b55e3cb1f05ec0'
    ]
  }
]
*/
