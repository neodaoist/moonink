// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.13;

import {MoonPhase} from "./MoonPhase.sol";

struct SecretMessage {
    MoonPhase phase;
    string text;
}
