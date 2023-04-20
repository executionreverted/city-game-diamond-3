// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {LibCityManager} from "./LibCityManager.sol";
import {LibResearchManager} from "./LibResearchManager.sol";
import {LibResearchs} from "./LibResearchs.sol";
import {LibResourceCalculator} from "./LibResourceCalculator.sol";
import {Resource} from "../shared/ResourceEnums.sol";
import "../shared/Errors.sol";

library LibResources {
    event SpendResource(uint indexed cityId, Resource indexed resource, uint amount);

    function addResource(uint cityId, Resource resource, uint _amount) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.CityResources[cityId][uint(resource)] += _amount;
    }

    function wrapResource(uint cityId, Resource resource) internal {
        // burn resource and wrap it in nft
    }

    function unwrapResource(uint cityId, uint nftId) internal {
        // burn nft and unwrap resource
    }

    function getCityStorage(uint cityId) internal view returns (uint[] memory) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint[] memory result = new uint[](5);
        uint tier = s.BuildingLevels[cityId][s.WAREHOUSE_ID].Tier;

        result[0] = s.BASE_GOLD_MAX + (s.WAREHOUSE_STORAGE_PER_TIER * tier);
        result[1] = s.BASE_WOOD_MAX + (s.WAREHOUSE_STORAGE_PER_TIER * tier);
        result[2] = s.BASE_STONE_MAX + (s.WAREHOUSE_STORAGE_PER_TIER * tier);
        result[3] = s.BASE_IRON_MAX + (s.WAREHOUSE_STORAGE_PER_TIER * tier);
        result[4] = s.BASE_FOOD_MAX + (s.WAREHOUSE_STORAGE_PER_TIER * tier);

        return (result);
    }

    function spendResources(uint cityId, uint[] memory amounts) internal {
        uint[] memory limits = getCityStorage(cityId);
        AppStorage storage s = LibAppStorage.diamondStorage();
        LibResourceCalculator.claimAllResources(s, cityId, limits);
        for (uint i = 0; i < s.MAX_RESOURCE_ID; ) {
            if (amounts[i] == 0) continue;
            if (amounts[i] > s.CityResources[cityId][uint(i)]) revert ErrorExceeds(amounts[i], s.CityResources[cityId][uint(i)]);
            s.CityResources[cityId][uint(i)] -= amounts[i];
            emit SpendResource(cityId, Resource(i), amounts[i]);
            unchecked {
                i++;
            }
        }
    }

    function spendResource(uint cityId, uint amount, Resource resource) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (amount >= s.CityResources[cityId][uint(resource)]) revert("exceeds");

        s.CityResources[cityId][uint(resource)] -= amount;
        emit SpendResource(cityId, resource, amount);
    }
}
