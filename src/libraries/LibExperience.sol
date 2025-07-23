// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { LibGotchiConstants } from "./LibGotchiConstants.sol";

library LibExperience {

    function sqrt(uint32 x) internal pure returns (uint32 y) {
        if (x == 0) return 0;

        uint32 z = (x + 1) / 2;
        y = x;

        while (z < y) {
            y = z;
            z = (x / z + z) /2;
        }
    }

    function power15(uint32 x) internal pure returns (uint32) {
        if (x == 0) return 0;
        if (x == 1) return 1;

        uint32 base = sqrt(x);
        uint32 baseSquared = base * base;

        if (baseSquared == x) {
            return x * base;
        }

        uint32 nextBase = base + 1;
        uint32 nextSquared = nextBase * nextBase;

        if (x < nextSquared) {
            uint256 basePower15 = baseSquared * base;
            uint256 nextPower15 = nextSquared * nextBase;

            uint256 ratio = ((x - baseSquared) * LibGotchiConstants.PRECISION) / (nextSquared - baseSquared);
            uint256 interpolated = basePower15 + ((nextPower15 - basePower15) * ratio) / LibGotchiConstants.PRECISION;
            
            return uint32(interpolated);
        }

        return x * base;
    }

    function calculateRequiredExp(uint16 level) internal pure returns (uint32) {
        require(level <= LibGotchiConstants.MAX_LEVEL, "LibExperience: Invalid level");

        if (level == 1) return 0;

        // XP = (OFFSET + STEP * level)^1.5
        uint32 base = LibGotchiConstants.BASE_OFFSET + LibGotchiConstants.EXP_STEP * level;
        uint32 result = power15(base);
        return result;
    }

    function calculateLevelFromExp(uint32 currentExp) internal pure returns (uint16) {
        if (currentExp == 0) return 1;
        
        uint32 accumulatedExp = 0;
        
        for (uint16 level = 2; level <= LibGotchiConstants.MAX_LEVEL; level++) {
            uint32 requiredExp = calculateRequiredExp(level);
            
            if (accumulatedExp + requiredExp > currentExp) {
                return level - 1;
            }
            
            accumulatedExp += requiredExp;
        }
        
        return LibGotchiConstants.MAX_LEVEL;
    }
}