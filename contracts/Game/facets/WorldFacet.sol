// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {Modifiers} from "../libraries/LibAppStorage.sol";
import {Plot, Coords, PlotContentTypes} from "../shared/WorldStructs.sol";
import {City, Race} from "../shared/CityStructs.sol";
import {Resource} from "../shared/ResourceEnums.sol";
import {LibWorld} from "../libraries/LibWorld.sol";
import {LibCities} from "../libraries/LibCities.sol";
import {LibCalculator} from "../libraries/LibCalculator.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import "../shared/Errors.sol";

contract WorldFacet is Modifiers {
    function createCity(Coords memory coords, bool pickClosest, Race race) external returns (Coords memory _coords) {
        _coords = LibWorld.createCity(coords, pickClosest, race);
    }

    function isPlotEmpty(Coords memory coords) public view returns (bool) {
        Plot memory _plot = plotProps(coords);
        return
            (_plot.Content.Type == PlotContentTypes.HABITABLE && !s.CoordsToPlot[coords.X][coords.Y].IsTaken) ||
            s.CoordsToCity[coords.X][coords.Y] == 0;
    }

    function scanCitiesBetweenCoords(int startX, int endX, int startY, int endY) external view returns (City[] memory, uint[] memory) {
        return LibWorld.scanCitiesBetweenCoords(startX, endX, startY, endY);
    }

    function scanPlotsForEmptyPlace(int startX, int endX, int startY, int endY) external view returns (Coords memory _coords) {
        return LibWorld.scanPlotsForEmptyPlace(startX, endX, startY, endY);
    }

    function scanPlots(int256 startX, int256 endX, int256 startY, int256 endY) external view returns (Plot[] memory) {
        return LibWorld.scanPlots(startX, endX, startY, endY);
    }

    function distanceBetweenTwoPoints(Coords memory a, Coords memory b) public pure returns (uint) {
        return LibCalculator.calculateDistance(a, b);
    }

    function plotProps(Coords memory _coords) public view returns (Plot memory _plot) {
        return LibWorld.plotProps(_coords);
    }
}
