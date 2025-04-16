// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import { Script } from "forge-std/Script.sol";
import { Diamond } from "../src/Diamond.sol";
import { InitDiamond } from "../src/InitDiamond.sol";
import { DiamondCutFacet } from "../src/facets/DiamondCutFacet.sol";
import { DiamondLoupeFacet } from "../src/facets/DiamondLoupeFacet.sol";
import { GotchipusFacet } from "../src/facets/GotchipusFacet.sol";
import { OwnershipFacet } from "../src/facets/OwnershipFacet.sol";
import { ERC6551AccountFacet } from "../src/facets/ERC6551AccountFacet.sol";
import { ERC6551RegistryFacet } from "../src/facets/ERC6551RegistryFacet.sol";
import { AttributesFacet } from "../src/facets/AttributesFacet.sol";
import { DNAFacet } from "../src/facets/DNAFacet.sol";
import { HooksFacet } from "../src/facets/HooksFacet.sol";
import { MockMarineFarmFacet } from "../src/facets/MockMarineFarmFacet.sol";
import { IDiamondCut } from "../src/interfaces/IDiamondCut.sol";


contract Deploy is Script {
    struct Deployment {
        Diamond diamond;
        InitDiamond initDiamond;
        DiamondCutFacet diamondCutFacet;
        DiamondLoupeFacet diamondLoupeFacet;
        GotchipusFacet gotchipusFacet;
        OwnershipFacet ownershipFacet;
        ERC6551AccountFacet erc6551AccountFacet;
        ERC6551RegistryFacet erc6551RegistryFacet;
        AttributesFacet attributesFacet;
        DNAFacet dnaFacet;
        HooksFacet hooksFacet;
        MockMarineFarmFacet mockMarineFarmFacet; 
    }

    function run() external returns (Deployment memory) {
        return deploy(msg.sender);
    }

    /** 
     * Pharos devnet
     * diamond: 0xD04DB12e84a902F5300335Df1c58E38B488dE8B7, 
     * initDiamond: 0x00dAFecfa294164d5097361e8952AdF5cDF5F31c, 
     * diamondCutFacet: 0xFC43f1558d3951cEE3c2144B9D118aAac45532c6, 
     * diamondLoupeFacet: 0x4b6A7c9d8A099B8E1d46E3300896f6bAdA339b32, 
     * gotchipusFacet: 0xCE79969840ef7A9C475B1571d1566a1a94e3b734, 
     * ownershipFacet: 0x3DF34B0F925484E48B31597Cf16B1E21bd576E95, 
     * erc6551AccountFacet: 0xFB574752A611781b33580DEb3A2FAfB590699987, 
     * erc6551RegistryFacet: 0x860ab36539277B16cb37A4668a3A64b9135D2ADc, 
     * attributesFacet: 0x788148eA4F59659657796579b9648f5F8202521c, 
     * dnaFacet: 0x33dD4Ecb1d76077144035cd41CB01ac3048a3Cd7, 
     * hooksFacet: 0x1f3a6f9369b70Ac9953efe60a55cfc9C5aF229ed, 
     * mockMarineFarmFacet: 0x9674d64375944ae675D624863d5053FaE05f69fc 
     * 
     */

    function deploy(address owner) public returns (Deployment memory) {
        vm.startBroadcast();

        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        DiamondLoupeFacet diamondLoupeFacet = new DiamondLoupeFacet();
        OwnershipFacet ownershipFacet = new OwnershipFacet();
        InitDiamond initDiamond = new InitDiamond();
        GotchipusFacet gotchipusFacet = new GotchipusFacet();
        ERC6551AccountFacet erc6551AccountFacet = new ERC6551AccountFacet();
        ERC6551RegistryFacet erc6551RegistryFacet = new ERC6551RegistryFacet();
        AttributesFacet attributesFacet = new AttributesFacet();
        DNAFacet dnaFacet = new DNAFacet();
        HooksFacet hooksFacet = new HooksFacet();
        MockMarineFarmFacet mockMarineFarmFacet = new MockMarineFarmFacet();

        Diamond diamond = new Diamond(owner, address(diamondCutFacet), address(diamondLoupeFacet), address(ownershipFacet));

        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](7);
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
            facetAddress: address(erc6551AccountFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors("ERC6551AccountFacet")
        });
        facetCuts[4] = IDiamondCut.FacetCut({
            facetAddress: address(erc6551RegistryFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors("ERC6551RegistryFacet")
        });
        facetCuts[5] = IDiamondCut.FacetCut({
            facetAddress: address(attributesFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors("AttributesFacet")
        });        
        facetCuts[6] = IDiamondCut.FacetCut({
            facetAddress: address(dnaFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors("DNAFacet")
        });

        InitDiamond.Args memory initArgs = InitDiamond.Args({
            name: "GotchipusNFT",
            symbol: "GTP",
            baseUri: "https://gotchipus.com/metadata/",
            createUtcHour: 0
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
            erc6551AccountFacet: erc6551AccountFacet,
            erc6551RegistryFacet: erc6551RegistryFacet,
            attributesFacet: attributesFacet,
            dnaFacet: dnaFacet,
            hooksFacet: hooksFacet,
            mockMarineFarmFacet: mockMarineFarmFacet
        });
    }

    function getSelectors(string memory facetName) internal pure returns (bytes4[] memory) {
        bytes4[] memory selectors;

        if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("GotchipusFacet"))) {
            selectors = new bytes4[](19);
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
        } else if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("ERC6551AccountFacet"))) {
            selectors = new bytes4[](7);
            selectors[0] = ERC6551AccountFacet.state.selector;
            selectors[1] = ERC6551AccountFacet.accountOwner.selector;
            selectors[2] = ERC6551AccountFacet.token.selector;
            selectors[3] = ERC6551AccountFacet.execute.selector;
            selectors[4] = ERC6551AccountFacet.isValidSignature.selector;
            selectors[5] = ERC6551AccountFacet.isValidSigner.selector;
        } else if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("ERC6551RegistryFacet"))) {
            selectors = new bytes4[](2);
            selectors[0] = ERC6551RegistryFacet.account.selector;
            selectors[1] = ERC6551RegistryFacet.createAccount.selector;
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
        }

        return selectors;
    }
}