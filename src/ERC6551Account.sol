// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { IERC6551Account } from "../src/interfaces/IERC6551Account.sol";
import { IERC6551Executable } from "../src/interfaces/IERC6551Executable.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";


contract ERC6551Account is IERC165, IERC1271, IERC6551Account, IERC6551Executable {
    uint256 public state;
    
    modifier OnlyOwnerOrGotchi() {
        (uint256 chainId, address tokenContract, uint256 tokenId) = token();
        require(
            msg.sender == IERC721(tokenContract).ownerOf(tokenId) ||
            msg.sender == tokenContract,
            "Invalid signer"
        );
        _;
    }

    receive() external payable override {}

    function token() public view virtual returns (uint256, address, uint256) {
        bytes memory footer = new bytes(0x60);

        assembly {
            extcodecopy(address(), add(footer, 0x20), 0x4d, 0x60)
        }

        return abi.decode(footer, (uint256, address, uint256));
    }

    function owner() public view virtual returns (address) {
        (uint256 chainId, address tokenContract, uint256 tokenId) = token();
        if (chainId != block.chainid) return address(0);

        return IERC721(tokenContract).ownerOf(tokenId);
    }

    function _isValidSigner(address signer) internal view virtual returns (bool) {
        return signer == owner();
    }

    function isValidSigner(address signer, bytes calldata) external view virtual returns (bytes4) {
        if (_isValidSigner(signer)) {
            return IERC6551Account.isValidSigner.selector;
        }

        return bytes4(0);
    }

    function isValidSignature(bytes32 hash, bytes memory signature)
        external
        view
        virtual
        returns (bytes4 magicValue)
    {
        bool isValid = SignatureChecker.isValidSignatureNow(owner(), hash, signature);

        if (isValid) {
            return IERC1271.isValidSignature.selector;
        }

        return bytes4(0);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId
            || interfaceId == type(IERC6551Account).interfaceId
            || interfaceId == type(IERC6551Executable).interfaceId;
    }

    function execute(address to, uint256 value, bytes calldata data, uint8 operation)
        external
        payable
        virtual
        OnlyOwnerOrGotchi
        returns (bytes memory result)
    {
        require(operation == 0, "Only call operations are supported");

        ++state;

        bool success;
        (success, result) = to.call{value: value}(data);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

}