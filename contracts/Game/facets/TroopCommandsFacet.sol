// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {LibAppStorage, AppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibTroopCommands} from "../libraries/LibTroopCommands.sol";
import {LibCalculator} from "../libraries/LibCalculator.sol";
import {LibTroops} from "../libraries/LibTroops.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {Resource} from "../shared/ResourceEnums.sol";
import {Coords} from "../shared/WorldStructs.sol";
import {Squad, Target, Purpose} from "../shared/TroopsStructs.sol";
import "../shared/Errors.sol";

contract TroopCommandsFacet is Modifiers {
    // prevent atk to friendly squads
    function attack(uint squadId, Target target, uint targetSquadId) external {
        Squad memory squad = s.SquadsById[squadId];
        if (squad.ActiveAfter == 0 || block.timestamp < squad.ActiveAfter) {
            revert ErrorAssertion(!squad.Active, false);
        }
        LibTroopCommands.checkIfSquadOwned(squad);
        if (squad.Purpose != Purpose.ATTACK) {
            revert ErrorAssertion(squad.Purpose != Purpose.ATTACK, false);
        }
        // implement if target == enemy squad
        if (target == Target.SQUAD) {
            // attack stuff
            if (s.CityList[s.SquadsById[targetSquadId].ControlledBy].Operator == LibMeta.msgSender()) {
                revert ErrorAttackerIsOwner(LibMeta.msgSender());
            }
            if (s.SquadsById[targetSquadId].ActiveAfter == 0 || block.timestamp < s.SquadsById[targetSquadId].ActiveAfter) {
                revert ErrorAssertion(!s.SquadsById[targetSquadId].Active, false);
            }
            LibTroopCommands.handleFieldBattle(squad, s.SquadsById[targetSquadId]);
        }
        // implement if target == enemy city in this plot
        else if (target == Target.CITY) {
            // check if city exists in plot
            handleCityAtk(squad);
        }
        // implement if target == plot content in this plot
        // npc fight, roll random enemy using plot seed
        else if (target == Target.PLOT_CONTENT) {} else {
            revert ErrorNull(0);
        }
    }

    function handleCityAtk(Squad memory squad) internal {
        uint cityId = s.CoordsToCity[squad.Position.X][squad.Position.Y];
        if (s.CityList[cityId].Operator == LibMeta.msgSender()) {
            revert ErrorAttackerIsOwner(LibMeta.msgSender());
        }
        if (cityId == 0) revert ErrorInvalidWorldCoordinates(squad.Position.X, squad.Position.Y);
        // todo check if city is protected etc.
        (uint squadSiegePower, uint citySiegePower, uint capacity) = calculateSiegePowers(squad, cityId);
        // add building bonuses stuff
        LibTroopCommands.handleCityAttack(squad, cityId, squadSiegePower, citySiegePower, capacity);
    }

    function calculateSiegePowers(Squad memory squad, uint cityId) internal view returns (uint, uint, uint) {
        (uint attackerSiegePower, uint cap) = getAttackerSiege(squad);
        uint defenderSiegePower = getDefenderSiege(cityId);
        return (attackerSiegePower, defenderSiegePower, cap);
    }

    function getAttackerSiege(Squad memory squad) internal pure returns (uint, uint) {
        (uint squadAtk, uint squadSiegeAtk, uint squadDef, uint squadSiegeDef, uint squadHp, uint _cap) = LibTroops.armyPower(
            squad.TroopIds,
            squad.TroopAmounts
        );
        return ((squadAtk * 1) + (squadDef * 1) + (squadSiegeAtk * 2) + (squadSiegeDef * 1) + (squadHp), _cap);
    }

    function getDefenderSiege(uint cityId) internal view returns (uint) {
        (uint Atk, uint SiegeAtk, uint Def, uint SiegeDef, uint Hp, ) = LibCalculator.armyPower(cityId);
        return ((Atk * 1) + (Def * 2) + (SiegeAtk * 1) + (SiegeDef * 2) + (Hp));
    }
}
