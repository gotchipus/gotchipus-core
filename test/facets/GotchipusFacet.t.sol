// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import "../utils/DiamondFixture.sol";
import { ALICE, MAX_TOTAL_SUPPLY } from "../utils/Constants.sol";
import { IERC721 } from "../../src/interfaces/IERC721.sol";
import { IERC721Metadata } from "../../src/interfaces/IERC721Metadata.sol";
import { IGotchipusFacet } from "../../src/interfaces/IGotchipusFacet.sol";
import { IERC6551Facet } from "../../src/interfaces/IERC6551Facet.sol";
import { IERC6551Account } from "../../src/interfaces/IERC6551Account.sol";

contract GotchipusFacetTest is DiamondFixture {
    uint256 price = 0.04 ether;

    function _doMint(uint256 amount) internal {
        IGotchipusFacet gotchi = IGotchipusFacet(address(diamond));
        uint256 payValue = amount * price;
        gotchi.mint{value: payValue}(amount);
    }

    function testGetName() public view {
        IERC721Metadata gotchi = IERC721Metadata(address(diamond));
        string memory name = gotchi.name();
        assertEq(name, "Gotchipus");
    }

    function testMint() public {
        vm.prank(ALICE);
        vm.deal(ALICE, 100 ether);

        IGotchipusFacet gotchi = IGotchipusFacet(address(diamond));
        uint256 amount = 10;

        _doMint(amount);
        for (uint256 i = 0; i < amount; i++) {
            assertEq(gotchi.ownerOf(i), ALICE);
        }
        
        uint256 totalSupply = gotchi.totalSupply();
        assertEq(totalSupply, amount);

        uint256 balance = gotchi.balanceOf(ALICE);
        assertEq(balance, amount);
    }

    function testMaxMint() public {
        vm.startPrank(ALICE);
        vm.deal(ALICE, 10000 ether);

        IGotchipusFacet gotchi = IGotchipusFacet(address(diamond));
        
        for (uint256 i = 0; i < MAX_TOTAL_SUPPLY; i++) {
            gotchi.mint{value: price}(1);
        }
        
        assertEq(gotchi.totalSupply(), MAX_TOTAL_SUPPLY);

        vm.expectRevert("MAX TOTAL SUPPLY");
        gotchi.mint{value: price}(1);
        assertEq(gotchi.totalSupply(), MAX_TOTAL_SUPPLY);
        
        vm.stopPrank();
    }

    function testWhitelistMint() public {
        address owner = address(this);

        vm.prank(owner);
        vm.deal(owner, 100 ether);

        IGotchipusFacet gotchi = IGotchipusFacet(address(diamond));
        address[] memory whitelists = new address[](1);
        whitelists[0] = address(2);
        bool[] memory bools = new bool[](1);
        bools[0] = true;

        gotchi.addWhitelist(whitelists, bools);
        
        vm.prank(address(2));
        gotchi.mint(1);

        assertEq(gotchi.balanceOf(address(2)), 1);
    }

    function testSummonGotchipus() public {
        vm.startPrank(ALICE);
        vm.deal(ALICE, 100 ether);

        _doMint(10);

        IGotchipusFacet.SummonArgs memory args = IGotchipusFacet.SummonArgs({
            gotchipusTokenId: 0,
            gotchiName: "Gotchi No.1",
            collateralToken: address(0),
            stakeAmount: 0.1 ether,
            utc: 0,
            story: "I'm Gotchi"
        });

        IGotchipusFacet(address(diamond)).summonGotchipus{value: 0.1 ether}(args);
        
        IERC6551Facet erc6551 = IERC6551Facet(address(diamond));
        IERC6551Account account = IERC6551Account(payable(erc6551.account(0)));
        address owner = account.owner();
        assertEq(owner, ALICE);
        assertEq(address(account).balance, 0.1 ether);

        vm.stopPrank();
    }
}