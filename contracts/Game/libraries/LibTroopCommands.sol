// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Race} from "../shared/CityEnums.sol";
import {Coords} from "../shared/WorldStructs.sol";
import {Resource} from "../shared/ResourceEnums.sol";
import {Troop, Squad, Purpose, Target} from "../shared/TroopsStructs.sol";
import {EnumerableSetUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import {LibAppStorage, AppStorage, MAX_TROOP_ID} from "./LibAppStorage.sol";
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
    event CityFight(
        uint indexed attackerSquadId,
        uint atkCityId,
        uint indexed defCityId,
        uint result,
        uint attackerCasualties,
        uint defenderCasualties
    );
    event Plunder(uint indexed attackerCity, uint indexed defenderCity, uint plunderPercentage);

    struct PlunderArgs {
        uint fromCity;
        uint toCity;
        uint percentage;
        uint carryingCapacity;
    }

    function handleFieldBattle(Squad memory attacker, Squad memory victim) internal {
        checkIfTargetInRange(attacker.Position, victim.Position);
        if (victim.ActiveAfter == 0 || block.timestamp < victim.ActiveAfter) {
            revert ErrorAssertion(victim.Active, true);
        }
        uint _result; // 0 ATK, 1 DEF, 2 DRAW
        (uint attackerArmyPower, uint defenderArmyPower) = fieldWarArmyPowerFormula(attacker, victim);
        // calculate attacker stats

        uint atkWinChance = LibCalculator.attackerVictoryChance(attackerArmyPower, defenderArmyPower);

        uint defWinChance = LibCalculator.defenderVictoryChance(attackerArmyPower, defenderArmyPower);
        // roll random

        uint atkRoll = LibRNG.d1000(block.timestamp + atkWinChance);
        uint defRoll = LibRNG.d1000(block.timestamp + atkWinChance + defWinChance + 1);

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

        finalizeFieldWar(_result, attacker, victim, attackerArmyPower, defenderArmyPower);
    }

    function handleCityAttack(Squad memory attacker, uint cityId, uint squadPower, uint cityPower, uint capacity) internal {
        uint _result; // 0 ATK, 1 DEF, 2 DRAW
        uint atkWinChance = LibCalculator.attackerVictoryChance(squadPower, cityPower);
        uint defWinChance = LibCalculator.defenderVictoryChance(squadPower, cityPower);
        uint atkRoll = LibRNG.d1000(block.timestamp + atkWinChance);
        uint defRoll = LibRNG.d1000(block.timestamp + defWinChance + 1);
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

        finalizeCitySiege(_result, attacker, cityId, squadPower, cityPower, capacity);
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

    function finalizeCitySiege(uint result, Squad memory attacker, uint cityId, uint atkArmyPower, uint defArmyPower, uint capacity) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
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
        uint plunder = LibCalculator.plunderAmountPercentage(atkArmyPower, defArmyPower);
        // kill atk troops
        bool attackerFullDead = true;
        for (uint i = 0; i < attacker.TroopIds.length; i++) {
            attacker.TroopAmounts[i] -= (attacker.TroopAmounts[i] * atkCasualties) / 100;
            if (attackerFullDead && attacker.TroopAmounts[i] != 0) {
                attackerFullDead = false;
            }
        }

        // kill def troops

        for (uint i = 0; i < MAX_TROOP_ID; i++) {
            uint killed = (defCasualties * s.CityTroops[cityId][i]) / 100;
            if (s.CityTroops[cityId][i] >= killed) s.CityTroops[cityId][i] -= killed;
            else s.CityTroops[cityId][i] = 0;
        }

        LibTroopsManager.editSquad(attacker, attackerFullDead);
        if (result == 1) plunder /= 3;

        if (result == 0 || result == 1) {
            plunderResources(capacity, cityId, attacker.ControlledBy, plunder);
        }
        emit CityFight(attacker.ID, attacker.ControlledBy, cityId, result, atkCasualties, defCasualties);
        /* if (result == 0) {
            // atk side win
        } else if (result == 1) {
            // def side win
        } else if (result == 2) {
            // draw
        } */
    }

    function plunderResources(uint carryingCapacity, uint fromCity, uint toCity, uint percentage) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        carryingCapacity /= s.MAX_RESOURCE_ID;
        if (carryingCapacity == 0) return;
        handlePlunder(s, PlunderArgs({fromCity: fromCity, toCity: toCity, percentage: percentage, carryingCapacity: carryingCapacity}));

        emit Plunder(fromCity, toCity, percentage);
    }

    function handlePlunder(AppStorage storage s, PlunderArgs memory _args) internal {
        uint cityMaxPlunderable;
        uint totalPlundered;
        uint bonus;
        uint maxUsableBonus;
        uint[] memory plunderedResources = new uint[](s.MAX_RESOURCE_ID);
        bool[] memory cityHasNoResources = new bool[](s.MAX_RESOURCE_ID);
        bool hasNoResource = true;
        for (uint i = 0; i < s.MAX_RESOURCE_ID; i++) {
            cityMaxPlunderable += (s.CityResources[_args.fromCity][i] * _args.percentage) / 1000;
        }
        for (uint i = 0; i < s.MAX_RESOURCE_ID; i++) {
            if (totalPlundered >= cityMaxPlunderable) {
                break;
            }
            uint resourceBalance = s.CityResources[_args.fromCity][i] - plunderedResources[i];
            uint plunderableAmount = (resourceBalance * _args.percentage) / 1000;

            if (plunderableAmount > _args.carryingCapacity) {
                plunderableAmount = _args.carryingCapacity;
                if (resourceBalance < plunderableAmount) {
                    plunderableAmount = resourceBalance;
                }
            }

            totalPlundered += plunderableAmount;
            plunderedResources[i] += plunderableAmount;
            setResources(_args.fromCity, _args.toCity, i, plunderableAmount);
        }

        do {
            if (totalPlundered >= cityMaxPlunderable) {
                break;
            }
            for (uint i = 0; i < cityHasNoResources.length; i++) {
                if (!hasNoResource) break;
                hasNoResource = cityHasNoResources[i];
            }

            if (hasNoResource) {
                break;
            }
            for (uint i = 0; i < s.MAX_RESOURCE_ID; i++) {
                if (totalPlundered >= cityMaxPlunderable) {
                    break;
                }
                uint usedBonus;
                uint resourceBalance = s.CityResources[_args.fromCity][i] - plunderedResources[i];
                uint plunderableAmount = (resourceBalance * _args.percentage) / 1000;

                if (
                    i == 0 &&
                    plunderableAmount + plunderedResources[i] < _args.carryingCapacity &&
                    plunderableAmount + plunderedResources[i] <= resourceBalance
                ) {
                    plunderableAmount = resourceBalance;
                }
                if (plunderableAmount + plunderedResources[i] > _args.carryingCapacity) {
                    plunderableAmount = _args.carryingCapacity;
                }
                if (plunderedResources[i] + plunderableAmount > _args.carryingCapacity) plunderableAmount = 0;

                if (plunderableAmount != 0 && plunderedResources[i] + plunderableAmount < _args.carryingCapacity) {
                    if (bonus > 0) {
                        maxUsableBonus = _args.carryingCapacity - (plunderedResources[i] + plunderableAmount);
                        if (maxUsableBonus > resourceBalance) {
                            maxUsableBonus = resourceBalance - plunderableAmount;
                        }
                        usedBonus += maxUsableBonus;
                        plunderableAmount += maxUsableBonus;
                    }
                }

                totalPlundered += plunderableAmount;
                bonus += _args.carryingCapacity - plunderedResources[i];
                bonus -= usedBonus;
                plunderedResources[i] += plunderableAmount;
                setResources(_args.fromCity, _args.toCity, i, plunderableAmount);
            }
            hasNoResource = true;
        } while (
            !hasNoResource &&
                totalPlundered < _args.carryingCapacity * s.MAX_RESOURCE_ID &&
                (plunderedResources[0] < _args.carryingCapacity ||
                    plunderedResources[1] < _args.carryingCapacity ||
                    plunderedResources[2] < _args.carryingCapacity ||
                    plunderedResources[3] < _args.carryingCapacity ||
                    plunderedResources[4] < _args.carryingCapacity) &&
                totalPlundered < cityMaxPlunderable
        );
    }

    function setResources(uint fromCity, uint toCity, uint res, uint plunderableAmount) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.CityResources[fromCity][res] -= plunderableAmount;
        s.CityResources[toCity][res] += plunderableAmount;
    }
}
