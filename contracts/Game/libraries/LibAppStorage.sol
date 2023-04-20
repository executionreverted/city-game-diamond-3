// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {LibDiamond} from "../../shared/libraries/LibDiamond.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {World, Coords, Plot} from "../shared/WorldStructs.sol";
import {City, Building} from "../shared/CityStructs.sol";
import {Squad} from "../shared/TroopsStructs.sol";

uint constant MAX_RACE_ID = 5;
uint constant MAX_TROOP_ID = 100;
// uint constant MAX_BUILDING_ID = 50;
// uint constant MINTER_ROLE = 5;
// uint constant MAX_RESOURCE_ID_VALUE = 5;

struct AppStorage {
    // CORE & CONTRACTS & CONSTANTS
    bytes32 domainSeparator;
    mapping(address => bool) GameManagers;
    // ICities CitiesNFT;
    // ICityManager CityManager;
    // IBuildings Buildings;
    // IResources Resources;
    // IGameWorld GameWorld;
    // ITroopsManager TroopsManager;
    // ICalculator Calculator;
    // IPerlinNoise PerlinNoise;
    uint MAX_RESOURCE_ID;
    uint MAX_BUILDING_ID;
    uint POPULATION_CAP_PER_TOWNHALL_TIER;
    // CITY
    mapping(uint => City) CityList;
    mapping(uint => uint) PopulationClaimDates;
    mapping(uint => uint[50]) BuildingLevelActivationTime;
    mapping(uint => Building[50]) BuildingLevels;
    uint[MAX_RACE_ID] RacePopulation;
    // indexes are stored 1 higher so that 0 means no items in items array
    mapping(address => mapping(uint256 => uint256)) ownerItemIndexes;
    mapping(uint256 => uint256) tokenIdToRandomNumber;
    mapping(address => uint32[]) ownerTokenIds;
    mapping(address => mapping(uint256 => uint256)) ownerTokenIdIndexes;
    uint32[] tokenIds;
    mapping(uint256 => uint256) tokenIdIndexes;
    mapping(address => mapping(address => bool)) operators;
    mapping(uint256 => address) approved;
    // WORLD
    World WorldState;
    mapping(uint => Coords) CityCoords;
    mapping(int => mapping(int => uint)) CoordsToCity;
    mapping(int => mapping(int => Plot)) CoordsToPlot;
    uint FOOD_PER_MINUTE;
    uint BASE_PLOT_INTERACTION_COOLDOWN;
    uint BASE_RESOURCE_SPAWN_AMOUNT;
    uint MAX_PLOT_TIER;
    uint DISTANCE_PER_PLOT;
    uint DISTANCE_TIME;
    int PERLIN_05;
    int PERLIN_1;
    int NOISE_AMOUNT;
    int MAP_SEED;
    uint EVENT_MAP_SEED;
    uint8 MAX_SQUADS_ON_PLOT;
    uint8 BARRACKS_ID; // TROOPS
    uint squadNonces;
    mapping(uint => uint[MAX_TROOP_ID]) CityTroops;
    // movement stuff
    mapping(uint => Squad) SquadsById;
    mapping(int => mapping(int => EnumerableSet.UintSet)) SquadsIdOnWorld;
    mapping(uint => EnumerableSet.UintSet) CityActiveSquads;
    uint ACTION_RANGE;
    // resources

    uint[10] BaseProductions;
    mapping(address => bool) Minters;
    mapping(uint => uint[10]) LastClaims;
    mapping(uint => uint[10]) CityResources;
    // modifiers from actions in game to decrease/increase productions
    uint PROD_CYCLE; // todo fix in prod
    uint WAREHOUSE_ID;
    uint WAREHOUSE_STORAGE_PER_TIER;
    uint BASE_GOLD_MAX;
    uint BASE_WOOD_MAX;
    uint BASE_STONE_MAX;
    uint BASE_IRON_MAX;
    uint BASE_FOOD_MAX;
    // researchs

    uint RESEARCH_CENTER_ID;
    mapping(uint => uint[100]) CityResearchesValidAfter;
    // premium features

    mapping(uint => uint) CITY_PREMIUM_STATUS;
    mapping(uint => uint) CITY_PREMIUM_EXPIRE_DATE;
}

library LibAppStorage {
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }

    function abs(int256 x) internal pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }
}

contract Modifiers {
    AppStorage internal s;

    modifier onlyOwner() {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        address sender = LibMeta.msgSender();
        require(sender == ds.contractOwner, "Only manager can call this function");
        _;
    }

    modifier onlyManager() {
        address sender = LibMeta.msgSender();
        require(s.GameManagers[sender], "Only manager can call this function");
        _;
    }

    modifier onlyCityOwner(uint cityId) {
        address sender = LibMeta.msgSender();
        require(s.CityList[cityId].Operator == sender, "Only city operator can call this function");
        _;
    }
}
