// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import { DiamondFixture } from "../utils/DiamondFixture.sol";
import { MetadataFacet } from "../../src/facets/MetadataFacet.sol";
import { MintFacet } from "../../src/facets/MintFacet.sol";
import { LibGotchiConstants } from "../../src/libraries/LibGotchiConstants.sol";

contract MetadataFacetTest is DiamondFixture {
    address internal user = address(0x1);

    function setUp() public override {
        super.setUp();
        metadataFacet = MetadataFacet(address(diamond));
        mintFacet = MintFacet(address(diamond));
        
        vm.prank(owner);
        metadataFacet.setBaseURI("https://api.gotchipus.com/");
    }

    function test_TokenURI() public {
        vm.deal(user, 10 ether);
        vm.startPrank(user);

        mintFacet.mint{value: LibGotchiConstants.PHAROS_PRICE}(1);
        
        string memory uri1 = metadataFacet.tokenURI(0);
        assertEq(uri1, "https://api.gotchipus.com/pharos/0");

        MintFacet.SummonArgs memory args = MintFacet.SummonArgs({
            gotchipusTokenId: 0,
            gotchiName: "Test",
            collateralToken: address(0),
            stakeAmount: 0,
            utc: 0,
            story: "",
            preIndex: 0
        });
        mintFacet.summonGotchipus(args);

        string memory uri2 = metadataFacet.tokenURI(0);
        assertEq(uri2, "https://api.gotchipus.com/gotchipus/0");

        vm.stopPrank();
    }
}