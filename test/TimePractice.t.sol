// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TimePractice.sol";

contract TimePracticeTest is Test {

    TimePractice private time;

    uint time1 = 1652723050; // Full moon, 2022-05-16 1:44 pm ET
    uint time2 = 1653342383; // Last quarter, 2022-05-23 1:46 pm ET
    uint time3 = 1653947183; // New moon, 2022-05-30 1:46 pm ET

    function setUp() public {
        time = new TimePractice();
    }

    function testGetCurrentTime() public {
        vm.warp(time1);

        assertEq(time.getCurrentTime(), time1);
    }

    function testCalculateDaysBetweenTimes() public {
        uint daysOneWeek = time.calculateDaysBetweenTimes(time1, time2);

        assertEq(daysOneWeek, 7);

        uint daysTwoWeeks = time.calculateDaysBetweenTimes(time1, time3);

        assertEq(daysTwoWeeks, 14);
    }

}
