// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, Vm} from "forge-std/Test.sol";
import {compile} from "./Deploy.sol";
import {LibString} from "solmate/utils/LibString.sol";

import {IHuffplug} from "src/IHuffplug.sol";

using {compile} for Vm;

contract ButtplugTest is Test {
    IHuffplug public huffplug;

    bytes32 SALT_SLOT = bytes32(uint256(0x031337));
    bytes32 TOTAL_MINTED_SLOT = bytes32(uint256(0x0420));

    address public user = makeAddr("user");
    address public owner = makeAddr("owner");

    string baseUrl = "ipfs://bafybeia7h7n6osru3b4mvivjb3h2fkonvmotobvboqw3k3v4pvyv5oyzse/";
    string contractURI ="ipfs://bafybeia7h7n6osru3b4mvivjb3h2fkonvmotobvboqw3k3v4pvyv5oyzse/collection.json";

    uint256 constant COLLECTION_START = 1000000;
    bytes32 constant MERKLE_HASH = 0x51496785f4dd04d525b568df7fa6f1057799bc21f7e76c26ee77d2f569b40601;

    function setUp() public {
        vm.warp(COLLECTION_START);
        vm.prank(owner);

        bytes memory bytecode = vm.compile(COLLECTION_START, MERKLE_HASH);

        // send owner to the constructor, owner is only for opensea main page admin
        bytecode = bytes.concat(bytecode, abi.encode(owner));

        address deployed;
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        vm.label(deployed, "huffplug");
        huffplug = IHuffplug(deployed);
        huffplug.setUri(baseUrl);
        huffplug.setContractUri(contractURI);
    }

    function testContractUri() public noGasMetering {
        assertEq(huffplug.contractURI(), contractURI);
    }

    function testDifficulty() public noGasMetering {
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

        console2.logUint(COLLECTION_START);
        // if there are no new mint the difficulty shoud decay after some time
        vm.warp(COLLECTION_START + 1 days);
        assertEq(huffplug.currentDifficulty(), 9, "difficulty should be 9");

        vm.warp(COLLECTION_START + 4 days);
        assertEq(huffplug.currentDifficulty(), 9, "difficulty should be 9");
        vm.warp(COLLECTION_START + 5 days);
        assertEq(huffplug.currentDifficulty(), 8, "difficulty should be 8");

        vm.warp(COLLECTION_START + 12 days);
        assertEq(huffplug.currentDifficulty(), 7, "difficulty should be 7");
        vm.warp(COLLECTION_START + 17 days);
        assertEq(huffplug.currentDifficulty(), 6, "difficulty should be 6");
        vm.warp(COLLECTION_START + 20 days);
        assertEq(huffplug.currentDifficulty(), 5, "difficulty should be 5");
        vm.warp(COLLECTION_START + 300 days);
        assertEq(huffplug.currentDifficulty(), 5, "difficulty should be 5");

        vm.warp(COLLECTION_START + 1 days);
        vm.store(address(huffplug), TOTAL_MINTED_SLOT, /* slot of totalminted */ bytes32(uint256(1000)));
        assertEq(huffplug.currentDifficulty(), 32, "difficulty should be 32");
    }

    function testTotalMinted() public noGasMetering {
        assertEq(huffplug.totalMinted(), 0);
        vm.store(address(huffplug), TOTAL_MINTED_SLOT, /* slot of totalminted */ bytes32(uint256(10)));
        assertEq(huffplug.totalMinted(), 10);
    }

    function testMint() public noGasMetering {
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

    function testMintReverts() public noGasMetering {
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

        vm.expectRevert(IHuffplug.ErrNoMoreUwU.selector);
        huffplug.mint(nonce);

    }

    function testMintMerkleFail() public noGasMetering {
        bytes32[] memory roots = new bytes32[](2);
        roots[0] = 0x000000000000000000000000ee081f9fea22c5b578aa9ab1b4fc16e4335f5d2b;
        roots[1] = 0xa3a47908ac03234744670fa693ee11af0774d84b1cec2d2edbcb2e77b7bdd37b;

        address user1 = 0xe7292962e48c18e04Bd26aB2AcCA00Ef794E8171;

        vm.prank(user1);
        //vm.expectRevert(IHuffplug.ErrIgnvalidProof.selector);
        vm.expectRevert();
        huffplug.mintWithMerkle(roots);
    }

    function testMintMerkle() public noGasMetering {
        vm.store(address(huffplug), SALT_SLOT, /* slot of salt in ButtplugPlugger */ keccak256("salt"));

        assertEq(huffplug.totalMinted(), 0);
        bytes32[] memory roots = new bytes32[](6);
        roots[0] = 0x000000000000000000000000ee081f9fea22c5b578aa9ab1b4fc16e4335f5d2b;
        roots[1] = 0xa3a47908ac03234744670fa693ee11af0774d84b1cec2d2edbcb2e77b7bdd37b;
        roots[2] = 0x37b41dcb9d4ad8085237134780b7b724bc29b68c1d3a279d148f539f787684e7;
        roots[3] = 0xc8f17160e0889a52c573378d6a8f22b32e6f19f793f6ca3955fb95865a047777;
        roots[4] = 0xd61e2cc2664ae8ce0b12c5102373373dafd85bcb94ecc4e3981e1d24b304f80a;
        roots[5] = 0x17fac14873233024352b293cc1b7b04296f09870d377591aef743942c10c67a1;

        address user1 = 0xe7292962e48c18e04Bd26aB2AcCA00Ef794E8171;

        assertFalse(huffplug.claimed(user1), "user1 should not have claimed");

        vm.prank(user1);
        huffplug.mintWithMerkle(roots);

        assertTrue(huffplug.claimed(user1), "user1 should have claimed");

        assertEq(huffplug.totalMinted(), 1);
        assertEq(huffplug.balanceOf(user1), 1);
        assertEq(huffplug.ownerOf(371), user1);

        vm.prank(user1);
        vm.expectRevert(IHuffplug.ErrAlreadyClaimed.selector);
        huffplug.mintWithMerkle(roots);

        // @dev after minting with merkle salt should NOT be changed
        assertEq(huffplug.salt(), keccak256("salt"));

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
        huffplug.mintWithMerkle(roots);

        address user3 = 0x673437D956065Fa0dc416c4A519CC5c37f6AD389;
        roots[0] = 0x0000000000000000000000006666ec43deb25910121dd544e89301a86165fa6b;
        roots[1] = 0x31e85a3621abd6389b837e72024a8e2e97a34ad7d669b4f2c6d769747b089fa6;
        roots[2] = 0x85da31bd83f18a50b924a96880222d70f2899ec83143aa8fdd97dc0c70f9b809;
        roots[3] = 0x18610d990ae73613d1d1e5d6b7dff0beffb091df917a2b589fb91e8de43e13e2;
        roots[4] = 0xc58f6e1b828a1b25a219d212596904a829dc6209c1f922036949ed75bdfae350;
        roots[5] = 0xf7f97a6790805d13b9b30da262c4bc167c5f4ce84fdfd8e31f8adbd9c24aa5c3;
        roots[6] = 0x352f1d855d1a93eb69ad310d832a1f4bdf1de4320c08eb9d12cc6710334670d2;
        roots[7] = 0xfbbbfd743cceb9d2bdc8602f027333f04f9078b3684a73c5c33fb8d79e5baed5;

        vm.label(user3, "user3");
        vm.prank(user3);
        huffplug.mintWithMerkle(roots);

        assertEq(huffplug.totalMinted(), 3, "buttplugs minted should be 3");
    }

    function testRendererFuzz(uint256 id) public noGasMetering {
        if (id == 0 || id > 1024) {
            vm.expectRevert();
            huffplug.tokenURI(id);
        } else {
            string memory expected;
            if (id < 10) {
                expected = string.concat(baseUrl, "000", LibString.toString(id));
            } else if (id < 100) {
                expected = string.concat(baseUrl, "00", LibString.toString(id));
            } else if (id < 1000) {
                expected = string.concat(baseUrl, "0", LibString.toString(id));
            } else {
                expected = string.concat(baseUrl, LibString.toString(id));
            }
            assertEq(huffplug.tokenURI(id), expected);
        }
    }

    function testMetadata() public noGasMetering {
        assertEq(huffplug.symbol(), "UwU");
        assertEq(huffplug.name(), "Buttpluggy");
        assertEq(huffplug.totalSupply(), 1024);
    }

    function testTokenUri() public noGasMetering {
        assertEq(huffplug.tokenURI(3), string.concat(baseUrl, "0003"));
        assertEq(huffplug.tokenURI(10), string.concat(baseUrl, "0010"));
        //vm.expectRevert();
        //huffplug.tokenURI(0);

        //vm.expectRevert();
        //huffplug.tokenURI(1025);

        assertEq(huffplug.tokenURI(1024), string.concat(baseUrl, "1024"));
    }

    function testOwner() public noGasMetering {
        console2.log(owner);
        console2.log(huffplug.owner());
        assertEq(huffplug.owner(), owner, "wrong owner");
    }

    function testSetOwner(address new_owner) public noGasMetering {
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
