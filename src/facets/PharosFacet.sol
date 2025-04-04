// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { AppStorage, Modifier } from "../libraries/LibAppStorage.sol";
import { IERC721Receiver } from "../interfaces/IERC721Receiver.sol";
import { IERC721Enumerable } from "../interfaces/IERC721Enumerable.sol";
import { IERC721 } from "../interfaces/IERC721.sol";
import { LibMeta } from "../libraries/LibMeta.sol";
import { LibERC721 } from "../libraries/LibERC721.sol";
import { LibStrings } from "../libraries/LibStrings.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";
import "../interfaces/IGotchipusFacet.sol";


contract PharosFacet is Modifier {
    uint256 constant PHAROS_PRICE = 0.04 ether;
    uint256 constant MAX_TOTAL_SUPPLY = 20000;

    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), "PharosFacet: owner can't is zero");
        return s.pharosInfoMap.balances[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address owner) {
        owner = s.pharosInfoMap.tokenOwners[_tokenId];
        require(owner != address(0), "PharosFacet: owner can't is zero");
    }

    function totalSupply() external view returns (uint256) {
        return s.pharosInfoMap.allTokens.length;
    }

    function tokenByIndex(uint256 _index) external view returns (uint256) {
        require(_index < s.pharosInfoMap.allTokens.length, "PharosFacet: ERC721 out of bounds index");
        return s.pharosInfoMap.allTokens[_index];
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256) {
        require(_index < s.balances[_owner], "PharosFacet: ERC721 out of bounds index");
        return s.pharosInfoMap.ownerTokens[_owner][_index];
    }

    function allTokensOfOwner(address _owner) external view returns (uint256[] memory) {
        return s.pharosInfoMap.ownerTokens[_owner];
    }

    function name() external view returns (string memory) {
        return s.pharosInfoMap.name;
    }

    function symbol() external view returns (string memory) {
        return s.pharosInfoMap.symbol;
    }

    function tokenURI(uint256 _tokenId) external pure returns (string memory) {
        return LibStrings.strWithUint("https://gotchipus.com/metadata/pharos/", _tokenId);
    }

    function getApproved(uint256 _tokenId) external view returns (address) {
        require(_tokenId < s.pharosInfoMap.allTokens.length, "ERC721: tokenId is invalid");
        return s.pharosInfoMap.tokenApprovals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return s.pharosInfoMap.operatorApprovals[_owner][_operator];
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
        address owner = s.pharosInfoMap.tokenOwners[_tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        require(_to != owner, "ERC721: approval to current owner");
        require(
            LibMeta.msgSender() == owner || s.pharosInfoMap.operatorApprovals[owner][LibMeta.msgSender()],
            "ERC721: approve caller is not owner nor approved for all"
        );
        LibERC721._approve(_to, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        require(_operator != LibMeta.msgSender(), "ERC721: approve to caller");
        s.pharosInfoMap.operatorApprovals[LibMeta.msgSender()][_operator] = _approved;
        emit LibERC721.ApprovalForAll(LibMeta.msgSender(), _operator, _approved);
    } 

    function setBaseURI(string memory _baseURI) external onlyOwner {
        s.pharosInfoMap.baseUri = _baseURI;
    }

    function mint(uint256 amount) external payable pharosMintIsPaused {
        bool isWhitelist = s.pharosInfoMap.isWhitelist[msg.sender];
        uint256 tokenId = s.pharosInfoMap.nextTokenId;
        require(tokenId + 1 <= MAX_TOTAL_SUPPLY, "MAX TOTAL SUPPLY");
        s.pharosInfoMap.nextTokenId++;

        if (isWhitelist) {
            LibERC721._mint(msg.sender, tokenId);
        } else {
            require(amount * PHAROS_PRICE == msg.value, "Invalid value");
            LibERC721._mint(msg.sender, tokenId);
        }
    }

    function summonGotchipus(uint256 gotchipusTokenId) external onlyPharosOwner(gotchipusTokenId) {
        LibERC721._burn(gotchipusTokenId);
        gotchipusFacet().mint(msg.sender, gotchipusTokenId);
    }

    function burn(uint256 tokenId) external {
        require(LibERC721._isApprovedOrOwner(LibMeta.msgSender(), tokenId), 
                "ERC721: caller is not owner nor approved");
        LibERC721._burn(tokenId);
    }

    function addWhitelist(address[] calldata _whitelists, bool[] calldata _isWhitelists) external onlyOwner {
        for (uint256 i = 0; i < _whitelists.length; i++) {
            s.pharosInfoMap.isWhitelist[_whitelists[i]] = _isWhitelists[i];
        }
    }

    function paused(bool _paused) external onlyOwner {
        s.pharosInfoMap.isPaused = _paused;
    }

    function _safeTransfer(address _from, address _to, uint256 _tokenId, bytes memory _data) internal {
        LibERC721._transfer(_from, _to, _tokenId);
        require(LibERC721._checkOnERC721Received(_from, _to, _tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function gotchipusFacet() internal view returns (IGotchipusFacet) {
        return IGotchipusFacet(address(this));
    }
}
