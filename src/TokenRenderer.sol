// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Owned} from "solmate/auth/Owned.sol";
import {LibString} from "solmate/utils/LibString.sol";

contract TokenRenderer is Owned(msg.sender) {
    string public baseurl;

    event UpdateBaseurl(string baseurl);

    constructor(string memory _baseurl) {
        baseurl = _baseurl;
        emit UpdateBaseurl(_baseurl);
    }

    /// @dev just in case we need to update the collection, owner should renounceOwnership after everything is ok
    function changeBaseurl(string memory newBaseurl) external onlyOwner {
        baseurl = newBaseurl;
        emit UpdateBaseurl(newBaseurl);
    }

    function tokenURI(uint256 id) external view returns (string memory url) {
        require(id > 0 && id < 1025, "invalid token");
        url = string.concat(baseurl, LibString.toString(id), ".json");
    }
}
