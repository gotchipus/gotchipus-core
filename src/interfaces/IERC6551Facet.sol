// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IERC6551Facet {
    function account(uint256 tokenId) external view returns (address);
    function execute(uint256 tokenId, address to, uint256 value, bytes calldata data, uint8 operation) external payable returns (bytes memory result);
}