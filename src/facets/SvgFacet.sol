// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { AppStorage, Modifier } from "../libraries/LibAppStorage.sol";
import { LibSvg } from "../libraries/LibSvg.sol";
import { LibStrings } from "../libraries/LibStrings.sol";

contract SvgFacet is Modifier {
    function getSvg(bytes32 svgType, uint256 id) external view returns (string memory svg) {
        address svgLayerContract = s.svgLayers[svgType][id].svgLayerContract;
        svg = string(LibSvg.readSvg(svgLayerContract));
    }

    function getSliceSvgs(bytes32 svgType, uint256[] calldata ids) external view returns (string[] memory svgs) {
        uint256 len = ids.length;
        svgs = new string[](len);
        for (uint256 i = 0; i < len; i++) {
            svgs[i] = string(LibSvg.sliceSvg(svgType, ids[i]));
        }
    }

    function getSliceSvg(bytes32 svgType, uint256 id) external view returns (string memory svg) {
        svg = string(LibSvg.sliceSvg(svgType, id));
    }

    function storeSvg(bytes calldata svg, LibSvg.SvgItem[] calldata svgItems) external onlyOwner {
        LibSvg.storeSvg(svg, svgItems);
    }

    function updateSvg(bytes calldata svg, LibSvg.SvgItem[] calldata svgItems) external onlyOwner {
        LibSvg.updateSvg(svg, svgItems);
    }
}