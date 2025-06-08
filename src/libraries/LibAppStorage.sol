// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibMeta } from "./LibMeta.sol";
import { LibDiamond } from "./LibDiamond.sol";
import { IHook } from "../interfaces/IHook.sol";
import { LibTime } from "./LibTime.sol";

struct GotchipusInfo {
    // nft info
    string name;
    string uri;
    bytes story; // gotchi story background
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

struct WearableInfo {
    string name;
    string description;
    string author;
    bytes32 svgType;
    uint8 svgId;
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

struct PaymasterConfig {
    uint256 nonce;
    mapping(bytes32 => bool) extTx;
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
    mapping(uint256 => mapping(IHook.GotchiEvent => address[])) tokenHooksByEvent;
    mapping(uint256 => mapping(address => bool)) isValidHook;

    // traits svg
    mapping(bytes32 => SvgLayer[]) svgLayers;

    // ext contract
    address erc6551Registry;
    address erc6551Implementation;
    mapping(address => PaymasterConfig) paymaster;
    mapping(address => bool) isPaymaster;

    // off-chain weather
    mapping(uint8 => LibTime.Weather) weatherByTimezone;

    // gotchipus traits index
    mapping(uint256 => mapping(uint8 => uint8)) gotchiTraitsIndex;
    mapping(uint8 => bytes32) svgTypeBytes32;

    // Wearable nft
    address wearableDiamond;
    mapping(address => mapping(uint256 => uint256)) ownerWearableBalances;
    mapping(address => uint256[]) ownerWearables;
    mapping(uint256 => WearableInfo) wearableInfo;
    mapping(uint256 => string) wearableUri;
    mapping(uint256 => mapping(uint256 => bool)) isEquipWearableByIndex;
    mapping(uint256 => bool) isAnyEquipWearable;
    uint256 nextWearableTokenId;
    string wearableBaseUri;
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

    modifier onlyOwnerOrPaymaster(uint256 _tokenId) {
        require(
            LibMeta.msgSender() == s.tokenOwners[_tokenId] ||
            s.isPaymaster[LibMeta.msgSender()],
            "LibAppStorage: Only gotchi owner or paymaster"
        );
        _;
    }

    modifier onlyWearable() {
        address sender = LibMeta.msgSender();
        require(sender == s.wearableDiamond, "LibAppStorage: Only wearable diamond");
        _;
    }

    modifier ownedGotchi() {
        address sender = LibMeta.msgSender();
        require(s.balances[sender] != 0, "LibAppStorage: Not Owned Gotchipus");
        _;
    }
}
