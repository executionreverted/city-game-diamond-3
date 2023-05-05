// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {Resource} from "../shared/ResourceEnums.sol";
import {AppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibResearchs} from "../libraries/LibResearchs.sol";
import {Research} from "../shared/ResearchStructs.sol";
import "../shared/Errors.sol";

contract ResearchsFacet is Modifiers {
    function allResearchs() external pure returns (Research[] memory) {
        Research[] memory _result = new Research[](250);
        for (uint i = 0; i < 250; i++) {
            _result[i] = LibResearchs.researchInfo(i + 1);
        }
        return _result;
    }

    function getResearchs(uint[] memory _ids) external pure returns (Research[] memory) {
        Research[] memory _result = new Research[](_ids.length);
        for (uint i = 0; i < _ids.length; i++) {
            _result[i] = LibResearchs.researchInfo(_ids[i]);
        }
        return _result;
    }

    function researchInfo(uint researchId) external pure returns (Research memory) {
        return LibResearchs.researchInfo(researchId);
    }
}
