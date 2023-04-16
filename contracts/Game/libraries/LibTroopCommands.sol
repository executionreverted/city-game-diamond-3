// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Race} from "../shared/CityEnums.sol";
import {Coords} from "../shared/WorldStructs.sol";
import {Resource} from "../shared/ResourceEnums.sol";
import {Troop, Squad, Purpose, Target} from "../shared/TroopsStructs.sol";
import {EnumerableSetUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
// import "hardhat/console.sol";
import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {LibTroops} from "./LibTroops.sol";
import {LibTroopsManager} from "./LibTroopsManager.sol";
import {LibCities} from "./LibCities.sol";
import {LibCityManager} from "./LibCityManager.sol";
import {LibCalculator} from "./LibCalculator.sol";
import {LibResources} from "./LibResources.sol";
import {LibWorld} from "./LibWorld.sol";
import {LibRNG} from "./LibRNG.sol";
import "../shared/Errors.sol";

library LibTroopCommands {
    event PlotFight(uint indexed attackerSquadId, uint indexed victimSquadId, uint result, uint attackerCasualties, uint defenderCasualties);

    // prevent atk to friendly squads
    function attack(uint squadId, Target target, uint targetSquadId) internal {
        Squad memory squad = LibTroopsManager.squadsById(squadId);
        if (!squad.Active) {
            revert ErrorAssertion(squad.Active, true);
        }
        checkIfSquadOwned(squad);
        if (squad.Purpose != Purpose.ATTACK) {
            revert ErrorAssertion(squad.Purpose != Purpose.ATTACK, false);
        }
        // implement if target == enemy squad
        if (target == Target.SQUAD) {
            // attack stuff
            handleFieldBattle(squad, LibTroopsManager.squadsById(targetSquadId));
        }
        // implement if target == enemy city in this plot
        else if (target == Target.CITY) {
            // check if city exists in plot
            // calculate battle functions
        }
        // implement if target == plot content in this plot
        // npc fight, roll random enemy using plot seed
        else if (target == Target.PLOT_CONTENT) {} else {
            revert ErrorNull(0);
        }
    }

    function handleFieldBattle(Squad memory attacker, Squad memory victim) internal {
        checkIfTargetInRange(attacker.Position, victim.Position);
        if (!victim.Active) {
            revert ErrorAssertion(victim.Active, true);
        }
        uint _result; // 0 ATK, 1 DEF, 2 DRAW
        (uint attackerArmyPower, uint defenderArmyPower) = fieldWarArmyPowerFormula(attacker, victim);
        // calculate attacker stats

        // console.log("powers:");
        // console.log(attackerArmyPower);
        // console.log(defenderArmyPower);
        uint atkWinChance = LibCalculator.attackerVictoryChance(attackerArmyPower, defenderArmyPower);

        // console.log("atkWinChance");
        // console.log(atkWinChance);

        uint defWinChance = LibCalculator.defenderVictoryChance(attackerArmyPower, defenderArmyPower);
        // roll random
        // console.log("defWinChance");
        // console.log(defWinChance);

        uint atkRoll = LibRNG.d1000(block.timestamp + atkWinChance);
        uint defRoll = LibRNG.d1000(block.timestamp + defWinChance + 1);
        // console.log("atkRoll");
        // console.log(atkRoll);
        // console.log("defRoll");
        // console.log(defRoll);

        if (atkRoll < atkWinChance && defRoll < defWinChance) {
            _result = 2;
        } else if (atkRoll > atkWinChance && defRoll > defWinChance) {
            _result = 2;
        } else if (atkRoll > atkWinChance && defRoll < defWinChance) {
            _result = 1;
        } else if (atkRoll < atkWinChance && defRoll > defWinChance) {
            _result = 0;
        } else {
            _result = 2;
        }

        // console.log("_result");
        // console.log(_result);

        finalizeFieldWar(_result, attacker, victim, attackerArmyPower, defenderArmyPower);
    }

    function protect() internal {}

    function checkIfTargetInRange(Coords memory c1, Coords memory c2) internal view returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint dist = LibCalculator.calculateDistance(c1, c2);
        uint ACTION_RANGE = s.ACTION_RANGE;
        if (dist > ACTION_RANGE) {
            revert ErrorExceeds(dist, ACTION_RANGE);
        }
        return true;
    }

    function checkIfSquadOwned(Squad memory squad) internal view returns (bool) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        if (s.CityList[squad.ControlledBy].Operator != LibMeta.msgSender()) {
            revert ErrorUnauthorized(LibMeta.msgSender());
        }
        return true;
    }

    function finalizeFieldWar(uint result, Squad memory attacker, Squad memory defender, uint atkArmyPower, uint defArmyPower) internal {
        // 0 atk win, 1 def win, 2 draw
        /*
        function attackerCasualties(
        uint atkArmyPower,
        uint defArmyPower,
        bool atkHasWon,
        bool draw
    )  */
        uint atkCasualties = LibCalculator.attackerCasualties(atkArmyPower, defArmyPower, result == 0, result == 2);
        uint defCasualties = LibCalculator.defenderCasualties(atkArmyPower, defArmyPower, result == 0, result == 2);
        // console.log("atkCasualties");
        // console.log(atkCasualties);
        // console.log("defCasualties");
        // console.log(defCasualties);
        // kill atk troops
        bool attackerFullDead = true;
        bool defenderFullDead = true;
        for (uint i = 0; i < attacker.TroopIds.length; i++) {
            attacker.TroopAmounts[i] -= (attacker.TroopAmounts[i] * atkCasualties) / 1000;
            if (attackerFullDead && attacker.TroopAmounts[i] != 0) {
                attackerFullDead = false;
            }
        }

        // kill def troops

        for (uint i = 0; i < defender.TroopIds.length; i++) {
            defender.TroopAmounts[i] -= (defender.TroopAmounts[i] * defCasualties) / 1000;
            if (defenderFullDead && defender.TroopAmounts[i] != 0) {
                defenderFullDead = false;
            }
        }

        // console.log("attackerFullDead");
        // console.log(attackerFullDead);
        // console.log("defenderFullDead");
        // console.log(defenderFullDead);
        LibTroopsManager.editSquad(attacker, attackerFullDead);
        LibTroopsManager.editSquad(defender, defenderFullDead);

        emit PlotFight(attacker.ID, defender.ID, result, atkCasualties, defCasualties);
        /* if (result == 0) {
            // atk side win
        } else if (result == 1) {
            // def side win
        } else if (result == 2) {
            // draw
        } */
    }

    function fieldWarArmyPowerFormula(Squad memory attacker, Squad memory victim) internal pure returns (uint, uint) {
        (uint attackerAtk, uint attackerSiegeAtk, uint attackerDef, uint attackerSiegeDef, uint attackerHp, ) = LibTroops.armyPower(
            attacker.TroopIds,
            attacker.TroopAmounts
        );
        // calculate defender stats

        (uint defenderAtk, uint defenderSiegeAtk, uint defenderDef, uint defenderSiegeDef, uint defenderHp, ) = LibTroops.armyPower(
            victim.TroopIds,
            victim.TroopAmounts
        );

        return (
            ((attackerAtk + attackerDef) * 2) + (attackerSiegeAtk + attackerSiegeDef) + attackerHp * 2,
            ((defenderAtk + defenderDef) * 2) + (defenderSiegeAtk + defenderSiegeDef) + defenderHp * 2
        );
    }
}
