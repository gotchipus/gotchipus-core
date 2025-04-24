// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import "../utils/DiamondFixture.sol";
import { IERC721Metadata } from "../../src/interfaces/IERC721Metadata.sol";

contract GotchipusFacetTest is DiamondFixture {
    function testGetName() public {
        IERC721Metadata gotchi = IERC721Metadata(address(diamond));

        string memory name = gotchi.name();
        assertEq(name, "GotchipusNFT");
    }
}