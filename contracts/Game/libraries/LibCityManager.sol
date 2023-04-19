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
    event CityCoordsUpdate(uint indexed cityId, Coords coords);
    event CityRaceUpdate(uint indexed cityId, Race race);
    event CityAliveUpdate(uint indexed cityId, bool value);

   
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
