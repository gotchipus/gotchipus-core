// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { AppStorage, Modifier, GotchipusInfo, EquipWearableType } from "../libraries/LibAppStorage.sol";
import { LibGotchiConstants } from "../libraries/LibGotchiConstants.sol";
import { IERC721Receiver } from "../interfaces/IERC721Receiver.sol";
import { IERC721Enumerable } from "../interfaces/IERC721Enumerable.sol";
import { IERC721 } from "../interfaces/IERC721.sol";
import { LibMeta } from "../libraries/LibMeta.sol";
import { LibERC721 } from "../libraries/LibERC721.sol";
import { LibStrings } from "../libraries/LibStrings.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";
import { LibDna } from "../libraries/LibDna.sol";
import { LibTime } from "../libraries/LibTime.sol";
import { LibTransferHelper } from "../libraries/LibTransferHepler.sol";
import { LibSvg } from "../libraries/LibSvg.sol";
import { IGotchipusFacet } from "../interfaces/IGotchipusFacet.sol";
import { IERC6551Registry } from "../interfaces/IERC6551Registry.sol";

contract GotchipusFacet is Modifier {

    struct SummonArgs {
        uint256 gotchipusTokenId;
        string gotchiName;
        address collateralToken;
        uint256 stakeAmount;
        uint8 utc;
        bytes story;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), "GotchipusFacet: owner can't is zero");
        return s.balances[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address owner) {
        owner = s.tokenOwners[_tokenId];
        require(owner != address(0), "GotchipusFacet: owner can't is zero");
    }

    function totalSupply() external view returns (uint256) {
        return s.allTokens.length;
    }

    function tokenByIndex(uint256 _index) external view returns (uint256) {
        require(_index < s.allTokens.length, "GotchipusFacet: ERC721 out of bounds index");
        return s.allTokens[_index];
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256) {
        require(_index < s.balances[_owner], "GotchipusFacet: ERC721 out of bounds index");
        return s.ownerTokens[_owner][_index];
    }

    function allTokensOfOwner(address _owner) external view returns (uint256[] memory) {
        return s.ownerTokens[_owner];
    }

    function name() external view returns (string memory) {
        return s.name;
    }

    function symbol() external view returns (string memory) {
        return s.symbol;
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        GotchipusInfo storage _ownedPus = s.ownedGotchipusInfos[s.tokenOwners[_tokenId]][_tokenId];
        if (_ownedPus.status == 0) {
            return LibStrings.strWithUint(string.concat(s.baseUri, "pharos/"), _tokenId);
        }
        return LibStrings.strWithUint(string.concat(s.baseUri, "gotchipus/"), _tokenId);
    }

    function ownedTokenInfo(address _owner, uint256 _tokenId) external view returns (GotchipusInfo memory info_) {
        info_ = s.ownedGotchipusInfos[_owner][_tokenId];
    }

    function getApproved(uint256 _tokenId) external view returns (address) {
        require(_tokenId < s.allTokens.length, "ERC721: tokenId is invalid");
        return s.tokenApprovals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return s.operatorApprovals[_owner][_operator];
    }

    function getGotchiTraitsIndex(uint256 tokenId) external view returns (uint8[] memory indexs) {
        indexs = s.allGotchiTraitsIndex[tokenId];
    }

    function getGotchiOrPharosInfo(address owner, uint8 status) external view returns (uint256[] memory tokenIds) {
        uint256[] storage allIds = s.ownerTokens[owner];
        uint256 count;

        for (uint256 i = 0; i < allIds.length; i++) {
            if (s.ownedGotchipusInfos[owner][allIds[i]].status == status) {
                count++;
            }
        }

        tokenIds = new uint256[](count);
        uint256 j;
        for (uint256 i = 0; i < allIds.length; i++) {
            uint256 id = allIds[i];
            if (s.ownedGotchipusInfos[owner][id].status == status) {
                tokenIds[j++] = id;
            }
        }
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return
            interfaceId == type(IERC721Enumerable).interfaceId ||
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == 0x01ffc9a7; // ERC165
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) external {
        require(LibERC721._isApprovedOrOwner(LibMeta.msgSender(), _tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(_from, _to, _tokenId, _data);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {
        require(LibERC721._isApprovedOrOwner(LibMeta.msgSender(), _tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(_from, _to, _tokenId, "");
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external {
        require(LibERC721._isApprovedOrOwner(LibMeta.msgSender(), _tokenId), "ERC721: transfer caller is not owner nor approved");
        LibERC721._transfer(_from, _to, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) external {
        address owner = s.tokenOwners[_tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        require(_to != owner, "ERC721: approval to current owner");
        require(
            LibMeta.msgSender() == owner || s.operatorApprovals[owner][LibMeta.msgSender()],
            "ERC721: approve caller is not owner nor approved for all"
        );
        LibERC721._approve(_to, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != LibMeta.msgSender(), "ERC721: approve to caller");
        s.operatorApprovals[LibMeta.msgSender()][_operator] = _approved;
        emit LibERC721.ApprovalForAll(LibMeta.msgSender(), _operator, _approved);
    } 

    function setBaseURI(string memory _baseURI) external onlyOwner {
        s.baseUri = _baseURI;
    }

    function freeMint() external {
        uint256 tokenId = s.nextTokenId;
        s.nextTokenId++;
        LibERC721._mint(msg.sender, tokenId);
    }

    function mint(uint256 amount) external payable pharosMintIsPaused {
        require(amount != 0 && amount <= LibGotchiConstants.MAX_PER_MINT, "Invalid amount");
        bool isWhitelist = s.isWhitelist[msg.sender];

        if (isWhitelist) {
            uint256 tokenId = s.nextTokenId;
            require(tokenId + 1 < LibGotchiConstants.MAX_TOTAL_SUPPLY, "MAX TOTAL SUPPLY");
            s.nextTokenId++;

            LibERC721._mint(msg.sender, tokenId);
        } else {
            require(amount * LibGotchiConstants.PHAROS_PRICE == msg.value, "Invalid value");
            require(s.allTokens.length + amount <= LibGotchiConstants.MAX_TOTAL_SUPPLY, "MAX TOTAL SUPPLY");

            for (uint256 i = 0; i < amount; i++) {
                uint256 tokenId = s.nextTokenId++;
                LibERC721._mint(msg.sender, tokenId);
            }
        }
    }

    function summonGotchipus(SummonArgs calldata _args) external payable onlyGotchipusOwner(_args.gotchipusTokenId) {
        require(s.accountOwnedByTokenId[_args.gotchipusTokenId] == address(0), "Pharos: already summon");
        
        bytes32 salt = keccak256(abi.encode(block.chainid, _args.gotchipusTokenId, address(this)));
        address account = IERC6551Registry(s.erc6551Registry).createAccount(
            s.erc6551Implementation,
            salt,
            block.chainid,
            address(this),
            _args.gotchipusTokenId
        );

        if (_args.collateralToken == address(0)) {
            LibTransferHelper.safeTransferETH(account, _args.stakeAmount);
        } else {
            LibTransferHelper.safeTransferFrom(_args.collateralToken, msg.sender, account, _args.stakeAmount);
        }

        uint256 randomDna = LibDna.getRandomGene(salt);
        GotchipusInfo storage _ownedPus = s.ownedGotchipusInfos[msg.sender][_args.gotchipusTokenId];
        _ownedPus.dna.geneSeed = randomDna;
        _ownedPus.dna.ruleVersion = s.dnaRuleVersion;
        _ownedPus.dna.generation = 0;
        _ownedPus.name = _args.gotchiName;
        _ownedPus.uri = LibStrings.strWithUint(string.concat(s.baseUri, "gotchipus/"), _args.gotchipusTokenId);
        _ownedPus.owner = msg.sender;
        _ownedPus.collateral = _args.collateralToken;
        _ownedPus.birthTime = uint32(block.timestamp);
        _ownedPus.timezone = _args.utc;
        
        _ownedPus.core.experience = 50;
        _ownedPus.core.soul = _getStableAether(_args.stakeAmount);

        _ownedPus.singer = msg.sender;
        _ownedPus.status = 1;
        _ownedPus.story = _args.story;
        s.accountOwnedByTokenId[_args.gotchipusTokenId] = account;
        
        uint8[] memory indexs = randomTraitsIndex(_args.gotchipusTokenId);
        
        uint256 packed = LibDna.computePacked(_args.gotchipusTokenId);
        LibDna.setPacked(_args.gotchipusTokenId, packed);

        s.allOwnerEquipWearableType[account].push(EquipWearableType({
            wearableType: LibSvg.SVG_TYPE_BG,
            wearableId: indexs[0],
            equiped: true
        }));
        s.allOwnerEquipWearableType[account].push(EquipWearableType({
            wearableType: LibSvg.SVG_TYPE_BODY,
            wearableId: indexs[1] + 9,
            equiped: true
        }));
        s.allOwnerEquipWearableType[account].push(EquipWearableType({
            wearableType: LibSvg.SVG_TYPE_EYE,
            wearableId: indexs[2] + 18,
            equiped: true
        }));
        s.isOwnerEquipWearable[account][LibSvg.SVG_TYPE_BG] = true;
        s.isOwnerEquipWearable[account][LibSvg.SVG_TYPE_BODY] = true;
        s.isOwnerEquipWearable[account][LibSvg.SVG_TYPE_EYE] = true;
    }

    function addWhitelist(address[] calldata _whitelists, bool[] calldata _isWhitelists) external onlyOwner {
        for (uint256 i = 0; i < _whitelists.length; i++) {
            s.isWhitelist[_whitelists[i]] = _isWhitelists[i];
        }
    }

    function paused(bool _paused) external onlyOwner {
        s.isPaused = _paused;
    }

    function _getStableAether(uint256 stakeAmount) internal pure returns (uint16) {
        uint256 formatAmount = stakeAmount / 10**18;
        if (formatAmount >= 1000) {
             return 100;
        } else if (formatAmount >= 500) { 
            return 75; 
        } else if (formatAmount >= 250) {
            return 50;
        } else if (formatAmount >= 100) {
            return 25;
        } else {
            return 10;
        }
    }

    function burn(uint256 tokenId) external {
        require(LibERC721._isApprovedOrOwner(LibMeta.msgSender(), tokenId), 
                "ERC721: caller is not owner nor approved");
        LibERC721._burn(tokenId);
    }

    function _safeTransfer(address _from, address _to, uint256 _tokenId, bytes memory _data) internal {
        LibERC721._transfer(_from, _to, _tokenId);
        require(LibERC721._checkOnERC721Received(_from, _to, _tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function randomTraitsIndex(uint256 tokenId) internal returns (uint8[] memory indexs_) {
        bytes32 seed = keccak256(abi.encodePacked(
            tokenId,
            block.timestamp,
            block.prevrandao
        ));

        indexs_ = new uint8[](LibSvg.MAX_BODY_NUM);

        for (uint256 i = 0; i < LibSvg.MAX_BODY_NUM; i++) {
            seed = keccak256(abi.encodePacked(seed, i));
            uint8 index = uint8(uint256(seed) % 10);
            index = index == 9 ? index - 1 : index;
            indexs_[i] = index;
            s.gotchiTraitsIndex[tokenId][uint8(i)] = index;
            s.allGotchiTraitsIndex[tokenId].push(index);
        }
    }

}
