// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {Resource} from "../shared/ResourceEnums.sol";
import {AppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibResearchs} from "../libraries/LibResearchs.sol";
import {Research} from "../shared/ResearchStructs.sol";
import "../shared/Errors.sol";

contract ResearchsFacet is Modifiers {
    function allResearchs() external pure returns (Research[] memory) {
        Research[] memory _result = new Research[](15);
        for (uint i = 0; i < 15; i++) {
            _result[i] = LibResearchs.researchInfo(i);
        }

        return _result;
    }

    function researchInfo(uint researchId) external pure returns (Research memory) {
        return LibResearchs.researchInfo(researchId);
    }
}
