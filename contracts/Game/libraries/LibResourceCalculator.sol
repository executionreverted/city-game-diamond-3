// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {LibCityManager} from "./LibCityManager.sol";
import {LibResearchManager} from "./LibResearchManager.sol";
import {Resource} from "../shared/ResourceEnums.sol";
import {ProductionArgs} from "../shared/ResourceStructs.sol";
import {Resource} from "../shared/ResourceEnums.sol";
import {Research} from "../shared/ResearchStructs.sol";
import {ResearchBonusType} from "../shared/ResearchEnums.sol";
import {IFetchGlobal} from "../interfaces/IFetchGlobal.sol";
import "../shared/Errors.sol";

library LibResourceCalculator {
    event ClaimTax(uint indexed cityId, uint amount);
    event ClaimResource(uint indexed cityId, Resource indexed resourceId, uint amount);

    function claimAllResources(AppStorage storage s, uint cityId, uint[] memory limits, uint resourceBoostAmount) internal {
        for (uint i = 1; i < s.MAX_RESOURCE_ID; i++) {
            LibResourceCalculator._claimSingle(s, cityId, Resource(i), limits[uint(i)], resourceBoostAmount);
        }
    }

    function claimResource(AppStorage storage s, uint cityId, Resource resource, uint limit) internal {
        (uint resourceBoostAmount, ) = resourceResearchBonus(cityId);
        LibResourceCalculator._claimSingle(s, cityId, resource, limit, resourceBoostAmount);
    }

    function _claimCityGold(AppStorage storage s, uint cityId, uint _claimableGold) internal {
        if (_claimableGold > 0) {
            s.LastClaims[cityId][uint(0)] = block.timestamp;
            s.CityResources[cityId][uint(0)] += _claimableGold;
            emit ClaimTax(cityId, _claimableGold);
        }
    }

    function claimableGold(AppStorage storage s, uint cityId) internal view returns (uint) {
        if (block.timestamp < s.LastClaims[cityId][0] + 23 hours) return 0;
        // add research boost.
        return s.CityList[cityId].Population * s.BaseProductions[0];
    }

    function _claimSingle(AppStorage storage s, uint cityId, Resource resource, uint limit, uint boostAmount) internal {
        uint amount = calculateHarvestableResource(s, cityId, resource, boostAmount);
        if (amount > 0) {
            if (amount > limit) amount = limit;
            s.LastClaims[cityId][uint(resource)] = block.timestamp;
            s.CityResources[cityId][uint(resource)] += amount;
            emit ClaimResource(cityId, resource, amount);
        } else return;
    }

    function calculateHarvestableResource(AppStorage storage s, uint cityId, Resource resource, uint boostAmount) internal view returns (uint) {
        uint buildingLvl;
        // check building lvl, check plot info
        if (resource == Resource.WOOD) {
            buildingLvl = s.BuildingLevels[cityId][1].Tier;
            if (block.timestamp < s.BuildingLevelActivationTime[cityId][1]) {
                buildingLvl -= 1;
            }
        } else if (resource == Resource.STONE) {
            buildingLvl = s.BuildingLevels[cityId][2].Tier;
            if (block.timestamp < s.BuildingLevelActivationTime[cityId][2]) {
                buildingLvl -= 1;
            }
        } else if (resource == Resource.IRON) {
            buildingLvl = s.BuildingLevels[cityId][3].Tier;
            if (block.timestamp < s.BuildingLevelActivationTime[cityId][3]) {
                buildingLvl -= 1;
            }
        } else if (resource == Resource.FOOD) {
            buildingLvl = s.BuildingLevels[cityId][4].Tier;
            if (block.timestamp < s.BuildingLevelActivationTime[cityId][4]) {
                buildingLvl -= 1;
            }
        }
        uint productionAmount = productionRate(
            s,
            ProductionArgs({cityId: cityId, buildingLvl: buildingLvl, resource: resource, boostAmount: boostAmount})
        );
        uint rounds = getRoundsSince(s, cityId, resource);
        uint produced = rounds * productionAmount;
        return produced;
    }

    function productionRate(AppStorage storage s, ProductionArgs memory _args) internal view returns (uint) {
        if (_args.buildingLvl == 0) return 0;
        if (_args.buildingLvl == 1) {
            uint p = s.BaseProductions[uint(_args.resource)];
            return p + (p * _args.boostAmount) / 100;
        }
        uint production = s.BaseProductions[uint(_args.resource)] + ((s.BaseProductions[uint(_args.resource)] * (_args.buildingLvl - 1) * 80) / 100);

        // uint allBoostAmount;
        // uint[] memory allResourceBoostResearchs = LibResearchManager.researchIdsByBonusType(ResearchBonusType.REDUCE_RESEARCH_COST);

        // add all research bonuses
        // add specific resource boosts

        production += (production * _args.boostAmount) / 100;
        return production;
    }

    function getRoundsSince(AppStorage storage s, uint cityId, Resource resource) internal view returns (uint _rounds) {
        uint lastClaim = s.LastClaims[cityId][uint(resource)];
        uint mintTime = s.CityList[cityId].CreationDate;
        if (mintTime == 0) {
            revert ErrorNull(mintTime);
        }
        uint elapsed = block.timestamp - (lastClaim == 0 ? mintTime : lastClaim);
        _rounds = elapsed / s.PROD_CYCLE;
    }

    function resourceResearchBonus(uint cityId) internal view returns (uint, uint) {
        uint resourceBoostAmount;
        uint goldBoostAmount;
        uint[] memory resourceBoostResearchs = LibResearchManager.researchIdsByBonusType(ResearchBonusType.WOOD_BONUS);
        for (uint i = 0; i < resourceBoostResearchs.length; i++) {
            if (resourceBoostResearchs[i] != 0 && LibResearchManager.isResearched(cityId, resourceBoostResearchs[i])) {
                // Research memory _targetResearch = LibResearchs.researchInfo(resourceBoostResearchs[i]);
                Research memory _targetResearch = IFetchGlobal(address(this)).researchInfo(resourceBoostResearchs[i]);
                resourceBoostAmount += _targetResearch.UtilityValue;
            }
        }
        uint[] memory goldBonusResearchs = LibResearchManager.researchIdsByBonusType((ResearchBonusType.GOLD_BONUS));
        for (uint i = 0; i < goldBonusResearchs.length; i++) {
            if (LibResearchManager.isResearched(cityId, goldBonusResearchs[i])) {
                Research memory _research = IFetchGlobal(address(this)).researchInfo(goldBonusResearchs[i]);
                goldBoostAmount += _research.UtilityValue;
            }
        }
        return (resourceBoostAmount, goldBoostAmount);
    }
}
