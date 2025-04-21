// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IHook {
    // test function
    function afterHarvest(
        address user,
        uint256 breedFish,
        bytes calldata data
    ) external returns (bool success, uint256 extraFish);

    // test function
    function beforeHarvest(
        address user,
        uint256 breedFish,
        bytes calldata data
    ) external returns (bool success, uint256 extraFish);
}

