// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {Research} from "../shared/ResearchStructs.sol";
import {ResearchBonusType} from "../shared/ResearchEnums.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {City, Race} from "../shared/CityStructs.sol";
import {Coords} from "../shared/WorldStructs.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {LibCityManager} from "./LibCityManager.sol";
import {LibResearchs} from "./LibResearchs.sol";
import {LibResources} from "./LibResources.sol";
import {LibAppStorage, AppStorage, Modifiers} from "./LibAppStorage.sol";
import {LibERC20} from "../../shared/libraries/LibERC20.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";
import {LibERC721} from "../../shared/libraries/LibERC721.sol";
import "../shared/Errors.sol";

library LibResearchManager {
    using EnumerableSet for EnumerableSet.UintSet;

    function researchIdsByBonusType(ResearchBonusType _type) internal pure returns (uint[] memory) {
        if (_type == ResearchBonusType.GOLD_BONUS) {
            uint[] memory researchIds = new uint[](4);
            researchIds[0] = 3;
            researchIds[1] = 6;
            researchIds[2] = 8;
            researchIds[3] = 10;
            return researchIds;
        }

        if (
            _type == ResearchBonusType.WOOD_BONUS ||
            _type == ResearchBonusType.IRON_BONUS ||
            _type == ResearchBonusType.STONE_BONUS ||
            _type == ResearchBonusType.FOOD_BONUS
        ) {
            uint[] memory researchIds = new uint[](5);
            researchIds[0] = 6;
            researchIds[1] = 22;
            researchIds[2] = 26;
            researchIds[3] = 28;
            researchIds[4] = 30;
            return researchIds;
        }

        if (_type == ResearchBonusType.BOOST_ARMY_POWER) {
            uint[] memory researchIds = new uint[](1);
            researchIds[0] = 45;
            return researchIds;
        }

        if (_type == ResearchBonusType.REDUCE_RESEARCH_COST) {
            uint[] memory researchIds = new uint[](1);
            researchIds[0] = 4;
            return researchIds;
        }

        if (_type == ResearchBonusType.REDUCE_RESEARCH_TIME) {
            uint[] memory researchIds = new uint[](1);
            researchIds[0] = 25;
            return researchIds;
        }

        if (_type == ResearchBonusType.REDUCE_BUILDING_COST) {
            uint[] memory researchIds = new uint[](1);
            researchIds[0] = 24;
            return researchIds;
        }

        if (_type == ResearchBonusType.REDUCE_BUILDING_TIME) {
            uint[] memory researchIds = new uint[](1);
            researchIds[0] = 21;
            return researchIds;
        }

        if (_type == ResearchBonusType.REDUCE_TRADING_FEE) {
            uint[] memory researchIds = new uint[](1);
            researchIds[0] = 9;
            return researchIds;
        }

        if (_type == ResearchBonusType.REDUCE_TROOPS_COST) {
            uint[] memory researchIds = new uint[](1);
            researchIds[0] = 42;
            return researchIds;
        }

        if (_type == ResearchBonusType.REDUCE_TROOP_RECRUIT_TIME) {
            uint[] memory researchIds = new uint[](1);
            researchIds[0] = 47;
            return researchIds;
        }

        if (_type == ResearchBonusType.REDUCE_TROOP_TRAVEL_COST) {
            uint[] memory researchIds = new uint[](1);
            researchIds[0] = 48;
            return researchIds;
        }

        return new uint[](1);
    }

    function isResearched(uint cityId, uint researchId) internal view returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint validAfter = s.CityResearchesValidAfter[cityId][researchId];
        if (validAfter != 0 && block.timestamp >= validAfter) return true;
        return false;
    }
}
