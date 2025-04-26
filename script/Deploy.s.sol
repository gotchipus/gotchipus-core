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
import { MockMarineFarmFacet } from "../src/facets/MockMarineFarmFacet.sol";
import { IDiamondCut } from "../src/interfaces/IDiamondCut.sol";
import { TraitsOffset } from "../src/libraries/LibAppStorage.sol";
import { ERC6551Registry } from "../src/ERC6551Registry.sol";
import { ERC6551Account } from "../src/ERC6551Account.sol";
import { ERC6551Facet } from "../../src/facets/ERC6551Facet.sol";

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
        MockMarineFarmFacet mockMarineFarmFacet;
        ERC6551Account erc6551Account;
        ERC6551Registry erc6551Registry;
        ERC6551Facet erc6551Facet;
    }

    function run() external returns (Deployment memory) {
        return deploy(msg.sender);
    }

    /** 
     * Pharos devnet
     * create2Factory: 0x000000f2529cafe47f13bc4d674e343a97a870c1
     * diamond: 0x0000000038f050528452D6Da1E7AACFA7B3Ec0a8, 
     * initDiamond: 0x28e3350B608E4bcFE0f654Bd3e288E20D94A8382, 
     * diamondCutFacet: 0xfb6CF9f914c76ccDc3Fc722b5c0D3EFa5C4F7DFA, 
     * diamondLoupeFacet: 0xd87AC654aA730ca72681a3Aa29898a8F0ae0dd57, 
     * gotchipusFacet: 0x1Ab5C117EFC5C358bFFF7c4fe2cf5ccCEb408309, 
     * ownershipFacet: 0x705F094215317bAe890b78d1b374E66caa052c12, 
     * attributesFacet: 0xcE6360CBE1d2E47734479E30a09Ffe0132a5C149, 
     * dnaFacet: 0x14E66f0056b336a87Fd5Ae876a03b1a5fbdBDC66, 
     * hooksFacet: 0x8A1B589729bC9e3F6C79940331EfC7a2bD83039d, 
     * mockMarineFarmFacet: 0xaf04Cb9171772d4E2a974393734CA6BD009ea56B
     */

    function deploy(address owner) public returns (Deployment memory) {
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
        MockMarineFarmFacet mockMarineFarmFacet = new MockMarineFarmFacet();
        ERC6551Account erc6551Account = new ERC6551Account();
        ERC6551Registry erc6551Registry = new ERC6551Registry();
        ERC6551Facet erc6551Facet = new ERC6551Facet();

        // Diamond diamond = new Diamond(owner, address(diamondCutFacet), address(diamondLoupeFacet), address(ownershipFacet));
        Diamond diamond = Diamond(payable(0x0000000038f050528452D6Da1E7AACFA7B3Ec0a8));
        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](6);
        facetCuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(mockMarineFarmFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors("MockMarineFarmFacet")
        });
        facetCuts[1] = IDiamondCut.FacetCut({
            facetAddress: address(hooksFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors("HooksFacet")
        });
        facetCuts[2] = IDiamondCut.FacetCut({
            facetAddress: address(gotchipusFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors("GotchipusFacet")
        });
        facetCuts[3] = IDiamondCut.FacetCut({
            facetAddress: address(attributesFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors("AttributesFacet")
        });        
        facetCuts[4] = IDiamondCut.FacetCut({
            facetAddress: address(dnaFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors("DNAFacet")
        });
        facetCuts[5] = IDiamondCut.FacetCut({
            facetAddress: address(erc6551Facet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors("ERC6551Facet")
        });

        InitDiamond.Args memory initArgs = InitDiamond.Args({
            name: "GotchipusNFT",
            symbol: "GTP",
            baseUri: "https://gotchipus.com/metadata/",
            createUtcHour: 0,
            traitsOffset: getTraitsOffset(),
            erc6551Registry: address(erc6551Registry),
            erc6551AccountImplementation: address(erc6551Account)
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
            mockMarineFarmFacet: mockMarineFarmFacet,
            erc6551Account: erc6551Account,
            erc6551Registry: erc6551Registry,
            erc6551Facet: erc6551Facet
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

    function getSelectors(string memory facetName) internal pure returns (bytes4[] memory) {
        bytes4[] memory selectors;

        if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("GotchipusFacet"))) {
            selectors = new bytes4[](22);
            selectors[0] = GotchipusFacet.balanceOf.selector;
            selectors[1] = GotchipusFacet.ownerOf.selector;
            selectors[2] = GotchipusFacet.totalSupply.selector;
            selectors[3] = GotchipusFacet.tokenByIndex.selector;
            selectors[4] = GotchipusFacet.tokenOfOwnerByIndex.selector;
            selectors[5] = GotchipusFacet.allTokensOfOwner.selector;
            selectors[6] = GotchipusFacet.name.selector;
            selectors[7] = GotchipusFacet.symbol.selector;
            selectors[8] = GotchipusFacet.tokenURI.selector;
            selectors[9] = GotchipusFacet.getApproved.selector;
            selectors[10] = GotchipusFacet.isApprovedForAll.selector;
            selectors[11] = bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes)"));
            selectors[12] = bytes4(keccak256("safeTransferFrom(address,address,uint256)"));
            selectors[13] = GotchipusFacet.transferFrom.selector;
            selectors[14] = GotchipusFacet.approve.selector;
            selectors[15] = GotchipusFacet.setApprovalForAll.selector;
            selectors[16] = GotchipusFacet.setBaseURI.selector;
            selectors[17] = GotchipusFacet.mint.selector;
            selectors[18] = GotchipusFacet.burn.selector;
            selectors[19] = GotchipusFacet.summonGotchipus.selector;
            selectors[20] = GotchipusFacet.addWhitelist.selector;
            selectors[21] = GotchipusFacet.paused.selector;
        } else if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("AttributesFacet"))) {
            selectors = new bytes4[](8);
            selectors[0] = AttributesFacet.aether.selector;
            selectors[1] = AttributesFacet.bonding.selector;
            selectors[2] = AttributesFacet.feed.selector;
            selectors[3] = AttributesFacet.getTokenName.selector;
            selectors[4] = AttributesFacet.growth.selector;
            selectors[5] = AttributesFacet.pet.selector;
            selectors[6] = AttributesFacet.setName.selector;
            selectors[7] = AttributesFacet.wisdom.selector;
        } else if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("DNAFacet"))) {
            selectors = new bytes4[](4);
            selectors[0] = DNAFacet.getGene.selector;
            selectors[1] = DNAFacet.ruleVersion.selector;
            selectors[2] = DNAFacet.setRuleVersion.selector;
            selectors[3] = DNAFacet.tokenGeneSeed.selector;
        } else if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("HooksFacet"))) {
            selectors = new bytes4[](2);
            selectors[0] = HooksFacet.addHook.selector;
            selectors[1] = HooksFacet.getHooks.selector;
        } else if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("MockMarineFarmFacet"))) {
            selectors = new bytes4[](4);
            selectors[0] = MockMarineFarmFacet.breed.selector;
            selectors[1] = MockMarineFarmFacet.claimFish.selector;
            selectors[2] = MockMarineFarmFacet.getFishs.selector;
            selectors[3] = MockMarineFarmFacet.harvest.selector;
        } else if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("ERC6551Facet"))) {
            selectors = new bytes4[](2);
            selectors[0] = ERC6551Facet.account.selector;
            selectors[1] = ERC6551Facet.execute.selector;
        }

        return selectors;
    }
}