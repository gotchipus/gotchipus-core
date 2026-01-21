// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import { DiamondFixture } from "../utils/DiamondFixture.sol";
import { TimeFacet } from "../../src/facets/TimeFacet.sol";
import { LibTime } from "../../src/libraries/LibTime.sol";

contract TimeFacetTest is DiamondFixture {

    function setUp() public override {
        super.setUp();
        timeFacet = TimeFacet(address(diamond));
    }

    function test_UpdateWeather() public {
        uint8[] memory zones = new uint8[](1);
        zones[0] = 1;
        
        LibTime.Weather[] memory weathers = new LibTime.Weather[](1);
        
        weathers[0] = LibTime.Weather.CLEAR; 
        
        vm.prank(owner);
        timeFacet.updateWeather(zones, weathers);
        
        LibTime.Weather w = timeFacet.getWeather(1);
        
        assertTrue(w == LibTime.Weather.CLEAR); 
    }
}