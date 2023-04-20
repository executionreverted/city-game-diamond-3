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
    event SquadRemoved(uint indexed troopId);
    event SquadMovement(uint indexed cityId, uint indexed squadId, Coords from, Coords to);
    using EnumerableSet for EnumerableSet.UintSet;

    function troopsOfCity(uint cityId) internal view returns (uint8[] memory, uint[] memory) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        Race race = s.CityList[cityId].Race;
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

    function cityTroops(uint cityId, uint troopId) internal view returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        return s.CityTroops[cityId][troopId];
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
