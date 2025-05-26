// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { AppStorage, Modifier, SvgLayer } from "../libraries/LibAppStorage.sol";
import { LibSvg } from "../libraries/LibSvg.sol";
import { LibStrings } from "../libraries/LibStrings.sol";

contract SvgFacet is Modifier {
    function getGotchipusSvg(uint256 tokenId) external view returns (string memory gs) {
        address owner = s.tokenOwners[tokenId];
        uint8 status = s.ownedGotchipusInfos[owner][tokenId].status;
        bytes memory svg;
        if (status == 0) {
            bytes32 pharos = bytes32(abi.encodePacked("pharos"));
            address svgLayerContract = s.svgLayers[pharos][0].svgLayerContract;
            svg = LibSvg.readSvg(svgLayerContract);
        } else if (status == 1) {
            for (uint256 i = 0; i < LibSvg.MAX_BODY_NUM; i++) {
                uint8 index = s.gotchiTraitsIndex[tokenId][uint8(i)];
                bytes32 svgType = s.svgTypeBytes32[uint8(i)];
                svg = bytes.concat(svg, LibSvg.sliceSvg(svgType, index));
            }

            if (s.isAnyEquipWearable[tokenId]) {
                for (uint256 i = LibSvg.MAX_BODY_NUM; i < LibSvg.MAX_TRAITS_NUM; i++) {
                    if (s.isEquipWearableByIndex[tokenId][i]) {
                        uint8 index = s.gotchiTraitsIndex[tokenId][uint8(i)];
                        bytes32 svgType = s.svgTypeBytes32[uint8(i)];
                        svg = bytes.concat(svg, LibSvg.sliceSvg(svgType, index));
                    }
                }
            }
        }

        gs = string(abi.encodePacked('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 80 80">', svg, "</svg>"));
    }

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