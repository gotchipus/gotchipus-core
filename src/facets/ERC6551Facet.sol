// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { AppStorage, Modifier } from "../libraries/LibAppStorage.sol";
import { IERC6551Executable } from "../interfaces/IERC6551Executable.sol";

contract ERC6551Facet is Modifier {
    function account(uint256 tokenId) external view returns (address) {
        return s.accountOwnedByTokenId[tokenId];
    }

    function execute(address to, uint256 value, bytes calldata data, uint8 operation) external payable returns (bytes memory result) {
        result = IERC6551Executable(s.erc6551Implementation).execute{value: value}(
            to,
            value,
            data,
            operation
        );
    }
}