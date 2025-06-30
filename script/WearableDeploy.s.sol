// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import { Script } from "forge-std/Script.sol";
import { WearableDiamond } from "../src/WearableDiamond/WearableDiamond.sol";
import { DiamondCutFacet } from "../src/facets/DiamondCutFacet.sol";
import { DiamondLoupeFacet } from "../src/facets/DiamondLoupeFacet.sol";
import { OwnershipFacet } from "../src/facets/OwnershipFacet.sol";
import { WearableFacet } from "../src/WearableDiamond/facets/WearableFacet.sol";
import { IDiamondCut } from "../src/interfaces/IDiamondCut.sol";

contract WearableDeploy is Script {
    function run() external {
        deploy();
    }

    /**
     * wearableDiamond 0x012FD852103Fe9AE0CE26F3610b506a226c2888a
     */

    function deploy() public {
        vm.startBroadcast();

        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        DiamondLoupeFacet diamondLoupeFacet = new DiamondLoupeFacet();
        OwnershipFacet ownershipFacet = new OwnershipFacet();
        WearableFacet wearableFacet = new WearableFacet();

        WearableDiamond wearableDiamond = new WearableDiamond(msg.sender, address(diamondCutFacet), address(diamondLoupeFacet), address(ownershipFacet));

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

        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](1);
        facetCuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(wearableFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: wearableFacetFunctions
        });

        IDiamondCut(address(wearableDiamond)).diamondCut(facetCuts, address(0), "");

        vm.stopBroadcast();
    }
}