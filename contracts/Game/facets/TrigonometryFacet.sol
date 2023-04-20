// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {Resource} from "../shared/ResourceEnums.sol";
import {AppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibTrigonometry} from "../libraries/LibTrigonometry.sol";
import "../shared/Errors.sol";

contract TrigonometryFacet is Modifiers {
    function sin(uint16 x) external pure returns (int256) {
        return LibTrigonometry.sin(x);
    }

    function cos(uint16 x) external pure returns (int256) {
        return LibTrigonometry.cos(x);
    }
}
