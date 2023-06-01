// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {Building} from "../shared/CityStructs.sol";
import {AppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibBuildings} from "../libraries/LibBuildings.sol";

contract DelegationFacet is Modifiers {
    function setDelegated(address delegate) external {
        require(s.Delegations[msg.sender] != delegate, "already");
        s.Delegations[msg.sender] = delegate;
    }

    function clearDelegate() external {
        require(s.Delegations[msg.sender] != address(0), "0");
        delete s.Delegations[msg.sender];
    }
}
