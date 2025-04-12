// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IHook {
    function afterHarvest(
        address user,
        uint256 breedFish,
        bytes calldata data
    ) external returns (bool success, uint256 extraFish);
}