// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {Research} from "../shared/ResearchStructs.sol";
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

    event BeginResearch(uint indexed cityId, uint indexed researchId, uint completionTime);

    // movement stuff

    function beginResearch(uint cityId, uint researchId) internal {
        // must be not researched
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.CityResearchesValidAfter[cityId][researchId] != 0) revert ErrorAlreadyGoingOn(researchId);

        // burn resources
        Research memory _research = LibResearchs.researchInfo(researchId);
        uint researchCenterTier = s.BuildingLevels[cityId][s.RESEARCH_CENTER_ID].Tier;
        if (researchCenterTier < _research.MinResearchCenterLevel) {
            revert ErrorAssertion(researchCenterTier < _research.MinResearchCenterLevel, false);
        }
        uint MAX_RESOURCE_ID = s.MAX_RESOURCE_ID;
        uint[] memory toBeBurn = new uint[](s.MAX_RESOURCE_ID);
        for (uint i = 0; i < MAX_RESOURCE_ID; i++) {
            toBeBurn[i] = _research.Cost[i];
        }
        LibResources.spendResources(cityId, toBeBurn);
        // set completion time
        s.CityResearchesValidAfter[cityId][researchId] = block.timestamp + _research.TimeRequired;

        emit BeginResearch(cityId, researchId, block.timestamp + _research.TimeRequired);
    }
}
