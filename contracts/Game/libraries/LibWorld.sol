// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;
import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {LibCityManager} from "./LibCityManager.sol";
import {LibCities} from "./LibCities.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {LibCalculator} from "./LibCalculator.sol";
import {Coords, Plot, PlotContentTypes} from "../shared/WorldStructs.sol";
import {Building, City, Race} from "../shared/CityStructs.sol";
import {Resource} from "../shared/ResourceEnums.sol";
import {IFetchGlobal} from "../interfaces/IFetchGlobal.sol";
import "../shared/Errors.sol";

library LibWorld {
    function noise(int x, int y) internal view returns (int) {
        return IFetchGlobal(address(this)).noise2d(x, y);
    }

    function sin(uint16 x) internal view returns (int) {
        return IFetchGlobal(address(this)).sin(x);
    }

    function generatePlotContent(AppStorage storage s, Plot memory _plot, Coords memory _coords) internal view returns (Plot memory) {
        _plot.Coords.X = _coords.X;
        _plot.Coords.Y = _coords.Y;
        _plot.IsTaken = s.CoordsToPlot[_coords.X][_coords.Y].IsTaken;
        if (_plot.IsTaken) {
            _plot.CityId = s.CoordsToCity[_coords.X][_coords.Y];
        }
        if (s.CoordsToPlot[_coords.X][_coords.Y].IsTaken) {
            _plot.Content.Type = PlotContentTypes.TAKEN;
            _plot.CityId = s.CoordsToCity[_coords.X][_coords.Y];
            return _plot;
        }

        uint256 a = uint256(uint256(_coords.X < 0 ? _coords.X * -1 : _coords.X) * 25);
        uint256 b = uint256(uint256(_coords.Y < 0 ? _coords.Y * -1 : _coords.Y) * 25);
        if (a > type(uint16).max) {
            a = type(uint16).max;
        }
        if (b > type(uint16).max) {
            b = type(uint16).max;
        }

        _plot.Climate = noise(sin(uint16(a % 65536)) * s.NOISE_AMOUNT * s.MAP_SEED, sin(uint16(b % 65536)) * s.NOISE_AMOUNT * s.MAP_SEED);

        uint randomness1 = useRandom(s, _coords, 316942069, 100); // determine if has plot content & what type it is
        uint randomness2 = useRandom(s, _coords, 420, 100); // determine plot content type e.g Resource Food
        uint randomness3 = useRandom(s, _coords, 69420, 100); // determine plot content content tier @MAX_PLOT_TIER
        uint randomness4 = useRandom(s, _coords, 3142069, 100); // determine param1 min value
        uint randomness5 = useRandom(s, _coords, 315269420, 100); // determine param2 max value
        // 5%
        bool inhabitable = randomness1 <= 8 || (_plot.Climate < -11 || _plot.Climate > 15);

        if (inhabitable) {
            _plot.Content.Type = PlotContentTypes.INHABITABLE;
            return _plot;
        }

        // has content
        if (randomness1 <= 15) {
            uint foundContent = ((randomness1 + 1)) % 5;

            _plot.Content.Type = PlotContentTypes(foundContent + 2);

            // select resource type
            _plot.Content.Tier = uint8(((randomness3 * 1337601) % s.MAX_PLOT_TIER) + 1);
            if (_plot.Content.Type == PlotContentTypes.RESOURCE) {
                // set resource type in this case.
                if (randomness2 >= 0 && randomness2 < 20) {
                    _plot.Content.Value1 = uint(Resource.GOLD);
                } else if (randomness2 >= 20 && randomness2 < 40) {
                    _plot.Content.Value1 = uint(Resource.WOOD);
                } else if (randomness2 >= 40 && randomness2 < 60) {
                    _plot.Content.Value1 = uint(Resource.STONE);
                } else if (randomness2 >= 60 && randomness2 < 80) {
                    _plot.Content.Value1 = uint(Resource.IRON);
                } else if (randomness2 >= 80 && randomness2 <= 100) {
                    _plot.Content.Value1 = uint(Resource.FOOD);
                }
                // Min.
                _plot.Content.Value2 = ((s.BASE_RESOURCE_SPAWN_AMOUNT * _plot.Content.Tier) * randomness4) / 100;
                // Max.
                _plot.Content.Value3 = _plot.Content.Value2 + (_plot.Content.Value2 * randomness5) / 100;
            }
        } else {
            _plot.Content.Type = PlotContentTypes.HABITABLE;
        }

        return _plot;
    }

    function generateNumberFromCoordsAndSeed(AppStorage storage s, Coords memory coords, uint internalSeed) internal view returns (uint) {
        uint random = uint256(keccak256(abi.encodePacked(coords.X, coords.Y, address(this), s.EVENT_MAP_SEED, internalSeed)));
        return random;
    }

    function useRandom(AppStorage storage s, Coords memory coords, uint seed, uint modulus) internal view returns (uint) {
        return (generateNumberFromCoordsAndSeed(s, coords, seed) % modulus) + 1;
    }
}
