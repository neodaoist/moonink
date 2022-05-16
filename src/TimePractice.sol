// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.13;

contract TimePractice {

    function getCurrentTime() public view returns (uint) {
        return block.timestamp;
    }

    function calculateDaysBetweenTimes(uint start, uint end) public pure returns (uint) {
        return (end - start) / 60 / 60 / 24;
    }
}
