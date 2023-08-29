// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

// Render contract for the Huffplugs
// source code: https://github.com/webtresclub/huffplug
// mint on goerli: https://buttplug-homepage.vercel.app/
import {LibString} from "solmate/utils/LibString.sol";
import {Ownable} from "./Ownable.sol";

contract TokenRenderer is Ownable {
    string private _baseurl;
    string public contractURI;

    constructor(string memory baseurl_, string memory contractURI_) payable {
        owner = msg.sender;
        _baseurl = baseurl_;
        contractURI = contractURI_;
    }

    /// @dev just in case we need to update the collection, owner should renounceOwnership after everything is ok
    function changeBaseurl(string memory baseurl_) external payable onlyOwner {
        _baseurl = baseurl_;
    }
     /// @dev just in case we need to update the collection, owner should renounceOwnership after everything is ok
    function changeContractUri(string memory contractURI_) external payable onlyOwner {
        contractURI = contractURI_;
    }

    function tokenURI(uint256 id) external view returns (string memory url) {
        unchecked {
            if ((id-1) > 1024) revert("invalid token id");
        }
        url = string.concat(_baseurl, LibString.toString(id), ".json");
    }
}
