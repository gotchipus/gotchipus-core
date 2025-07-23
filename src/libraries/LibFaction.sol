// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { LibGotchiConstants } from "./LibGotchiConstants.sol";

library LibFaction {
    enum GotchiFaction {
        COMBAT,
        DEFENSE,
        TECHNOLOGY
    }

    enum GotchiAttributes {
        // combat
        FLAME,
        STORM,
        SHADOW,
        // defense
        ICE,
        EARTH,
        LIGHT,
        // technology
        LIGHTNING,
        WATER,
        VOID
    }

    function randomFaction(uint256 randomSeed) internal pure returns (uint8) {
        uint256 randomValue = randomSeed % 10000;

        if (randomValue < LibGotchiConstants.COMBAT_WEIGHT) {
            return uint8(GotchiFaction.COMBAT);
        } else if (randomValue < LibGotchiConstants.COMBAT_WEIGHT + LibGotchiConstants.DEFENSE_WEIGHT) {
            return uint8(GotchiFaction.DEFENSE);
        } else {
            return uint8(GotchiFaction.TECHNOLOGY);
        }
    }

    function randomAttributeByFaction(uint8 faction, uint256 randomSeed) internal pure returns (uint8) {
        require(LibGotchiConstants.FACTION_COUNT > faction, "LibFaction: Invalid faction name");

        uint256 randomValue = randomSeed % 3;

        if (faction == uint8(GotchiFaction.COMBAT)) {
            return uint8(randomValue);
        } else if (faction == uint8(GotchiFaction.DEFENSE)) {
            return uint8(3 + randomValue);
        } else {
            return uint8(6 + randomValue);
        }
    }

    function attributeMastery(uint8 rarity, uint256 randomSeed) internal pure returns (uint8 mastery_) {
        uint256 baseMastery = randomSeed % 2;
        mastery_ = uint8(baseMastery) + rarity;
    }

    function getFactionName(uint8 faction_) internal pure returns (string memory) {
        require(LibGotchiConstants.FACTION_COUNT > faction_, "LibFaction: Invalid faction name");
        if (faction_ == 0) return "COMBAT";
        if (faction_ == 1) return "DEFENSE";
        if (faction_ == 2) return "TECHNOLOGY";
        return "Unknown";
    }

    function getAttributesName(uint8 attr_) internal pure returns (string memory) {
        require(LibGotchiConstants.ATTRIBUTE_COUNT > attr_, "LibFaction: Invalid attribute name");
        if (attr_ == 0) return "FLAME";
        if (attr_ == 1) return "STORM";
        if (attr_ == 2) return "SHADOW";
        if (attr_ == 3) return "ICE";
        if (attr_ == 4) return "EARTH";
        if (attr_ == 5) return "LIGHT";
        if (attr_ == 6) return "LIGHTNING";
        if (attr_ == 7) return "WATER";
        if (attr_ == 8) return "VOID";
        return "Unknown";
    }
}