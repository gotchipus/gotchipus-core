// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import { Diamond } from "../../src/Diamond.sol";
import { InitDiamond } from "../../src/InitDiamond.sol";
import { DiamondCutFacet } from "../../src/facets/DiamondCutFacet.sol";
import { DiamondLoupeFacet } from "../../src/facets/DiamondLoupeFacet.sol";
import { GotchipusFacet } from "../../src/facets/GotchipusFacet.sol";
import { OwnershipFacet } from "../../src/facets/OwnershipFacet.sol";
import { AttributesFacet } from "../../src/facets/AttributesFacet.sol";
import { DNAFacet } from "../../src/facets/DNAFacet.sol";
import { HooksFacet } from "../../src/facets/HooksFacet.sol";
import { IDiamondCut } from "../../src/interfaces/IDiamondCut.sol";
import { TraitsOffset } from "../../src/libraries/LibAppStorage.sol";
import { ERC6551Registry } from "../../src/ERC6551Registry.sol";
import { ERC6551Account } from "../../src/ERC6551Account.sol";
import { ERC6551Facet } from "../../src/facets/ERC6551Facet.sol";
import { LibSvg } from "../../src/libraries/LibSvg.sol";
import { FacetSelectors } from "./FacetSelectors.sol";
import { GotchiWearableFacet } from "../../src/facets/GotchiWearableFacet.sol";
import { SvgFacet } from "../../src/facets/SvgFacet.sol";
import { ALICE } from "./Constants.sol";


contract DiamondFixture is Test {
    Diamond public diamond;
    InitDiamond public initDiamond;
    DiamondCutFacet public cutFacet;
    DiamondLoupeFacet public loupeFacet;
    GotchipusFacet public gotchipusFacet;
    OwnershipFacet public ownershipFacet;
    AttributesFacet public attributesFacet;
    DNAFacet public dnaFacet;
    HooksFacet public hooksFacet;
    ERC6551Facet public erc6551Facet;
    ERC6551Account public erc6551Account;
    ERC6551Registry public erc6551Registry;
    GotchiWearableFacet public gotchiWearableFacet;
    SvgFacet public svgFacet;

    address internal owner = address(this);
    
    function setUp() public {
        cutFacet = new DiamondCutFacet();
        loupeFacet = new DiamondLoupeFacet();
        ownershipFacet = new OwnershipFacet();
        initDiamond = new InitDiamond();
        gotchipusFacet = new GotchipusFacet();
        attributesFacet = new AttributesFacet();
        dnaFacet = new DNAFacet();
        hooksFacet = new HooksFacet();
        erc6551Facet = new ERC6551Facet();
        erc6551Account = new ERC6551Account();
        erc6551Registry = new ERC6551Registry();
        gotchiWearableFacet = new GotchiWearableFacet();
        svgFacet = new SvgFacet();

        diamond = new Diamond(owner, address(cutFacet), address(loupeFacet), address(ownershipFacet));
        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](6);
        facetCuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(erc6551Facet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: FacetSelectors.getSelectors("ERC6551Facet")
        });
        facetCuts[1] = IDiamondCut.FacetCut({
            facetAddress: address(hooksFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: FacetSelectors.getSelectors("HooksFacet")
        });
        facetCuts[2] = IDiamondCut.FacetCut({
            facetAddress: address(gotchipusFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: FacetSelectors.getSelectors("GotchipusFacet")
        });
        facetCuts[3] = IDiamondCut.FacetCut({
            facetAddress: address(attributesFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: FacetSelectors.getSelectors("AttributesFacet")
        });        
        facetCuts[4] = IDiamondCut.FacetCut({
            facetAddress: address(dnaFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: FacetSelectors.getSelectors("DNAFacet")
        });
        facetCuts[5] = IDiamondCut.FacetCut({
            facetAddress: address(svgFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: FacetSelectors.getSelectors("SvgFacet")
        });

        bytes32[6] memory svgTypes;
        svgTypes[0] = LibSvg.SVG_TYPE_BG;
        svgTypes[1] = LibSvg.SVG_TYPE_BODY;
        svgTypes[2] = LibSvg.SVG_TYPE_EYE;
        svgTypes[3] = LibSvg.SVG_TYPE_HAND;
        svgTypes[4] = LibSvg.SVG_TYPE_HEAD;
        svgTypes[5] = LibSvg.SVG_TYPE_CLOTHES;

        InitDiamond.Args memory initArgs = InitDiamond.Args({
            name: "Gotchipus",
            symbol: "GOTCHI",
            baseUri: "https://app.gotchipus.com/metadata/",
            createUtcHour: 0,
            traitsOffset: getTraitsOffset(),
            erc6551Registry: address(erc6551Registry),
            erc6551AccountImplementation: address(erc6551Account),
            svgTypes: svgTypes
        });
        bytes memory initCalldata = abi.encodeWithSelector(InitDiamond.init.selector, initArgs);

        IDiamondCut(address(diamond)).diamondCut(facetCuts, address(initDiamond), initCalldata);
    }

    function getTraitsOffset() internal pure returns (TraitsOffset[] memory) {
        uint256 traitsNumber = 26;
        TraitsOffset[] memory traitsOffset = new TraitsOffset[](traitsNumber);
        uint8[26] memory widths = [uint8(3), 1, 4, 4, 1, 4, 1, 4, 1, 4, 4, 1, 4, 4, 1, 4, 4, 1, 4, 4, 4, 4, 4, 4, 4, 4];
        uint8 offset = 0;

        for (uint256 i = 0; i < traitsNumber; i++) {
            traitsOffset[i] = TraitsOffset({
                offset: offset,
                width: widths[i]
            });
            offset += widths[i];
        }

        return traitsOffset;
    }


}
