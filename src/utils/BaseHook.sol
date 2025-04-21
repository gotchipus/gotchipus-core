// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { Permissions } from "../libraries/LibAppStorage.sol";
import { LibHooks } from "../libraries/LibHooks.sol";
import { IHook } from "../interfaces/IHook.sol";

abstract contract BaseHook is IHook {
    function getHookPermissions() public pure virtual returns (Permissions memory);

    function validateHookAddress(BaseHook _this) internal pure virtual {
        LibHooks.validateHookPermissions(_this, getHookPermissions());
    }
}