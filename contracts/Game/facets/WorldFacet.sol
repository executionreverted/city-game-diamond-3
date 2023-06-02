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
    event CityCreated(uint indexed cityId, address indexed owner, Coords coords);

    function createCity(Coords memory coords, bool pickClosest, Race race) external returns (Coords memory _coords) {
        bool isEmpty = isPlotEmpty(coords);
        if ((!isEmpty && !pickClosest) || ((coords.X == 0 && coords.Y == 0))) revert ErrorInvalidWorldCoordinates(coords.X, coords.Y);

        if (coords.X > 0) {
            if (coords.X - s.MAX_AWAY_FROM > s.WorldState.LastXPositive) revert ErrorInvalidWorldCoordinates(coords.X, coords.Y);
        } else {
            if (coords.X + s.MAX_AWAY_FROM < s.WorldState.LastXNegative) revert ErrorInvalidWorldCoordinates(coords.X, coords.Y);
        }

        if (coords.Y > 0) {
            if (coords.Y - s.MAX_AWAY_FROM > s.WorldState.LastYPositive) revert ErrorInvalidWorldCoordinates(coords.X, coords.Y);
        } else {
            if (coords.Y + s.MAX_AWAY_FROM < s.WorldState.LastYNegative) revert ErrorInvalidWorldCoordinates(coords.X, coords.Y);
        }

        address to = LibMeta.msgSender();

        _coords = getNextCity(coords, true);

        uint token = LibCities.mint(to, _coords, race);
        s.CoordsToCity[_coords.X][_coords.Y] = token;
        s.CoordsToPlot[_coords.X][_coords.Y].IsTaken = true;

        if (_coords.X > 0) {
            if (s.WorldState.LastXPositive < _coords.X) s.WorldState.LastXPositive = _coords.X;
        } else {
            if (s.WorldState.LastXNegative > _coords.X) s.WorldState.LastXNegative = _coords.X;
        }

        if (_coords.Y > 0) {
            if (s.WorldState.LastYPositive < _coords.Y) s.WorldState.LastYPositive = _coords.Y;
        } else {
            if (s.WorldState.LastYNegative > _coords.Y) s.WorldState.LastYNegative = _coords.Y;
        }

        s.CityCoords[token] = _coords;
        emit CityCreated(token, to, _coords);
    }

    function cityCoords(uint cityId) external view returns (Coords memory _coords) {
        return s.CityCoords[cityId];
    }

    function getNextCity(Coords memory requestedCoords, bool flip) internal view returns (Coords memory _finalCoords) {
        if (isPlotEmpty(requestedCoords)) return requestedCoords;

        _finalCoords = requestedCoords;

        while (!isPlotEmpty(_finalCoords)) {
            if (_finalCoords.X == _finalCoords.Y || flip) {
                if (_finalCoords.X > 0) {
                    _finalCoords.X++;
                } else {
                    _finalCoords.X--;
                }
            } else {
                if (_finalCoords.Y > 0) {
                    _finalCoords.Y++;
                } else {
                    _finalCoords.Y--;
                }
            }
            flip = !flip;
        }

        return getNextCity(_finalCoords, flip);
    }

    function plotProps(Coords memory _coords) internal view returns (Plot memory _plot) {
        // param 1
        // use cos and noise

        if (_coords.X == 0 && _coords.Y == 0) {
            _plot.Content.Type = PlotContentTypes.INHABITABLE;
            return _plot;
        }

        _plot = LibWorld.generatePlotContent(s, _plot, _coords);
    }

    function isPlotEmpty(Coords memory coords) public view returns (bool) {
        Plot memory _plot = plotProps(coords);
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
}
