// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { LibMeta } from "./LibMeta.sol";
import { LibDiamond } from "./LibDiamond.sol";
import { IHook } from "../interfaces/IHook.sol";
import { LibTime } from "./LibTime.sol";
import { LibFaction } from "./LibFaction.sol";
import { LibDynamicStates } from "./LibDynamicStates.sol";

uint256 constant MAX_NUM_PER_TRAITS = 255;
uint256 constant MAX_BODY_NUM = 3;
uint256 constant MAX_TRAITS_NUM = 8;

struct SoulCore {
    uint32 balance;
    uint32 maxSoulCapacity;
    uint32 lastSoulUpdate;
    uint8 dormantSince;
}

struct GotchipusCore {
    uint32 experience;
    uint16 level;
    uint8 evolution;
    uint16 availablePoints;
    uint32 strength;    // STR
    uint32 defense;     // DEF
    uint32 mind;        // INT
    uint32 vitality;    // VIT 
    uint32 agility;     // AGI
    uint32 luck;        // LUK
    SoulCore soul;
}

struct FactionCore {
    uint8 primaryFaction;
    uint8 dominantAttr;
    uint8 factionPurity; // faction purity 0-100
    uint8 attributeMastery; // 0-20
    bool hasSecondaryFaction;
    uint8 secondaryFaction;
    uint8 secondaryAttr;
    uint8 secondaryRatio;
}

struct AttributeSpecialization {
    uint8[9] masteryLevels;
    uint16[6] combatBonus;
    uint16[6] defenseBonus;
    uint16[6] technologyBonus;
    uint16[6] allocatedPoints;
}

struct StrategicStats {
    uint16 leadership;
    uint16 economics; 
    uint16 technology;
    uint16 warfare;   
    uint16 foodProductionBonus;    
    uint16 materialMiningBonus;    
    uint16 energyEfficiencyBonus;  
    uint16 researchSpeedBonus;     
    uint16 constructionSpeedBonus; 
    uint16 tradeIncomeBonus;       
}

struct EvolutionData {
    uint8 currentStage;
    uint32 evolutionExp;
    bool canEvolve;
    uint8[] evolutionHistory;
    uint32[] evolutionDates; 
    bool hasSpecialEvolution; 
    uint8 specialEvolutionType;
}

struct LevelingSystem {
    uint32 currentExp;     
    uint32 requiredExp;    
    uint32 totalExp;       
    uint32 battleExp;      
    uint32 buildingExp;    
    uint32 interactionExp; 
    uint32 questExp;       
    uint16 expMultiplier;
    uint32 lastExpGain;    
}

struct GotchipusInfo {
    string name;
    string uri;
    bytes story;
    address owner;
    address collateral;
    uint256 collateralAmount;
    uint8 status;
    bool locked;
    uint32 birthTime;
    uint8 timezone;
    GotchipusCore core;
    FactionCore faction;
    AttributeSpecialization spec;
    LibDynamicStates.DynamicStates states;
    StrategicStats strategy;
    EvolutionData evolution;
    LevelingSystem leveling;
    DNAData dna;
    // erc6551
    address singer;
    uint256 nonces;
}

struct WearableInfo {
    string name;
    string description;
    string author;
    bytes32 wearableType;
    uint8 wearableId;
}

struct DNAData {
    uint256 geneSeed;  
    uint8 ruleVersion; 
    uint8 rarity;
    uint8 generation;  
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

struct EquipWearableType {
    bytes32 wearableType;
    uint256 wearableId;
    bool equiped;
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

    // Hooks
    // address can owned multiple hooks
    mapping(uint256 => mapping(IHook.GotchiEvent => address[])) tokenHooksByEvent;
    mapping(uint256 => mapping(address => bool)) isValidHook;

    // ext contract
    address erc6551Registry;
    address erc6551Implementation;
    mapping(address => PaymasterConfig) paymaster;
    mapping(address => bool) isPaymaster;

    // off-chain weather
    mapping(uint8 => LibTime.Weather) weatherByTimezone;

    // Wearable && traits
    mapping(bytes32 => SvgLayer[]) svgLayers;
    mapping(uint256 => mapping(uint8 => uint8)) gotchiTraitsIndex;
    mapping(uint8 => bytes32) svgTypeBytes32;
    mapping(uint256 => uint8[MAX_TRAITS_NUM]) allGotchiTraitsIndex;

    address wearableDiamond;
    uint256 nextWearableTokenId;
    string wearableBaseUri;
    mapping(address => mapping(uint256 => uint256)) ownerWearableBalances;
    mapping(address => uint256[]) ownerWearables;
    mapping(uint256 => WearableInfo) wearableInfo;
    mapping(uint256 => string) wearableUri;
    mapping(uint256 => mapping(uint256 => bool)) isEquipWearableByIndex;
    mapping(uint256 => bool) isAnyEquipWearable;
    mapping(uint256 => uint256) equipWearableCount;
    mapping(address => EquipWearableType[MAX_TRAITS_NUM]) allOwnerEquipWearableType;
    mapping(address => mapping(bytes32 => bool)) isOwnerEquipWearable;
    mapping(bytes32 => uint8) countWearablesByType;
    mapping(bytes32 => mapping(uint8 => uint256)) idByWearableType;
    mapping(uint256 => mapping(bytes32 => uint8)) typeIndexByWearableId;
    mapping(address => bool) isWearableClaimed;
    /**
     * We’ve added a pity system:
     * RARE guaranteed after 15 pulls
     * EPIC after 30
     * LEGENDARY after 60
     */
    mapping(address => uint256) summonPityCount;
    uint256 globalSalt;
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
