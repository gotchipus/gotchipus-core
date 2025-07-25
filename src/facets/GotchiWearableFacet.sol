// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { Modifier, WearableInfo, EquipWearableType } from "../libraries/LibAppStorage.sol";
import { LibStrings } from "../libraries/LibStrings.sol";
import { LibSvg } from "../libraries/LibSvg.sol";
import { LibERC1155 } from "../WearableDiamond/libraries/LibERC1155.sol";
import { IWearableFacet } from "../WearableDiamond/interfaces/IWearableFacet.sol";

contract GotchiWearableFacet is Modifier {
    event AddWearable(address indexed wearable);
    event WearableURI(uint256 indexed tokenId, string indexed wearableUri);

    function wearableBalanceOf(address owner, uint256 tokenId) public view returns (uint256 bn) {
        bn = s.ownerWearableBalances[owner][tokenId];
    }

    function wearableBalanceOfBatch(address[] calldata owners, uint256[] calldata tokenIds) external view returns (uint256[] memory) {
        require(owners.length == tokenIds.length, "ERC1155: owners and tokenIds length mismatch");

        uint256[] memory batchBalances = new uint256[](owners.length);
        for (uint256 i = 0; i < owners.length; i++) {
            batchBalances[i] = wearableBalanceOf(owners[i], tokenIds[i]);
        } 

        return batchBalances;
    }

    function wearableUri(uint256 tokenId) external view returns (string memory) {
        string memory tokenUri = s.wearableUri[tokenId];

        if (bytes(tokenUri).length == 0) {
            return string(abi.encodePacked(s.wearableBaseUri, LibStrings.uint2str(tokenId)));
        }
        
        return tokenUri;
    }

    function getWearableInfo(uint256 tokenId) external view returns (WearableInfo memory info_) {
        info_ = s.wearableInfo[tokenId];
    }

    function getAllEquipWearableType(uint256 gotchiTokenId) external view returns (EquipWearableType[] memory ew_) {
        address account = s.accountOwnedByTokenId[gotchiTokenId];
        ew_ = s.allOwnerEquipWearableType[account];
    }

    function getWearableDiamond() view external returns (address wd_) {
        wd_ = s.wearableDiamond;
    }

    function setWearableUri(uint256 tokenId, string memory tokenUri) external onlyOwner {
        s.wearableUri[tokenId] = tokenUri;
        emit WearableURI(tokenId, tokenUri);
    }

    function setWearableBaseURI(string memory baseUri) external onlyWearable {
        s.wearableBaseUri = baseUri;
    }

    function setWearableApprovalForAll(address owner, address operator, bool approved) external onlyWearable {
        s.operatorApprovals[owner][operator] = approved;
    }

    function wearableSafeTransferFrom(
        address operator, 
        address from, 
        address to, 
        uint256 tokenId, 
        uint256 value, 
        bytes calldata data
    ) external onlyWearable {
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            operator == from || s.operatorApprovals[from][operator],
            "ERC1155: caller is not owner nor approved"
        );

        LibERC1155.beforeTokenTransfer(operator, from, to, LibERC1155.asSingletonArray(tokenId), LibERC1155.asSingletonArray(value), data);

        uint256 fromBalance = s.ownerWearableBalances[from][tokenId];
        require(fromBalance >= value, "ERC1155: insufficient balance for transfer");
        s.ownerWearableBalances[from][tokenId] = fromBalance - value;
        s.ownerWearableBalances[to][tokenId] += value;

        LibERC1155.doSafeTransferAcceptanceCheck(operator, from, to, tokenId, value, data);
    }

    function wearableSafeBatchTransferFrom(
        address operator,
        address from, 
        address to, 
        uint256[] calldata tokenIds, 
        uint256[] calldata values, 
        bytes calldata data
    ) external onlyWearable {
        require(tokenIds.length == values.length, "ERC1155: tokenIds and values length mismatch");
        require(
            operator == from || s.operatorApprovals[from][operator],
            "ERC1155: transfer caller is not owner nor approved"
        );

        LibERC1155.beforeTokenTransfer(operator, from, to, tokenIds, values, data);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            uint256 value = values[i];

            uint256 fromBalance = s.ownerWearableBalances[from][tokenId];
            require(fromBalance >= value, "ERC1155: insufficient balance for transfer");
            s.ownerWearableBalances[from][tokenId] = fromBalance - value;
            s.ownerWearableBalances[to][tokenId] += value;
        }

        LibERC1155.doSafeBatchTransferAcceptanceCheck(operator, from, to, tokenIds, values, data);
    }

    function createWearable(string calldata tokenUri, WearableInfo calldata info) external onlyOwner {
        uint256 wearableTokenId = s.nextWearableTokenId;
        s.nextWearableTokenId++;
        s.wearableUri[wearableTokenId] = tokenUri;
        
        s.wearableInfo[wearableTokenId].name = info.name;
        s.wearableInfo[wearableTokenId].description = info.description;
        s.wearableInfo[wearableTokenId].author = info.author;
        s.wearableInfo[wearableTokenId].svgType = info.svgType;
        s.wearableInfo[wearableTokenId].svgId = uint8(wearableTokenId);
        emit WearableURI(wearableTokenId, tokenUri);
    }

    function createBatchWearable(string[] calldata tokenUris, WearableInfo[] calldata infos) external onlyOwner {
        for (uint256 i = 0; i < tokenUris.length; i++) {
            uint256 wearableTokenId = s.nextWearableTokenId++;
            s.wearableUri[wearableTokenId] = tokenUris[i];

            s.wearableInfo[wearableTokenId].name = infos[i].name;
            s.wearableInfo[wearableTokenId].description = infos[i].description;
            s.wearableInfo[wearableTokenId].author = infos[i].author;
            s.wearableInfo[wearableTokenId].svgType = infos[i].svgType;
            s.wearableInfo[wearableTokenId].svgId = uint8(wearableTokenId);
            emit WearableURI(wearableTokenId, tokenUris[i]);
        }
    }

    function setWearableDiamond(address wearable) external onlyOwner {
        s.wearableDiamond = wearable;
        emit AddWearable(wearable);
    }

    function equipWearable(uint256 gotchiTokenId, uint256 wearableTokenId) external onlyGotchipusOwner(gotchiTokenId) {
        require(s.ownerWearableBalances[msg.sender][wearableTokenId] > 0, "Wearable: Insufficient balance");
        require(s.accountOwnedByTokenId[gotchiTokenId] == msg.sender, "Wearable: Only TBA call");
        
        s.isEquipWearableByIndex[gotchiTokenId][wearableTokenId] = true;
        s.isAnyEquipWearable[gotchiTokenId] = true;
    }

    function simpleEquipWearable(uint256 gotchiTokenId, uint256 wearableTokenId, bytes32 wearableType) external {
        require(s.ownerWearableBalances[msg.sender][wearableTokenId] > 0, "Wearable: Insufficient balance");
        s.isEquipWearableByIndex[gotchiTokenId][wearableTokenId] = true;
        s.isAnyEquipWearable[gotchiTokenId] = true;

        address account = s.accountOwnedByTokenId[gotchiTokenId];
        s.ownerWearableBalances[msg.sender][wearableTokenId] -= 1;
        s.ownerWearableBalances[account][wearableTokenId] += 1;
        
        bool isEquip = s.isOwnerEquipWearable[account][wearableType];
        if (!isEquip) {
            s.allOwnerEquipWearableType[account].push(EquipWearableType({
                wearableType: wearableType,
                wearableId: wearableTokenId,
                equiped: true
            }));
            s.isOwnerEquipWearable[account][wearableType] = true;
        } else {
            uint256 typeIndex = getWearbaleTypeIndex(wearableType);
            EquipWearableType storage wearableToModify = s.allOwnerEquipWearableType[account][typeIndex];
            wearableToModify.wearableId = wearableTokenId;
        }

        uint8 svgTypeIndex;
        uint256 svgTypeOffset;
        if (wearableType == LibSvg.SVG_TYPE_HAND) {
            svgTypeIndex = 3;
            svgTypeOffset = 27;
        } else if (wearableType == LibSvg.SVG_TYPE_HEAD) {
            svgTypeIndex = 4;
            svgTypeOffset = 36;
        } else if (wearableType == LibSvg.SVG_TYPE_CLOTHES) {
            svgTypeIndex = 5;
            svgTypeOffset = 45;
        }
        
        uint8 svgIndex = uint8(wearableTokenId - svgTypeOffset);
        s.gotchiTraitsIndex[gotchiTokenId][svgTypeIndex] = svgIndex;
        s.allGotchiTraitsIndex[gotchiTokenId].push(svgIndex);

        if (!s.isOwnerEquipWearable[account][LibSvg.SVG_TYPE_BG]) {
            s.allOwnerEquipWearableType[account].push(EquipWearableType({
                wearableType: LibSvg.SVG_TYPE_BG,
                wearableId: s.gotchiTraitsIndex[gotchiTokenId][0],
                equiped: true
            }));
            s.isOwnerEquipWearable[account][LibSvg.SVG_TYPE_BG] = true;
        }

        if (!s.isOwnerEquipWearable[account][LibSvg.SVG_TYPE_BODY]) {
            s.allOwnerEquipWearableType[account].push(EquipWearableType({
                wearableType: LibSvg.SVG_TYPE_BODY,
                wearableId: s.gotchiTraitsIndex[gotchiTokenId][1] + 9,
                equiped: true
            }));
            s.isOwnerEquipWearable[account][LibSvg.SVG_TYPE_BODY] = true;
        }

        if (!s.isOwnerEquipWearable[account][LibSvg.SVG_TYPE_EYE]) {
            s.allOwnerEquipWearableType[account].push(EquipWearableType({
                wearableType: LibSvg.SVG_TYPE_EYE,
                wearableId: s.gotchiTraitsIndex[gotchiTokenId][2] + 18,
                equiped: true
            }));
            s.isOwnerEquipWearable[account][LibSvg.SVG_TYPE_EYE] = true;
        }      

        emit IWearableFacet.TransferSingle(msg.sender, msg.sender, account, wearableTokenId, 1);
    }

    function claimWearable() external ownedGotchi {
        for (uint256 i = 27; i < 54; i++) {
            s.ownerWearableBalances[msg.sender][i] += 1;
            emit IWearableFacet.TransferSingle(msg.sender, address(0), msg.sender, i, 1);
        }
    }

    function getWearbaleTypeIndex(bytes32 wearableType) internal pure returns (uint256) {
        if (wearableType == LibSvg.SVG_TYPE_BODY) {
            return 1;
        } else if (wearableType == LibSvg.SVG_TYPE_EYE) {
            return 2;
        } else if (wearableType == LibSvg.SVG_TYPE_HAND) {
            return 3;
        } else if (wearableType == LibSvg.SVG_TYPE_HEAD) {
            return 4;
        } else if (wearableType == LibSvg.SVG_TYPE_CLOTHES) {
            return 5;
        } else {
            return 0;
        }
    }
}