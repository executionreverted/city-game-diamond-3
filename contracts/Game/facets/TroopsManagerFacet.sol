// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {LibAppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibResources} from "../libraries/LibResources.sol";
import {LibCityManager} from "../libraries/LibCityManager.sol";
import {LibTroopsManager} from "../libraries/LibTroopsManager.sol";
import {LibTroops} from "../libraries/LibTroops.sol";
import {Coords} from "../shared/WorldStructs.sol";
import {Squad, Purpose, Troop} from "../shared/TroopsStructs.sol";
import {Resource} from "../shared/ResourceEnums.sol";
import "../shared/Errors.sol";

contract TroopsManagerFacet is Modifiers {
    using EnumerableSet for EnumerableSet.UintSet;
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
        uint MAX_RESOURCE_ID = s.MAX_RESOURCE_ID;
        uint[] memory _costs = new uint[](MAX_RESOURCE_ID);
        for (uint i = 0; i < amounts.length; ) {
            if (amounts[i] == 0) {
                revert ErrorNull(amounts[i]);
            }
            // check requirements, burn and set resource modifier
            Troop memory _troop = LibTroops.troopInfo(troopIds[i]);
            // int _modifier;
            // check population

            for (uint y = 0; y < MAX_RESOURCE_ID; y++) {
                _costs[y] += _troop.Cost.ResourceCost[y] * amounts[i];
            }

            _population += _troop.Population * amounts[i];
            s.CityTroops[cityId][troopIds[i]] += amounts[i];
            emit Recruitment(cityId, troopIds[i], amounts[i]);
            unchecked {
                i++;
            }
        }

        uint _cityPopulation = s.CityList[cityId].Population;
        if (_cityPopulation < _population) {
            revert ErrorExceeds(_cityPopulation, _population);
        }
        LibResources.spendResources(cityId, _costs, useAutoClaim);
        s.CityList[cityId].Population = (_cityPopulation - _population);
    }

    function recruitTroop(uint cityId, uint troopId, uint amount, bool useAutoClaim) external {
        if (amount == 0) {
            revert ErrorNull(amount);
        }
        // check requirements, burn and set resource modifier
        Troop memory _troop = LibTroops.troopInfo(troopId);
        // int _modifier;
        uint _cityPopulation = s.CityList[cityId].Population;
        uint _population;

        // MinBarracksLevel
        uint barracksLevel = s.BuildingLevels[cityId][s.BARRACKS_ID].Tier;
        if (barracksLevel < _troop.Cost.MinBarracksLevel) {
            revert ErrorAssertion(barracksLevel < _troop.Cost.MinBarracksLevel, false);
        }
        // check population
        uint MAX_RESOURCE_ID = s.MAX_RESOURCE_ID;
        uint[] memory _costs = new uint[](MAX_RESOURCE_ID);
        for (uint i = 0; i < MAX_RESOURCE_ID; i++) {
            _costs[i] = _troop.Cost.ResourceCost[i] * amount;
        }

        LibResources.spendResources(cityId, _costs, useAutoClaim);

        _population += _troop.Population * amount;

        if (_population > _cityPopulation) {
            revert ErrorExceeds(_cityPopulation, _population);
        }

        s.CityList[cityId].Population = _cityPopulation - _population;
        s.CityTroops[cityId][troopId] += amount;
        emit Recruitment(cityId, troopId, amount);
    }

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
}
