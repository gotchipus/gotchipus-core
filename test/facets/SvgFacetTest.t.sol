// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import { DiamondFixture } from "../utils/DiamondFixture.sol";
import { SvgFacet } from "../../src/facets/SvgFacet.sol";
import { MintFacet } from "../../src/facets/MintFacet.sol";
import { LibGotchiConstants } from "../../src/libraries/LibGotchiConstants.sol";
import { LibSvg } from "../../src/libraries/LibSvg.sol"; 
import { IMetadataFacet } from "../../src/interfaces/IMetadataFacet.sol";

contract SvgFacetTest is DiamondFixture {
    MintFacet internal mintFacetBound;
    SvgFacet internal svgFacetBound;

    function setUp() public override {
        super.setUp();
        mintFacetBound = MintFacet(address(diamond));
        svgFacetBound = SvgFacet(address(diamond));
    }

    function testStoreSvg() public {
        vm.startPrank(owner);

        // 1. Upload placeholder SVG to prevent array out-of-bounds errors in Fork mode
        _setupAllSvgs();

        // 2. mint and summon
        mintFacetBound.mint{value: LibGotchiConstants.PHAROS_PRICE}(1);
        
        MintFacet.SummonArgs memory args = MintFacet.SummonArgs({
            gotchipusTokenId: 0,
            gotchiName: "TestGotchi",
            collateralToken: address(0),
            stakeAmount: 0,
            utc: 0,
            story: "",
            preIndex: 0
        });
        mintFacetBound.summonGotchipus(args);

        // 3. Debug print
        uint8[8] memory indexs = IMetadataFacet(address(diamond)).getGotchiTraitsIndex(0);
        for (uint256 i = 0; i < indexs.length; i++) {
            console.log("indexs[%s] = %s", i, indexs[i]);
        }

        // 4. get SVG
        string memory uri = svgFacetBound.getGotchipusSvg(0);
        
        // 5. verify
        assertTrue(bytes(uri).length > 0);
        
        bytes memory uriBytes = bytes(uri);
        if(uriBytes.length >= 4) {
            assertEq(string(abi.encodePacked(uriBytes[0], uriBytes[1], uriBytes[2], uriBytes[3])), "<svg");
        }

        vm.stopPrank();
    }

    function _setupAllSvgs() internal {
        _mockStore(LibSvg.SVG_TYPE_BG, 16);
        _mockStore(LibSvg.SVG_TYPE_BODY, 24);    
        _mockStore(LibSvg.SVG_TYPE_EYE, 8);
        _mockStore(LibSvg.SVG_TYPE_HAND, 14);
        _mockStore(LibSvg.SVG_TYPE_HEAD, 17);
        _mockStore(LibSvg.SVG_TYPE_CLOTHES, 9);
        _mockStore(LibSvg.SVG_TYPE_FACE, 7);
        _mockStore(LibSvg.SVG_TYPE_MOUTH, 6);
    }

    function _mockStore(bytes32 argType, uint256 count) internal {
        string memory placeholder = "<g></g>";
        bytes memory fullSvg = "";
        
        LibSvg.SvgItem[] memory items = new LibSvg.SvgItem[](count);
        uint256 size = bytes(placeholder).length;
        
        for(uint i=0; i<count; i++) {
            fullSvg = abi.encodePacked(fullSvg, placeholder);
            items[i] = LibSvg.SvgItem({
                svgType: argType,
                size: size
            });
        }
        
        svgFacetBound.storeSvg(fullSvg, items);
    }
}