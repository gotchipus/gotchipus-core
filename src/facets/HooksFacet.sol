// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { Modifier } from "../libraries/LibAppStorage.sol";

contract HooksFacet is Modifier {
    function addHook(address hook) external {
        s.accountHooks[msg.sender].push(hook);
    }

    function getHooks(address sender) external view returns (address[] memory) {
        return s.accountHooks[sender];
    }
}