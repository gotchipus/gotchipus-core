// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { AppStorage, LibAppStorage } from "./LibAppStorage.sol";
import { LibGotchiConstants } from "./LibGotchiConstants.sol";

library LibGotchiRarity {
    enum Rarity {
        COMMON,
        RARE,
        EPIC,
        LEGENDARY
    }

    function getRandomSeed(address sender, uint256 nonce) internal view returns (uint256 randomSeed) {
        randomSeed = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.prevrandao,
            sender,
            nonce,
            blockhash(block.number - 1)
        )));
    }

    function calculateRarity(address sender, uint256 randomSeed, uint256 stakingAmount) internal view returns (uint8) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint256 pityCount = s.summonPityCount[sender];
        if (pityCount >= 60) {
            return uint8(Rarity.LEGENDARY);
        } else if (pityCount >= 30) {
            return uint8(Rarity.EPIC);
        } else if (pityCount >= 15) {
            return uint8(Rarity.RARE);
        }

        // For every 500 tokens held, the legendary chance increases by 1%, up to a maximum of 5%.
        uint256 stakingBonus = (stakingAmount / 500) > 5 ? 5 : (stakingAmount / 500);

        uint16 adjustedLegendary = LibGotchiConstants.LEGENDARY_WEIGHT + uint16(stakingBonus) * 100;
        uint16 adjustedEpic = LibGotchiConstants.EPIC_WEIGHT;
        uint16 adjustedRare = LibGotchiConstants.RARE_WEIGHT;
        // uint16 adjustedCommon = 10000 - adjustedLegendary - adjustedEpic - adjustedRare;
        
        uint256 randomValue = randomSeed % 10000;

        if (randomValue < adjustedLegendary) {
            return uint8(Rarity.LEGENDARY);
        } else if (randomValue < adjustedLegendary + adjustedEpic) {
            return uint8(Rarity.EPIC);
        } else if (randomValue < adjustedLegendary + adjustedEpic + adjustedRare) {
            return uint8(Rarity.RARE);
        } else {
            return uint8(Rarity.COMMON);
        }
    } 
    
    function getRarityName(uint8 rarity_) internal pure returns (string memory) {
        if (rarity_ == 0) return "COMMON";
        if (rarity_ == 1) return "RARE";
        if (rarity_ == 2) return "EPIC";
        if (rarity_ == 3) return "LEGENDARY";
        return "Unknown";
    }

    function getRarityWeight(uint8 rarity_) internal pure returns (uint16) {
        if (rarity_ == 0) return LibGotchiConstants.COMMON_WEIGHT;
        if (rarity_ == 1) return LibGotchiConstants.RARE_WEIGHT;
        if (rarity_ == 2) return LibGotchiConstants.EPIC_WEIGHT;
        if (rarity_ == 3) return LibGotchiConstants.LEGENDARY_WEIGHT;
        return 0;
    }
}