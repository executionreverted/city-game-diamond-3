// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Race} from "../shared/CityEnums.sol";
import {Coords} from "../shared/WorldStructs.sol";
import {Resource} from "../shared/ResourceEnums.sol";
import {Troop, Squad, Purpose} from "../shared/TroopsStructs.sol";
import {EnumerableSetUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {LibTroops} from "./LibTroops.sol";
import {LibCityManager} from "./LibCityManager.sol";
import {LibCalculator} from "./LibCalculator.sol";
import {LibResources} from "./LibResources.sol";
import {LibWorld} from "./LibWorld.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import "../shared/Errors.sol";

library LibTroopsManager {
    event Recruitment(uint indexed cityId, uint indexed troopId, uint amount);
    event SquadRemoved(uint indexed troopId);
    event SquadMovement(uint indexed cityId, uint indexed squadId, Coords from, Coords to);
    using EnumerableSet for EnumerableSet.UintSet;

    function troopsOfCity(uint cityId) internal view returns (uint8[] memory, uint[] memory) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        Race race = LibCityManager.race(cityId);
        // race stuff... determine ids of troops by race
        uint i;
        uint8 startTroop = 0 * uint8(race);
        uint8 endTroop = 1 * uint8(race);

        uint8[] memory troopIds = new uint8[](endTroop - startTroop);
        uint[] memory amounts = new uint[](endTroop - startTroop);

        for (startTroop; startTroop < endTroop; ) {
            troopIds[i] = startTroop;
            amounts[i] = s.CityTroops[cityId][startTroop];
            unchecked {
                i++;
                startTroop++;
            }
        }

        return (troopIds, amounts);
    }

    function recruitTroop(uint cityId, uint troopId, uint amount) internal {
        if (amount == 0) {
            revert ErrorNull(amount);
        }
        AppStorage storage s = LibAppStorage.diamondStorage();
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

        LibResources.spendResources(cityId, _costs);

        _population += _troop.Population * amount;

        if (_population > _cityPopulation) {
            revert ErrorExceeds(_cityPopulation, _population);
        }

        LibCityManager.updateCityPopulation(cityId, _cityPopulation - _population);
        s.CityTroops[cityId][troopId] += amount;
        emit Recruitment(cityId, troopId, amount);
    }

    function recruitTroops(uint cityId, uint8[] calldata troopIds, uint[] calldata amounts) internal {
        if (troopIds.length != amounts.length) {
            revert ErrorAssertion(troopIds.length == amounts.length, false);
        }
        uint _population;
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint MAX_RESOURCE_ID = s.MAX_RESOURCE_ID;
        uint[] memory _costs = new uint[](MAX_RESOURCE_ID);
        for (uint i = 0; i < amounts.length; ) {
            uint amount = amounts[i];
            uint troopId = troopIds[i];
            if (amount == 0) {
                revert ErrorNull(amount);
            }
            // check requirements, burn and set resource modifier
            Troop memory _troop = LibTroops.troopInfo(troopId);
            // int _modifier;
            // check population

            for (uint y = 0; y < MAX_RESOURCE_ID; y++) {
                _costs[y] += _troop.Cost.ResourceCost[y] * amount;
            }

            _population += _troop.Population * amount;
            s.CityTroops[cityId][troopId] += amount;
            emit Recruitment(cityId, troopId, amount);
            unchecked {
                i++;
            }
        }

        uint _cityPopulation = s.CityList[cityId].Population;
        if (_cityPopulation < _population) {
            revert ErrorExceeds(_cityPopulation, _population);
        }
        LibResources.spendResources(cityId, _costs);
        LibCityManager.updateCityPopulation(cityId, _cityPopulation - _population);
    }

    function _releaseTroop(uint cityId, uint troopId, uint amount) internal returns (uint) {
        if (amount == 0) {
            revert ErrorNull(amount);
        }
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.CityTroops[cityId][troopId] < amount) {
            revert ErrorExceeds(s.CityTroops[cityId][troopId], amount);
        }
        s.CityTroops[cityId][troopId] -= amount;
        uint _population;
        Troop memory _troop = LibTroops.troopInfo(troopId);
        _population += _troop.Population * amount;
        return _population;
    }

    function releaseTroops(uint cityId, uint[] calldata troopIds, uint[] calldata amounts) internal {
        if (troopIds.length != amounts.length) {
            revert ErrorAssertion(troopIds.length == amounts.length, false);
        }
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint population;

        for (uint i = 0; i < troopIds.length; i++) {
            population += _releaseTroop(cityId, troopIds[i], amounts[i]);
        }

        uint _cityPopulation = s.CityList[cityId].Population;

        LibCityManager.updateCityPopulation(cityId, _cityPopulation + population);
    }

    function cityTroops(uint cityId, uint troopId) internal view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.CityTroops[cityId][troopId];
    }

    function sendSquadTo(uint cityId, Coords memory coords, uint8[] memory troopIds, uint[] memory troopAmounts, Purpose purpose) internal {
        if (hasDupes(troopIds)) {
            revert ErrorAssertion(true, false);
        }

        if (troopIds.length != troopAmounts.length) {
            revert ErrorAssertion(troopIds.length == troopAmounts.length, false);
        }
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint squadsOnThisPlot = EnumerableSet.length(s.SquadsIdOnWorld[coords.X][coords.Y]);
        if (squadsOnThisPlot >= s.MAX_SQUADS_ON_PLOT) {
            revert ErrorExceeds(squadsOnThisPlot, s.MAX_SQUADS_ON_PLOT);
        }
        // limit squads on a coordinate point
        checkTroops(cityId, troopIds, troopAmounts);
        reduceTroopsInTown(cityId, troopIds, troopAmounts);
        Coords memory cityCoords = s.CityCoords[cityId];
        uint timeBetweenCoords = LibCalculator.timeBetweenTwoPoints(cityCoords, coords);

        uint FOOD_PER_MINUTE = s.FOOD_PER_MINUTE;
        // burn food
        LibResources.spendResource(cityId, (FOOD_PER_MINUTE) + ((timeBetweenCoords / 1 minutes) * FOOD_PER_MINUTE), Resource.FOOD);

        Squad memory newSquad = Squad({
            ID: s.squadNonces,
            TroopIds: troopIds,
            TroopAmounts: troopAmounts,
            Position: coords,
            Purpose: purpose,
            ActiveAfter: block.timestamp + timeBetweenCoords,
            Active: false,
            ControlledBy: cityId
        });
        uint squadNonces = s.squadNonces;
        s.SquadsById[squadNonces] = newSquad;
        s.SquadsIdOnWorld[coords.X][coords.Y].add(squadNonces);
        s.CityActiveSquads[cityId].add(squadNonces);
        s.squadNonces++;
        emit SquadMovement(cityId, squadNonces, coords, coords);
    }

    function callSquadBack(uint cityId, uint squadId) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (!s.CityActiveSquads[cityId].contains(squadId)) {
            revert ErrorNull(0);
        }
        // todo check other stuff like return half road etc.

        for (uint i = 0; i < s.SquadsById[squadId].TroopIds.length; i++) {
            s.CityTroops[cityId][s.SquadsById[squadId].TroopIds[i]] += s.SquadsById[squadId].TroopAmounts[i];
        }

        s.SquadsIdOnWorld[s.SquadsById[squadId].Position.X][s.SquadsById[squadId].Position.Y].remove(squadId);
        s.CityActiveSquads[cityId].remove(squadId);
        delete s.SquadsById[squadId];
        emit SquadRemoved(squadId);
    }

    function repositionSquad(uint cityId, uint squadId, Coords memory newCoords) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        Squad memory squad = s.SquadsById[squadId];

        if (!s.CityActiveSquads[cityId].contains(squadId)) {
            revert ErrorNull(0);
        }
        if (block.timestamp < squad.ActiveAfter) {
            revert ErrorBadTiming(block.timestamp, squad.ActiveAfter);
        }

        uint squadsInThisPlot = s.SquadsIdOnWorld[newCoords.X][newCoords.Y].length();
        uint MAX_SQUADS_ON_PLOT = s.MAX_SQUADS_ON_PLOT;
        if (squadsInThisPlot >= MAX_SQUADS_ON_PLOT) {
            revert ErrorExceeds(squadsInThisPlot, MAX_SQUADS_ON_PLOT);
        }
        uint timeBetweenCoords = LibCalculator.timeBetweenTwoPoints(squad.Position, newCoords);

        // burn food
        LibResources.spendResource(cityId, (timeBetweenCoords / 1 minutes) * s.FOOD_PER_MINUTE, Resource.FOOD);
        emit SquadMovement(cityId, s.squadNonces, squad.Position, newCoords);
        s.SquadsIdOnWorld[squad.Position.X][squad.Position.Y].remove(squadId);
        s.SquadsById[squadId].Position = newCoords;
        s.SquadsIdOnWorld[newCoords.X][newCoords.Y].add(squadId);
        s.SquadsById[squadId].ActiveAfter = block.timestamp + timeBetweenCoords;
        // SquadsById[squadId].ActiveAfter = SquadsById[squadId].ActiveAfter + timeBetweenCoords;
    }

    function editSquad(Squad memory squad, bool destroy) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (destroy) {
            // console.log("destroy");
            // console.log(destroy, squad.ID);
            s.SquadsIdOnWorld[squad.Position.X][squad.Position.Y].remove(squad.ID);
            s.CityActiveSquads[squad.ControlledBy].remove(squad.ID);
            s.SquadsById[squad.ID].Active = false;
            s.SquadsById[squad.ID].ActiveAfter = 0;
            // delete SquadsById[squad.ID];
            emit SquadRemoved(squad.ID);
        } else {
            s.SquadsById[squad.ID] = squad;
        }
    }

    function changePurpose(uint cityId, uint squadId, Purpose newPurpose) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        require(s.SquadsById[squadId].ControlledBy == cityId, "???");
        s.SquadsById[squadId].Purpose = newPurpose;
    }

    function reduceTroopsInTown(uint cityId, uint8[] memory troopIds, uint[] memory troopAmounts) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        for (uint i = 0; i < troopIds.length; ) {
            s.CityTroops[cityId][i] -= troopAmounts[i];
            unchecked {
                i++;
            }
        }
    }

    function checkTroops(uint cityId, uint8[] memory troopIds, uint[] memory troopAmounts) internal view {
        AppStorage storage s = LibAppStorage.diamondStorage();
        for (uint i = 0; i < troopIds.length; ) {
            require(s.CityTroops[cityId][troopIds[i]] >= troopAmounts[i], "not enough");
            unchecked {
                i++;
            }
        }
    }

    function squadsById(uint squadId) internal view returns (Squad memory) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        Squad memory squad = s.SquadsById[squadId];
        if (squad.ActiveAfter != 0 && block.timestamp > squad.ActiveAfter) squad.Active = true;
        return squad;
    }

    function squadsIdOnWorld(Coords memory coords) internal view returns (uint[] memory) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.SquadsIdOnWorld[coords.X][coords.Y].values();
    }

    function squadsOnPlot(Coords memory coords) internal view returns (Squad[] memory) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint[] memory squadIds = s.SquadsIdOnWorld[coords.X][coords.Y].values();
        Squad[] memory result = new Squad[](squadIds.length);

        for (uint i = 0; i < squadIds.length; i++) {
            result[i] = s.SquadsById[squadIds[i]];
        }
        return result;
    }

    function hasDupes(uint8[] memory arr) internal pure returns (bool) {
        uint temp;
        for (uint i = 0; i < arr.length; i++) {
            temp = arr[i];
            for (uint j = 0; j < arr.length; j++) {
                if ((j != i) && (temp == arr[j])) {
                    return true;
                }
            }
        }
        return false;
    }
}
