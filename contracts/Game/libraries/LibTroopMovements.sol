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

library LibTroopMovements {
    event SquadRemoved(uint indexed troopId);
    event SquadMovement(uint indexed cityId, uint indexed squadId, Coords from, Coords to);
    using EnumerableSet for EnumerableSet.UintSet;

 
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
