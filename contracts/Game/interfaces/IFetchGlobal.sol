// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {Building} from "../shared/CityStructs.sol";
import {Research} from "../shared/ResearchStructs.sol";
import {IFetchGlobal} from "../interfaces/IFetchGlobal.sol";

interface IFetchGlobal {
    function buildingInfo(uint buildingId) external view returns (Building memory);

    function researchInfo(uint researchId) external view returns (Research memory);

    function noise2d(int x, int y) external view returns (int);

    function sin(uint16 x) external view returns (int);

    function cos(uint16 x) external view returns (int);
}
