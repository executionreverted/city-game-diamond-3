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

    function cityCoords(uint cityId) external view returns (Coords memory _coords) {
        return s.CityCoords[cityId];
    }

    function isPlotEmpty(Coords memory coords) external view returns (bool) {
        Plot memory _plot = LibWorld.plotProps(coords);
        return
            (_plot.Content.Type == PlotContentTypes.HABITABLE && !s.CoordsToPlot[coords.X][coords.Y].IsTaken) ||
            s.CoordsToCity[coords.X][coords.Y] == 0;
    }

    function scanCitiesBetweenCoords(int startX, int endX, int startY, int endY) external view returns (City[] memory, uint[] memory) {
        require(startX < endX && startY < endY, "start must be lower");
        uint resultLen = uint(endX - startX) * uint(endY - startY);
        uint i;
        City[] memory resultCities = new City[](resultLen);
        uint[] memory resultCityIds = new uint[](resultLen);

        for (int x = startX; x < endX; x++) {
            for (int y = startY; y < endY; y++) {
                uint cityId = s.CoordsToCity[x][y];
                if (cityId == 0) continue;
                resultCities[i] = s.CityList[cityId];
                resultCityIds[i] = cityId;
                i++;
            }
        }

        return (resultCities, resultCityIds);
    }

    function scanPlotsForEmptyPlace(int startX, int endX, int startY, int endY) external view returns (Coords memory _coords) {
        for (int x = startX; x < endX; x++) {
            for (int y = startY; y < endY; y++) {
                if (x == 0 && y == 0) continue;
                if (s.CoordsToCity[x][y] == 0) {
                    _coords.X = x;
                    _coords.Y = y;
                    break;
                }
            }
        }
    }

    function scanPlots(int256 startX, int256 endX, int256 startY, int256 endY) external view returns (Plot[] memory) {
        require(startX < endX && startY < endY, "invalid input");
        uint i;
        int xRange = endX - startX;
        int yRange = endY - startY;
        uint resultLen = uint(xRange * yRange);
        Plot[] memory resultPlots = new Plot[](resultLen);
        for (int x = startX; x < endX; x++) {
            for (int y = startY; y < endY; y++) {
                if (x == 0 && y == 0) continue;
                uint256 a = uint256(uint256(x < 0 ? x * -1 : x) * 25);
                uint256 b = uint256(uint256(y < 0 ? y * -1 : y) * 25);
                if (a > type(uint16).max) {
                    a = type(uint16).max;
                }
                if (b > type(uint16).max) {
                    b = type(uint16).max;
                }
                resultPlots[i] = LibWorld.generatePlotContent(s, resultPlots[i], Coords({X: x, Y: y}));

                i++;
            }
        }

        return resultPlots;
    }

    function plotProps(Coords memory _coords) external view returns (Plot memory _plot) {
        return LibWorld.plotProps(_coords);
    }
}
