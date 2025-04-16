// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { Modifier } from "../libraries/LibAppStorage.sol";
import { IHook } from "../interfaces/IHook.sol";

contract MockMarineFarmFacet is Modifier {
    error HookFailed();

    function claimFish() external returns (bool) {
        s.ownedFish[msg.sender] += 100;
        return true;
    }

    function breed(uint256 amount) external returns (bool) {
        s.ownedFish[msg.sender] -= amount;
        s.breedFish[msg.sender] += amount;
        return true;
    }

    function harvest(address afterHarvest, bytes calldata data) external returns (bool) {
        uint256 oldBreedFish = s.breedFish[msg.sender];
        uint256 harvestFish = oldBreedFish * 2;
        s.breedFish[msg.sender] = 0;
        s.ownedFish[msg.sender] += harvestFish;

        uint256 extraFish = 0;
        if (afterHarvest != address(0)) {
            (bool success, bytes memory result) = afterHarvest.call(abi.encodeCall(IHook.afterHarvest, (msg.sender, oldBreedFish, data)));
            if (!success) revert HookFailed();
            (, uint256 hookExtraFish) = abi.decode(result, (bool, uint256));
            extraFish = hookExtraFish;
            s.ownedFish[msg.sender] += extraFish;
        }

        return true;
    }

    function getFishs(address sender) external view returns (uint256) {
        return s.ownedFish[sender];
    }
}