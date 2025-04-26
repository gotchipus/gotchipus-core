// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import "../utils/DiamondFixture.sol";
import { IERC721 } from "../../src/interfaces/IERC721.sol";
import { IERC721Metadata } from "../../src/interfaces/IERC721Metadata.sol";
import { IGotchipusFacet } from "../../src/interfaces/IGotchipusFacet.sol";
import { IERC6551Facet } from "../../src/interfaces/IERC6551Facet.sol";
import { IERC6551Account } from "../../src/interfaces/IERC6551Account.sol";

contract GotchipusFacetTest is DiamondFixture {
    uint256 price = 0.04 ether;

    function testGetName() public view {
        IERC721Metadata gotchi = IERC721Metadata(address(diamond));
        string memory name = gotchi.name();
        assertEq(name, "GotchipusNFT");
    }

    function testMint() public {
        vm.prank(address(1));
        vm.deal(address(1), 100 ether);
        IGotchipusFacet gotchi = IGotchipusFacet(address(diamond));

        uint256 amount = 10;
        uint256 payValue = amount * price;
        gotchi.mint{value: payValue}(10);
        
        assertEq(gotchi.ownerOf(0), address(1));
    }

    function testSummonGotchipus() public {
        vm.startPrank(address(1));
        vm.deal(address(1), 100 ether);
        IGotchipusFacet gotchi = IGotchipusFacet(address(diamond));

        uint256 amount = 10;
        uint256 payValue = amount * price;
        gotchi.mint{value: payValue}(10);
        
        assertEq(gotchi.ownerOf(0), address(1)); 

        IGotchipusFacet.SummonArgs memory args = IGotchipusFacet.SummonArgs({
            gotchipusTokenId: 0,
            pusName: "Gotchi No.1",
            collateralToken: address(0),
            stakeAmount: 0.1 ether,
            utc: 0
        });

        gotchi.summonGotchipus{value: 0.1 ether}(args);
        
        IERC6551Facet erc6551 = IERC6551Facet(address(diamond));
        IERC6551Account account = IERC6551Account(payable(erc6551.account(0)));
        address owner = account.owner();
        assertEq(owner, address(1));
        assertEq(address(account).balance, 0.1 ether);

        vm.stopPrank();
    }
}