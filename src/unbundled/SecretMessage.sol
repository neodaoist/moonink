// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.13;

import {MoonPhase} from "./MoonPhase.sol";

struct SecretMessage {
    MoonPhase phase; // TODO do we need this if we store timestamp now?
    uint256 timestamp;
    address writer;
    string text;
}
