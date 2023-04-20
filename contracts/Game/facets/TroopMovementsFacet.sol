// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;
import {LibAppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibResources} from "../libraries/LibResources.sol";
import {LibCityManager} from "../libraries/LibCityManager.sol";
import {LibTroopMovements} from "../libraries/LibTroopMovements.sol";
import {LibTroops} from "../libraries/LibTroops.sol";
import {Coords} from "../shared/WorldStructs.sol";
import {Squad, Purpose, Troop} from "../shared/TroopsStructs.sol";
import {Resource} from "../shared/ResourceEnums.sol";
import "../shared/Errors.sol";

contract TroopMovementsFacet is Modifiers {
    event Recruitment(uint indexed cityId, uint indexed troopId, uint amount);

    function sendSquadTo(
        uint cityId,
        Coords memory coords,
        uint8[] memory troopIds,
        uint[] memory troopAmounts,
        Purpose purpose
    ) external onlyCityOwner(cityId) {
        LibTroopMovements.sendSquadTo(cityId, coords, troopIds, troopAmounts, purpose);
    }

    function callSquadBack(uint cityId, uint squadId) external onlyCityOwner(cityId) {
        LibTroopMovements.callSquadBack(cityId, squadId);
    }

    function repositionSquad(uint cityId, uint squadId, Coords memory newCoords) external onlyCityOwner(cityId) {
        LibTroopMovements.repositionSquad(cityId, squadId, newCoords);
    }

    function changePurpose(uint cityId, uint squadId, Purpose newPurpose) external onlyCityOwner(cityId) {
        LibTroopMovements.changePurpose(cityId, squadId, newPurpose);
    }
}
