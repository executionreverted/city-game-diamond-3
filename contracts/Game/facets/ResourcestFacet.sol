// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {Resource} from "../shared/ResourceEnums.sol";
import {AppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibResources} from "../libraries/LibResources.sol";
import "../shared/Errors.sol";

contract ResourcesFacet is Modifiers {
    function claimDailyTax(uint cityId) external onlyCityOwner(cityId) {
        LibResources.claimDailyTax(cityId);
    }

    function claimableGold(uint cityId) external view returns (uint) {
        if (block.timestamp < s.LastClaims[cityId][0] + 23 hours) return 0;
        return s.CityList[cityId].Population * s.BaseProductions[0];
    }

    function claimAllResources(uint cityId) external onlyCityOwner(cityId) {
        LibResources.claimAllResources(cityId);
    }

    function claimResource(uint cityId, Resource resource) external onlyCityOwner(cityId) {
        uint[] memory limits = LibResources.getCityStorage(cityId);
        LibResources._claimSingle(s, cityId, resource, limits[uint(resource)]);
    }

    function cityResourceModifiers(uint256 cityId, Resource resource) external view returns (int256) {
        return s.CityResourceModifiers[cityId][uint(resource)];
    }

    function cityResources(uint256 cityId, Resource resource) external view returns (uint256) {
        return s.CityResources[cityId][uint(resource)];
    }

    function lastClaims(uint256 cityId, Resource resource) external view returns (uint256) {
        return s.LastClaims[cityId][uint(resource)];
    }
}
