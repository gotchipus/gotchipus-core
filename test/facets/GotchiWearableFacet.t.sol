// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import { DiamondFixture } from "../utils/DiamondFixture.sol";
import { GotchiWearableFacet } from "../../src/facets/GotchiWearableFacet.sol";
import { MintFacet } from "../../src/facets/MintFacet.sol";
import { WearableInfo } from "../../src/libraries/LibAppStorage.sol";
import { LibSvg } from "../../src/libraries/LibSvg.sol";
import { LibGotchiConstants } from "../../src/libraries/LibGotchiConstants.sol";

contract GotchiWearableFacetTest is DiamondFixture {
    GotchiWearableFacet internal wearableFacetBound;
    address internal user = address(0xABC);

    function setUp() public override {
        super.setUp();
        wearableFacetBound = GotchiWearableFacet(address(diamond));
        mintFacet = MintFacet(address(diamond));

        // Register yourself as a Wearable contract (for mintWearable permissions)
        vm.prank(owner);
        wearableFacetBound.setWearableDiamond(address(this));
    }

    function test_CreateAndMintWearable() public {
        // 1. Get the next available ID
        // DiamondFixture has already initialized equipment numbers 0-84, so this should be number 85
        uint256 newId = wearableFacetBound.getNextTokenId();

        WearableInfo memory info = WearableInfo({
            name: "God Sword",
            description: "A powerful sword",
            author: "Dev",
            wearableType: LibSvg.SVG_TYPE_HAND,
            wearableId: uint8(newId) // Although `create` rewrites the ID internally, it's good practice to maintain consistency
        });

        vm.prank(owner);
        wearableFacetBound.createWearable("ipfs://sword", info);

        // 2. Verification information (using dynamically obtained newId, instead of hardcoding 0)
        WearableInfo memory fetched = wearableFacetBound.getWearableInfo(newId);
        assertEq(fetched.name, "God Sword");

        // 3. Mint equipment for users
        // Only WearableDiamond (parallel to address(this)) can call mint
        vm.deal(address(this), 1 ether);
        
        uint256 amount = 10;
        uint256 price = 0.001 ether;
        uint256 cost = amount * price;

        // Payment amount must equal amount * 0.001
        wearableFacetBound.mintWearable{value: cost}(user, newId, amount);

        assertEq(wearableFacetBound.wearableBalanceOf(user, newId), amount);
    }

    function test_EquipAndUnequip() public {
        // 1. Preparation environment: The user has Gotchi and equipment
        // The `_setupGotchiAndWearable` function internally creates an item with ID 85.
        uint256 swordId = _setupGotchiAndWearable();

        vm.startPrank(user);

        // 2. equipment
        // Equip with the correct swordId (85)
        wearableFacetBound.equipWearable(0, swordId, LibSvg.SVG_TYPE_HAND);

        // Verify the balance change (initially 5, becomes 4 after wearing)
        assertEq(wearableFacetBound.wearableBalanceOf(user, swordId), 4);
        
        // 3. take off
        wearableFacetBound.unequipWearable(0, swordId, LibSvg.SVG_TYPE_HAND);
        assertEq(wearableFacetBound.wearableBalanceOf(user, swordId), 5);

        vm.stopPrank();
    }

    // Return the created equipment ID
    function _setupGotchiAndWearable() internal returns (uint256) {
        uint256 newId = wearableFacetBound.getNextTokenId();

        // Create equipment (ID = newId, for example, 85)
        WearableInfo memory info = WearableInfo({
            name: "Sword",
            description: "Weapon",
            author: "Admin",
            wearableType: LibSvg.SVG_TYPE_HAND,
            wearableId: uint8(newId)
        });
        vm.prank(owner);
        wearableFacetBound.createWearable("uri", info);

        vm.deal(address(this), 1 ether);
        
        // Payment amounts must match (5 * 0.001 = 0.005 ether)
        uint256 amount = 5;
        uint256 cost = amount * 0.001 ether;
        wearableFacetBound.mintWearable{value: cost}(user, newId, amount);

        // Mint Gotchi for User
        vm.deal(user, 10 ether);
        vm.prank(user);
        mintFacet.mint{value: LibGotchiConstants.PHAROS_PRICE}(1);
        
        // Summon
        vm.prank(user);
        MintFacet.SummonArgs memory args = MintFacet.SummonArgs({
            gotchipusTokenId: 0,
            gotchiName: "Warrior",
            collateralToken: address(0),
            stakeAmount: 0,
            utc: 0,
            story: "",
            preIndex: 0
        });
        mintFacet.summonGotchipus(args);

        return newId;
    }
}