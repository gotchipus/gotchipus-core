// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { Permissions, AppStorage, LibAppStorage } from "./LibAppStorage.sol";
import { IHook } from "../interfaces/IHook.sol";

library LibHooks {
    using LibHooks for IHook;

    error HookAddressNotValid(address hook);
    error HookCallFailed();


    function validateHookPermissions(IHook self, Permissions memory permissions) internal pure returns (bool) {
        return true;
    }

    function isValidHookAddress(address hook) internal view returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.isValidHook[msg.sender][hook];
    }
}