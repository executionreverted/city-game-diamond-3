// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {LibCityManager} from "../libraries/LibCityManager.sol";
import {LibBuildings} from "../libraries/LibBuildings.sol";
import {LibResources} from "../libraries/LibResources.sol";
import {Modifiers} from "../libraries/LibAppStorage.sol";
import {Coords} from "../shared/WorldStructs.sol";
import {City, Building} from "../shared/CityStructs.sol";
import {Race} from "../shared/CityEnums.sol";
import "../shared/Errors.sol";

// Access Control
import "../../shared/interfaces/IERC173.sol";

contract CityManagerFacet is Modifiers {
    event BuildingUpgraded(uint indexed cityId, uint indexed buildingId, uint newTier, uint when);
    event CityPopulationUpdate(uint indexed cityId, uint population);

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

    function upgradeBuilding(uint cityId, uint buildingId) external onlyCityOwner(cityId) {
        uint MAX_RESOURCE_ID = s.MAX_RESOURCE_ID;
        uint BuildingLevelActivationTime = s.BuildingLevelActivationTime[cityId][buildingId];
        if (block.timestamp < BuildingLevelActivationTime) {
            revert ErrorBadTiming(BuildingLevelActivationTime, block.timestamp);
        }

        uint currentTier = s.BuildingLevels[cityId][buildingId].Tier;
        Building memory _building = LibBuildings.buildingInfo(buildingId);
        if (_building.MaxTier <= currentTier) {
            revert ErrorExceeds(_building.MaxTier, currentTier);
        }

        // calculate resources
        uint[] memory _costs = new uint[](MAX_RESOURCE_ID);
        for (uint i = 0; i < MAX_RESOURCE_ID; i++) {
            _costs[i] = _building.Cost[currentTier + 1][i];
        }
        LibResources.spendResources(cityId, _costs);
        s.BuildingLevels[cityId][buildingId].Tier++;
        uint Deadline = block.timestamp + _building.UpgradeTime[currentTier];

        // implement research and reductions
        s.BuildingLevelActivationTime[cityId][buildingId] = Deadline;

        emit BuildingUpgraded(cityId, buildingId, currentTier + 1, Deadline);
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
}
