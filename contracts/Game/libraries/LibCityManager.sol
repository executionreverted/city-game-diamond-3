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

    function setPremiumStatus(uint cityId, uint premiumTier, uint _days) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.CITY_PREMIUM_STATUS[cityId] = premiumTier;
        s.CITY_PREMIUM_EXPIRE_DATE[cityId] = block.timestamp + (_days * 1 days);
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
