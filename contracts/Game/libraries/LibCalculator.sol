// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {Coords} from "../shared/WorldStructs.sol";
import {LibTroopsManager} from "../libraries/LibTroopsManager.sol";
import {LibTroops} from "../libraries/LibTroops.sol";

library LibCalculator {
    uint constant Precision = 3;
    uint constant Absolute = 10 ** Precision;
    uint constant MaxPlunderPercentage = 500; // 1000

    /*     
        Army power = (Number of soldiers * Attack power * Defense power * Health) * Morale bonus
    */
    function armyPower(uint cityId) internal view returns (uint Atk, uint SiegeAtk, uint Def, uint SiegeDef, uint Hp, uint Capacity) {
        (uint8[] memory troops, uint[] memory amounts) = LibTroopsManager.troopsOfCity(cityId);
        // add morale bonus
        return LibTroops.armyPower(troops, amounts);
    }

    /* 
        Attacker victory chance
    */

    function attackerVictoryChance(uint atkArmyPower, uint defArmyPower) internal pure returns (uint) {
        // todo add defender bonus etc.
        if (atkArmyPower <= defArmyPower) {
            uint p = divide(atkArmyPower, defArmyPower) / 1e15;
            if (p > Absolute) return Absolute;
            return p / 2;
        } else {
            uint p = Absolute - (percent(defArmyPower, atkArmyPower, 3) * 80) / 100;
            if (p >= Absolute) return Absolute;
            return p;
        }
    }

    /* 
        Defender victory chance
    */
    function defenderVictoryChance(uint atkArmyPower, uint defArmyPower) internal pure returns (uint) {
        return 1000 - attackerVictoryChance(atkArmyPower, defArmyPower);
    }

    /* 
        Plunder amount percentage
    */
    function plunderAmountPercentage(uint atkArmyPower, uint defArmyPower) internal pure returns (uint) {
        if (atkArmyPower < defArmyPower) {
            return percent(atkArmyPower, defArmyPower, Precision) / 10;
        }

        uint chance = attackerVictoryChance(atkArmyPower, defArmyPower) / 2;
        return chance > MaxPlunderPercentage ? MaxPlunderPercentage : chance;
    }

    /* 
        Plundered resources = (Percentage of plundered resources * Defender's total resources) * Plunder efficiency factor
    */
    function plunderededResources() internal view returns (uint) {}

    /* 
        Attacker casualties = (Attacker army power / Defender army power) * Defender casualties
    */
    function attackerCasualties(uint atkArmyPower, uint defArmyPower, bool atkHasWon, bool draw) internal pure returns (uint) {
        if (atkArmyPower == 0 && defArmyPower == 0) return 0;
        if (atkArmyPower == 0) atkArmyPower = 1;
        if (defArmyPower == 0) defArmyPower = 1;
        uint amount;
        if (atkArmyPower < defArmyPower) {
            amount = percent(atkArmyPower, defArmyPower, Precision);
            uint ratio = (defArmyPower * 120) / atkArmyPower;
            if (defArmyPower / atkArmyPower >= 10) {
                amount = 1000;
            } else {
                amount = (amount * ratio) / 1000;
            }
            // amount *= 3;
            // amount /= 7;
        } else {
            amount = percent(defArmyPower, atkArmyPower, Precision);
            amount *= 2;
            amount /= 10;
        }
        // amount /= 10;

        if (draw) return min((amount * 80) / 100, 1000);

        if (atkHasWon) {
            amount = amount / 2;
        }
        return min(amount, 1000);
    }

    /* 
    Defender casualties = (Defender army power / Attacker army power) * Attacker casualties 
    */
    function defenderCasualties(uint atkArmyPower, uint defArmyPower, bool atkHasWon, bool draw) internal pure returns (uint) {
        if (atkArmyPower == 0 && defArmyPower == 0) return 0;
        if (atkArmyPower == 0) atkArmyPower = 1;
        if (defArmyPower == 0) defArmyPower = 1;
        uint amount;
        if (atkArmyPower > defArmyPower) {
            amount = percent(defArmyPower, atkArmyPower, Precision);
            uint ratio = (atkArmyPower * 100) / defArmyPower;
            if (atkArmyPower / defArmyPower >= 10) {
                amount = 1000;
            } else {
                amount = (amount * ratio) / 1000;
            }
        } else {
            amount = percent(atkArmyPower, defArmyPower, Precision);
            amount /= 10;
        }
        if (draw) return min(((amount * 800) / 1000), 1000);

        if (atkHasWon) {
            if (percent(defArmyPower, atkArmyPower, Precision) > 300) {
                amount *= 2;
            }
        } else {
            amount = (amount * 75) / 100;
        }
        return min(amount, 1000);
    }

    function min(uint a, uint b) internal pure returns (uint) {
        return a > b ? b : a;
    }

    function calculateDistance(Coords memory c1, Coords memory c2) internal pure returns (uint distance) {
        distance = uint(sqrt((c2.X - c1.X) ** 2 + (c2.Y - c1.Y) ** 2));
    }

    function timeBetweenTwoPoints(Coords memory a, Coords memory b) internal pure returns (uint) {
        return calculateDistance(a, b) * 2 minutes;
    }

    function _calculateDistance(int x1, int y1, int x2, int y2) internal pure returns (uint distance) {
        distance = uint(sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2));
    }

    /* UTILS */
    function sqrt(int x) internal pure returns (int y) {
        int z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function divide(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "division by zero will result in infinity.");
        return (a * 1e18) / b;
    }

    function percent(uint numerator, uint denominator, uint precision) internal pure returns (uint quotient) {
        // caution, check safe-to-multiply here
        uint _numerator = numerator * 10 ** (precision + 1);
        // with rounding of last digit
        uint _quotient = ((_numerator / denominator) + 5) / 10;
        return (_quotient);
    }
}
