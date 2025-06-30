// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { IHook } from "../interfaces/IHook.sol";
import { LibHooks } from "../libraries/LibHooks.sol";

abstract contract BaseHook is IHook {
    address public immutable diamond;

    error NotDiamond();
    error HookNotImplemented();
    
    modifier onlyDiamond() {
        if (msg.sender != diamond) revert NotDiamond();
        _;
    }

    constructor(address _diamond) {
        diamond = _diamond;
        
        validateHookAddress(this);
    }

    function getHookPermissions() public pure virtual returns (IHook.Permissions memory);

    function validateHookAddress(BaseHook _this) internal pure virtual {
        LibHooks.validateHookPermissions(_this, getHookPermissions());
    }

    function beforeExecute(HookParams calldata params) external onlyDiamond returns (bytes4) {
        return _beforeExecute(params);
    }

    function _beforeExecute(HookParams calldata) internal virtual returns (bytes4) {
        revert HookNotImplemented();
    }

    function afterExecute(HookParams calldata params) external onlyDiamond returns (bytes4) {
        return _afterExecute(params);
    }

    function _afterExecute(HookParams calldata) internal virtual returns (bytes4) {
        revert HookNotImplemented();
    }
}