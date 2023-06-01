// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Modifiers} from "../libraries/LibAppStorage.sol";
import {LibCalculator} from "../libraries/LibCalculator.sol";
import {Coords} from "../shared/WorldStructs.sol";

contract CalculatorFacet is Modifiers {
    /*     
        Army power = (Number of soldiers * Attack power * Defense power * Health) * Morale bonus
    */
    function armyPower(uint cityId) external view returns (uint Atk, uint SiegeAtk, uint Def, uint SiegeDef, uint Hp, uint Capacity) {
        // add morale bonus
        return LibCalculator.armyPower(cityId);
    }

    /* 
        Attacker victory chance
    */

    function attackerVictoryChance(uint atkArmyPower, uint defArmyPower) external pure returns (uint) {
        return LibCalculator.attackerVictoryChance(atkArmyPower, defArmyPower);
    }

    /* 
        Defender victory chance
    */
    function defenderVictoryChance(uint atkArmyPower, uint defArmyPower) external pure returns (uint) {
        return 1000 - LibCalculator.attackerVictoryChance(atkArmyPower, defArmyPower);
    }

    /* 
        Plunder amount percentage
    */
    function plunderAmountPercentage(uint atkArmyPower, uint defArmyPower) external pure returns (uint) {
        return LibCalculator.plunderAmountPercentage(atkArmyPower, defArmyPower);
    }

    /* 
        Plundered resources = (Percentage of plundered resources * Defender's total resources) * Plunder efficiency factor
    */
    function plunderededResources() external view returns (uint) {}

    /* 
        Attacker casualties = (Attacker army power / Defender army power) * Defender casualties
    */
    function attackerCasualties(uint atkArmyPower, uint defArmyPower, bool atkHasWon, bool draw) external pure returns (uint) {
        return LibCalculator.attackerCasualties(atkArmyPower, defArmyPower, atkHasWon, draw);
    }

    /* 
    Defender casualties = (Defender army power / Attacker army power) * Attacker casualties 
    */
    function defenderCasualties(uint atkArmyPower, uint defArmyPower, bool atkHasWon, bool draw) external pure returns (uint) {
        return LibCalculator.defenderCasualties(atkArmyPower, defArmyPower, atkHasWon, draw);
    }

    function calculateDistance(Coords memory c1, Coords memory c2) external pure returns (uint distance) {
        return LibCalculator.calculateDistance(c1, c2);
    }

    function timeBetweenTwoPoints(Coords memory a, Coords memory b) external pure returns (uint) {
        return LibCalculator.calculateDistance(a, b) * 2 minutes;
    }
}
