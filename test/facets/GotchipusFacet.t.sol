// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import { Test } from "forge-std/Test.sol";
import { GotchipusFacet } from "../../src/facets/GotchipusFacet.sol";

contract GotchipusFacetTest is Test {
    GotchipusFacet gotchipusFacet;

    function setUp() public {
        gotchipusFacet = new GotchipusFacet();
    }
}