// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { AppStorage, LibAppStorage } from "./LibAppStorage.sol";
import { IHook } from "../interfaces/IHook.sol";
import { CustomRevert } from "./CustomRevert.sol";


library LibHooks {
    using LibHooks for IHook;
    using CustomRevert for bytes4;

    bytes4 internal constant HOOK_SUCCESS = bytes4(keccak256("HOOK_SUCCESS"));

    error HookPermissionsNotValid(address hook);
    error HookCallFailed();
    error InvalidHookResponse();

    event HookExecuted(uint256 indexed tokenId, address indexed hook, IHook.GotchiEvent eventType, bool success);
    event HookExecutionFailed(uint256 indexed tokenId, address indexed hook, IHook.GotchiEvent eventType, bytes reason);

    function validateHookPermissions(IHook hook, IHook.Permissions memory permissions) internal pure {
        IHook.Permissions memory actualPermissions = hook.getHookPermissions();
        
        if ((permissions.beforeExecute && !actualPermissions.beforeExecute) || 
            (permissions.afterExecute && !actualPermissions.afterExecute)) {
            HookPermissionsNotValid.selector.revertWith(address(hook));
        }
        
        if (!actualPermissions.beforeExecute && !actualPermissions.afterExecute) {
            HookPermissionsNotValid.selector.revertWith(address(hook));
        }
    }

    function isValidHookAddress(uint256 tokenId, IHook hook) internal view returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.isValidHook[tokenId][address(hook)];
    }

    function runHooks(uint256 tokenId, IHook.GotchiEvent eventType, IHook.HookParams memory params) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        address[] storage hooks = s.tokenHooksByEvent[tokenId][eventType];
        uint256 length = hooks.length;

        bytes4 functionSelector = eventType == IHook.GotchiEvent.BeforeExecute ? 
            IHook.beforeExecute.selector : 
            IHook.afterExecute.selector;

        for (uint256 i = 0; i < length; i++) {
            address hook = hooks[i];
            if (!s.isValidHook[tokenId][hook]) continue;

            try IHook(hook).beforeExecute(params) returns (bytes4 magic) {
                if (magic != HOOK_SUCCESS) revert InvalidHookResponse();
                emit HookExecuted(tokenId, hook, eventType, true);
            } catch (bytes memory reason) {
                emit HookExecutionFailed(tokenId, hook, eventType, reason);
                CustomRevert.bubbleUpAndRevertWith(hook, functionSelector, HookCallFailed.selector);
            }
        }
    }
}

