// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import { DiamondFixture } from "../utils/DiamondFixture.sol";
import { DNAFacet } from "../../src/facets/DNAFacet.sol";
import { MintFacet } from "../../src/facets/MintFacet.sol";
import { LibGotchiConstants } from "../../src/libraries/LibGotchiConstants.sol";

contract DNAFacetTest is DiamondFixture {
    // Remove duplicate declarations: DNAFacet internal dnaFacet;
    // Remove duplicate declarations: MintFacet internal mintFacet;

    function setUp() public override {
        super.setUp();
        // Directly assign to inherited variables
        dnaFacet = DNAFacet(address(diamond));
        mintFacet = MintFacet(address(diamond));
    }

    function test_RuleVersion() public {
        vm.prank(owner);
        dnaFacet.setRuleVersion(2);
        assertEq(dnaFacet.ruleVersion(), 2);
    }

    function test_TokenGeneSeed() public {
        address user = address(0x1);
        vm.deal(user, 1 ether);
        vm.startPrank(user);
        
        uint256 price = LibGotchiConstants.PHAROS_PRICE;
        mintFacet.mint{value: price}(1);
        
        // Verify that the call does not report any errors
        dnaFacet.tokenGeneSeed(0);
        
        vm.stopPrank();
    }
}