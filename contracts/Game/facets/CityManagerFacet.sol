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
    function cityPopulation(uint cityId) internal view returns (uint) {
        return s.CityList[cityId].Population;
    }

    function buildingLevel(uint cityId, uint buildingId) internal view returns (uint result) {
        result = s.BuildingLevels[cityId][buildingId].Tier;
        if (result == 0) return result;
        if (block.timestamp < s.BuildingLevelActivationTime[cityId][buildingId]) {
            result -= 1;
        }
        return result;
    }

    function buildingLevels(uint cityId) internal view returns (Building[] memory) {
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

    function upgradeBuilding(uint cityId, uint buildingId) external onlyCityOwner(cityId) returns (bool) {
        LibCityManager.upgradeBuilding(cityId, buildingId);
    }
}
