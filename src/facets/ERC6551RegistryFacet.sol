// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { Modifier, AppStorage } from "../libraries/LibAppStorage.sol";
import { LibERC6551Registry } from "../libraries/LibERC6551Registry.sol";
import { IERC6551RegistryFacet } from "../interfaces/IERC6551RegistryFacet.sol";

contract ERC6551RegistryFacet is Modifier, IERC6551RegistryFacet {
    function createAccount(
        address implementation,
        bytes32 salt,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId
    ) external returns (address) {
        address newAccount = LibERC6551Registry.createAccount(
            implementation,
            salt,
            chainId,
            tokenContract,
            tokenId
       );

        s.accountOwnedByTokenId[tokenId] = newAccount;

       return newAccount;
    }

    function account(
        address implementation,
        bytes32 salt,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId
    ) external view returns (address) {
        return LibERC6551Registry.account(
            implementation,
            salt,
            chainId,
            tokenContract,
            tokenId
        );
    }
}