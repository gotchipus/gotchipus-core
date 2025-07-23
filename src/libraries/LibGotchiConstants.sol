// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

library LibGotchiConstants {
    uint256 constant PHAROS_PRICE = 0.04 ether;
    uint256 constant MAX_TOTAL_SUPPLY = 20000;
    uint256 constant TOTAL_GENES = 33000;
    uint8 constant MAX_PER_MINT = 30;
    
    uint32 constant BASE_EXP = 100;
    uint16 constant MAX_LEVEL = 999;
    uint8 constant MAX_EVOLUTION = 8;

    uint16 constant MAX_ATTRIBUTE = 800;
    uint16 constant BASE_ATTRIBUTE = 10;
    uint8 constant MAX_PURITY = 100;
    uint8 constant MAX_MASTERY = 20;

    uint8 constant MAX_STATE = 100;
    uint8 constant MIN_STATE = 0;
    int8 constant MAX_MODIFIER = 50;
    int8 constant MIN_MODIFIER = -50;
    uint32 constant HOUR = 3600;
    uint32 constant DAY = 86400;
    uint32 constant WEEK = 604800;
    uint8 constant HEALTH_DECAY_RATE = 1;   // 1.0 point/hour
    uint8 constant ENERGY_DECAY_RATE = 2;   // 2.0 point/hour  
    uint8 constant MORALE_DECAY_RATE = 2;   // 2.0 point/hour
    uint8 constant FOCUS_DECAY_RATE = 1;    // 1.0 point/hour

    uint8 constant FACTION_COUNT = 3;
    uint8 constant ATTRIBUTE_COUNT = 9;

    uint16 constant COMMON_WEIGHT = 6000;       // 60.00%
    uint16 constant RARE_WEIGHT = 2500;         // 25.00%
    uint16 constant EPIC_WEIGHT = 1200;         // 12.00%
    uint16 constant LEGENDARY_WEIGHT = 300;     // 3.00%

    uint16 constant COMBAT_WEIGHT = 3500;       // 35.00%
    uint16 constant DEFENSE_WEIGHT = 3300;      // 33.00%
    uint16 constant TECHNOLOGY_WEIGHT = 3200;   // 32.00%
}