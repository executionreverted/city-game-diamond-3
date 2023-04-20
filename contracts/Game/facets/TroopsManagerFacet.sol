// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {LibAppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibResources} from "../libraries/LibResources.sol";
import {LibCityManager} from "../libraries/LibCityManager.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {LibResearchManager} from "../libraries/LibResearchManager.sol";
import {LibTroopsManager} from "../libraries/LibTroopsManager.sol";
import {LibTroops} from "../libraries/LibTroops.sol";
import {Coords} from "../shared/WorldStructs.sol";
import {IFetchGlobal} from "../interfaces/IFetchGlobal.sol";
import {Squad, Purpose, Troop, Training} from "../shared/TroopsStructs.sol";
import {Resource} from "../shared/ResourceEnums.sol";
import {Research} from "../shared/ResearchStructs.sol";
import {ResearchBonusType} from "../shared/ResearchEnums.sol";
import "../shared/Errors.sol";

contract TroopsManagerFacet is Modifiers {
    using EnumerableSet for EnumerableSet.UintSet;
    struct RecruitArgs {
        uint8[] troopIds;
        uint[] _costs;
        uint[] amounts;
        uint cityId;
        uint _population;
        uint _timeRequired;
        bool useAutoClaim;
    }
    event Recruitment(uint indexed cityId, uint indexed troopId, uint amount);

    function troopInfo(uint troopId) external pure returns (Troop memory) {
        return LibTroops.troopInfo(troopId);
    }

    function troopsOfCity(uint cityId) external view returns (uint8[] memory, uint[] memory) {
        return LibTroopsManager.troopsOfCity(cityId);
    }

    function cityTroops(uint cityId, uint troopId) external view returns (uint) {
        return s.CityTroops[cityId][troopId];
    }

    function recruitTroops(uint cityId, uint8[] calldata troopIds, uint[] calldata amounts, bool useAutoClaim) external onlyCityOwner(cityId) {
        if (troopIds.length != amounts.length) {
            revert ErrorAssertion(troopIds.length == amounts.length, false);
        }
        uint _population;
        uint _timeRequired;
        uint[] memory _costs = new uint[](s.MAX_RESOURCE_ID);
        for (uint i = 0; i < amounts.length; ) {
            if (amounts[i] == 0) {
                revert ErrorNull(amounts[i]);
            }
            // check requirements, burn and set resource modifier
            Troop memory _troop = LibTroops.troopInfo(troopIds[i]);
            // int _modifier;
            // check population

            for (uint y = 0; y < s.MAX_RESOURCE_ID; y++) {
                _costs[y] += _troop.Cost.ResourceCost[y] * amounts[i];
                _timeRequired += _troop.Cost.TimeRequired * amounts[i];
            }

            _population += _troop.Population * amounts[i];
            unchecked {
                i++;
            }
        }
        _recruit(
            RecruitArgs({
                troopIds: troopIds,
                _costs: _costs,
                amounts: amounts,
                cityId: cityId,
                _population: _population,
                _timeRequired: _timeRequired,
                useAutoClaim: useAutoClaim
            })
        );
    }

    function _recruit(RecruitArgs memory args) internal {
        if (s.TrainingGoingOn[args.cityId].length() > s.MAX_TRAINING) {
            revert ErrorExceeds(s.TrainingGoingOn[args.cityId].length(), s.MAX_TRAINING);
        }

        uint _cityPopulation = s.CityList[args.cityId].Population;
        if (_cityPopulation < args._population) {
            revert ErrorExceeds(_cityPopulation, args._population);
        }
        (uint[] memory costs, uint finalTime) = reduceCosts(args.cityId, args._costs, args._timeRequired);
        LibResources.spendResources(args.cityId, costs, args.useAutoClaim);
        s.CityList[args.cityId].Population = (_cityPopulation - args._population);
        s.TrainingGoingOn[args.cityId].add(s.trainingNonce);
        s.Trainings[s.trainingNonce] = Training({TroopAmounts: args.amounts, TroopIds: args.troopIds, EndTime: block.timestamp + finalTime});
        s.trainingNonce++;
    }

    function finalizeTraining(uint cityId, uint trainingId) external onlyCityOwner(cityId) {
        if (!s.TrainingGoingOn[cityId].contains(trainingId)) {
            revert ErrorUnauthorized(LibMeta.msgSender());
        }
        Training memory _training = s.Trainings[trainingId];
        if (_training.EndTime > block.timestamp) {
            revert ErrorBadTiming(block.timestamp, _training.EndTime);
        }

        s.TrainingGoingOn[cityId].remove(trainingId);
        for (uint i = 0; i < _training.TroopIds.length; i++) {
            s.CityTroops[cityId][_training.TroopIds[i]] += _training.TroopAmounts[i];
            emit Recruitment(cityId, _training.TroopIds[i], _training.TroopAmounts[i]);
        }
    }

    function reduceCosts(uint cityId, uint[] memory _costs, uint timeRequired) internal view returns (uint[] memory, uint) {
        (uint timeReduced, uint costReduced) = troopResearchModifiers(cityId);
        for (uint i = 0; i < _costs.length; i++) {
            _costs[i] -= (_costs[i] * costReduced) / 100;
        }

        return (_costs, (timeRequired - ((timeRequired * timeReduced) / 100)));
    }

    // function recruitTroop(uint cityId, uint troopId, uint amount, bool useAutoClaim) external {
    //     if (amount == 0) {
    //         revert ErrorNull(amount);
    //     }
    //     // check requirements, burn and set resource modifier
    //     Troop memory _troop = LibTroops.troopInfo(troopId);
    //     // int _modifier;
    //     uint _cityPopulation = s.CityList[cityId].Population;
    //     uint _population;

    //     // MinBarracksLevel
    //     uint barracksLevel = s.BuildingLevels[cityId][s.BARRACKS_ID].Tier;
    //     if (barracksLevel < _troop.Cost.MinBarracksLevel) {
    //         revert ErrorAssertion(barracksLevel < _troop.Cost.MinBarracksLevel, false);
    //     }
    //     // check population
    //     uint MAX_RESOURCE_ID = s.MAX_RESOURCE_ID;
    //     uint[] memory _costs = new uint[](MAX_RESOURCE_ID);
    //     for (uint i = 0; i < MAX_RESOURCE_ID; i++) {
    //         _costs[i] = _troop.Cost.ResourceCost[i] * amount;
    //     }

    //     LibResources.spendResources(cityId, _costs, useAutoClaim);

    //     _population += _troop.Population * amount;

    //     if (_population > _cityPopulation) {
    //         revert ErrorExceeds(_cityPopulation, _population);
    //     }

    //     s.CityList[cityId].Population = _cityPopulation - _population;
    //     s.CityTroops[cityId][troopId] += amount;
    //     emit Recruitment(cityId, troopId, amount);
    // }

    function _releaseTroop(uint cityId, uint troopId, uint amount) internal returns (uint) {
        if (amount == 0) {
            revert ErrorNull(amount);
        }
        if (s.CityTroops[cityId][troopId] < amount) {
            revert ErrorExceeds(s.CityTroops[cityId][troopId], amount);
        }
        s.CityTroops[cityId][troopId] -= amount;
        uint _population;
        Troop memory _troop = LibTroops.troopInfo(troopId);
        _population += _troop.Population * amount;
        return _population;
    }

    function releaseTroops(uint cityId, uint[] calldata troopIds, uint[] calldata amounts) external onlyCityOwner(cityId) {
        if (troopIds.length != amounts.length) {
            revert ErrorAssertion(troopIds.length == amounts.length, false);
        }
        uint population;

        for (uint i = 0; i < troopIds.length; i++) {
            population += _releaseTroop(cityId, troopIds[i], amounts[i]);
        }

        uint _cityPopulation = s.CityList[cityId].Population;

        s.CityList[cityId].Population = (_cityPopulation + population);
    }

    function squadsById(uint squadId) external view returns (Squad memory) {
        Squad memory squad = s.SquadsById[squadId];
        if (squad.ActiveAfter != 0 && block.timestamp > squad.ActiveAfter) squad.Active = true;
        return squad;
    }

    function squadsIdOnWorld(Coords memory coords) external view returns (uint[] memory) {
        return LibTroopsManager.squadsIdOnWorld(coords);
    }

    function squadsOnPlot(Coords memory coords) public view returns (Squad[] memory) {
        return LibTroopsManager.squadsOnPlot(coords);
    }

    function cityActiveSquads(uint cityId) external view returns (uint[] memory) {
        return s.CityActiveSquads[cityId].values();
    }

    function cityActiveTrainings(uint cityId) external view returns (Training[] memory) {
        uint[] memory ids = s.TrainingGoingOn[cityId].values();
        Training[] memory trs = new Training[](ids.length);
        for (uint i = 0; i < ids.length; i++) {
            trs[i] = s.Trainings[ids[i]];
        }
        return trs;
    }

    function troopResearchModifiers(uint cityId) public view returns (uint reducedRecruitTime, uint reducedRecruitCost) {
        uint[] memory recruitTimeResearchs = LibResearchManager.researchIdsByBonusType(ResearchBonusType.REDUCE_TROOP_RECRUIT_TIME);
        uint[] memory recruitCostResearchs = LibResearchManager.researchIdsByBonusType(ResearchBonusType.REDUCE_TROOPS_COST);
        for (uint i = 0; i < recruitTimeResearchs.length; i++) {
            if (LibResearchManager.isResearched(cityId, recruitTimeResearchs[i])) {
                Research memory _research = IFetchGlobal(address(this)).researchInfo(recruitTimeResearchs[i]);
                reducedRecruitTime += _research.UtilityValue;
            }
        }
        for (uint i = 0; i < recruitCostResearchs.length; i++) {
            if (LibResearchManager.isResearched(cityId, recruitCostResearchs[i])) {
                Research memory _research = IFetchGlobal(address(this)).researchInfo(recruitCostResearchs[i]);
                reducedRecruitCost += _research.UtilityValue;
            }
        }
    }
}
