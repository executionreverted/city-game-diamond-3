// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {LibCityManager} from "../libraries/LibCityManager.sol";
import {LibBuildings} from "../libraries/LibBuildings.sol";
import {LibResources} from "../libraries/LibResources.sol";
import {LibResourceCalculator} from "../libraries/LibResourceCalculator.sol";
import {LibResearchManager} from "../libraries/LibResearchManager.sol";
import {IFetchGlobal} from "../interfaces/IFetchGlobal.sol";
import {Modifiers} from "../libraries/LibAppStorage.sol";
import {Coords} from "../shared/WorldStructs.sol";
import {City, Building} from "../shared/CityStructs.sol";
import {Race} from "../shared/CityEnums.sol";
import {Research} from "../shared/ResearchStructs.sol";
import {ResearchBonusType} from "../shared/ResearchEnums.sol";
import "../shared/Errors.sol";
//  LibResourceCalculator.claimAllResources(s, cityId, limits);

// Access Control
import "../../shared/interfaces/IERC173.sol";

contract CityManagerFacet is Modifiers {
    event BuildingUpgraded(uint indexed cityId, uint indexed buildingId, uint newTier, uint when);
    event CityPopulationUpdate(uint indexed cityId, uint population);

    function setPremiumStatus(uint cityId, uint premiumTier, uint _days) external onlyManager {
        LibCityManager.setPremiumStatus(cityId, premiumTier, _days);
    }

    function premiumStatus(uint cityId) external view returns (uint _tier, uint _expirationDate) {
        _tier = s.CITY_PREMIUM_STATUS[cityId];
        _expirationDate = s.CITY_PREMIUM_EXPIRE_DATE[cityId];
    }

    function racePopulation(uint _race) external view returns (uint) {
        return s.RacePopulation[_race];
    }

    function race(uint cityId) external view returns (Race) {
        return s.CityList[cityId].Race;
    }

    function city(uint cityId) external view returns (City memory) {
        return s.CityList[cityId];
    }

    function cityPopulation(uint cityId) external view returns (uint) {
        return s.CityList[cityId].Population;
    }

    function buildingLevel(uint cityId, uint buildingId) external view returns (uint result) {
        result = s.BuildingLevels[cityId][buildingId].Tier;
        if (result == 0) return result;
        if (block.timestamp < s.BuildingLevelActivationTime[cityId][buildingId]) {
            result -= 1;
        }
        return result;
    }

    function buildingLevels(uint cityId) external view returns (Building[] memory) {
        uint MAX_BUILDING_ID = s.MAX_BUILDING_ID;
        Building[] memory result = new Building[](MAX_BUILDING_ID);
        for (uint i = 0; i < MAX_BUILDING_ID; ) {
            result[i] = s.BuildingLevels[cityId][i];
            if (block.timestamp < s.BuildingLevelActivationTime[cityId][i]) {
                result[i].Tier -= 1;
            }
            unchecked {
                i++;
            }
        }
        return result;
    }

    function upgradeBuilding(uint cityId, uint buildingId, bool autoClaim) external onlyCityOwner(cityId) {
        uint MAX_RESOURCE_ID = s.MAX_RESOURCE_ID;
        uint BuildingLevelActivationTime = s.BuildingLevelActivationTime[cityId][buildingId];
        if (block.timestamp < BuildingLevelActivationTime) {
            revert ErrorBadTiming(BuildingLevelActivationTime, block.timestamp);
        }

        uint currentTier = s.BuildingLevels[cityId][buildingId].Tier;
        Building memory _building = IFetchGlobal(address(this)).buildingInfo(buildingId);
        if (_building.MaxTier <= currentTier) {
            revert ErrorExceeds(_building.MaxTier, currentTier);
        }
        (uint reducedTime, uint reducedCost) = buildingResearchModifiers(cityId);
        // calculate resources
        uint[] memory _costs = new uint[](MAX_RESOURCE_ID);
        for (uint i = 0; i < MAX_RESOURCE_ID; i++) {
            _costs[i] = _building.Cost[currentTier + 1][i] - ((_building.Cost[currentTier + 1][i] * reducedCost) / 100);
        }

        LibResources.spendResources(cityId, _costs, autoClaim);
        s.BuildingLevels[cityId][buildingId].Tier++;
        uint Deadline = block.timestamp + (_building.UpgradeTime[currentTier] - ((_building.UpgradeTime[currentTier] * reducedTime)) / 100);

        // implement research and reductions
        s.BuildingLevelActivationTime[cityId][buildingId] = Deadline;

        emit BuildingUpgraded(cityId, buildingId, currentTier + 1, Deadline);
    }

    function buildingResearchModifiers(uint cityId) public view returns (uint reducedupgradeTime, uint reducedupgradeCost) {
        uint[] memory upgradeTimeResearchs = LibResearchManager.researchIdsByBonusType(ResearchBonusType.REDUCE_BUILDING_TIME);
        uint[] memory upgradeCostResearchs = LibResearchManager.researchIdsByBonusType(ResearchBonusType.REDUCE_BUILDING_COST);
        for (uint i = 0; i < upgradeTimeResearchs.length; i++) {
            if (LibResearchManager.isResearched(cityId, upgradeTimeResearchs[i])) {
                Research memory _research = IFetchGlobal(address(this)).researchInfo(upgradeTimeResearchs[i]);
                reducedupgradeTime += _research.UtilityValue;
            }
        }
        for (uint i = 0; i < upgradeCostResearchs.length; i++) {
            if (LibResearchManager.isResearched(cityId, upgradeCostResearchs[i])) {
                Research memory _research = IFetchGlobal(address(this)).researchInfo(upgradeCostResearchs[i]);
                reducedupgradeCost += _research.UtilityValue;
            }
        }
    }

    function recruitPopulation(uint cityId) external onlyCityOwner(cityId) {
        City memory _city = s.CityList[cityId];
        if (!_city.Alive) {
            revert ErrorAssertion(_city.Alive, false);
        }
        uint _recruitable = calculateRecruitable(cityId);
        if (_recruitable > 0) {
            s.PopulationClaimDates[cityId] = block.timestamp + 1 days;
            s.CityList[cityId].Population = _city.Population + _recruitable;
        } else revert ErrorNull(_recruitable);
        emit CityPopulationUpdate(cityId, _city.Population + _recruitable);
    }

    function calculateRecruitable(uint cityId) public view returns (uint) {
        if (block.timestamp < s.PopulationClaimDates[cityId]) {
            /* revert ErrorBadTiming(
                PopulationClaimDates[cityId],
                block.timestamp
            ); */
            return 0;
        }

        uint _recruitable;
        City memory _city = s.CityList[cityId];

        uint _townhallTier = s.BuildingLevels[cityId][0].Tier;
        uint _housingsTier = s.BuildingLevels[cityId][8].Tier;
        // fetch townhall lvl & housing, give bonus daily population, 4 townhall & 7 housing
        _recruitable += _townhallTier;
        _recruitable += _housingsTier * 2;
        uint cap = _townhallTier * s.POPULATION_CAP_PER_TOWNHALL_TIER;
        if (_city.Population + _recruitable >= cap) {
            if (_city.Population <= cap) {
                _recruitable = cap - _city.Population;
            } else {
                _recruitable = 0;
            }
        }
        return _recruitable;
    }

    function buildingUpgradeCompletionTimes(uint cityId) external view returns (uint[] memory) {
        uint[] memory result = new uint[](s.MAX_BUILDING_ID);
        for (uint i = 0; i < s.MAX_BUILDING_ID; ) {
            result[i] = s.BuildingLevelActivationTime[cityId][i];
            unchecked {
                i++;
            }
        }
        return result;
    }
}
