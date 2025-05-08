// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { AppStorage, LibAppStorage } from "./LibAppStorage.sol";
import { IHook } from "../interfaces/IHook.sol";
import { CustomRevert } from "./CustomRevert.sol";

struct Permissions {
    bool onPet;
}

library LibHooks {
    using LibHooks for IHook;
    using CustomRevert for bytes4;

    error HookPermissionsNotValid(address hook);
    error HookCallFailed();
    error InvalidHookResponse();

    function validateHookPermissions(IHook hook, Permissions memory permissions) internal pure {
        if (!permissions.onPet) {
            HookPermissionsNotValid.selector.revertWith(address(hook));
        }
    }

    function isValidHookAddress(uint256 tokenId, IHook hook) internal view returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.isValidHook[tokenId][address(hook)];
    }

    function callHook(IHook hook, bytes memory data) internal returns (bytes memory result) {
        bool success;
        assembly {
            success := call(gas(), hook, 0, add(data, 0x20), mload(data), 0, 0)
        }

        if (!success) CustomRevert.bubbleUpAndRevertWith(address(hook), bytes4(data), HookCallFailed.selector);

        assembly {
            result := mload(0x40)
            mstore(0x40, add(result, and(add(returndatasize(), 0x3f), not(0x1f))))
            mstore(result, returndatasize())
            returndatacopy(add(result, 0x20), 0, returndatasize())
        }

        if (result.length < 32) {
            InvalidHookResponse.selector.revertWith();
        }

    }
}