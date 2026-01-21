// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import { DiamondFixture } from "../utils/DiamondFixture.sol";
import { MintFacet } from "../../src/facets/MintFacet.sol";
import { GotchipusFacet } from "../../src/facets/GotchipusFacet.sol";
import { ERC6551Facet } from "../../src/facets/ERC6551Facet.sol"; 
import { IERC721 } from "../../src/interfaces/IERC721.sol";
import { LibGotchiConstants } from "../../src/libraries/LibGotchiConstants.sol";

contract MintFacetTest is DiamondFixture {
    MintFacet internal mintFacetBound;
    GotchipusFacet internal gotchipusFacetBound;
    ERC6551Facet internal erc6551FacetBound;

    function setUp() public override {
        super.setUp();
        mintFacetBound = MintFacet(address(diamond));
        gotchipusFacetBound = GotchipusFacet(address(diamond));
        // Bind the Diamond address to the ERC6551 Facet interface
        erc6551FacetBound = ERC6551Facet(address(diamond));
    }

    // Test whitelist casting (no payment required)
    function test_MintWhitelist() public {
        address user = address(0x10);
        
        // 1. Set whitelist
        address[] memory whitelist = new address[](1);
        whitelist[0] = user;
        bool[] memory status = new bool[](1);
        status[0] = true;
        
        vm.prank(owner);
        mintFacetBound.addWhitelist(whitelist, status);

        // 2. Mint
        vm.startPrank(user);
        mintFacetBound.mint(1);
        
        IERC721 token = IERC721(address(diamond));
        assertEq(token.balanceOf(user), 1);
        assertEq(token.ownerOf(0), user);
        vm.stopPrank();
    }

    // Test public minting (requires a fee of 0.04 ETH/unit)
    function test_MintPublic() public {
        address user = address(0x11);
        uint256 mintAmount = 2;
        uint256 price = LibGotchiConstants.PHAROS_PRICE;
        uint256 totalCost = price * mintAmount;

        // Send ETH to users
        vm.deal(user, 10 ether);

        vm.startPrank(user);
        
        // Record the balance before mint
        uint256 preBalance = user.balance;

        // Paid mint
        mintFacetBound.mint{value: totalCost}(mintAmount);

        // Verify that the balance deduction is correct
        assertEq(user.balance, preBalance - totalCost);

        // Verify the number of NFTs
        IERC721 token = IERC721(address(diamond));
        assertEq(token.balanceOf(user), mintAmount);
        
        vm.stopPrank();
    }

    // Test: Insufficient payment amount should result in failure
    function test_RevertIf_InsufficientETH() public {
        address user = address(0x12);
        uint256 mintAmount = 1;
        uint256 price = LibGotchiConstants.PHAROS_PRICE;

        vm.deal(user, 1 ether);
        vm.startPrank(user);

        // Try paying less than 0.04 ETH
        vm.expectRevert("Invalid value"); 
        mintFacetBound.mint{value: price - 0.01 ether}(mintAmount);

        vm.stopPrank();
    }

    // Test: Exceeding the maximum number of castings per batch (30) should result in failure
    function test_RevertIf_MaxPerMintExceeded() public {
        address user = address(0x13);
        uint256 maxPerMint = LibGotchiConstants.MAX_PER_MINT;
        uint256 mintAmount = maxPerMint + 1; // 31
        uint256 price = LibGotchiConstants.PHAROS_PRICE;

        vm.deal(user, 100 ether);
        vm.startPrank(user);

        vm.expectRevert("Invalid amount");
        mintFacetBound.mint{value: price * mintAmount}(mintAmount);

        vm.stopPrank();
    }

    // Testing Summon Logic
    function test_SummonGotchipus() public {
        address user = address(0x14);
        uint256 price = LibGotchiConstants.PHAROS_PRICE;
        
        vm.deal(user, 10 ether);
        vm.startPrank(user);
        
        // mint first
        mintFacetBound.mint{value: price}(1);
        uint256 tokenId = 0; // first ID

        // Prepare summon parameters
        MintFacet.SummonArgs memory args = MintFacet.SummonArgs({
            gotchipusTokenId: tokenId,
            gotchiName: "Hero",
            collateralToken: address(0), 
            stakeAmount: 0,
            utc: 8,
            story: bytes("Legend begins"),
            preIndex: 0
        });

        // Summon now
        mintFacetBound.summonGotchipus(args);

        // Verify summoning results: Modify to use erc6551FacetBound to call account
        address account = erc6551FacetBound.account(tokenId);
        assertTrue(account != address(0), "Account should be deployed");
        
        vm.stopPrank();
    }
}