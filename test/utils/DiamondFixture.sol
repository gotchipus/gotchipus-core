// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import "forge-std/Test.sol";
import { Diamond } from "../../src/Diamond.sol";
import { InitDiamond } from "../../src/InitDiamond.sol";
import { DiamondCutFacet } from "../../src/facets/DiamondCutFacet.sol";
import { DiamondLoupeFacet } from "../../src/facets/DiamondLoupeFacet.sol";
import { GotchipusFacet } from "../../src/facets/GotchipusFacet.sol";
import { OwnershipFacet } from "../../src/facets/OwnershipFacet.sol";
import { ERC6551AccountFacet } from "../../src/facets/ERC6551AccountFacet.sol";
import { ERC6551RegistryFacet } from "../../src/facets/ERC6551RegistryFacet.sol";
import { AttributesFacet } from "../../src/facets/AttributesFacet.sol";
import { DNAFacet } from "../../src/facets/DNAFacet.sol";
import { HooksFacet } from "../../src/facets/HooksFacet.sol";
import { MockMarineFarmFacet } from "../../src/facets/MockMarineFarmFacet.sol";
import { IDiamondCut } from "../../src/interfaces/IDiamondCut.sol";
import { TraitsOffset } from "../../src/libraries/LibAppStorage.sol";


contract DiamondFixture is Test {
    Diamond           public diamond;
    InitDiamond       public initDiamond;
    DiamondCutFacet   public cutFacet;
    DiamondLoupeFacet public loupeFacet;
    GotchipusFacet    public gotchipusFacet;
    OwnershipFacet    public ownershipFacet;
    ERC6551AccountFacet  public erc6551AccountFacet;
    ERC6551RegistryFacet public erc6551RegistryFacet;
    AttributesFacet      public attributesFacet;
    DNAFacet             public dnaFacet;
    HooksFacet           public hooksFacet;
    MockMarineFarmFacet  public mockMarineFarmFacet;

    address internal owner = address(this);
    
    function setUp() public {
        cutFacet = new DiamondCutFacet();
        loupeFacet = new DiamondLoupeFacet();
        ownershipFacet = new OwnershipFacet();
        initDiamond = new InitDiamond();
        gotchipusFacet = new GotchipusFacet();
        erc6551AccountFacet = new ERC6551AccountFacet();
        erc6551RegistryFacet = new ERC6551RegistryFacet();
        attributesFacet = new AttributesFacet();
        dnaFacet = new DNAFacet();
        hooksFacet = new HooksFacet();
        mockMarineFarmFacet = new MockMarineFarmFacet();

        diamond = new Diamond(owner, address(cutFacet), address(loupeFacet), address(ownershipFacet));
        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](7);
        facetCuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(mockMarineFarmFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors("MockMarineFarmFacet")
        });
        facetCuts[1] = IDiamondCut.FacetCut({
            facetAddress: address(hooksFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors("HooksFacet")
        });
        facetCuts[2] = IDiamondCut.FacetCut({
            facetAddress: address(gotchipusFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors("GotchipusFacet")
        });
        facetCuts[3] = IDiamondCut.FacetCut({
            facetAddress: address(erc6551AccountFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors("ERC6551AccountFacet")
        });
        facetCuts[4] = IDiamondCut.FacetCut({
            facetAddress: address(erc6551RegistryFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors("ERC6551RegistryFacet")
        });
        facetCuts[5] = IDiamondCut.FacetCut({
            facetAddress: address(attributesFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors("AttributesFacet")
        });        
        facetCuts[6] = IDiamondCut.FacetCut({
            facetAddress: address(dnaFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: getSelectors("DNAFacet")
        });

        InitDiamond.Args memory initArgs = InitDiamond.Args({
            name: "GotchipusNFT",
            symbol: "GTP",
            baseUri: "https://gotchipus.com/metadata/",
            createUtcHour: 0,
            traitsOffset: getTraitsOffset()
        });
        bytes memory initCalldata = abi.encodeWithSelector(InitDiamond.init.selector, initArgs);

        IDiamondCut(address(diamond)).diamondCut(facetCuts, address(initDiamond), initCalldata);
    }

    function getTraitsOffset() internal pure returns (TraitsOffset[] memory) {
        uint256 traitsNumber = 26;
        TraitsOffset[] memory traitsOffset = new TraitsOffset[](traitsNumber);
        uint8[26] memory widths = [uint8(3), 1, 4, 4, 1, 4, 1, 4, 1, 4, 4, 1, 4, 4, 1, 4, 4, 1, 4, 4, 4, 4, 4, 4, 4, 4];
        uint8 offset = 0;

        for (uint256 i = 0; i < traitsNumber; i++) {
            traitsOffset[i] = TraitsOffset({
                offset: offset,
                width: widths[i]
            });
            offset += widths[i];
        }

        return traitsOffset;
    }

    function getSelectors(string memory facetName) internal pure returns (bytes4[] memory) {
        bytes4[] memory selectors;

        if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("GotchipusFacet"))) {
            selectors = new bytes4[](20);
            selectors[0] = GotchipusFacet.balanceOf.selector;
            selectors[1] = GotchipusFacet.ownerOf.selector;
            selectors[2] = GotchipusFacet.totalSupply.selector;
            selectors[3] = GotchipusFacet.tokenByIndex.selector;
            selectors[4] = GotchipusFacet.tokenOfOwnerByIndex.selector;
            selectors[5] = GotchipusFacet.allTokensOfOwner.selector;
            selectors[6] = GotchipusFacet.name.selector;
            selectors[7] = GotchipusFacet.symbol.selector;
            selectors[8] = GotchipusFacet.tokenURI.selector;
            selectors[9] = GotchipusFacet.getApproved.selector;
            selectors[10] = GotchipusFacet.isApprovedForAll.selector;
            selectors[11] = bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes)"));
            selectors[12] = bytes4(keccak256("safeTransferFrom(address,address,uint256)"));
            selectors[13] = GotchipusFacet.transferFrom.selector;
            selectors[14] = GotchipusFacet.approve.selector;
            selectors[15] = GotchipusFacet.setApprovalForAll.selector;
            selectors[16] = GotchipusFacet.setBaseURI.selector;
            selectors[17] = GotchipusFacet.mint.selector;
            selectors[18] = GotchipusFacet.burn.selector;
            selectors[19] = GotchipusFacet.testMint.selector;
        } else if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("ERC6551AccountFacet"))) {
            selectors = new bytes4[](6);
            selectors[0] = ERC6551AccountFacet.state.selector;
            selectors[1] = ERC6551AccountFacet.accountOwner.selector;
            selectors[2] = ERC6551AccountFacet.token.selector;
            selectors[3] = ERC6551AccountFacet.execute.selector;
            selectors[4] = ERC6551AccountFacet.isValidSignature.selector;
            selectors[5] = ERC6551AccountFacet.isValidSigner.selector;
        } else if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("ERC6551RegistryFacet"))) {
            selectors = new bytes4[](2);
            selectors[0] = ERC6551RegistryFacet.account.selector;
            selectors[1] = ERC6551RegistryFacet.createAccount.selector;
        } else if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("AttributesFacet"))) {
            selectors = new bytes4[](8);
            selectors[0] = AttributesFacet.aether.selector;
            selectors[1] = AttributesFacet.bonding.selector;
            selectors[2] = AttributesFacet.feed.selector;
            selectors[3] = AttributesFacet.getTokenName.selector;
            selectors[4] = AttributesFacet.growth.selector;
            selectors[5] = AttributesFacet.pet.selector;
            selectors[6] = AttributesFacet.setName.selector;
            selectors[7] = AttributesFacet.wisdom.selector;
        } else if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("DNAFacet"))) {
            selectors = new bytes4[](4);
            selectors[0] = DNAFacet.getGene.selector;
            selectors[1] = DNAFacet.ruleVersion.selector;
            selectors[2] = DNAFacet.setRuleVersion.selector;
            selectors[3] = DNAFacet.tokenGeneSeed.selector;
        } else if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("HooksFacet"))) {
            selectors = new bytes4[](2);
            selectors[0] = HooksFacet.addHook.selector;
            selectors[1] = HooksFacet.getHooks.selector;
        } else if (keccak256(abi.encodePacked(facetName)) == keccak256(abi.encodePacked("MockMarineFarmFacet"))) {
            selectors = new bytes4[](4);
            selectors[0] = MockMarineFarmFacet.breed.selector;
            selectors[1] = MockMarineFarmFacet.claimFish.selector;
            selectors[2] = MockMarineFarmFacet.getFishs.selector;
            selectors[3] = MockMarineFarmFacet.harvest.selector;
        }

        return selectors;
    }
}
