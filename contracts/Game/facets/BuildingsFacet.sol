// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {IBuildings} from "../interfaces/IBuildings.sol";
import {Building} from "../shared/CityStructs.sol";
import {AppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibBuildings} from "../libraries/LibBuildings.sol";

contract BuildingsFacet is IBuildings, Modifiers {
    function allBuildings() external view returns (Building[] memory) {
        return LibBuildings.allBuildings();
    }

    function buildingInfo(uint buildingId) public view override returns (Building memory) {
        return LibBuildings.buildingInfo(buildingId);
    }
}
