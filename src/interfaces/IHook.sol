// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;


interface IHook {
    struct HookParams {
        uint256 tokenId;
        address account;
        address caller;
        address to;
        uint256 value;
        bytes4 selector;
        bytes hookData;
        // afterExxcute
        bool success;
        bytes returnData;
    }

    struct Permissions {
        bool beforeExecute;
        bool afterExecute;
    }

    enum GotchiEvent {
        BeforeExecute,
        AfterExecute
    }
    
    /// @notice Returns the permissions that this hook has
    /// @return permissions A struct of boolean flags indicating which hooks are implemented
    function getHookPermissions() external pure returns (Permissions memory);

    /// @dev MUST return this value on success: bytes4(keccak256("HOOK_SUCCESS"))
    function beforeExecute(HookParams calldata params) external returns (bytes4);

    function afterExecute(HookParams calldata params) external returns (bytes4);
}

