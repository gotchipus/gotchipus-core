// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { GotchipusInfo, SoulCore, AppStorage, LibAppStorage } from "./LibAppStorage.sol";
import { LibGotchiConstants } from "./LibGotchiConstants.sol";

library LibSoul {
    enum SoulState {
        DORMANT,
        CRITICAL,
        LOW,
        NORMRL,
        FULL
    }

    function initializeSoul(address stakeToken, uint256 stakeAmount) internal view returns (SoulCore memory sc) {
        uint32 soul;
        if (stakeToken == address(0)) {
            soul = uint32(stakeAmount * LibGotchiConstants.PHRS_TO_SOUL / 10**18);
        } else if (stakeToken == LibGotchiConstants.USDC) {
            soul = uint32(stakeAmount * LibGotchiConstants.USDC_TO_SOUL / 10**6);
        } else if (stakeToken == LibGotchiConstants.USDT) {
            soul = uint32(stakeAmount * LibGotchiConstants.USDT_TO_SOUL / 10**6);
        } else if (stakeToken == LibGotchiConstants.WETH) {
            soul = uint32(stakeAmount * LibGotchiConstants.WETH_TO_SOUL / 10**18);
        } else if (stakeToken == LibGotchiConstants.WBTC) {
            soul = uint32(stakeAmount * LibGotchiConstants.WBTC_TO_SOUL / 10**18);
        }

        sc = SoulCore({
            balance: soul,
            maxSoulCapacity: soul,
            lastSoulUpdate: uint32(block.timestamp),
            dormantSince: 4
        });
    }
    
    function getSoulStateName(uint8 state) internal pure returns (string memory) {
        if (state == 0) return "Dormant";
        if (state == 1) return "Critical";
        if (state == 2) return "Low";
        if (state == 3) return "Normrl";
        if (state == 4) return "Full";
        return "Unknown";
    }
}