// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { IERC721 } from "./IERC721.sol";
import { IERC721Metadata } from "./IERC721Metadata.sol";
import { IERC721Enumerable } from "./IERC721Enumerable.sol";

interface IGotchipusFacet is IERC721, IERC721Enumerable, IERC721Metadata {
    struct SummonArgs {
        uint256 gotchipusTokenId;
        string pusName;
        address collateralToken;
        uint256 stakeAmount;
        uint8 utc;
        bytes story;
    }

    function mint(uint256 amount) external payable;
    function summonGotchipus(SummonArgs calldata _args) external payable;
    function addWhitelist(address[] calldata _whitelists, bool[] calldata _isWhitelists) external;
    function paused(bool _paused) external;
}