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


contract Deploy is Script {
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
    }

    function run() external returns (Deployment memory) {
        return deploy();
    }

    /** 
     * Pharos testnet
     * create2Factory: 0x000000f2529CaFE47f13BC4d674e343A97A870c1
     * diamond: 0x0000000038f050528452D6Da1E7AACFA7B3Ec0a8, 
     * ERC6551Registry: 0x000000E7C8746fdB64D791f6bb387889c5291454
     * ERC6551Account: 0xee8862134dFe901C62dbC72B25930da791a20CFf
     * 
     * initDiamond: 0xd7178B120D93cd975737902d8c8e46D430eBd502, 
     * diamondCutFacet: 0xfb6CF9f914c76ccDc3Fc722b5c0D3EFa5C4F7DFA, 
     * diamondLoupeFacet: 0xd87AC654aA730ca72681a3Aa29898a8F0ae0dd57, 
     * gotchipusFacet: 0x450C122c5A317EFF2A7E0cb6AF65a483c2d530D7, 
     * ownershipFacet: 0x705F094215317bAe890b78d1b374E66caa052c12, 
     * attributesFacet: 0x14E66f0056b336a87Fd5Ae876a03b1a5fbdBDC66, 
     * dnaFacet: 0x8A1B589729bC9e3F6C79940331EfC7a2bD83039d, 
     * hooksFacet: 0xaf04Cb9171772d4E2a974393734CA6BD009ea56B, 
     * svgFacet: 0x902ACfCcD0b5430Bc4A9a004cdBd53F2E0a6438d
     * paymasterFacet: 0x75E7765769789DcF2E7392B648d292239aDb3f2C
     * gotchiWearableFacet: 0x034e5b8F4675D8b21177a2bCa3dd2cAC9b927465
     * TimeFacet: 0xf0B248C4141931D592eC5b28FDB60d3B893d4a23
     */

    function deploy() public returns (Deployment memory) {
        vm.startBroadcast();

        // DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        // DiamondLoupeFacet diamondLoupeFacet = new DiamondLoupeFacet();
        // OwnershipFacet ownershipFacet = new OwnershipFacet();
        DiamondCutFacet diamondCutFacet = DiamondCutFacet(0xfb6CF9f914c76ccDc3Fc722b5c0D3EFa5C4F7DFA);
        DiamondLoupeFacet diamondLoupeFacet = DiamondLoupeFacet(0xd87AC654aA730ca72681a3Aa29898a8F0ae0dd57);
        OwnershipFacet ownershipFacet = OwnershipFacet(0x705F094215317bAe890b78d1b374E66caa052c12);
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

        // Diamond diamond = new Diamond(owner, address(diamondCutFacet), address(diamondLoupeFacet), address(ownershipFacet));
        Diamond diamond = Diamond(payable(0x0000000038f050528452D6Da1E7AACFA7B3Ec0a8));
        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](7);
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

        bytes32[] memory svgTypes;
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
            paymasterFacet: paymasterFacet
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