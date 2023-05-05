// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {Resource} from "../shared/ResourceEnums.sol";
import {AppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibResources} from "../libraries/LibResources.sol";
import {LibResearchManager} from "../libraries/LibResearchManager.sol";
import {LibResearchs} from "../libraries/LibResearchs.sol";
import {Research} from "../shared/ResearchStructs.sol";
import {LibResourceCalculator} from "../libraries/LibResourceCalculator.sol";
import {ProductionArgs} from "../shared/ResourceStructs.sol";
import {ResearchBonusType} from "../shared/ResearchEnums.sol";
import {IFetchGlobal} from "../interfaces/IFetchGlobal.sol";
import "../shared/Errors.sol";

contract ResourcesFacet is Modifiers {
    function addResource(uint cityId, Resource resource, uint _amount) external onlyManager {
        LibResources.addResource(cityId, resource, _amount);
    }

    function claimDailyTax(uint cityId) external onlyCityOwner(cityId) {
        LibResourceCalculator._claimCityGold(s, cityId, claimableGold(cityId, false));
    }

    function claimAllResources(uint cityId) external onlyCityOwner(cityId) {
        (uint resourceBoostAmount, uint goldBoost) = resourceResearchBonus(cityId);
        uint claimable = (s.CityList[cityId].Population * s.BaseProductions[0]);

        LibResourceCalculator._claimCityGold(s, cityId, claimable + ((claimable * goldBoost) / 100));
        LibResourceCalculator.claimAllResources(s, cityId, getCityStorage(cityId), resourceBoostAmount);
    }

    function claimableGold(uint cityId, bool ignoreCurrentTimestamp) public view returns (uint) {
        if (!ignoreCurrentTimestamp && block.timestamp < s.LastClaims[cityId][0] + 23 hours) return 0;
        // add research boost.
        (, uint goldBoost) = resourceResearchBonus(cityId);
        uint claimable = (s.CityList[cityId].Population * s.BaseProductions[0]);
        return claimable + ((claimable * goldBoost) / 100);
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
        uint[] memory limits = getCityStorage(cityId);
        uint[] memory claimable = new uint[](s.MAX_RESOURCE_ID);
        (uint resourceBoostAmount, uint goldBoost) = resourceResearchBonus(cityId);
        claimable[0] = LibResourceCalculator.calculateHarvestableResource(s, cityId, Resource(0), resourceBoostAmount + goldBoost);
        for (uint i = 1; i < claimable.length; i++) {
            claimable[i] = LibResourceCalculator.calculateHarvestableResource(s, cityId, Resource(i), resourceBoostAmount);
            if (claimable[i] > limits[i]) {
                claimable[i] = limits[i];
            }
        }
        return claimable;
    }

    function resourcesPerTick(uint256 cityId) external view returns (uint256[] memory) {
        uint[] memory claimable = new uint[](s.MAX_RESOURCE_ID);
        (uint resourceBoostAmount, ) = LibResourceCalculator.resourceResearchBonus(cityId);

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

    function resourceResearchBonus(uint256 cityId) public view returns (uint256 resourceBoostAmount, uint256 goldBoostAmount) {
        (uint resourceBoostAmount$, ) = LibResourceCalculator.resourceResearchBonus(cityId);
        uint[] memory goldBonusResearchs = LibResearchManager.researchIdsByBonusType((ResearchBonusType.GOLD_BONUS));
        for (uint i = 0; i < goldBonusResearchs.length; i++) {
            if (LibResearchManager.isResearched(cityId, goldBonusResearchs[i])) {
                Research memory _research = IFetchGlobal(address(this)).researchInfo(goldBonusResearchs[i]);
                goldBoostAmount += _research.UtilityValue;
            }
        }
        resourceBoostAmount = resourceBoostAmount$;
    }

    function lastClaims(uint256 cityId, Resource resource) external view returns (uint256) {
        return s.LastClaims[cityId][uint(resource)];
    }
}
