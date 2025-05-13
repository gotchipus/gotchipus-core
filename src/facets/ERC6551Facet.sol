// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { AppStorage, Modifier } from "../libraries/LibAppStorage.sol";
import { IERC6551Executable } from "../interfaces/IERC6551Executable.sol";

contract ERC6551Facet is Modifier {
    error AccountExecuteRevert();

    function account(uint256 tokenId) external view returns (address) {
        return s.accountOwnedByTokenId[tokenId];
    }

    function executeAccount(
        address acc,
        uint256 tokenId, 
        address to, 
        uint256 value, 
        bytes calldata data
    ) external onlyOwnerOrPaymaster(tokenId) returns (bytes memory result) {
        bool success;
        (success, result) = acc.call(abi.encodeWithSignature("execute(address,uint256,bytes,uint8)", to, value, data, 0));
        if (success && result.length > 0) {
            (result) = abi.decode(result, (bytes));
        } else if (result.length > 0) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        } else if (!success) {
            revert AccountExecuteRevert();
        }
    }
}