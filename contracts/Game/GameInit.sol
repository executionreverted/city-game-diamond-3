// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {AppStorage} from "./libraries/LibAppStorage.sol";
import {LibMeta} from "../shared/libraries/LibMeta.sol";
import {LibDiamond} from "../shared/libraries/LibDiamond.sol";
import {IDiamondCut} from "../shared/interfaces/IDiamondCut.sol";
import {IERC165} from "../shared/interfaces/IERC165.sol";
import {IDiamondLoupe} from "../shared/interfaces/IDiamondLoupe.sol";
import {IERC173} from "../shared/interfaces/IERC173.sol";

contract GameInit {
    AppStorage internal s;

    function init() external {
        s.domainSeparator = LibMeta.domainSeparator("Game", "V1");
        s.GameManagers[msg.sender] = true;
        s.MAX_RESOURCE_ID = 5;
        s.MAX_BUILDING_ID = 50;
        s.POPULATION_CAP_PER_TOWNHALL_TIER = 500;
        s.BASE_PLOT_INTERACTION_COOLDOWN = 1 minutes;
        s.BASE_RESOURCE_SPAWN_AMOUNT = 100;
        s.MAX_PLOT_TIER = 5;
        s.DISTANCE_PER_PLOT = 2000;
        s.DISTANCE_TIME;
        s.PERLIN_05 = 32768;
        s.PERLIN_1 = 32768 * 2;
        s.NOISE_AMOUNT = 15;
        s.MAP_SEED = 1;
        s.EVENT_MAP_SEED = 123456789;
        s.MAX_RESOURCE_ID = 5;
        s.PROD_CYCLE = 1 minutes; // todo fix in prod
        s.WAREHOUSE_ID = 5;
        s.WAREHOUSE_STORAGE_PER_TIER = 250;
        s.BASE_GOLD_MAX = 300;
        s.BASE_WOOD_MAX = 300;
        s.BASE_STONE_MAX = 300;
        s.BASE_IRON_MAX = 300;
        s.BASE_FOOD_MAX = 300;
        s.BaseProductions[0] = 100;
        s.BaseProductions[1] = 100;
        s.BaseProductions[2] = 100;
        s.BaseProductions[3] = 100;
        s.BaseProductions[4] = 100;
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        s.MAX_SQUADS_ON_PLOT = 10;
        s.BARRACKS_ID = 6;
        s.ACTION_RANGE = 3;
        s.RESEARCH_CENTER_ID = 9;
        // adding ERC165 data
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        // s.name = _args.name;
        // s.symbol = _args.symbol;
    }
}
