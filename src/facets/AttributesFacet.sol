// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { Modifier, GotchipusInfo } from "../libraries/LibAppStorage.sol";
import { LibAttributes } from "../libraries/LibAttributes.sol";
import { LibDynamicStates } from "../libraries/LibDynamicStates.sol";

contract AttributesFacet is Modifier {
    event SetName(string indexed newName);
    event Pet(uint256 indexed gotchiTokenId);

    function pet(uint256 gotchipusTokenId) external {
        require(uint256(s.lastPetTime[gotchipusTokenId]) + 1 days <= block.timestamp, "gotchipus already pet");
        s.lastPetTime[gotchipusTokenId] = uint32(block.timestamp);

        GotchipusInfo storage pus = s.ownedGotchipusInfos[msg.sender][gotchipusTokenId];
        pus.core.experience = (pus.core.experience + 20 >= type(uint32).max) ? type(uint32).max : pus.core.experience + 20;
        pus.states.health = (pus.states.health + 20 >= type(uint8).max) ? type(uint8).max : pus.states.health + 20;
        pus.states.energy = (pus.states.energy + 20 >= type(uint8).max) ? type(uint8).max : pus.states.energy + 20;
        pus.states.morale = (pus.states.morale + 20 >= type(uint8).max) ? type(uint8).max : pus.states.morale + 20;
        pus.states.focus = (pus.states.focus + 20 >= type(uint8).max) ? type(uint8).max : pus.states.focus + 20;
        pus.states.lastInteraction = uint32(block.timestamp);
        pus.states.currentMood = LibDynamicStates.GotchiMood.HAPPY;
        pus.leveling.currentExp += 20;
        pus.leveling.totalExp += 20;
        pus.leveling.interactionExp += 20;
        pus.leveling.lastExpGain = uint32(block.timestamp);

        emit Pet(gotchipusTokenId);
    }     

    function setName(string calldata newName, uint256 gotchipusTokenId) external onlyGotchipusOwner(gotchipusTokenId) {
        s.ownedGotchipusInfos[msg.sender][gotchipusTokenId].name = newName;
        emit SetName(newName);
    }

    function getLastPetTime(uint256 tokenId) external view returns (uint32) {
        return s.lastPetTime[tokenId];
    }

    function getTokenName(uint256 gotchipusTokenId) external view returns (string memory) {
        return s.ownedGotchipusInfos[s.tokenOwners[gotchipusTokenId]][gotchipusTokenId].name;
    }

    function getAttributes(uint256 gotchiTokenId) external view returns (uint32[6] memory) {
        return LibAttributes.calculateAttribute(s.tokenOwners[gotchiTokenId], gotchiTokenId);
    }
}