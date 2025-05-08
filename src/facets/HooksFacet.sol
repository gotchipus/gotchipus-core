// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { Modifier } from "../libraries/LibAppStorage.sol";
import { LibHooks } from "../libraries/LibHooks.sol";
import { IHook } from "../interfaces/IHook.sol";

contract HooksFacet is Modifier {
    function addHook(uint256 tokenId, IHook.GotchiEvent eventType, IHook hook) external onlyGotchipusOwner(tokenId) {
        require(!s.isValidHook[tokenId][address(hook)], "HooksFacet: Hook already exists");

        s.tokenHooksByEvent[tokenId][eventType].push(address(hook));
        s.isValidHook[tokenId][address(hook)] = true;
    }

    function removeHook(uint256 tokenId, IHook.GotchiEvent eventType, IHook hook) external onlyGotchipusOwner(tokenId) {
        require(s.isValidHook[tokenId][address(hook)], "HooksFacet: Hook not found");

        s.isValidHook[tokenId][address(hook)] = false;
        address[] storage hooks = s.tokenHooksByEvent[tokenId][eventType];
        uint256 len = hooks.length;
        for (uint256 i = 0; i < len; i++) {
            if (hooks[i] == address(hook)) {
                hooks[i] = hooks[len-1];
                hooks.pop();
                return;
            }
        }
    }

    function getHooks(uint256 tokenId, IHook.GotchiEvent eventType) external view returns (address[] memory hooks) {
        hooks = s.tokenHooksByEvent[tokenId][eventType];
    }
}