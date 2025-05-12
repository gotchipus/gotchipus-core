// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { Modifier } from "../libraries/LibAppStorage.sol";
import { UserOperation, LibUserOperation } from "../libraries/LibUserOperation.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract PaymasterFacet is Modifier {
    using SafeERC20 for IERC20;
    using LibUserOperation for UserOperation;

    function getNonce(address account) external view returns (uint256) {
        return s.paymaster[account].nonce;
    }

    function isExecutedTx(address account, bytes32 hashTx) external view returns (bool) {
        return s.paymaster[account].extTx[hashTx];
    }

    function isPaymaster(address paymaster) external view returns (bool) {
        return s.isPaymaster[paymaster];
    }

    function ValidateSignature(UserOperation calldata userOp) internal view returns (bool) {
        if (userOp.signature.length == 0) {
            return true;
        }

        return SignatureChecker.isValidSignatureNow(
            s.tokenOwners[userOp.tokenId], 
            getSignHash(userOp), 
            userOp.signature
        );
    }
     
    function getSignHash(UserOperation calldata userOp) internal view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                userOp.hash()
            )
        );
    }


}