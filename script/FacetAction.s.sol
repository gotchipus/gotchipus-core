// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import { Script } from "forge-std/Script.sol";
import { FacetSelectors } from "../test/utils/FacetSelectors.sol";
import { GotchipusFacet } from "../src/facets/GotchipusFacet.sol";
import { SvgFacet } from "../src/facets/SvgFacet.sol";
import { Diamond } from "../src/Diamond.sol";
import { IDiamondCut } from "../src/interfaces/IDiamondCut.sol";
import { GotchiWearableFacet } from "../src/facets/GotchiWearableFacet.sol";
import { TimeFacet } from "../src/facets/TimeFacet.sol";
import { AttributesFacet } from "../src/facets/AttributesFacet.sol";

contract FacetAction is Script {
    function run() external {
        action();
    }

    function action() public {
        vm.startBroadcast();

        GotchipusFacet gotchipusFacet = new GotchipusFacet();
        AttributesFacet attributesFacet = new AttributesFacet();
        // SvgFacet svgFacet = new SvgFacet();
        // GotchiWearableFacet gotchiWearableFacet = new GotchiWearableFacet();
        // TimeFacet timeFacet = new TimeFacet();
        Diamond diamond = Diamond(payable(0x0000000038f050528452D6Da1E7AACFA7B3Ec0a8));

        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](2);
        bytes4[] memory newSelectors = new bytes4[](1);
        newSelectors[0] = GotchipusFacet.getGotchiOrPharosInfo.selector;

        facetCuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(gotchipusFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: newSelectors
        });

        bytes4[] memory attributesToAdd = new bytes4[](1);
        attributesToAdd[0] = AttributesFacet.getLastPetTime.selector;
        facetCuts[1] = IDiamondCut.FacetCut({
            facetAddress: address(attributesFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: attributesToAdd
        });
        
        // bytes4[] memory svgToReplace = new bytes4[](1);
        // svgToReplace[0] = SvgFacet.getGotchipusSvg.selector;
        // facetCuts[0] = IDiamondCut.FacetCut({
        //     facetAddress: address(gotchipusFacet),
        //     action: IDiamondCut.FacetCutAction.Replace,
        //     functionSelectors: FacetSelectors.getSelectors("GotchipusFacet")
        // });
        // bytes4[] memory wearableToReplace = new bytes4[](1);
        // wearableToReplace[0] = GotchiWearableFacet.simpleEquipWearable.selector;

        // facetCuts[0] = IDiamondCut.FacetCut({
        //     facetAddress: address(gotchiWearableFacet),
        //     action: IDiamondCut.FacetCutAction.Replace,
        //     functionSelectors: wearableToReplace
        // });

        // bytes4[] memory wearableToReplace = new bytes4[](1);
        // wearableToReplace[0] = GotchiWearableFacet.claimWearable.selector;

        // facetCuts[0] = IDiamondCut.FacetCut({
        //     facetAddress: address(gotchiWearableFacet),
        //     action: IDiamondCut.FacetCutAction.Replace,
        //     functionSelectors: wearableToReplace
        // });
        // facetCuts[2] = IDiamondCut.FacetCut({
        //     facetAddress: address(timeFacet),
        //     action: IDiamondCut.FacetCutAction.Add,
        //     functionSelectors: FacetSelectors.getSelectors("TimeFacet")
        // });

        IDiamondCut(address(diamond)).diamondCut(facetCuts, address(0), "");

        vm.stopBroadcast();
    }
}