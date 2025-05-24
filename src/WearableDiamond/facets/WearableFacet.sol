// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { GotchiWearableFacet } from "../../facets/GotchiWearableFacet.sol";
import { WearableLibDiamond } from "../libraries/WearableLibDiamond.sol";
import { GotchipusFacet } from "../../facets/GotchipusFacet.sol";

contract WearableFacet {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);

    function gotchiWearableFacet() internal pure returns (GotchiWearableFacet gwFacet) {
        gwFacet = GotchiWearableFacet(WearableLibDiamond.GOTCHIPUS_DIAMOND);
    }

    function gotchipusFacet() internal pure returns (GotchipusFacet gFacet) {
        gFacet = GotchipusFacet(WearableLibDiamond.GOTCHIPUS_DIAMOND);
    }

    function balanceOf(address owner, uint256 tokenId) external view returns (uint256 bn) {
        bn = gotchiWearableFacet().wearableBalanceOf(owner, tokenId);
    }

    function balanceOfBatch(address[] calldata owners, uint256[] calldata tokenIds) external view returns (uint256[] memory bns) {
        bns = gotchiWearableFacet().wearableBalanceOfBatch(owners, tokenIds);
    }

    function uri(uint256 tokenId) external view returns (string memory) {
        return gotchiWearableFacet().wearableUri(tokenId);
    }

    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return gotchipusFacet().isApprovedForAll(owner, operator);
    }

    function setApprovalForAll(address operator, bool approved) external {
        gotchiWearableFacet().setWearableApprovalForAll(msg.sender, operator, approved);
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function setBaseURI(string memory baseUri) external {
        WearableLibDiamond.enforceIsContractOwner();
        gotchiWearableFacet().setWearableBaseURI(baseUri);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 value, bytes calldata data) external {
        gotchiWearableFacet().wearableSafeTransferFrom(msg.sender, from, to, tokenId, value, data);
        emit TransferSingle(msg.sender, from, to, tokenId, value);
    }

    function safeBatchTransferFrom(address from, address to, uint256[] calldata tokenIds, uint256[] calldata values, bytes calldata data) external {
        gotchiWearableFacet().wearableSafeBatchTransferFrom(msg.sender, from, to, tokenIds, values, data);
        emit TransferBatch(msg.sender, from, to, tokenIds, values);
    }

}