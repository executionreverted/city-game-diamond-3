// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {LibAppStorage, AppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibTroopCommands} from "../libraries/LibTroopCommands.sol";
import {Coords} from "../shared/WorldStructs.sol";
import {Squad, Target, Purpose} from "../shared/TroopsStructs.sol";
import {Resource} from "../shared/ResourceEnums.sol";
import "../shared/Errors.sol";

contract TroopCommandsFacet is Modifiers {
    function attack(uint squadId, Target target, uint targetSquadId) external {
        LibTroopCommands.attack(squadId, target, targetSquadId);
    }
    
}
