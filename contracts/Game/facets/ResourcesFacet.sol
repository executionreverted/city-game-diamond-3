// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {Resource} from "../shared/ResourceEnums.sol";
import {AppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibResources} from "../libraries/LibResources.sol";
import {LibResearchManager} from "../libraries/LibResearchManager.sol";
import {LibResearchs} from "../libraries/LibResearchs.sol";
import {LibResourceCalculator} from "../libraries/LibResourceCalculator.sol";
import {ProductionArgs} from "../shared/ResourceStructs.sol";
import {ResearchBonusType} from "../shared/ResearchEnums.sol";
import "../shared/Errors.sol";

contract ResourcesFacet is Modifiers {
    function addResource(uint cityId, Resource resource, uint _amount) external onlyManager {
        LibResources.addResource(cityId, resource, _amount);
    }

    function claimDailyTax(uint cityId) external onlyCityOwner(cityId) {
        LibResourceCalculator._claimCityGold(s, cityId);
    }

    function claimAllResources(uint cityId) external onlyCityOwner(cityId) {
        LibResourceCalculator._claimCityGold(s, cityId);
        LibResourceCalculator.claimAllResources(s, cityId, getCityStorage(cityId));
    }

    function claimableGold(uint cityId) public view returns (uint) {
        if (block.timestamp < s.LastClaims[cityId][0] + 23 hours) return 0;
        // add research boost.
        return s.CityList[cityId].Population * s.BaseProductions[0];
    }

    function claimResource(uint cityId, Resource resource) external onlyCityOwner(cityId) {
        uint[] memory limits = getCityStorage(cityId);
        LibResourceCalculator.claimResource(s, cityId, resource, limits[uint(resource)]);
    }

    function getCityStorage(uint cityId) internal view returns (uint[] memory) {
        return LibResources.getCityStorage(cityId);
    }

    function cityResources(uint256 cityId, Resource resource) external view returns (uint256) {
        return s.CityResources[cityId][uint(resource)];
    }

    function harvestableResources(uint256 cityId) external view returns (uint256[] memory) {
        uint[] memory claimable = new uint[](s.MAX_RESOURCE_ID);
        uint resourceBoostAmount = LibResourceCalculator.resourceResearchBonus(cityId, ResearchBonusType.WOOD_BONUS);
        for (uint i = 1; i < claimable.length; i++) {
            claimable[i] = LibResourceCalculator.calculateHarvestableResource(s, cityId, Resource(i), resourceBoostAmount);
        }
        return claimable;
    }

    function resourcesPerTick(uint256 cityId) external view returns (uint256[] memory) {
        uint[] memory claimable = new uint[](s.MAX_RESOURCE_ID);
        uint resourceBoostAmount = LibResourceCalculator.resourceResearchBonus(cityId, ResearchBonusType.WOOD_BONUS);

        for (uint i = 1; i < claimable.length; i++) {
            uint buildingLevel = s.BuildingLevels[cityId][i].Tier;
            if (block.timestamp < s.BuildingLevelActivationTime[cityId][i]) {
                buildingLevel -= 1;
            }

            claimable[i] = LibResourceCalculator.productionRate(
                s,
                ProductionArgs({cityId: cityId, resource: Resource(i), boostAmount: resourceBoostAmount, buildingLvl: buildingLevel})
            );
        }
        return claimable;
    }

    function resourceResearchBonus(uint256 cityId) external view returns (uint256) {
        uint resourceBoostAmount = LibResourceCalculator.resourceResearchBonus(cityId, ResearchBonusType.WOOD_BONUS);
        return resourceBoostAmount;
    }

    function lastClaims(uint256 cityId, Resource resource) external view returns (uint256) {
        return s.LastClaims[cityId][uint(resource)];
    }
}
