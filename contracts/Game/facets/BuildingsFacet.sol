// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {Building} from "../shared/CityStructs.sol";
import {AppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibBuildings} from "../libraries/LibBuildings.sol";

contract BuildingsFacet is Modifiers {
    function allBuildings() external view returns (Building[] memory) {
        return LibBuildings.allBuildings();
    }

    function buildingInfo(uint buildingId) external view returns (Building memory) {
        return LibBuildings.buildingInfo(buildingId);
    }
}
