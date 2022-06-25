// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.13;

interface IMoonInk {
    //
    function mint(string memory text_) external returns (uint256);

    function mint(address recipient_, string memory text_) external returns (uint256);
}
