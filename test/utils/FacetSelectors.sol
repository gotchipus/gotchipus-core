// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import { GotchipusFacet } from "../../src/facets/GotchipusFacet.sol";
import { AttributesFacet } from "../../src/facets/AttributesFacet.sol";
import { DNAFacet } from "../../src/facets/DNAFacet.sol";
import { HooksFacet } from "../../src/facets/HooksFacet.sol";
import { ERC6551Facet } from "../../src/facets/ERC6551Facet.sol";
import { GotchiWearableFacet } from "../../src/facets/GotchiWearableFacet.sol";
import { SvgFacet } from "../../src/facets/SvgFacet.sol";
import { PaymasterFacet } from "../../src/facets/PaymasterFacet.sol";
import { TimeFacet } from "../../src/facets/TimeFacet.sol";

library FacetSelectors {
    function getSelectors(string memory facetName) internal pure returns (bytes4[] memory) {
        bytes4[] memory selectors;

        if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("GotchipusFacet"))) {
            selectors = new bytes4[](23);
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
            selectors[22] = GotchipusFacet.ownedTokenInfo.selector;
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
            selectors = new bytes4[](3);
            selectors[0] = HooksFacet.addHook.selector;
            selectors[1] = HooksFacet.getHooks.selector;
            selectors[2] = HooksFacet.removeHook.selector;
        } else if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("ERC6551Facet"))) {
            selectors = new bytes4[](2);
            selectors[0] = ERC6551Facet.account.selector;
            selectors[1] = ERC6551Facet.executeAccount.selector;
        } else if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("GotchiWearableFacet"))) {
            selectors = new bytes4[](13);
            selectors[0] = GotchiWearableFacet.wearableBalanceOf.selector;
            selectors[1] = GotchiWearableFacet.wearableBalanceOfBatch.selector;
            selectors[2] = GotchiWearableFacet.wearableUri.selector;
            selectors[3] = GotchiWearableFacet.setWearableUri.selector;
            selectors[4] = GotchiWearableFacet.setWearableBaseURI.selector;
            selectors[5] = GotchiWearableFacet.setWearableApprovalForAll.selector;
            selectors[6] = GotchiWearableFacet.wearableSafeTransferFrom.selector;
            selectors[7] = GotchiWearableFacet.wearableSafeBatchTransferFrom.selector;
            selectors[8] = GotchiWearableFacet.createWearable.selector;
            selectors[9] = GotchiWearableFacet.createBatchWearable.selector;
            selectors[10] = GotchiWearableFacet.setWearableDiamond.selector;
            selectors[11] = GotchiWearableFacet.equipWearable.selector;
            selectors[12] = GotchiWearableFacet.claimWearable.selector;
        } else if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("SvgFacet"))) {
            selectors = new bytes4[](1);
            // selectors[0] = SvgFacet.getSvg.selector;
            // selectors[1] = SvgFacet.getSliceSvgs.selector;
            // selectors[2] = SvgFacet.getSliceSvg.selector;
            // selectors[3] = SvgFacet.storeSvg.selector;
            // selectors[4] = SvgFacet.updateSvg.selector;
            selectors[0] = SvgFacet.getGotchipusSvg.selector;
        } else if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("PaymasterFacet"))) {
            selectors = new bytes4[](5);
            selectors[0] = PaymasterFacet.getNonce.selector;
            selectors[1] = PaymasterFacet.isExecutedTx.selector;
            selectors[2] = PaymasterFacet.isPaymaster.selector;
            selectors[3] = PaymasterFacet.addPaymaster.selector;
            selectors[4] = PaymasterFacet.execute.selector;
        } else if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("TimeFacet"))) {
            selectors = new bytes4[](2);
            selectors[0] = TimeFacet.getWeather.selector;
            selectors[1] = TimeFacet.updateWeather.selector;
        }

        return selectors;
    }
}