// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {Research} from "../shared/ResearchStructs.sol";

library LibResearchs {
    function researchInfo(uint researchId) internal pure returns (Research memory) {
        if (researchId == 1) return SettledLife();
        if (researchId == 2) return Savings101();
        if (researchId == 3) return VAT();
        if (researchId == 4) return ScienceBudget();
        if (researchId == 5) return TradingRoutes();
        if (researchId == 6) return Commisions();
        if (researchId == 7) return FromEggToSky();
        if (researchId == 8) return SPT();
        if (researchId == 9) return AdvancedLogistics();
        if (researchId == 10) return Investing();
        if (researchId == 21) return Pulley();
        if (researchId == 22) return AdvancedToolsI();
        if (researchId == 23) return BeyondOurRealm();
        if (researchId == 24) return Architecture();
        if (researchId == 25) return Ink();
        if (researchId == 26) return AdvancedToolsII();
        if (researchId == 27) return Machinery();
        if (researchId == 28) return AdvancedToolsIII();
        if (researchId == 29) return PowerOfSteam();
        if (researchId == 30) return AutomatizedProduction();
        if (researchId == 41) return Enlisting();
        if (researchId == 42) return Rhetorics();
        if (researchId == 43) return MilitaryLogistics();
        if (researchId == 44) return ProtectionI();
        if (researchId == 45) return Propaganda();
        if (researchId == 46) return Demolishion();
        if (researchId == 47) return Mobilization();
        if (researchId == 48) return MarchMarch();
        if (researchId == 49) return ProtectionII();
        if (researchId == 50) return SteamEnginesMachineries();
        revert("not implemented");
    }

    function SettledLife() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 1; // no requirements.
        _baseResearch.RequiredResearchId = 0; // no requirements.

        // if its default unlocked, uncomment that line.
        // _baseResearch.IsUnlocked = true; // no requirements.

        _baseResearch.TimeRequired = 15 minutes;
        _baseResearch.MinResearchCenterLevel = 1;
        //_baseResearch.UtilityValue= 5;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 4802;
        _baseResearch.Cost[1] = 16870;
        _baseResearch.Cost[2] = 14280;
        _baseResearch.Cost[3] = 9830;
        _baseResearch.Cost[4] = 14400;

        return _baseResearch;
    }

    function Savings101() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 2;
        _baseResearch.RequiredResearchId = 1;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 60 minutes;
        _baseResearch.MinResearchCenterLevel = 1;
        //_baseResearch.UtilityValue= 5;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 14310;
        _baseResearch.Cost[1] = 122208;
        _baseResearch.Cost[2] = 113752;
        _baseResearch.Cost[3] = 72472;
        _baseResearch.Cost[4] = 86840;

        return _baseResearch;
    }

    function VAT() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 3;
        _baseResearch.RequiredResearchId = 2;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 240 minutes;
        _baseResearch.MinResearchCenterLevel = 2;
        _baseResearch.UtilityValue = 2;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 23160;
        _baseResearch.Cost[1] = 0;
        _baseResearch.Cost[2] = 0;
        _baseResearch.Cost[3] = 0;
        _baseResearch.Cost[4] = 144880;

        return _baseResearch;
    }

    function ScienceBudget() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 4;
        _baseResearch.RequiredResearchId = 3;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 720 minutes;
        _baseResearch.MinResearchCenterLevel = 3;
        _baseResearch.UtilityValue = 5; //negative

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 31160;
        _baseResearch.Cost[1] = 0;
        _baseResearch.Cost[2] = 0;
        _baseResearch.Cost[3] = 0;
        _baseResearch.Cost[4] = 162920;

        return _baseResearch;
    }

    function TradingRoutes() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 5;
        _baseResearch.RequiredResearchId = 4;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 1440 minutes;
        _baseResearch.MinResearchCenterLevel = 4;
        //_baseResearch.UtilityValue= 5;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 33660;
        _baseResearch.Cost[1] = 240882;
        _baseResearch.Cost[2] = 209088;
        _baseResearch.Cost[3] = 124268;
        _baseResearch.Cost[4] = 195960;

        return _baseResearch;
    }

    function Commisions() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 6;
        _baseResearch.RequiredResearchId = 5;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 2048 minutes;
        _baseResearch.MinResearchCenterLevel = 5;
        _baseResearch.UtilityValue = 4;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 35160;
        _baseResearch.Cost[1] = 339400;
        _baseResearch.Cost[2] = 312600;
        _baseResearch.Cost[3] = 198600;
        _baseResearch.Cost[4] = 312000;

        return _baseResearch;
    }

    function FromEggToSky() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 7;
        _baseResearch.RequiredResearchId = 6;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 4096 minutes;
        _baseResearch.MinResearchCenterLevel = 6;
        //_baseResearch.UtilityValue= 5;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 35660;
        _baseResearch.Cost[1] = 600896;
        _baseResearch.Cost[2] = 653624;
        _baseResearch.Cost[3] = 332264;
        _baseResearch.Cost[4] = 307720;

        return _baseResearch;
    }

    function SPT() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 8;
        _baseResearch.RequiredResearchId = 7;
        _baseResearch.RequiredResearchId = 23;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 8192 minutes;
        _baseResearch.MinResearchCenterLevel = 7;
        _baseResearch.UtilityValue = 5;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 40660;
        _baseResearch.Cost[1] = 0;
        _baseResearch.Cost[2] = 0;
        _baseResearch.Cost[3] = 474128;
        _baseResearch.Cost[4] = 670160;

        return _baseResearch;
    }

    function AdvancedLogistics() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 9;
        _baseResearch.RequiredResearchId = 8;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 9600 minutes;
        _baseResearch.MinResearchCenterLevel = 8;
        _baseResearch.UtilityValue = 10; //negative

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 40460;
        _baseResearch.Cost[1] = 796488;
        _baseResearch.Cost[2] = 733072;
        _baseResearch.Cost[3] = 445992;
        _baseResearch.Cost[4] = 721240;

        return _baseResearch;
    }

    function Investing() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 10;
        _baseResearch.RequiredResearchId = 9;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 11520 minutes;
        _baseResearch.MinResearchCenterLevel = 9;
        _baseResearch.UtilityValue = 15;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 60000;
        _baseResearch.Cost[1] = 1000000;
        _baseResearch.Cost[2] = 1000000;
        _baseResearch.Cost[3] = 1000000;
        _baseResearch.Cost[4] = 1000000;

        return _baseResearch;
    }

    function Pulley() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 21;
        _baseResearch.RequiredResearchId = 1;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 15 minutes;
        _baseResearch.MinResearchCenterLevel = 1;
        _baseResearch.UtilityValue = 5; //negative

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 4052;
        _baseResearch.Cost[1] = 16420;
        _baseResearch.Cost[2] = 15080;
        _baseResearch.Cost[3] = 10330;
        _baseResearch.Cost[4] = 12000;

        return _baseResearch;
    }

    function AdvancedToolsI() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 22;
        _baseResearch.RequiredResearchId = 21;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 60 minutes;
        _baseResearch.MinResearchCenterLevel = 1;
        _baseResearch.UtilityValue = 5;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 13910;
        _baseResearch.Cost[1] = 132208;
        _baseResearch.Cost[2] = 118752;
        _baseResearch.Cost[3] = 83472;
        _baseResearch.Cost[4] = 76840;

        return _baseResearch;
    }

    function BeyondOurRealm() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 23;
        _baseResearch.RequiredResearchId = 22;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 240 minutes;
        _baseResearch.MinResearchCenterLevel = 2;
        //_baseResearch.UtilityValue= 5;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 20660;
        _baseResearch.Cost[1] = 266784;
        _baseResearch.Cost[2] = 249296;
        _baseResearch.Cost[3] = 144856;
        _baseResearch.Cost[4] = 139880;

        return _baseResearch;
    }

    function Architecture() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 24;
        _baseResearch.RequiredResearchId = 23;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 720 minutes;
        _baseResearch.MinResearchCenterLevel = 3;
        _baseResearch.UtilityValue = 5; //negative

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 24910;
        _baseResearch.Cost[1] = 296256;
        _baseResearch.Cost[2] = 251464;
        _baseResearch.Cost[3] = 187504;
        _baseResearch.Cost[4] = 142920;

        return _baseResearch;
    }

    function Ink() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 25;
        _baseResearch.RequiredResearchId = 24;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 1440 minutes;
        _baseResearch.MinResearchCenterLevel = 4;
        //_baseResearch.UtilityValue= 5;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 30160;
        _baseResearch.Cost[1] = 220152;
        _baseResearch.Cost[2] = 187088;
        _baseResearch.Cost[3] = 121768;
        _baseResearch.Cost[4] = 170960;

        return _baseResearch;
    }

    function AdvancedToolsII() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 26;
        _baseResearch.RequiredResearchId = 25;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 2048 minutes;
        _baseResearch.MinResearchCenterLevel = 5;
        _baseResearch.UtilityValue = 5; //negative

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 34160;
        _baseResearch.Cost[1] = 375400;
        _baseResearch.Cost[2] = 342600;
        _baseResearch.Cost[3] = 208600;
        _baseResearch.Cost[4] = 287000;

        return _baseResearch;
    }

    function Machinery() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 27;
        _baseResearch.RequiredResearchId = 26;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 4096 minutes;
        _baseResearch.MinResearchCenterLevel = 6;
        //_baseResearch.UtilityValue= 5;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 39160;
        _baseResearch.Cost[1] = 570896;
        _baseResearch.Cost[2] = 503624;
        _baseResearch.Cost[3] = 332264;
        _baseResearch.Cost[4] = 342720;

        return _baseResearch;
    }

    function AdvancedToolsIII() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 28;
        _baseResearch.RequiredResearchId = 27;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 8192 minutes;
        _baseResearch.MinResearchCenterLevel = 7;
        _baseResearch.UtilityValue = 5;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 40660;
        _baseResearch.Cost[1] = 1309288;
        _baseResearch.Cost[2] = 1176272;
        _baseResearch.Cost[3] = 444128;
        _baseResearch.Cost[4] = 670160;

        return _baseResearch;
    }

    function PowerOfSteam() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 29;
        _baseResearch.RequiredResearchId = 28;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 9600 minutes;
        _baseResearch.MinResearchCenterLevel = 8;
        //_baseResearch.UtilityValue= 5;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 40160;
        _baseResearch.Cost[1] = 761488;
        _baseResearch.Cost[2] = 653072;
        _baseResearch.Cost[3] = 480992;
        _baseResearch.Cost[4] = 646240;

        return _baseResearch;
    }

    function AutomatizedProduction() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 30;
        _baseResearch.RequiredResearchId = 29;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 11520 minutes;
        _baseResearch.MinResearchCenterLevel = 9;
        _baseResearch.UtilityValue = 10;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 60000;
        _baseResearch.Cost[1] = 1000000;
        _baseResearch.Cost[2] = 1000000;
        _baseResearch.Cost[3] = 1000000;
        _baseResearch.Cost[4] = 1000000;

        return _baseResearch;
    }

    function Enlisting() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 41;
        _baseResearch.RequiredResearchId = 1;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 15 minutes;
        _baseResearch.MinResearchCenterLevel = 1;
        //_baseResearch.UtilityValue= 5;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 4552;
        _baseResearch.Cost[1] = 13420;
        _baseResearch.Cost[2] = 15580;
        _baseResearch.Cost[3] = 10880;
        _baseResearch.Cost[4] = 14400;

        return _baseResearch;
    }

    function Rhetorics() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 42;
        _baseResearch.RequiredResearchId = 41;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 60 minutes;
        _baseResearch.MinResearchCenterLevel = 1;
        _baseResearch.UtilityValue = 5; //negative

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 13460;
        _baseResearch.Cost[1] = 92208;
        _baseResearch.Cost[2] = 93752;
        _baseResearch.Cost[3] = 61472;
        _baseResearch.Cost[4] = 111840;

        return _baseResearch;
    }

    function MilitaryLogistics() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 43;
        _baseResearch.RequiredResearchId = 42;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 240 minutes;
        _baseResearch.MinResearchCenterLevel = 2;
        //_baseResearch.UtilityValue= 5;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 17660;
        _baseResearch.Cost[1] = 202784;
        _baseResearch.Cost[2] = 190296;
        _baseResearch.Cost[3] = 144856;
        _baseResearch.Cost[4] = 89880;

        return _baseResearch;
    }

    function ProtectionI() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 44;
        _baseResearch.RequiredResearchId = 43;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 720 minutes;
        _baseResearch.MinResearchCenterLevel = 3;
        //_baseResearch.UtilityValue= 5;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 28660;
        _baseResearch.Cost[1] = 200152;
        _baseResearch.Cost[2] = 197088;
        _baseResearch.Cost[3] = 123768;
        _baseResearch.Cost[4] = 175960;

        return _baseResearch;
    }

    function Propaganda() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 45;
        _baseResearch.RequiredResearchId = 44;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 1440 minutes;
        _baseResearch.MinResearchCenterLevel = 4;
        _baseResearch.UtilityValue = 3;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 28660;
        _baseResearch.Cost[1] = 200152;
        _baseResearch.Cost[2] = 197088;
        _baseResearch.Cost[3] = 123768;
        _baseResearch.Cost[4] = 175960;

        return _baseResearch;
    }

    function Demolishion() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 46;
        _baseResearch.RequiredResearchId = 26;
        _baseResearch.RequiredResearchId = 45;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 2048 minutes;
        _baseResearch.MinResearchCenterLevel = 5;
        //_baseResearch.UtilityValue= 5;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 34160;
        _baseResearch.Cost[1] = 375400;
        _baseResearch.Cost[2] = 342600;
        _baseResearch.Cost[3] = 218600;
        _baseResearch.Cost[4] = 312000;

        return _baseResearch;
    }

    function Mobilization() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 47;
        _baseResearch.RequiredResearchId = 46;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 4096 minutes;
        _baseResearch.MinResearchCenterLevel = 6;
        _baseResearch.UtilityValue = 3; //negative

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 37160;
        _baseResearch.Cost[1] = 0;
        _baseResearch.Cost[2] = 0;
        _baseResearch.Cost[3] = 0;
        _baseResearch.Cost[4] = 327720;

        return _baseResearch;
    }

    function MarchMarch() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 48;
        _baseResearch.RequiredResearchId = 47;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 8192 minutes;
        _baseResearch.MinResearchCenterLevel = 7;
        _baseResearch.UtilityValue = 3; //negative

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 36160;
        _baseResearch.Cost[1] = 954288;
        _baseResearch.Cost[2] = 861272;
        _baseResearch.Cost[3] = 414128;
        _baseResearch.Cost[4] = 575160;

        return _baseResearch;
    }

    function ProtectionII() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 49;
        _baseResearch.RequiredResearchId = 23;
        _baseResearch.RequiredResearchId = 48;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 9600 minutes;
        _baseResearch.MinResearchCenterLevel = 8;
        //_baseResearch.UtilityValue= 5;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 39160;
        _baseResearch.Cost[1] = 856488;
        _baseResearch.Cost[2] = 828072;
        _baseResearch.Cost[3] = 480992;
        _baseResearch.Cost[4] = 671240;

        return _baseResearch;
    }

    function SteamEnginesMachineries() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 50;
        _baseResearch.RequiredResearchId = 28;
        _baseResearch.RequiredResearchId = 49;

        _baseResearch.IsUnlocked = false;

        _baseResearch.TimeRequired = 1440 minutes;
        _baseResearch.MinResearchCenterLevel = 4;
        //_baseResearch.UtilityValue= 5;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 60000;
        _baseResearch.Cost[1] = 1000000;
        _baseResearch.Cost[2] = 1000000;
        _baseResearch.Cost[3] = 1000000;
        _baseResearch.Cost[4] = 1000000;

        return _baseResearch;
    }

    /* [
    GOLD, 0
    WOOD, 1
    STONE,2
    IRON, 3
    FOOD  4
    ] */

    /* PRODUCTION BUILDING */

    function generateCostArray() internal pure returns (uint[100] memory _return) {}
}
