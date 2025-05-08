// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;


interface IHook {
    enum GotchiEvent {
        OnPet
    }

    struct AttributeDelta {
        string name;
        int256 delta;
    }

    function onEvent(GotchiEvent eventType, uint256 tokenId, bytes calldata data) external returns (AttributeDelta memory delta);
}

