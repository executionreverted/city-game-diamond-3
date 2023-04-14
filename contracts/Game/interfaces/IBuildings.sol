import {Building} from "../shared/CityStructs.sol";
// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

interface IBuildings {
    function buildingInfo(
        uint buildingId
    ) external view returns (Building memory);
}
