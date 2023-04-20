// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {Building} from "../shared/CityStructs.sol";

library LibBuildings {
    function allBuildings() internal view returns (Building[] memory) {
        Building[] memory _result = new Building[](15);
        for (uint i = 0; i < 15; i++) {
            _result[i] = buildingInfo(i);
        }
        return _result;
    }

    function buildingInfo(uint buildingId) internal view returns (Building memory) {
        if (buildingId == 0) return TownHall();
        if (buildingId == 1) return Forest();
        if (buildingId == 2) return Farms();
        if (buildingId == 3) return Mines();
        if (buildingId == 4) return Quarry();
        if (buildingId == 5) return Warehouse();
        if (buildingId == 6) return Barracks();
        if (buildingId == 7) return Workshop();
        if (buildingId == 8) return Housing();
        if (buildingId == 9) return ResearchCenter();
        if (buildingId == 10) return DefenseTower();
        if (buildingId == 11) return TradingPost();
        if (buildingId == 12) return Hatchery();
        if (buildingId == 13) return WorldBossPortal();
        if (buildingId == 14) return Walls();
        revert("not implemented");
    }

    function calculateValue(uint tier, uint base, uint coeff, uint coeffPerc) internal pure returns (uint) {
        // base point * ( cofficient1 * coefficient perc * (level * level-1))

        return base + (((coeff * (coeffPerc)) / 100) * (tier * tier - 1));
    }

    /* [
    GOLD, 0
    WOOD, 1
    STONE,2
    IRON, 3
    FOOD  4
    ] */

    /* PRODUCTION BUILDING */

    function Forest() internal view returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 10;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 720;
        _baseBuilding.Coefficient = 25;
        _baseBuilding.CoefficientRatio = 60; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 4013;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 2500;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 170;
        _baseBuilding.BaseCosts.BaseWood = 10000;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 3000;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 180;
        _baseBuilding.BaseCosts.BaseStone = 12000;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 3250;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 240;
        _baseBuilding.BaseCosts.BaseIron = 8000;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 3250;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 2240;
        _baseBuilding.BaseCosts.BaseFood = 12000;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 3250;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 240;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function Farms() internal view returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 10;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 720;
        _baseBuilding.Coefficient = 25;
        _baseBuilding.CoefficientRatio = 65; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 4013;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 2500;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 170;
        _baseBuilding.BaseCosts.BaseWood = 14000;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 3000;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 180;
        _baseBuilding.BaseCosts.BaseStone = 14000;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 3250;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 240;
        _baseBuilding.BaseCosts.BaseIron = 10000;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 3250;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseFood = 10000;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 3250;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 240;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function Mines() internal view returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 10;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 720;
        _baseBuilding.Coefficient = 30;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 4013;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 2500;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 170;
        _baseBuilding.BaseCosts.BaseWood = 14000;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 3000;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 180;
        _baseBuilding.BaseCosts.BaseStone = 14000;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 3250;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 240;
        _baseBuilding.BaseCosts.BaseIron = 8000;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 3250;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 240;
        _baseBuilding.BaseCosts.BaseFood = 14000;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 3250;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 240;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function Quarry() internal view returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 10;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 720;
        _baseBuilding.Coefficient = 35;
        _baseBuilding.CoefficientRatio = 65; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 4013;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 2500;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 170;
        _baseBuilding.BaseCosts.BaseWood = 14000;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 3000;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 180;
        _baseBuilding.BaseCosts.BaseStone = 10000;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 3250;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 240;
        _baseBuilding.BaseCosts.BaseIron = 11250;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 3250;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 240;
        _baseBuilding.BaseCosts.BaseFood = 14000;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 3250;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 240;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    /* UTILITY BUILDINGS */
    function TownHall() internal view returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 50;
        // _baseBuilding.RequiredResearchID = ;

        // building time values
        _baseBuilding.BaseTime = 13;
        _baseBuilding.Coefficient = 15;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 1486;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 1100;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 270;
        _baseBuilding.BaseCosts.BaseWood = 5184;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 3800;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 75;
        _baseBuilding.BaseCosts.BaseStone = 4320;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 3800;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 75;
        _baseBuilding.BaseCosts.BaseIron = 4320;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 3800;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 75;
        _baseBuilding.BaseCosts.BaseFood = 4320;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 3800;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 75;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function Warehouse() internal view returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 25;
        _baseBuilding.RequiredResearchID = 2;

        // building time values
        _baseBuilding.BaseTime = 5;
        _baseBuilding.Coefficient = 11;
        _baseBuilding.CoefficientRatio = 50; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 516;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 300;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 20;
        _baseBuilding.BaseCosts.BaseWood = 1800;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 1000;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 50;
        _baseBuilding.BaseCosts.BaseStone = 1500;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 1000;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 50;
        _baseBuilding.BaseCosts.BaseIron = 1500;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 1000;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 50;
        _baseBuilding.BaseCosts.BaseFood = 1500;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 1000;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 50;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function Barracks() internal view returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 15;
        _baseBuilding.RequiredResearchID = 41;

        // building time values
        _baseBuilding.BaseTime = 10;
        _baseBuilding.Coefficient = 11;
        _baseBuilding.CoefficientRatio = 60; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 602;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 350;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 50;
        _baseBuilding.BaseCosts.BaseWood = 2100;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 650;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 30;
        _baseBuilding.BaseCosts.BaseStone = 2000;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 700;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 30;
        _baseBuilding.BaseCosts.BaseIron = 2160;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 750;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 30;
        _baseBuilding.BaseCosts.BaseFood = 2160;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 750;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 30;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function Workshop() internal view returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 10;
        _baseBuilding.RequiredResearchID = 46;

        // building time values
        _baseBuilding.BaseTime = 12;
        _baseBuilding.Coefficient = 12;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 445;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 300;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 5;
        _baseBuilding.BaseCosts.BaseWood = 1555;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 1000;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 30;
        _baseBuilding.BaseCosts.BaseStone = 1100;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 750;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 30;
        _baseBuilding.BaseCosts.BaseIron = 1500;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 1500;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 30;
        _baseBuilding.BaseCosts.BaseFood = 1296;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 1000;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 30;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function Housing() internal view returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 50;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 5;
        _baseBuilding.Coefficient = 10;
        _baseBuilding.CoefficientRatio = 50; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 1783;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 1350;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 27;
        _baseBuilding.BaseCosts.BaseWood = 6220;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 4150;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 75;
        _baseBuilding.BaseCosts.BaseStone = 5184;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 4250;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 75;
        _baseBuilding.BaseCosts.BaseIron = 4350;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 3200;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 75;
        _baseBuilding.BaseCosts.BaseFood = 5000;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 3500;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 75;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function ResearchCenter() internal view returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 10;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 10;
        _baseBuilding.Coefficient = 15;
        _baseBuilding.CoefficientRatio = 60; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 825;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 600;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 15;
        _baseBuilding.BaseCosts.BaseWood = 2880;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 1500;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 50;
        _baseBuilding.BaseCosts.BaseStone = 1700;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 1500;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 50;
        _baseBuilding.BaseCosts.BaseIron = 2000;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 1300;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 50;
        _baseBuilding.BaseCosts.BaseFood = 2600;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 1500;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 50;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function DefenseTower() internal view returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.UtilityValues = new uint[](_baseBuilding.MaxTier);
        _baseBuilding.UtilityValues[0] = 1; // means at tier 1, it will have value of 5% for whatever it does
        _baseBuilding.UtilityValues[1] = 2;
        _baseBuilding.UtilityValues[2] = 3;
        _baseBuilding.UtilityValues[3] = 4;
        _baseBuilding.UtilityValues[4] = 5;
        _baseBuilding.RequiredResearchID = 49;

        // building time values
        _baseBuilding.BaseTime = 25;
        _baseBuilding.Coefficient = 39;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 891;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 1000;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 20;
        _baseBuilding.BaseCosts.BaseWood = 3110;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 2650;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 50;
        _baseBuilding.BaseCosts.BaseStone = 2500;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 2600;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 50;
        _baseBuilding.BaseCosts.BaseIron = 2200;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 1500;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 50;
        _baseBuilding.BaseCosts.BaseFood = 1600;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 750;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 50;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function TradingPost() internal view returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 10;
        _baseBuilding.RequiredResearchID = 5;

        // building time values
        _baseBuilding.BaseTime = 5;
        _baseBuilding.Coefficient = 11;
        _baseBuilding.CoefficientRatio = 60; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 516;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 300;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 15;
        _baseBuilding.BaseCosts.BaseWood = 1800;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 1000;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 50;
        _baseBuilding.BaseCosts.BaseStone = 1500;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 1000;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 50;
        _baseBuilding.BaseCosts.BaseIron = 1500;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 1000;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 50;
        _baseBuilding.BaseCosts.BaseFood = 1500;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 1000;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 50;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function Hatchery() internal view returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.RequiredResearchID = 7;

        // building time values
        _baseBuilding.BaseTime = 15;
        _baseBuilding.Coefficient = 50;
        _baseBuilding.CoefficientRatio = 90; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 412;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 400;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 5;
        _baseBuilding.BaseCosts.BaseWood = 1440;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 1500;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 20;
        _baseBuilding.BaseCosts.BaseStone = 1200;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 1500;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 20;
        _baseBuilding.BaseCosts.BaseIron = 1200;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 1500;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 20;
        _baseBuilding.BaseCosts.BaseFood = 1200;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 1500;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 20;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function WorldBossPortal() internal view returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 10;
        _baseBuilding.RequiredResearchID = 23;

        // building time values
        _baseBuilding.BaseTime = 30;
        _baseBuilding.Coefficient = 45;
        _baseBuilding.CoefficientRatio = 200; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 296;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 500;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 15;
        _baseBuilding.BaseCosts.BaseWood = 1036;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 1000;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 50;
        _baseBuilding.BaseCosts.BaseStone = 864;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 1000;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 50;
        _baseBuilding.BaseCosts.BaseIron = 864;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 1000;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 50;
        _baseBuilding.BaseCosts.BaseFood = 864;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 1000;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 50;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function Walls() internal view returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.UtilityValues = new uint[](_baseBuilding.MaxTier);
        _baseBuilding.UtilityValues[0] = 2; // means at tier 1, it will have value of 5% for whatever it does
        _baseBuilding.UtilityValues[1] = 4;
        _baseBuilding.UtilityValues[2] = 6;
        _baseBuilding.UtilityValues[3] = 8;
        _baseBuilding.UtilityValues[4] = 10;
        _baseBuilding.RequiredResearchID = 44;

        // building time values
        _baseBuilding.BaseTime = 30;
        _baseBuilding.Coefficient = 45;
        _baseBuilding.CoefficientRatio = 80; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 1100;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 850;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 30;
        _baseBuilding.BaseCosts.BaseWood = 3840;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 2250;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 90;
        _baseBuilding.BaseCosts.BaseStone = 5200;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 2500;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 90;
        _baseBuilding.BaseCosts.BaseIron = 2700;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 1750;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 90;
        _baseBuilding.BaseCosts.BaseFood = 1500;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 1250;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 75;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function generateCostArray(uint maxTier) internal view returns (uint[][] memory) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint MAX_RESOURCE_ID = s.MAX_RESOURCE_ID;
        uint[][] memory _tierArray = new uint[][](maxTier);
        for (uint i = 0; i < _tierArray.length; i++) {
            _tierArray[i] = new uint[](MAX_RESOURCE_ID);
        }

        return _tierArray;
    }

    /*    function generateTimeArray(
        uint[] memory timeRequiredByTiers
    ) internal view returns (uint[] memory) {
        uint[] memory _return = new uint[](timeRequiredByTiers.length);
        for (uint i = 0; i < timeRequiredByTiers.length; ) {
            _return[i] = timeRequiredByTiers[i];
            unchecked {
                i++;
            }
        }
        return _return;
    } */

    function enterResourceCost(Building memory _baseBuilding) internal view returns (Building memory) {
        uint len = _baseBuilding.MaxTier + 1;
        _baseBuilding.Cost = generateCostArray(len);
        for (uint i = 1; i <= len; ) {
            _baseBuilding.Cost[i - 1][0] = calculateValue(
                i,
                _baseBuilding.BaseCosts.BaseGold,
                _baseBuilding.BaseCosts.BaseGoldCoefficient1,
                _baseBuilding.BaseCosts.BaseGoldCoefficient2
            );
            _baseBuilding.Cost[i - 1][1] = calculateValue(
                i,
                _baseBuilding.BaseCosts.BaseWood,
                _baseBuilding.BaseCosts.BaseWoodCoefficient1,
                _baseBuilding.BaseCosts.BaseWoodCoefficient2
            );
            _baseBuilding.Cost[i - 1][2] = calculateValue(
                i,
                _baseBuilding.BaseCosts.BaseStone,
                _baseBuilding.BaseCosts.BaseStoneCoefficient1,
                _baseBuilding.BaseCosts.BaseStoneCoefficient2
            );
            _baseBuilding.Cost[i - 1][3] = calculateValue(
                i,
                _baseBuilding.BaseCosts.BaseIron,
                _baseBuilding.BaseCosts.BaseIronCoefficient1,
                _baseBuilding.BaseCosts.BaseIronCoefficient2
            );
            _baseBuilding.Cost[i - 1][4] = calculateValue(
                i,
                _baseBuilding.BaseCosts.BaseFood,
                _baseBuilding.BaseCosts.BaseFoodCoefficient1,
                _baseBuilding.BaseCosts.BaseFoodCoefficient2
            );
            unchecked {
                i++;
            }
        }
        return _baseBuilding;
    }

    function enterTimeCost(Building memory _baseBuilding) internal pure returns (Building memory) {
        // uint len = _baseBuilding.MaxTier + 1;
        uint[] memory timeRequired = new uint[](_baseBuilding.MaxTier);
        for (uint i = 1; i <= timeRequired.length; ) {
            timeRequired[i - 1] = calculateValue(i, _baseBuilding.BaseTime, _baseBuilding.Coefficient, _baseBuilding.CoefficientRatio) * 1 minutes;
            unchecked {
                i++;
            }
        }
        _baseBuilding.UpgradeTime = timeRequired;
        return _baseBuilding;
    }
}
