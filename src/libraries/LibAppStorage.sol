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
    uint8 status; // 0 = pharos, 1 = summon
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

struct DNAData {
    uint256 geneSeed;
    uint8 ruleVersion;
}

struct TraitsOffset {
    uint8 offset;
    uint8 width;
}

struct SvgLayer {
    address svgLayerContract;
    uint16 offset;
    uint16 size;
}

struct Permissions {
    bool beforePet;
    bool afterPet;
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
    mapping(address => bool) isWhitelist;
    bool isPaused;
    mapping(address => mapping(uint256 => GotchipusInfo)) ownedGotchipusInfos;
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
    TraitsOffset[] traitsOffset; 
    mapping(uint256 => uint256) tokenTraitsPacked;

    // Mock farm 
    mapping(address => uint256) ownedFish;
    mapping(address => uint256) breedFish;

    // Hooks
    // address can owned multiple hooks
    mapping(address => address[]) accountHooks;
    mapping(address => mapping(address => bool)) isValidHook;

    // traits svg
    mapping(bytes32 => SvgLayer[]) svgLayers;
}


library LibAppStorage {
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
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
        require(!s.isPaused, "LibAppStorage: mint paused");
        _;
    }

    modifier onlyPharosOwner(uint256 _tokenId) {
        require(LibMeta.msgSender() == s.tokenOwners[_tokenId], "LibAppStorage: Only pharos owner");
        _;
    }
}