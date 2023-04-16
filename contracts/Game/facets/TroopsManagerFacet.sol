// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {LibAppStorage, AppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibTroopsManager} from "../libraries/LibTroopsManager.sol";
import {LibTroops} from "../libraries/LibTroops.sol";
import {Coords} from "../shared/WorldStructs.sol";
import {Squad, Purpose, Troop} from "../shared/TroopsStructs.sol";
import {Resource} from "../shared/ResourceEnums.sol";
import "../shared/Errors.sol";

contract TroopsManagerFacet is Modifiers {
    using EnumerableSet for EnumerableSet.UintSet;

    function troopInfo(uint troopId) external pure returns (Troop memory) {
        return LibTroops.troopInfo(troopId);
    }

    function troopsOfCity(uint cityId) external view returns (uint8[] memory, uint[] memory) {
        return LibTroopsManager.troopsOfCity(cityId);
    }

    function cityTroops(uint cityId, uint troopId) external view returns (uint) {
        return s.CityTroops[cityId][troopId];
    }

    // function recruitTroop(uint cityId, uint troopId, uint amount) external onlyCityOwner(cityId) {
    //     LibTroopsManager.recruitTroop(cityId, troopId, amount);
    // }

    function recruitTroops(uint cityId, uint8[] calldata troopIds, uint[] calldata amounts) external onlyCityOwner(cityId) {
        LibTroopsManager.recruitTroops(cityId, troopIds, amounts);
    }

    function releaseTroops(uint cityId, uint[] calldata troopIds, uint[] calldata amounts) external onlyCityOwner(cityId) {
        LibTroopsManager.releaseTroops(cityId, troopIds, amounts);
    }

    function sendSquadTo(
        uint cityId,
        Coords memory coords,
        uint8[] memory troopIds,
        uint[] memory troopAmounts,
        Purpose purpose
    ) external onlyCityOwner(cityId) {
        LibTroopsManager.sendSquadTo(cityId, coords, troopIds, troopAmounts, purpose);
    }

    function callSquadBack(uint cityId, uint squadId) external onlyCityOwner(cityId) {
        LibTroopsManager.callSquadBack(cityId, squadId);
    }

    function repositionSquad(uint cityId, uint squadId, Coords memory newCoords) external onlyCityOwner(cityId) {
        LibTroopsManager.repositionSquad(cityId, squadId, newCoords);
    }

    function changePurpose(uint cityId, uint squadId, Purpose newPurpose) external onlyCityOwner(cityId) {
        LibTroopsManager.changePurpose(cityId, squadId, newPurpose);
    }

    function squadsById(uint squadId) external view returns (Squad memory) {
        Squad memory squad = s.SquadsById[squadId];
        if (squad.ActiveAfter != 0 && block.timestamp > squad.ActiveAfter) squad.Active = true;
        return squad;
    }

    function squadsIdOnWorld(Coords memory coords) external view returns (uint[] memory) {
        return LibTroopsManager.squadsIdOnWorld(coords);
    }

    function squadsOnPlot(Coords memory coords) public view returns (Squad[] memory) {
        return LibTroopsManager.squadsOnPlot(coords);
    }

    function cityActiveSquads(uint cityId) external view returns (uint[] memory) {
        return s.CityActiveSquads[cityId].values();
    }
}
