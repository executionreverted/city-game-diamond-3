// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {LibCityManager} from "../libraries/LibCityManager.sol";
import {Modifiers} from "../libraries/LibAppStorage.sol";
import {Coords} from "../shared/WorldStructs.sol";
import {City, Building} from "../shared/CityStructs.sol";
import {Race} from "../shared/CityEnums.sol";

// Access Control
import "../../shared/interfaces/IERC173.sol";

contract CityManagerFacet is Modifiers {
    function racePopulation(uint _race) external view returns (uint) {
        return s.RacePopulation[_race];
    }

    function race(uint cityId) external view returns (Race) {
        return s.CityList[cityId].Race;
    }

    function city(uint cityId) external view returns (City memory) {
        return s.CityList[cityId];
    }

    function recruitPopulation(uint cityId) external onlyCityOwner(cityId) {
        LibCityManager.recruitPopulation(cityId);
    }

    function cityPopulation(uint cityId) external view returns (uint) {
        return s.CityList[cityId].Population;
    }

    function calculateRecruitable(uint cityId) external view returns (uint) {
        return LibCityManager.calculateRecruitable(cityId);
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
        LibCityManager.upgradeBuilding(cityId, buildingId);
    }
}
