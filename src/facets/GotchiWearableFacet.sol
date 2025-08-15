// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { Modifier, WearableInfo, EquipWearableType, MAX_TRAITS_NUM } from "../libraries/LibAppStorage.sol";
import { LibStrings } from "../libraries/LibStrings.sol";
import { LibSvg } from "../libraries/LibSvg.sol";
import { LibERC1155 } from "../WearableDiamond/libraries/LibERC1155.sol";
import { IWearableFacet } from "../WearableDiamond/interfaces/IWearableFacet.sol";

contract GotchiWearableFacet is Modifier {
    event AddWearable(address indexed wearable);
    event WearableURI(uint256 indexed tokenId, string indexed wearableUri);

    uint256 public PRICE = 0.001 ether;

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

    function getAllEquipWearableType(uint256 gotchiTokenId) external view returns (EquipWearableType[MAX_TRAITS_NUM] memory ew_) {
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
        
        uint8 count = s.countWearablesByType[info.wearableType]++;
        s.idByWearableType[info.wearableType][count] = wearableTokenId;
        s.typeIndexByWearableId[wearableTokenId][info.wearableType] = count;

        s.wearableInfo[wearableTokenId] = WearableInfo({
            name: info.name,
            description: info.description,
            author: info.author,
            wearableType: info.wearableType,
            wearableId: uint8(wearableTokenId)
        });

        emit WearableURI(wearableTokenId, tokenUri);
    }

    function createBatchWearable(string[] calldata tokenUris, WearableInfo[] calldata infos) external onlyOwner {
        for (uint256 i = 0; i < tokenUris.length; i++) {
            uint256 wearableTokenId = s.nextWearableTokenId++;
            s.wearableUri[wearableTokenId] = tokenUris[i];

            uint8 count = s.countWearablesByType[infos[i].wearableType]++;
            s.idByWearableType[infos[i].wearableType][count] = wearableTokenId;
            s.typeIndexByWearableId[wearableTokenId][infos[i].wearableType] = count;

            s.wearableInfo[wearableTokenId] = WearableInfo({
                name: infos[i].name,
                description: infos[i].description,
                author: infos[i].author,
                wearableType: infos[i].wearableType,
                wearableId: uint8(wearableTokenId)
            });

            emit WearableURI(wearableTokenId, tokenUris[i]);
        }
    }

    function setWearableDiamond(address wearable) external onlyOwner {
        s.wearableDiamond = wearable;
        emit AddWearable(wearable);
    }

    function equipWearable(uint256 gotchiTokenId, uint256 wearableTokenId, bytes32 wearableType) external onlyGotchipusOwner(gotchiTokenId) {
        require(s.ownerWearableBalances[msg.sender][wearableTokenId] > 0, "WearableFacet: Insufficient balance");
        
        s.isEquipWearableByIndex[gotchiTokenId][wearableTokenId] = true;
        s.isAnyEquipWearable[gotchiTokenId] = true;
        s.equipWearableCount[gotchiTokenId] += 1;

        address account = s.accountOwnedByTokenId[gotchiTokenId];
        s.ownerWearableBalances[msg.sender][wearableTokenId] -= 1;
        s.ownerWearableBalances[account][wearableTokenId] += 1;

        uint256 typeIndex = LibSvg.getWearbaleTypeIndex(wearableType);
        bool isEquip = s.isOwnerEquipWearable[account][wearableType];

        if (!isEquip) {
            s.allOwnerEquipWearableType[account][typeIndex] = EquipWearableType({
                wearableType: wearableType,
                wearableId: wearableTokenId,
                equiped: true
            });
            s.isOwnerEquipWearable[account][wearableType] = true;
        } else {
            EquipWearableType storage wearableToModify = s.allOwnerEquipWearableType[account][typeIndex];
            uint256 oldWearableId = wearableToModify.wearableId;
            wearableToModify.wearableId = wearableTokenId;

            s.ownerWearableBalances[msg.sender][oldWearableId] += 1;
            s.ownerWearableBalances[account][oldWearableId] -= 1;
            s.isEquipWearableByIndex[gotchiTokenId][oldWearableId] = false;
            emit IWearableFacet.TransferSingle(msg.sender, account, msg.sender, oldWearableId, 1);
        }
        
        uint8 svgIndex = s.typeIndexByWearableId[wearableTokenId][wearableType];
        s.gotchiTraitsIndex[gotchiTokenId][uint8(typeIndex)] = svgIndex;
        s.allGotchiTraitsIndex[gotchiTokenId][typeIndex] = svgIndex;

        emit IWearableFacet.TransferSingle(msg.sender, msg.sender, account, wearableTokenId, 1);
    }

    function batchEquipWearable(uint256 gotchiTokenId, uint256[] calldata wearableTokenIds, bytes32[] calldata wearableTypes) external onlyGotchipusOwner(gotchiTokenId) {
        require(wearableTokenIds.length == wearableTypes.length, "WearableFacet: Invalid length");

        s.isAnyEquipWearable[gotchiTokenId] = true;
        address account = s.accountOwnedByTokenId[gotchiTokenId];
        uint256[] memory values = new uint256[](wearableTokenIds.length);

        for (uint256 i = 0; i < wearableTokenIds.length; i++) {
            uint256 wid = wearableTokenIds[i];
            bytes32 wtype = wearableTypes[i];
            require(s.ownerWearableBalances[msg.sender][wid] != 0, "WearableFacet: Insufficient balance");

            s.isEquipWearableByIndex[gotchiTokenId][wid] = true;
            s.ownerWearableBalances[msg.sender][wid] -= 1;
            s.ownerWearableBalances[account][wid] += 1;

            uint256 typeIndex = LibSvg.getWearbaleTypeIndex(wtype);
            bool isEquip = s.isOwnerEquipWearable[account][wtype];

            if (!isEquip) {
                s.allOwnerEquipWearableType[account][typeIndex] = EquipWearableType({
                    wearableType: wtype,
                    wearableId: wid,
                    equiped: true
                });
                s.isOwnerEquipWearable[account][wtype] = true;
            } else {
                EquipWearableType storage wearableToModify = s.allOwnerEquipWearableType[account][typeIndex];
                uint256 oldWearableId = wearableToModify.wearableId;
                wearableToModify.wearableId = wid;

                s.ownerWearableBalances[msg.sender][oldWearableId] += 1;
                s.ownerWearableBalances[account][oldWearableId] -= 1;
                s.isEquipWearableByIndex[gotchiTokenId][oldWearableId] = false;
                emit IWearableFacet.TransferSingle(msg.sender, account, msg.sender, oldWearableId, 1);
            }

            uint8 svgIndex = s.typeIndexByWearableId[wid][wtype];
            s.gotchiTraitsIndex[gotchiTokenId][uint8(typeIndex)] = svgIndex;
            s.allGotchiTraitsIndex[gotchiTokenId][typeIndex] = svgIndex;
            s.equipWearableCount[gotchiTokenId] += 1;
            values[i] = 1;
        }
        
        emit IWearableFacet.TransferBatch(msg.sender, msg.sender, account, wearableTokenIds, values);
    }

    function unequipWearable(uint256 gotchiTokenId, uint256 wearableTokenId, bytes32 wearableType) external onlyGotchipusOwner(gotchiTokenId) {
        require(s.isEquipWearableByIndex[gotchiTokenId][wearableTokenId], "WearableFacet: already unequip");

        address account = s.accountOwnedByTokenId[gotchiTokenId];
        s.isEquipWearableByIndex[gotchiTokenId][wearableTokenId] = false;

        uint256 equipCount = --s.equipWearableCount[gotchiTokenId];
        if (equipCount == 0) {
            s.isAnyEquipWearable[gotchiTokenId] = false;
        }

        s.ownerWearableBalances[msg.sender][wearableTokenId] += 1;
        s.ownerWearableBalances[account][wearableTokenId] -= 1;

        uint256 typeIndex = LibSvg.getWearbaleTypeIndex(wearableType);
        s.isOwnerEquipWearable[account][wearableType] = false;
        delete s.allOwnerEquipWearableType[account][typeIndex];
        delete s.gotchiTraitsIndex[gotchiTokenId][uint8(typeIndex)];
        delete s.allGotchiTraitsIndex[gotchiTokenId][typeIndex];

        emit IWearableFacet.TransferSingle(msg.sender, account, msg.sender, wearableTokenId, 1);
    }

    function batchUnequipWearable(uint256 gotchiTokenId, uint256[] calldata wearableTokenIds, bytes32[] calldata wearableTypes) external onlyGotchipusOwner(gotchiTokenId) {
        require(wearableTokenIds.length == wearableTypes.length, "WearableFacet: Invalid length");

        address account = s.accountOwnedByTokenId[gotchiTokenId];
        uint256[] memory values = new uint256[](wearableTokenIds.length);

        for (uint256 i = 0; i < wearableTokenIds.length; i++) {
            uint256 wid = wearableTokenIds[i];
            bytes32 wtype = wearableTypes[i];
            require(s.isEquipWearableByIndex[gotchiTokenId][wid], "WearableFacet: already unequip");
            s.isEquipWearableByIndex[gotchiTokenId][wid] = false;

            s.ownerWearableBalances[msg.sender][wid] += 1;
            s.ownerWearableBalances[account][wid] -= 1;

            uint256 typeIndex = LibSvg.getWearbaleTypeIndex(wtype);
            s.isOwnerEquipWearable[account][wtype] = false;
            delete s.allOwnerEquipWearableType[account][typeIndex];
            delete s.gotchiTraitsIndex[gotchiTokenId][uint8(typeIndex)];
            delete s.allGotchiTraitsIndex[gotchiTokenId][typeIndex];
            values[i] = 1;
        }

        uint256 equipCount = s.equipWearableCount[gotchiTokenId] - wearableTokenIds.length;
        if (equipCount == 0) {
            s.isAnyEquipWearable[gotchiTokenId] = false;
        }
        s.equipWearableCount[gotchiTokenId] = equipCount;

        emit IWearableFacet.TransferBatch(msg.sender, account, msg.sender, wearableTokenIds, values);
    }

    function mintWearable(address sender, uint256 wearableTokenId, uint256 amount) external payable onlyWearable {
        require(amount * PRICE == msg.value, "WearableFacet: Invalid value");

        s.ownerWearableBalances[sender][wearableTokenId] += amount;
        emit IWearableFacet.TransferSingle(sender, address(0), sender, wearableTokenId, amount);
    }

    function claimWearable(address sender) external onlyWearable {
        require(s.isWearableClaimed[sender], "WearableFacet: alreday claimed");

        bytes32 seed = keccak256(abi.encodePacked(
            s.ownedGotchipusInfos[sender][s.ownerTokens[sender][0]].dna.geneSeed,
            block.timestamp,
            block.prevrandao
        ));

        bytes32[] memory tp = new bytes32[](3);
        for (uint256 i = 0; i < 3; i++) {
            uint256 tIndex = uint256(seed) % 6;
            if (tIndex == 0) {
                tp[i] = LibSvg.SVG_TYPE_LEFT_HAND;
            } else if (tIndex == 1) {
                tp[i] = LibSvg.SVG_TYPE_RIGHT_HAND;
            } else if (tIndex == 2) {
                tp[i] = LibSvg.SVG_TYPE_CLOTHES;
            } else if (tIndex == 3) {
                tp[i] = LibSvg.SVG_TYPE_FACE;
            } else if (tIndex == 4) {
                tp[i] = LibSvg.SVG_TYPE_MOUTH;
            } else if (tIndex == 5) {
                tp[i] = LibSvg.SVG_TYPE_HEAD;
            }
        }

        for (uint256 i = 0; i < 3; i++) {
            bytes32 svgType = tp[i];

            uint8 count = s.countWearablesByType[svgType];
            seed = keccak256(abi.encodePacked(seed, i));
            uint8 index = uint8(uint256(seed) % uint256(count));

            uint256 wearableId = s.idByWearableType[svgType][index];
            s.ownerWearableBalances[sender][wearableId] += 1;

            emit IWearableFacet.TransferSingle(sender, address(0), sender, wearableId, 1);
        }
    }
}