// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {AppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibPerlinNoise} from "../libraries/LibPerlinNoise.sol";

contract PerlinNoiseFacet is Modifiers {
    function noise2d(int256 x, int256 y) external pure returns (int256) {
        return LibPerlinNoise.noise2d(x, y);
    }
}
