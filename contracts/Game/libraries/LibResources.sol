// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {LibCityManager} from "./LibCityManager.sol";
import {Resource} from "../shared/ResourceEnums.sol";
import "../shared/Errors.sol";

library LibResources {
    event ClaimResource(uint indexed cityId, Resource indexed resourceId, uint amount);
    event ClaimTax(uint indexed cityId, uint amount);
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

    function claimDailyTax(uint cityId) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint lastClaimDate = s.LastClaims[cityId][0] + 23 hours;
        if (block.timestamp < lastClaimDate) {
            revert ErrorBadTiming(lastClaimDate, block.timestamp);
        }
        uint amount = claimableGold(cityId);

        s.LastClaims[cityId][uint(0)] = block.timestamp;
        s.CityResources[cityId][uint(0)] += amount;

        emit ClaimTax(cityId, amount);
    }

    function claimableGold(uint cityId) internal view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (block.timestamp < s.LastClaims[cityId][0] + 23 hours) return 0;
        return s.CityList[cityId].Population * s.BaseProductions[0];
    }

    function claimResource(uint cityId, Resource resource) internal {
        uint[] memory limits = getCityStorage(cityId);
        AppStorage storage s = LibAppStorage.diamondStorage();

        _claimSingle(s, cityId, resource, limits[uint(resource)]);
    }

    function _claimCityGold(AppStorage storage s, uint cityId) internal {
        uint _claimableGold = claimableGold(cityId);
        if (_claimableGold > 0) {
            s.LastClaims[cityId][uint(0)] = block.timestamp;
            s.CityResources[cityId][uint(0)] += _claimableGold;
        }
    }

    function claimAllResources(uint cityId) internal {
        uint[] memory limits = getCityStorage(cityId);
        AppStorage storage s = LibAppStorage.diamondStorage();
        _claimCityGold(s, cityId);
        for (uint i = 0; i < s.MAX_RESOURCE_ID; i++) {
            _claimSingle(s, cityId, Resource(i), limits[uint(i)]);
        }
    }

    function _claimSingle(AppStorage storage s, uint cityId, Resource resource, uint limit) internal {
        uint amount = calculateHarvestableResource(cityId, resource);
        if (amount > 0) {
            if (amount > limit) amount = limit;
            s.LastClaims[cityId][uint(resource)] = block.timestamp;
            s.CityResources[cityId][uint(resource)] += amount;
            emit ClaimResource(cityId, resource, amount);
        } else return;
    }

    function getCityStorage(uint cityId) internal view returns (uint[] memory) {
        uint[] memory result = new uint[](5);
        AppStorage storage s = LibAppStorage.diamondStorage();
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
        _claimCityGold(s, cityId);
        for (uint i = 0; i < s.MAX_RESOURCE_ID; ) {
            _claimSingle(s, cityId, Resource(i), limits[uint(i)]);
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

    function calculateHarvestableResource(uint cityId, Resource resource) internal view returns (uint) {
        uint buildingLvl;
        AppStorage storage s = LibAppStorage.diamondStorage();
        // check building lvl, check plot info
        if (resource == Resource.WOOD) {
            buildingLvl = s.BuildingLevels[cityId][1].Tier;
        } else if (resource == Resource.FOOD) {
            buildingLvl = s.BuildingLevels[cityId][2].Tier;
        } else if (resource == Resource.IRON) {
            buildingLvl = s.BuildingLevels[cityId][3].Tier;
        } else if (resource == Resource.STONE) {
            buildingLvl = s.BuildingLevels[cityId][4].Tier;
        }
        uint productionAmount = productionRate(cityId, buildingLvl, resource);
        uint rounds = getRoundsSince(cityId, resource);
        uint produced = rounds * productionAmount;
        return produced;
    }

    function productionRate(uint cityId, uint buildingLvl, Resource resource) internal view returns (uint) {
        if (buildingLvl == 0) return 0;
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint production = s.BaseProductions[uint(resource)] + ((s.BaseProductions[uint(resource)] * (buildingLvl - 1) * 80) / 100);
        /*  if (CityResourceModifiers[cityId][uint(resource)] > int(production)) {
            return 0;
        } */
        return uint(int(production) + s.CityResourceModifiers[cityId][uint(resource)]);
    }

    function getRoundsSince(uint cityId, Resource resource) internal view returns (uint _rounds) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint lastClaim = s.LastClaims[cityId][uint(resource)];
        uint mintTime = s.CityList[cityId].CreationDate;
        if (mintTime == 0) {
            revert ErrorNull(mintTime);
        }
        uint elapsed = block.timestamp - (lastClaim == 0 ? mintTime : lastClaim);
        _rounds = elapsed / s.PROD_CYCLE;
    }

    function updateModifier(uint cityId, Resource resource, int value) internal returns (int _newModifier) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.CityResourceModifiers[cityId][uint(resource)] += value;
        return s.CityResourceModifiers[cityId][uint(resource)];
    }
}
