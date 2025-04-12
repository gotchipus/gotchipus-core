// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibMeta } from "./LibMeta.sol";
import { LibDiamond } from "./LibDiamond.sol";


struct GotchipusInfo {
    // nft info
    uint256 tokenId;
    string name;
    string uri;
    address owner;
    address collateral;
    uint256 collateralAmount;
    uint256 level;
    uint8 status;
    uint8 evolution;
    bool locked;
    uint32 epoch;
    uint32 utc; // time zone
    // attributes
    DNAData dna;
    uint8 bonding;
    uint32 growth;
    uint8 wisdom;
    uint32 aether;
    // erc6551 info
    address singer;
    uint256 nonces;
}

struct PharosInfo {
    string name;
    string symbol;
    string baseUri;
    mapping(uint256 => address) tokenOwners;
    mapping(address => uint256) balances;
    mapping(uint256 => address) tokenApprovals;
    mapping(address => mapping(address => bool)) operatorApprovals;
    mapping(uint256 => string) tokenURIs;
    uint256 nextTokenId;
    uint256[] allTokens;
    mapping(uint256 => uint256) allTokensIndex;
    mapping(address => uint256[]) ownerTokens;
    mapping(uint256 => uint256) ownedTokensIndex;
    mapping(address => bool) isWhitelist;
    bool isPaused;
}

struct DNAData {
    uint256 geneSeed;
    uint8 ruleVersion;
}

struct AppStorage {
    string name;
    string symbol;
    string baseUri;
    mapping(uint256 => address) tokenOwners;
    mapping(address => uint256) balances;
    mapping(uint256 => address) tokenApprovals;
    mapping(address => mapping(address => bool)) operatorApprovals;
    mapping(uint256 => string) tokenURIs;
    uint256 nextTokenId;
    uint256[] allTokens;
    mapping(uint256 => uint256) allTokensIndex;
    mapping(address => uint256[]) ownerTokens;
    mapping(uint256 => uint256) ownedTokensIndex;
    mapping(address => mapping(uint256 => GotchipusInfo)) ownedGotchipusInfos;
    PharosInfo pharosInfoMap;
    uint32 createWorldTime;
    uint8 createTimeForTimeHour;
    // action
    mapping(uint256 => uint32) lastPetTime;
    mapping(uint256 => uint32) lastFeedTime;
    // ERC6551
    mapping(uint256 => address) accountOwnedByTokenId;
    uint256 state;
    // DNA
    uint8 dnaRuleVersion;

    // Mock farm 
    mapping(address => uint256) ownedFish;
    mapping(address => uint256) breedFish;

    // Hooks
    // address can owned multiple hooks
    mapping(address => address[]) accountHooks;
}


library LibAppStorage {
    bytes32 constant DIAMOND_APP_STORAGE_POSITION = keccak256("diamond.standard.app.storage");

    function diamondStorage() internal pure returns (AppStorage storage ds) {
        bytes32 position = DIAMOND_APP_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}

contract Modifier {
    AppStorage internal s;

    modifier onlyOwner() {
        LibDiamond.enforceIsContractOwner();
        _;
    }

    modifier onlyGotchipusOwner(uint256 _tokenId) {
        require(LibMeta.msgSender() == s.tokenOwners[_tokenId], "LibAppStorage: Only token owner");
        _;
    }

    modifier pharosMintIsPaused() {
        require(!s.pharosInfoMap.isPaused, "LibAppStorage: mint paused");
        _;
    }

    modifier onlyPharosOwner(uint256 _tokenId) {
        require(LibMeta.msgSender() == s.pharosInfoMap.tokenOwners[_tokenId], "LibAppStorage: Only pharos owner");
        _;
    }
}