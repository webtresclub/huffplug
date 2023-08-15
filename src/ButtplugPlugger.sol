// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

// Minter contract for the Huffplugs
// source code: https://github.com/webtresclub/huffplug
// mint on goerli: https://buttplug-homepage.vercel.app/
import {MerkleProofLib} from "solmate/utils/MerkleProofLib.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {IHuffplug} from "src/IHuffplug.sol";

contract ButtplugPlugger {
    /// @dev The difficulty is the number of 0s that the hash of the address and the nonce must have
    ///      5 means 0x00000, im expecting to take a few secs to find a nonce
    uint256 public constant DEFAULT_DIFFICULTY = 5;
    uint256 public constant MAX_DIFFICULTY = 32;
    /// @dev The maximum number of Buttplug (UwU) that can be minted
    uint256 public constant MAX_SUPPLY = 1024;

    /// @dev The address of the Huffplug ERC721 contract
    IHuffplug immutable HUFFPLUG;
    /// @dev The timestamp when the collection started, useful to calculate the difficulty
    uint256 immutable COLLECTION_START = block.timestamp;
    /// @dev The merkle root of the merkle tree that contains the proofs of the users that can claim their Buttplug (UwU)
    bytes32 immutable MERKLE_ROOT;

    /// @dev The salt used to generate the pseudo random number for the minting
    bytes32 public salt;
    /// @dev The mapping of the users that have claimed their Buttplug (UwU)
    mapping(address => bool) public claimed;
    /// @dev The number of Buttplug (UwU) that have been minted, useful to calculate the difficulty
    uint256 public minted;

    /// @notice The error that is thrown when the user tries to mint more than MAX_SUPPLY
    error NoMoreUwU();
    /// @notice The error that is thrown when the user tries to mint without the correct nonce
    error YouHaveToGiveMeYourConsent();
    /// @notice The error that is thrown when the user tries to mint more than one Buttplug using the merkle tree
    error YouHaveClaimYourUwU();

    /// @notice The constructor of the contract
    /// @param _HUFFPLUG The address of the Huffplug contract
    constructor(address _HUFFPLUG, bytes32 _merkleRoot) {
        HUFFPLUG = IHuffplug(_HUFFPLUG);
        MERKLE_ROOT = _merkleRoot;

        salt = keccak256(abi.encodePacked(msg.sender, block.prevrandao));
    }

    /// @dev Returns the current difficulty, calculated using VERGA curve
    /// @return The current difficulty, calculated using VERGA curve between 5 and 32
    function currentDifficulty() public view returns (uint256) {
        return _currentDifficulty(minted);
    }

    /// @dev Returns the current difficulty, calculated using VERGA curve
    ///      The difficulty is calculated using the following formula:
    ///      difficulty = sqrt(totalMinted - delta) + 5
    ///      where delta is the number of Buttplug minted for today (1UwU per day)
    ///      and totalMinted is the number of Buttplug (UwU) that have been minted
    /// @param totalMinted The total minted supply of Buttplug (UwU)
    function _currentDifficulty(uint256 totalMinted) private view returns (uint256 difficulty) {
        unchecked {
            /// @dev We expect to mint 1 Buttplug (UwU) per day
            uint256 delta = (block.timestamp - COLLECTION_START) / 1 days;

            /// @dev If we have minted less than we supposed to difficulty is 6 (easy)
            if (delta > totalMinted) {
                return DEFAULT_DIFFICULTY;
            }

            difficulty = FixedPointMathLib.sqrt(totalMinted - delta) + DEFAULT_DIFFICULTY;
            if (difficulty < DEFAULT_DIFFICULTY) return DEFAULT_DIFFICULTY;
            if (difficulty > MAX_DIFFICULTY) return MAX_DIFFICULTY;
            return difficulty;
        }
    }

    function mint(uint256 nonce) external {
        uint256 _minted = minted;

        // if the totalMinted is >= MAX_SUPPLY, revert
        if (_minted >= MAX_SUPPLY) revert NoMoreUwU();

        // pseudo random number
        bytes32 random = keccak256(abi.encodePacked(msg.sender, salt, nonce));

        /// @dev This is inspired by the difficulty adjustment algorithm of Bitcoin
        uint256 difficulty = _currentDifficulty(_minted);
        assembly {
            // bitmask = bytes32(type(uint256).max << ((64-difficulty)*4));
            let bitmask := shl(sub(256, difficulty), not(0))
            //if (!(random & bitmask == 0)) revert YouHaveToGiveMeYourConsent();
            if and(random, bitmask) { 
                mstore(0x00, 0xae8c9b06) //revert YouHaveToGiveMeYourConsent();
                revert(0x1c, 0x04)
            }
        }

        /// @dev We have to update the minted counter after the check, otherwise we could mint more than MAX_SUPPLY
        unchecked {
            // update salt
            salt = blockhash(block.number - 1);

            minted = _minted + 1;
            HUFFPLUG.plug(msg.sender, uint256(random) % 1024 + 1);
        }
    }

    /// @notice Mint a Buttplug (UwU) using a merkle proof
    /// @param proofs The merkle proofs of the user
    /// @dev Users with at least two poap of the community can mint a Buttplug (UwU) using a merkle proof
    function mintWithMerkle(bytes32[] calldata proofs) external {
        if (claimed[msg.sender]) revert YouHaveClaimYourUwU();

        // if the totalMinted is >= MAX_SUPPLY, revert
        if (minted >= MAX_SUPPLY) revert NoMoreUwU();

        /// @dev Tag that the user has claimed his Buttplug (UwU) and can't claim more
        claimed[msg.sender] = true;

        require(MerkleProofLib.verify(proofs, MERKLE_ROOT, bytes32(uint256(uint160(msg.sender)))), "INVALID PROOF");

        /// @dev We have to update the minted counter after the check, otherwise we could mint more than MAX_SUPPLY
        unchecked {
            ++minted;
            HUFFPLUG.plug(msg.sender, uint256(keccak256(abi.encode(msg.sender, salt))) % 1024 + 1);
        }
    }
}
