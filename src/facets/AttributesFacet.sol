// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { Modifier, GotchipusInfo } from "../libraries/LibAppStorage.sol";

contract AttributesFacet is Modifier {
    event SetName(string indexed newName);
    
    function pet(uint256 gotchipusTokenId) external {
        require(uint256(s.lastPetTime[gotchipusTokenId]) + 1 days <= block.timestamp, "gotchipus already pet");
        s.lastPetTime[gotchipusTokenId] = uint32(block.timestamp);

        GotchipusInfo storage pus = s.ownedGotchipusInfos[msg.sender][gotchipusTokenId];
        uint8 bond = bonding(gotchipusTokenId);
        pus.bonding = (bond + 20 >= type(uint8).max) ? type(uint8).max : bond + 20;
        pus.growth = (pus.growth + 20 >= type(uint32).max) ? type(uint32).max : pus.growth + 20;
    }

    function feed(uint256 gotchipusTokenId) external {
        require(uint256(s.lastFeedTime[gotchipusTokenId]) + 3 hours <= block.timestamp, "gotchipus already feed");
        s.lastFeedTime[gotchipusTokenId] = uint32(block.timestamp);

        GotchipusInfo storage pus = s.ownedGotchipusInfos[msg.sender][gotchipusTokenId];
        uint8 bond = bonding(gotchipusTokenId);
        pus.bonding = (bond + 50 >= type(uint8).max) ? type(uint8).max : bond + 50;
        pus.growth = (pus.growth + 50 >= type(uint32).max) ? type(uint32).max : pus.growth + 50;
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

    function bonding(uint256 gotchipusTokenId) public view returns (uint8 bond) {
        uint256 elapsedTime = block.timestamp - uint256(s.lastPetTime[gotchipusTokenId]);
        uint256 secondsInDay = elapsedTime % 1 days;
        bond = s.ownedGotchipusInfos[s.tokenOwners[gotchipusTokenId]][gotchipusTokenId].bonding - uint8(secondsInDay);
    }

    function growth(uint256 gotchipusTokenId) external view returns (uint32) {
        return s.ownedGotchipusInfos[s.tokenOwners[gotchipusTokenId]][gotchipusTokenId].growth;
    }

    function wisdom(uint256 gotchipusTokenId) external view returns (uint8) {
        return s.ownedGotchipusInfos[s.tokenOwners[gotchipusTokenId]][gotchipusTokenId].wisdom;
    }
        
    function aether(uint256 gotchipusTokenId) external view returns (uint32) {
        return s.ownedGotchipusInfos[s.tokenOwners[gotchipusTokenId]][gotchipusTokenId].aether;
    }

     
}