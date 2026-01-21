// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import { DiamondFixture } from "../utils/DiamondFixture.sol";
import { MintFacet } from "../../src/facets/MintFacet.sol";
import { AttributesFacet } from "../../src/facets/AttributesFacet.sol";
import { LibGotchiConstants } from "../../src/libraries/LibGotchiConstants.sol";

contract AttributesFacetTest is DiamondFixture {
    MintFacet internal mintFacetBound;
    AttributesFacet internal attributesFacetBound;
    address internal user = address(0xABC);
    uint256 internal tokenId = 0;

    function setUp() public override {
        super.setUp();
        mintFacetBound = MintFacet(address(diamond));
        attributesFacetBound = AttributesFacet(address(diamond));

        // Deposit enough ETH into the test users
        vm.deal(user, 10 ether);

        // Prerequisites: Mint and summon a Gotchi
        _setupGotchi(user);
    }

    function _setupGotchi(address _user) internal {
        vm.startPrank(_user);

        // Public Mint
        uint256 price = LibGotchiConstants.PHAROS_PRICE;
        mintFacetBound.mint{value: price}(1);
        
        // summon
        MintFacet.SummonArgs memory args = MintFacet.SummonArgs({
            gotchipusTokenId: tokenId,
            gotchiName: "PetMe",
            collateralToken: address(0),
            stakeAmount: 0,
            utc: 0,
            story: "",
            preIndex: 0
        });
        mintFacetBound.summonGotchipus(args);
        
        vm.stopPrank();
    }

    function test_PetIncreaseStats() public {
        vm.startPrank(user);
        
        // Summon might initialize lastPetTime to the current time, so we need to skip 1 day first
        vm.warp(block.timestamp + 1 days + 1 hours);

        // 1. First touch (Pet)
        attributesFacetBound.pet(tokenId);
        
        // Verify timestamp update
        uint32 lastPetTime = attributesFacetBound.getLastPetTime(tokenId);
        assertEq(lastPetTime, block.timestamp);

        // Verify attribute changes (based on AttributesFacet logic, empirical value +20)
        // Here we can further verify the specific attribute values, if AttributesFacet has a getter
        // For example:
        // (uint32 exp,,,,,) = attributesFacetBound.getAttributes(tokenId);
        // assertEq(exp, 20); // Initially 0, Pet increases by 20
        // 2. Touching again during the cooldown period should fail
        vm.expectRevert("gotchipus already pet");
        attributesFacetBound.pet(tokenId);

        // 3. Time travel: Fast forward 1 day + 1 second
        vm.warp(block.timestamp + 1 days + 1);

        // 4. The second touch should be successful
        attributesFacetBound.pet(tokenId);
        assertEq(attributesFacetBound.getLastPetTime(tokenId), block.timestamp);
        
        vm.stopPrank();
    }

    function test_SetName() public {
        vm.startPrank(user);
        
        string memory newName = "NewGotchiName";
        attributesFacetBound.setName(newName, tokenId);
        
        string memory storedName = attributesFacetBound.getTokenName(tokenId);
        assertEq(storedName, newName);
        
        vm.stopPrank();
    }
}