// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;
import {Resource} from "../shared/ResourceEnums.sol";
import {AppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibResearchManager} from "../libraries/LibResearchManager.sol";
import "../shared/Errors.sol";

contract ResearchManagerFacet is Modifiers {
    function beginResearch(uint cityId, uint researchId) external onlyCityOwner(cityId) {
        LibResearchManager.beginResearch(cityId, researchId);
    }

    function researchTime(uint cityId, uint resId) external view returns (uint) {
        return s.CityResearchesValidAfter[cityId][resId];
    }

    function isResearched(uint cityId, uint researchId) external view returns (bool) {
        uint validAfter = s.CityResearchesValidAfter[cityId][researchId];
        if (validAfter != 0 && block.timestamp >= validAfter) return true;
        return false;
    }

    function isResearchedBatch(uint cityId, uint[] memory researchIds) external view returns (bool[] memory) {
        bool[] memory result = new bool[](researchIds.length);
        for (uint i = 0; i < researchIds.length; ) {
            uint validAfter = s.CityResearchesValidAfter[cityId][researchIds[i]];
            if (validAfter != 0 && block.timestamp >= validAfter) {
                result[i] = true;
            }
            unchecked {
                i++;
            }
        }
        return result;
    }
}
