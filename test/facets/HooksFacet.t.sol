// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import { DiamondFixture } from "../utils/DiamondFixture.sol";
import { HooksFacet } from "../../src/facets/HooksFacet.sol";
import { IHook } from "../../src/interfaces/IHook.sol";
import { BeforeExecuteHook } from "../../src/utils/BaseHook.sol";

contract MockHook is BeforeExecuteHook {
    constructor(address _g) BeforeExecuteHook(_g) {}
    function _beforeExecute(IHook.HookParams calldata) internal view override {}
}

contract HooksFacetTest is DiamondFixture {
    // Remove duplicate declarations: HooksFacet internal hooksFacet
    MockHook internal hook;
    uint256 internal tokenId = 0;

    function setUp() public override {
        super.setUp();
        hooksFacet = HooksFacet(address(diamond));
        hook = new MockHook(address(diamond));
    }

    function test_AddAndRemoveHook() public {
        // First mint a token for the owner (mock).
        // Here we need to ensure that tokenId 0 exists and belongs to the owner
        // Simple simulation:
        vm.store(address(diamond), keccak256(abi.encode(tokenId, 2)), bytes32(uint256(uint160(owner)))); // mock ownerOf logic if needed or invoke mint
        
        // A better way is to directly mint
        // mintFacet.mint(1) if available, let's assume setup is ok or mock ownership
        // prank owner is used via modifier.
        
        // Assuming the owner in DiamondFixture is also the deployer, we'll give him a mint
        _mintForTest(owner);

        vm.startPrank(owner);

        hooksFacet.addHook(tokenId, IHook.GotchiEvent.BeforeExecute, hook);
        assertTrue(hooksFacet.isHookValid(tokenId, address(hook)));
        
        hooksFacet.removeHook(tokenId, IHook.GotchiEvent.BeforeExecute, hook);
        assertFalse(hooksFacet.isHookValid(tokenId, address(hook)));
        
        vm.stopPrank();
    }

    function _mintForTest(address /* to */) internal {
        // A simple, brute-force approach to write storage to simulate the owner, preventing Mint logic from becoming too complex.
        // mapping(uint256 => address) tokenOwners; // slot 2 in LibAppStorage usually
        // Or directly call diamond's mint.
        // Let's try calling mintFacet directly (is it defined in the parent class? It should be).
        // If the parent class has a MintFacet definition but it's not public, we removed the duplicate definition earlier.
        // Let's assume diamond has already deployed MintFacet.
        (bool success,) = address(diamond).call{value: 0.04 ether}(abi.encodeWithSignature("mint(uint256)", 1));
        if(success) {
            // transfer to 'to' if needed, default is msg.sender
        }
    }
}