// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { GotchipusInfo, GotchipusCore, SoulCore, AppStorage, LibAppStorage } from "./LibAppStorage.sol";
import { LibGotchiConstants } from "./LibGotchiConstants.sol";
import { LibExperience } from "./LibExperience.sol";
import { LibSoul } from "./LibSoul.sol";
import { LibDynamicStates } from "../libraries/LibDynamicStates.sol";

library LibAttributes {

    function initializeAttribute(address sender, uint256 tokenId, uint8 rarity, address stakeToken, uint256 stakeAmount) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        GotchipusInfo storage info = s.ownedGotchipusInfos[sender][tokenId];
        
        uint16 point = LibExperience.calculateSkillPoints(rarity, 0);
        uint32 strength;
        uint32 defense;
        uint32 mind;
        uint32 vitality;
        uint32 agility;
        uint32 luck;

        if (rarity == 0) {
            (strength, defense, mind, vitality, agility, luck) = (1200, 1200, 1200, 1200, 1200, 1200);
        } else if (rarity == 1) {
            (strength, defense, mind, vitality, agility, luck) = (1500, 1500, 1500, 1500, 1500, 1500);
        } else if (rarity == 2) {
            (strength, defense, mind, vitality, agility, luck) = (1800, 1800, 1800, 1800, 1800, 1800);
        } else if (rarity == 3) {
            (strength, defense, mind, vitality, agility, luck) = (2200, 2200, 2200, 2200, 2200, 2200);
        }

        info.core = GotchipusCore({
            experience: 0,
            level: 1,
            evolution: 0,
            availablePoints: point,
            strength: strength,
            defense: defense,
            mind: mind,
            vitality: vitality,
            agility: agility,
            luck: luck,
            soul: LibSoul.initializeSoul(stakeToken, stakeAmount)
        });

        info.states = LibDynamicStates.initializeStates(vitality);
    }

    function calculateAttribute(address sender, uint256 tokenId) internal view returns (uint32[6] memory) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        GotchipusInfo storage info = s.ownedGotchipusInfos[sender][tokenId];
        uint32 strength = info.core.strength;
        uint32 defense = info.core.defense;
        uint32 mind = info.core.mind;
        uint32 vitality = info.core.vitality;
        uint32 agility = info.core.agility;
        uint32 luck = info.core.luck;

        uint8 faction = info.faction.primaryFaction;

        if (faction == 0) {
            uint16[6] memory bonus = info.spec.combatBonus;
            strength += (strength * bonus[0] / LibGotchiConstants.ATTRIBUTE_PRECISION);
            agility += (agility * bonus[4] / LibGotchiConstants.ATTRIBUTE_PRECISION);
        } else if (faction == 1) {
            uint16[6] memory bonus = info.spec.defenseBonus;
            defense += (defense * bonus[1] / LibGotchiConstants.ATTRIBUTE_PRECISION);
            vitality += (vitality * bonus[3] / LibGotchiConstants.ATTRIBUTE_PRECISION);
        } else if (faction == 2) {
            uint16[6] memory bonus = info.spec.technologyBonus;
            mind += (mind * bonus[2] / LibGotchiConstants.ATTRIBUTE_PRECISION);
            luck += (luck * bonus[5] / LibGotchiConstants.ATTRIBUTE_PRECISION);
        }

        return [strength, defense, mind, vitality, agility, luck];
    }
}