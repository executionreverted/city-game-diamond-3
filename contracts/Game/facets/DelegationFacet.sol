// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {Building} from "../shared/CityStructs.sol";
import {AppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibBuildings} from "../libraries/LibBuildings.sol";

contract DelegationFacet is Modifiers {
    function setDelegated(address delegate) external {
        require(s.Delegations[msg.sender] != delegate, "already");
        s.Delegations[msg.sender] = delegate;
        s.BurnerToOwner[delegate] = msg.sender;
    }

    function clearDelegate() external {
        require(s.Delegations[msg.sender] != address(0), "0");
        delete s.BurnerToOwner[s.Delegations[msg.sender]];
        delete s.Delegations[msg.sender];
    }

    function getDelegated(address _owner) external view returns (address) {
        return s.Delegations[_owner];
    }

    function getBurnerOwner(address _burner) external view returns (address) {
        return s.BurnerToOwner[_burner];
    }
}
