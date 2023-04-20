// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;
import {Resource} from "../shared/ResourceEnums.sol";
import {AppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibResearchManager} from "../libraries/LibResearchManager.sol";
import {LibResearchs} from "../libraries/LibResearchs.sol";
import {LibResources} from "../libraries/LibResources.sol";
import {Research} from "../shared/ResearchStructs.sol";
import {ResearchBonusType} from "../shared/ResearchEnums.sol";
import "../shared/Errors.sol";

contract ResearchManagerFacet is Modifiers {
    event BeginResearch(uint indexed cityId, uint indexed researchId, uint completionTime);

    function beginResearch(uint cityId, uint researchId) external onlyCityOwner(cityId) {
        // must be not researched
        if (s.CityResearchesValidAfter[cityId][researchId] != 0) revert ErrorAlreadyGoingOn(researchId);

        Research memory _research = LibResearchs.researchInfo(researchId);

        // check requirement before
        if (_research.RequiredResearchId != 0 && !isResearched(cityId, _research.RequiredResearchId)) {
            revert ErrorRequirementsNotSatisfied(_research.RequiredResearchId);
        }

        if (s.BuildingLevels[cityId][s.RESEARCH_CENTER_ID].Tier < _research.MinResearchCenterLevel) {
            revert ErrorAssertion(s.BuildingLevels[cityId][s.RESEARCH_CENTER_ID].Tier < _research.MinResearchCenterLevel, false);
        }

        // research bonuses -- reduce time and cost
        _research = applyResearchBonuses(cityId, _research);

        // burn resources
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

    function applyResearchBonuses(uint cityId, Research memory _research) internal view returns (Research memory) {
        uint[] memory researchTimeResearchs = LibResearchManager.researchIdsByBonusType(ResearchBonusType.REDUCE_RESEARCH_TIME);
        uint[] memory researchCostResearchs = LibResearchManager.researchIdsByBonusType(ResearchBonusType.REDUCE_RESEARCH_COST);

        uint reducedCost;
        uint reducedTime;

        // reduce cost
        for (uint i = 0; i < researchCostResearchs.length; ) {
            if (researchCostResearchs[i] != 0 && isResearched(cityId, researchCostResearchs[i])) {
                Research memory _targetResearch = LibResearchs.researchInfo(researchCostResearchs[i]);
                reducedCost += _targetResearch.UtilityValue;
            }
            unchecked {
                i++;
            }
        }

        for (uint j = 0; j < s.MAX_RESOURCE_ID; j++) {
            _research.Cost[j] -= (_research.Cost[j] * reducedCost) / 100;
        }

        // reduce time
        for (uint i = 0; i < researchTimeResearchs.length; ) {
            if (researchCostResearchs[i] != 0 && isResearched(cityId, researchCostResearchs[i])) {}
            Research memory _targetResearch = LibResearchs.researchInfo(researchCostResearchs[i]);
            reducedTime += _targetResearch.UtilityValue;
            unchecked {
                i++;
            }
        }

        for (uint j = 0; j < s.MAX_RESOURCE_ID; j++) {
            _research.TimeRequired -= (_research.TimeRequired * reducedTime) / 100;
        }

        return _research;
    }

    function researchTime(uint cityId, uint resId) external view returns (uint) {
        return s.CityResearchesValidAfter[cityId][resId];
    }

    function isResearched(uint cityId, uint researchId) public view returns (bool) {
        uint validAfter = s.CityResearchesValidAfter[cityId][researchId];
        if (validAfter != 0 && block.timestamp >= validAfter) return true;
        return false;
    }

    function isResearchedBatch(uint cityId, uint[] memory researchIds) external view returns (bool[] memory) {
        bool[] memory result = new bool[](researchIds.length);
        for (uint i = 0; i < researchIds.length; ) {
            uint validAfter = s.CityResearchesValidAfter[cityId][researchIds[i]];
            if (validAfter != 0 && block.timestamp >= validAfter) {
                result[i] = true;
            }
            unchecked {
                i++;
            }
        }
        return result;
    }
}
