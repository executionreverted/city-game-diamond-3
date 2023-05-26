// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {Troop} from "../shared/TroopsStructs.sol";

library LibTroops {
    function troopInfo(uint troopId) internal pure returns (Troop memory) {
        if (troopId == 0) return Slave();
        if (troopId == 1) return Peasant();
        if (troopId == 2) return Slinger();
        if (troopId == 3) return Swordsman();
        if (troopId == 4) return Spearman();
        if (troopId == 5) return Archer();
        if (troopId == 6) return Skirmishers();
        if (troopId == 7) return Berserkers();
        if (troopId == 8) return Knights();
        if (troopId == 9) return Cataphracts();
        if (troopId == 10) return SiegeShield();
        if (troopId == 11) return Catapult();
        if (troopId == 12) return Ballista();
        if (troopId == 13) return Trebuchet();
        if (troopId == 14) return SiegeTower();
        if (troopId == 15) return Cannon();
        if (troopId == 16) return SteamTank();
        if (troopId == 17) return Airship();
        if (troopId == 18) return PlasmaCannon();
        if (troopId == 19) return QuantumMech();
        revert("not implemented");
    }

    /* [
    GOLD, 0
    WOOD, 1
    STONE,2
    IRON, 3
    FOOD  4
    ] */

    /* PRODUCTION troop */

    function armyPower(
        uint8[] memory troopIds,
        uint[] memory amounts
    ) internal pure returns (uint Atk, uint SiegeAtk, uint Def, uint SiegeDef, uint Hp, uint Capacity) {
        require(troopIds.length == amounts.length, "mismatch");
        for (uint i = 0; i < troopIds.length; i++) {
            Troop memory _troop = troopInfo(troopIds[i]);
            Atk += _troop.Atk * amounts[i];
            SiegeAtk += _troop.SiegeAtk * amounts[i];
            Def += _troop.Def * amounts[i];
            SiegeDef += _troop.SiegeDef * amounts[i];
            Hp += _troop.Hp * amounts[i];
            Capacity += _troop.Capacity * amounts[i];
        }
    }

    function Slave() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 2;
        _baseTroop.SiegeAtk = 1;
        _baseTroop.Def = 1;
        _baseTroop.SiegeDef = 3;
        _baseTroop.Hp = 5;
        _baseTroop.Capacity = 332;
        _baseTroop.Cost.FoodCostMultiplier = 1;
        _baseTroop.Cost.RequiredResearch = 43;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 1; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 23; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 21; // STONE
        _baseTroop.Cost.ResourceCost[3] = 15; // IRON
        _baseTroop.Cost.ResourceCost[4] = 19; // FOOD
        _baseTroop.Cost.TimeRequired = 30 seconds; // TIME
        _baseTroop.Cost.MinBarracksLevel = 1;
        _baseTroop.Population = 1;

        return _baseTroop;
    }

    function Peasant() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 8;
        _baseTroop.SiegeAtk = 1;
        _baseTroop.Def = 4;
        _baseTroop.SiegeDef = 1;
        _baseTroop.Hp = 16;
        _baseTroop.Capacity = 29;
        _baseTroop.Cost.FoodCostMultiplier = 1;
        _baseTroop.Cost.RequiredResearch = 1;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 1; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 17; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 16; // STONE
        _baseTroop.Cost.ResourceCost[3] = 11; // IRON
        _baseTroop.Cost.ResourceCost[4] = 14; // FOOD
        _baseTroop.Cost.TimeRequired = 60 seconds; // TIME
        _baseTroop.Cost.MinBarracksLevel = 1;
        _baseTroop.Population = 1;

        return _baseTroop;
    }

    function Slinger() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 12;
        _baseTroop.SiegeAtk = 3;
        _baseTroop.Def = 3;
        _baseTroop.SiegeDef = 1;
        _baseTroop.Hp = 30;
        _baseTroop.Capacity = 42;
        _baseTroop.Cost.FoodCostMultiplier = 1;
        _baseTroop.Cost.RequiredResearch = 1;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 2; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 24; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 23; // STONE
        _baseTroop.Cost.ResourceCost[3] = 16; // IRON
        _baseTroop.Cost.ResourceCost[4] = 20; // FOOD
        _baseTroop.Cost.TimeRequired = 90 seconds; // TIME
        _baseTroop.Cost.MinBarracksLevel = 3;
        _baseTroop.Population = 1;

        return _baseTroop;
    }

    function Swordsman() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 24;
        _baseTroop.SiegeAtk = 3;
        _baseTroop.Def = 6;
        _baseTroop.SiegeDef = 2;
        _baseTroop.Hp = 48;
        _baseTroop.Capacity = 56;
        _baseTroop.Cost.FoodCostMultiplier = 2;
        _baseTroop.Cost.RequiredResearch = 0;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 3; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 32; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 30; // STONE
        _baseTroop.Cost.ResourceCost[3] = 21; // IRON
        _baseTroop.Cost.ResourceCost[4] = 27; // FOOD
        _baseTroop.Cost.TimeRequired = 3 minutes; // TIME
        _baseTroop.Cost.MinBarracksLevel = 1;
        _baseTroop.Population = 1;

        return _baseTroop;
    }

    function Spearman() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 35;
        _baseTroop.SiegeAtk = 4;
        _baseTroop.Def = 10;
        _baseTroop.SiegeDef = 3;
        _baseTroop.Hp = 66;
        _baseTroop.Capacity = 70;
        _baseTroop.Cost.FoodCostMultiplier = 2;
        _baseTroop.Cost.RequiredResearch = 0;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 4; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 40; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 38; // STONE
        _baseTroop.Cost.ResourceCost[3] = 26; // IRON
        _baseTroop.Cost.ResourceCost[4] = 33; // FOOD
        _baseTroop.Cost.TimeRequired = 4 minutes; // TIME
        _baseTroop.Cost.MinBarracksLevel = 5;
        _baseTroop.Population = 1;

        return _baseTroop;
    }

    function Archer() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 40;
        _baseTroop.SiegeAtk = 5;
        _baseTroop.Def = 8;
        _baseTroop.SiegeDef = 2;
        _baseTroop.Hp = 80;
        _baseTroop.Capacity = 111;
        _baseTroop.Cost.FoodCostMultiplier = 2;
        _baseTroop.Cost.RequiredResearch = 0;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 5; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 63; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 60; // STONE
        _baseTroop.Cost.ResourceCost[3] = 42; // IRON
        _baseTroop.Cost.ResourceCost[4] = 53; // FOOD
        _baseTroop.Cost.TimeRequired = 5 minutes; // TIME
        _baseTroop.Cost.MinBarracksLevel = 7;
        _baseTroop.Population = 1;

        return _baseTroop;
    }

    function Skirmishers() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 53;
        _baseTroop.SiegeAtk = 6;
        _baseTroop.Def = 19;
        _baseTroop.SiegeDef = 6;
        _baseTroop.Hp = 102;
        _baseTroop.Capacity = 129;
        _baseTroop.Cost.FoodCostMultiplier = 2;
        _baseTroop.Cost.RequiredResearch = 0;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 5; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 74; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 70; // STONE
        _baseTroop.Cost.ResourceCost[3] = 49; // IRON
        _baseTroop.Cost.ResourceCost[4] = 61; // FOOD
        _baseTroop.Cost.TimeRequired = 6 minutes; // TIME
        _baseTroop.Cost.MinBarracksLevel = 9;
        _baseTroop.Population = 1;

        return _baseTroop;
    }

    function Berserkers() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 70;
        _baseTroop.SiegeAtk = 8;
        _baseTroop.Def = 24;
        _baseTroop.SiegeDef = 8;
        _baseTroop.Hp = 137;
        _baseTroop.Capacity = 140;
        _baseTroop.Cost.FoodCostMultiplier = 2;
        _baseTroop.Cost.RequiredResearch = 0;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 6; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 126; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 119; // STONE
        _baseTroop.Cost.ResourceCost[3] = 84; // IRON
        _baseTroop.Cost.ResourceCost[4] = 105; // FOOD
        _baseTroop.Cost.TimeRequired = 9 minutes; // TIME
        _baseTroop.Cost.MinBarracksLevel = 11;
        _baseTroop.Population = 1;

        return _baseTroop;
    }

    function Knights() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 80;
        _baseTroop.SiegeAtk = 10;
        _baseTroop.Def = 33;
        _baseTroop.SiegeDef = 11;
        _baseTroop.Hp = 157;
        _baseTroop.Capacity = 148;
        _baseTroop.Cost.FoodCostMultiplier = 2;
        _baseTroop.Cost.RequiredResearch = 0;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 7; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 141; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 134; // STONE
        _baseTroop.Cost.ResourceCost[3] = 94; // IRON
        _baseTroop.Cost.ResourceCost[4] = 118; // FOOD
        _baseTroop.Cost.TimeRequired = 12 minutes; // TIME
        _baseTroop.Cost.MinBarracksLevel = 13;
        _baseTroop.Population = 1;

        return _baseTroop;
    }

    function Cataphracts() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 90;
        _baseTroop.SiegeAtk = 11;
        _baseTroop.Def = 40;
        _baseTroop.SiegeDef = 13;
        _baseTroop.Hp = 177;
        _baseTroop.Capacity = 166;
        _baseTroop.Cost.FoodCostMultiplier = 3;
        _baseTroop.Cost.RequiredResearch = 0;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 8; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 191; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 180; // STONE
        _baseTroop.Cost.ResourceCost[3] = 127; // IRON
        _baseTroop.Cost.ResourceCost[4] = 159; // FOOD
        _baseTroop.Cost.TimeRequired = 15 minutes; // TIME
        _baseTroop.Cost.MinBarracksLevel = 15;
        _baseTroop.Population = 1;

        return _baseTroop;
    }

    function SiegeShield() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 0;
        _baseTroop.SiegeAtk = 2;
        _baseTroop.Def = 3;
        _baseTroop.SiegeDef = 10;
        _baseTroop.Hp = 40;
        _baseTroop.Capacity = 90;
        _baseTroop.Cost.FoodCostMultiplier = 3;
        _baseTroop.Cost.RequiredResearch = 46;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 2; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 81; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 38; // STONE
        _baseTroop.Cost.ResourceCost[3] = 27; // IRON
        _baseTroop.Cost.ResourceCost[4] = 33; // FOOD
        _baseTroop.Cost.TimeRequired = 3 minutes; // TIME
        _baseTroop.Cost.MinBarracksLevel = 1;
        _baseTroop.Population = 2;

        return _baseTroop;
    }

    function Catapult() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 1;
        _baseTroop.SiegeAtk = 10;
        _baseTroop.Def = 1;
        _baseTroop.SiegeDef = 5;
        _baseTroop.Hp = 40;
        _baseTroop.Capacity = 90;
        _baseTroop.Cost.FoodCostMultiplier = 3;
        _baseTroop.Cost.RequiredResearch = 2;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 2; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 81; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 38; // STONE
        _baseTroop.Cost.ResourceCost[3] = 27; // IRON
        _baseTroop.Cost.ResourceCost[4] = 33; // FOOD
        _baseTroop.Cost.TimeRequired = 4 minutes; // TIME
        _baseTroop.Cost.MinBarracksLevel = 2;
        _baseTroop.Population = 2;

        return _baseTroop;
    }

    function Ballista() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 1;
        _baseTroop.SiegeAtk = 12;
        _baseTroop.Def = 1;
        _baseTroop.SiegeDef = 4;
        _baseTroop.Hp = 30;
        _baseTroop.Capacity = 136;
        _baseTroop.Cost.FoodCostMultiplier = 3;
        _baseTroop.Cost.RequiredResearch = 46;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 8; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 86; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 81; // STONE
        _baseTroop.Cost.ResourceCost[3] = 57; // IRON
        _baseTroop.Cost.ResourceCost[4] = 72; // FOOD
        _baseTroop.Cost.TimeRequired = 5 minutes; // TIME
        _baseTroop.Cost.MinBarracksLevel = 3;
        _baseTroop.Population = 2;

        return _baseTroop;
    }

    function Trebuchet() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 2;
        _baseTroop.SiegeAtk = 20;
        _baseTroop.Def = 1;
        _baseTroop.SiegeDef = 5;
        _baseTroop.Hp = 60;
        _baseTroop.Capacity = 164;
        _baseTroop.Cost.FoodCostMultiplier = 3;
        _baseTroop.Cost.RequiredResearch = 47;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 12; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 116; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 109; // STONE
        _baseTroop.Cost.ResourceCost[3] = 77; // IRON
        _baseTroop.Cost.ResourceCost[4] = 97; // FOOD
        _baseTroop.Cost.TimeRequired = 6 minutes; // TIME
        _baseTroop.Cost.MinBarracksLevel = 4;
        _baseTroop.Population = 2;

        return _baseTroop;
    }

    function SiegeTower() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 4;
        _baseTroop.SiegeAtk = 35;
        _baseTroop.Def = 3;
        _baseTroop.SiegeDef = 10;
        _baseTroop.Hp = 100;
        _baseTroop.Capacity = 172;
        _baseTroop.Cost.FoodCostMultiplier = 4;
        _baseTroop.Cost.RequiredResearch = 47;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 14; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 139; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 132; // STONE
        _baseTroop.Cost.ResourceCost[3] = 93; // IRON
        _baseTroop.Cost.ResourceCost[4] = 116; // FOOD
        _baseTroop.Cost.TimeRequired = 9 minutes; // TIME
        _baseTroop.Cost.MinBarracksLevel = 5;
        _baseTroop.Population = 2;

        return _baseTroop;
    }

    function Cannon() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 5;
        _baseTroop.SiegeAtk = 45;
        _baseTroop.Def = 5;
        _baseTroop.SiegeDef = 15;
        _baseTroop.Hp = 128;
        _baseTroop.Capacity = 200;
        _baseTroop.Cost.FoodCostMultiplier = 4;
        _baseTroop.Cost.RequiredResearch = 47;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 18; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 228; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 215; // STONE
        _baseTroop.Cost.ResourceCost[3] = 152; // IRON
        _baseTroop.Cost.ResourceCost[4] = 190; // FOOD
        _baseTroop.Cost.TimeRequired = 12 minutes; // TIME
        _baseTroop.Cost.MinBarracksLevel = 6;
        _baseTroop.Population = 2;

        return _baseTroop;
    }

    function SteamTank() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 7;
        _baseTroop.SiegeAtk = 60;
        _baseTroop.Def = 7;
        _baseTroop.SiegeDef = 22;
        _baseTroop.Hp = 178;
        _baseTroop.Capacity = 271;
        _baseTroop.Cost.FoodCostMultiplier = 4;
        _baseTroop.Cost.RequiredResearch = 48;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 31; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 386; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 364; // STONE
        _baseTroop.Cost.ResourceCost[3] = 257; // IRON
        _baseTroop.Cost.ResourceCost[4] = 321; // FOOD
        _baseTroop.Cost.TimeRequired = 15 minutes; // TIME
        _baseTroop.Cost.MinBarracksLevel = 7;
        _baseTroop.Population = 3;

        return _baseTroop;
    }

    function Airship() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 8;
        _baseTroop.SiegeAtk = 70;
        _baseTroop.Def = 9;
        _baseTroop.SiegeDef = 28;
        _baseTroop.Hp = 210;
        _baseTroop.Capacity = 312;
        _baseTroop.Cost.FoodCostMultiplier = 4;
        _baseTroop.Cost.RequiredResearch = 48;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 37; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 687; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 649; // STONE
        _baseTroop.Cost.ResourceCost[3] = 458; // IRON
        _baseTroop.Cost.ResourceCost[4] = 573; // FOOD
        _baseTroop.Cost.TimeRequired = 20 minutes; // TIME
        _baseTroop.Cost.MinBarracksLevel = 8;
        _baseTroop.Population = 3;

        return _baseTroop;
    }

    function PlasmaCannon() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 10;
        _baseTroop.SiegeAtk = 80;
        _baseTroop.Def = 11;
        _baseTroop.SiegeDef = 33;
        _baseTroop.Hp = 235;
        _baseTroop.Capacity = 377;
        _baseTroop.Cost.FoodCostMultiplier = 5;
        _baseTroop.Cost.RequiredResearch = 48;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 41; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 771; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 728; // STONE
        _baseTroop.Cost.ResourceCost[3] = 514; // IRON
        _baseTroop.Cost.ResourceCost[4] = 642; // FOOD
        _baseTroop.Cost.TimeRequired = 30 minutes; // TIME
        _baseTroop.Cost.MinBarracksLevel = 9;
        _baseTroop.Population = 3;

        return _baseTroop;
    }

    function QuantumMech() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 11;
        _baseTroop.SiegeAtk = 90;
        _baseTroop.Def = 13;
        _baseTroop.SiegeDef = 40;
        _baseTroop.Hp = 266;
        _baseTroop.Capacity = 416;
        _baseTroop.Cost.FoodCostMultiplier = 5;
        _baseTroop.Cost.RequiredResearch = 49;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 44; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 996; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 940; // STONE
        _baseTroop.Cost.ResourceCost[3] = 664; // IRON
        _baseTroop.Cost.ResourceCost[4] = 830; // FOOD
        _baseTroop.Cost.TimeRequired = 40 minutes; // TIME
        _baseTroop.Cost.MinBarracksLevel = 10;
        _baseTroop.Population = 3;

        return _baseTroop;
    }

    function generateCostArray() internal pure returns (uint[100] memory _return) {}
}
