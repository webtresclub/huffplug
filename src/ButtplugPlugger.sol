// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {IHuffplug} from "src/IHuffplug.sol";

contract ButtplugPlugger {
    /// @dev The difficulty is the number of 0s that the hash of the address and the nonce must have
    ///      5 means 0x00000, anf im expecting to take a few secs to find a nonce
    uint256 public constant DEFAULT_DIFFICULTY = 5;
    uint256 public constant MAX_DIFFICULTY = 32;
    /// @dev The maximum number of Buttplug (UwU) that can be minted
    uint256 public constant MAX_SUPPLY = 1024;

    IHuffplug immutable HUFFPLUG;
    uint256 immutable COLLECTION_START = block.timestamp;

    bytes32 public salt;
    mapping(address => bool) public claimed;
    uint256 public minted;

    error NoMoreUwU();
    error YouHaveToGiveMeYourConsent();

    /// @notice The constructor of the contract
    /// @param _HUFFPLUG The address of the Huffplug contract
    /// @param _premintedByMerkletree The number of Buttplug (UwU) that can be minted by the merkle tree
    constructor(address _HUFFPLUG, uint256 _premintedByMerkletree) {
        HUFFPLUG = IHuffplug(_HUFFPLUG);
        minted = _premintedByMerkletree;

        salt = keccak256(abi.encodePacked(msg.sender, block.prevrandao));
    }

    /// @dev Returns the current difficulty, calculated using VERGA curve
    /// @return The current difficulty, calculated using VERGA curve between 5 and 32
    function currentDifficulty() public view returns (uint256) {
        return _currentDifficulty(minted);
    }

    function _currentDifficulty(uint256 tSupply) private view returns (uint256) {
        unchecked {
            /// @dev We expect to mint 1 Buttplug (UwU) per day
            uint256 delta = (block.timestamp - COLLECTION_START) / 1 days;

            /// @dev If we have minted less than we supposed to, we are in the first phase
            if (delta < tSupply + 1) {
                return DEFAULT_DIFFICULTY;
            }

            // uint256 ret = 2 ** (tSupply - delta);
            uint256 ret = (tSupply - delta) / 10;
            if (ret < DEFAULT_DIFFICULTY) return DEFAULT_DIFFICULTY;
            if (ret > MAX_DIFFICULTY) return MAX_DIFFICULTY;
            return ret;
        }
    }

    function mint(uint256 nonce) external {
        uint256 _minted = minted;
        if (_minted >= MAX_SUPPLY) revert NoMoreUwU();

        /// @dev This is inspired by the difficulty adjustment algorithm of Bitcoin
        uint256 difficulty = _currentDifficulty(_minted);
        bytes32 bitmask = bytes32(2 ** (4 * difficulty) - 1 << 4 * (64 - difficulty));

        // pseudo random number
        bytes32 random = keccak256(abi.encode(msg.sender, salt, nonce));

        // bool canPlug = keccak256(abi.encodePacked(msg.sender, salt, nonce)) & bitmask == 0;
        bool canPlug = (random & bitmask) == 0;
        if (!canPlug) revert YouHaveToGiveMeYourConsent();

        // update salt
        salt = keccak256(abi.encodePacked(msg.sender, block.prevrandao, nonce));

        /// @dev We have to update the minted counter after the check, otherwise we could mint more than MAX_SUPPLY
        unchecked {
            minted = _minted + 1;
        }

        HUFFPLUG.plug(msg.sender, uint256(random) % 1024 + 1);
    }

    function mintWithMerkle() external {
        require(!claimed[msg.sender], "already claimed");
        // @todo chequear que msg.sender este en el merkle
        
        /// @dev Tag that the user has claimed his Buttplug (UwU) and can't claim more
        claimed[msg.sender] = true;

        /// @dev We have to update the minted counter after the check, otherwise we could mint more than MAX_SUPPLY
        unchecked {
            ++minted;
        }

        HUFFPLUG.plug(msg.sender, uint256(keccak256(abi.encode(msg.sender, salt))) % 1024 + 1);
    }
}