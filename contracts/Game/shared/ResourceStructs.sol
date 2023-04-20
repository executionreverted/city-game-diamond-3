// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {Resource} from "./ResourceEnums.sol";

struct ClaimableResource {
    uint256 Amount;
    uint256 ClaimableAfter;
    uint256 Deadline;
    Resource Resource;
}

struct ProductionArgs {
    uint cityId;
    uint buildingLvl;
    uint boostAmount;
    Resource resource;
}
