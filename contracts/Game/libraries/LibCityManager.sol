// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {City, Race, Building} from "../shared/CityStructs.sol";
import {Coords} from "../shared/WorldStructs.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {LibBuildings} from "./LibBuildings.sol";
import {LibResources} from "./LibResources.sol";
import "../shared/Errors.sol";

library LibCityManager {
    event BuildingUpgraded(uint indexed cityId, uint indexed buildingId, uint newTier, uint when);
    event CityCoordsUpdate(uint indexed cityId, Coords coords);
    event CityRaceUpdate(uint indexed cityId, Race race);
    event CityAliveUpdate(uint indexed cityId, bool value);
    event CityPopulationUpdate(uint indexed cityId, uint population);

   
    function race(uint cityId) internal view returns (Race) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.CityList[cityId].Race;
    }

    function city(uint cityId) internal view returns (City memory) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.CityList[cityId];
    }

    // function mintTime(uint cityId) public view returns (uint) {
    //     AppStorage storage s = LibAppStorage.diamondStorage();
    //     return s.CityList[cityId].CreationDate;
    // }

    function recruitPopulation(uint cityId) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
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

    function calculateRecruitable(uint cityId) internal view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
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

    function upgradeBuilding(uint cityId, uint buildingId) internal returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
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
        return true;
    }

    function updateCityCoords(uint cityId, Coords memory _param) internal returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.CityList[cityId].Coords = _param;
        emit CityCoordsUpdate(cityId, _param);
        return true;
    }

    function updateCityRace(uint cityId, Race _param) internal returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.RacePopulation[uint(s.CityList[cityId].Race)]--;
        s.CityList[cityId].Race = _param;
        s.RacePopulation[uint(_param)]++;
        emit CityRaceUpdate(cityId, _param);
        return true;
    }

    function updateCityAlive(uint cityId, bool _param) internal returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.CityList[cityId].Alive = _param;
        emit CityAliveUpdate(cityId, _param);
        return true;
    }

    function updateCityPopulation(uint cityId, uint _param) internal returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.CityList[cityId].Population = _param;
        return true;
    }

    function setCity(uint cityId, City memory _city) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.CityList[cityId] = _city;
        s.RacePopulation[uint(_city.Race)]++;
        s.BuildingLevels[cityId][0].Tier = 1;
        s.BuildingLevelActivationTime[cityId][0] = block.timestamp;
        s.BuildingLevels[cityId][1].Tier = 1;
        s.BuildingLevelActivationTime[cityId][1] = block.timestamp;
        s.BuildingLevels[cityId][2].Tier = 1;
        s.BuildingLevelActivationTime[cityId][2] = block.timestamp;
        s.BuildingLevels[cityId][3].Tier = 1;
        s.BuildingLevelActivationTime[cityId][3] = block.timestamp;
        s.BuildingLevels[cityId][4].Tier = 1;
        s.BuildingLevelActivationTime[cityId][4] = block.timestamp;
    }
}
