// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { AppStorage, LibAppStorage } from "../libraries/LibAppStorage.sol";


library LibDna {
    event SetRuleVersion(uint8 indexed ruleVersion);

    uint256 constant TOTAL_GENES = 33000;

    function getRandomGene(bytes32 seed) internal pure returns (uint256) {
        return uint256(seed);
    }

    function getGene(uint256 gotchipusTokenId, uint256 index) internal view returns (uint256) {
        require(index < TOTAL_GENES, "Invalid gene index");

        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 geneSeed = s.ownedGotchipusInfos[s.tokenOwners[gotchipusTokenId]][gotchipusTokenId].dna.geneSeed;
        uint256 segment = index / 1000;
        uint256 offset = index % 1000;

        bytes32 subSeed = keccak256(abi.encodePacked(geneSeed, segment));
        for (uint256 i=0; i < offset; i++) {
            subSeed = keccak256(abi.encodePacked(subSeed));
        }
        
        return uint256(subSeed) % 10;
    }
}