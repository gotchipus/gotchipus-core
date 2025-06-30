// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import { Script } from "forge-std/Script.sol";
import { Diamond } from "../src/Diamond.sol";
import { InitDiamond } from "../src/InitDiamond.sol";
import { DiamondCutFacet } from "../src/facets/DiamondCutFacet.sol";
import { DiamondLoupeFacet } from "../src/facets/DiamondLoupeFacet.sol";
import { GotchipusFacet } from "../src/facets/GotchipusFacet.sol";
import { OwnershipFacet } from "../src/facets/OwnershipFacet.sol";
import { AttributesFacet } from "../src/facets/AttributesFacet.sol";
import { DNAFacet } from "../src/facets/DNAFacet.sol";
import { HooksFacet } from "../src/facets/HooksFacet.sol";
import { IDiamondCut } from "../src/interfaces/IDiamondCut.sol";
import { TraitsOffset } from "../src/libraries/LibAppStorage.sol";
import { ERC6551Registry } from "../src/ERC6551Registry.sol";
import { ERC6551Account } from "../src/ERC6551Account.sol";
import { ERC6551Facet } from "../src/facets/ERC6551Facet.sol";
import { SvgFacet } from "../src/facets/SvgFacet.sol";
import { PaymasterFacet } from "../src/facets/PaymasterFacet.sol";
import { LibSvg } from "../src/libraries/LibSvg.sol";
import { FacetSelectors } from "../test/utils/FacetSelectors.sol";
import { GotchiWearableFacet } from "../src/facets/GotchiWearableFacet.sol";
import { WearableDiamond } from "../src/WearableDiamond/WearableDiamond.sol";
import { WearableFacet } from "../src/WearableDiamond/facets/WearableFacet.sol";
import { IGotchiWearableFacet } from "../src/interfaces/IGotchiWearableFacet.sol";
import { IGotchipusFacet } from "../src/interfaces/IGotchipusFacet.sol";


contract MockDeploy is Script {
    struct Deployment {
        Diamond diamond;
        InitDiamond initDiamond;
        DiamondCutFacet diamondCutFacet;
        DiamondLoupeFacet diamondLoupeFacet;
        GotchipusFacet gotchipusFacet;
        OwnershipFacet ownershipFacet;
        AttributesFacet attributesFacet;
        DNAFacet dnaFacet;
        HooksFacet hooksFacet;
        ERC6551Account erc6551Account;
        ERC6551Registry erc6551Registry;
        ERC6551Facet erc6551Facet;
        SvgFacet svgFacet;
        PaymasterFacet paymasterFacet;
        GotchiWearableFacet gotchiWearableFacet;
        WearableDiamond wearableDiamond;
    }

    function run() external returns (Deployment memory) {
        return deploy();
    }

    /** 
     * mock testnet
     * diamond: 0x87858d49a56e15B9377A3896fD8CcEcaEa050336, 
     */

    function deploy() public returns (Deployment memory) {
        vm.startBroadcast();
        address owner = msg.sender;
        
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        DiamondLoupeFacet diamondLoupeFacet = new DiamondLoupeFacet();
        OwnershipFacet ownershipFacet = new OwnershipFacet();
        InitDiamond initDiamond = new InitDiamond();
        GotchipusFacet gotchipusFacet = new GotchipusFacet();
        AttributesFacet attributesFacet = new AttributesFacet();
        DNAFacet dnaFacet = new DNAFacet();
        HooksFacet hooksFacet = new HooksFacet();
        ERC6551Account erc6551Account = ERC6551Account(payable(0xee8862134dFe901C62dbC72B25930da791a20CFf));
        ERC6551Registry erc6551Registry = ERC6551Registry(0x000000E7C8746fdB64D791f6bb387889c5291454);
        ERC6551Facet erc6551Facet = new ERC6551Facet();
        SvgFacet svgFacet = new SvgFacet();
        PaymasterFacet paymasterFacet = new PaymasterFacet();
        GotchiWearableFacet gotchiWearableFacet = new GotchiWearableFacet();

        Diamond diamond = new Diamond(owner, address(diamondCutFacet), address(diamondLoupeFacet), address(ownershipFacet));

        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](8);
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
        facetCuts[6] = IDiamondCut.FacetCut({
            facetAddress: address(paymasterFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: FacetSelectors.getSelectors("PaymasterFacet")
        });
        facetCuts[7] = IDiamondCut.FacetCut({
            facetAddress: address(gotchiWearableFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: FacetSelectors.getSelectors("GotchiWearableFacet")
        });

        bytes32[6] memory svgTypes = [
            LibSvg.SVG_TYPE_BG,
            LibSvg.SVG_TYPE_BODY,
            LibSvg.SVG_TYPE_EYE,
            LibSvg.SVG_TYPE_HAND,
            LibSvg.SVG_TYPE_HEAD,
            LibSvg.SVG_TYPE_CLOTHES
        ];

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

        // wearable diamond
        DiamondCutFacet wearableDiamondCutFacet = new DiamondCutFacet();
        DiamondLoupeFacet wearableDiamondLoupeFacet = new DiamondLoupeFacet();
        OwnershipFacet warableOwnershipFacet = new OwnershipFacet();
        WearableFacet wearableFacet = new WearableFacet();

        // 0x9C974DfA49fC46b05306E83a6afaB616dc781732
        WearableDiamond wearableDiamond = new WearableDiamond(owner, address(wearableDiamondCutFacet), address(wearableDiamondLoupeFacet), address(warableOwnershipFacet));

        bytes4[] memory wearableFacetFunctions = new bytes4[](10);
        wearableFacetFunctions[0] = WearableFacet.name.selector;
        wearableFacetFunctions[1] = WearableFacet.symbol.selector;
        wearableFacetFunctions[2] = WearableFacet.balanceOf.selector;
        wearableFacetFunctions[3] = WearableFacet.balanceOfBatch.selector;
        wearableFacetFunctions[4] = WearableFacet.uri.selector;
        wearableFacetFunctions[5] = WearableFacet.isApprovedForAll.selector;
        wearableFacetFunctions[6] = WearableFacet.setApprovalForAll.selector;
        wearableFacetFunctions[7] = WearableFacet.setBaseURI.selector;
        wearableFacetFunctions[8] = WearableFacet.safeTransferFrom.selector;
        wearableFacetFunctions[9] = WearableFacet.safeBatchTransferFrom.selector;

        IDiamondCut.FacetCut[] memory wearableFacetCuts = new IDiamondCut.FacetCut[](1);
        wearableFacetCuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(wearableFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: wearableFacetFunctions
        });

        IDiamondCut(address(wearableDiamond)).diamondCut(wearableFacetCuts, address(0), "");

        // **************************************************** // 
        //                  external call                       //
        // **************************************************** //

        // IGotchiWearableFacet(address(diamond)).setWearableDiamond(address(wearableDiamond));
        // IGotchipusFacet(address(diamond)).freeMint();

        // IGotchipusFacet.SummonArgs memory args = IGotchipusFacet.SummonArgs({
        //     gotchipusTokenId: 0,
        //     gotchiName: "Gotchi #1",
        //     collateralToken: address(0),
        //     stakeAmount: 0.001 ether,
        //     utc: 0,
        //     story: "0x"
        // });

        // IGotchipusFacet(address(diamond)).summonGotchipus{value: 0.001 ether}(args);

        vm.stopBroadcast();

        return Deployment({
            diamond: diamond,
            initDiamond: initDiamond,
            diamondCutFacet: diamondCutFacet,
            diamondLoupeFacet: diamondLoupeFacet,
            gotchipusFacet: gotchipusFacet,
            ownershipFacet: ownershipFacet,
            attributesFacet: attributesFacet,
            dnaFacet: dnaFacet,
            hooksFacet: hooksFacet,
            erc6551Account: erc6551Account,
            erc6551Registry: erc6551Registry,
            erc6551Facet: erc6551Facet,
            svgFacet: svgFacet,
            paymasterFacet: paymasterFacet,
            gotchiWearableFacet: gotchiWearableFacet,
            wearableDiamond: wearableDiamond
        });
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