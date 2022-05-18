// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MoonInk.sol";

contract MoonInkTest is Test {
    
    // using stdStorage for StdStorage;

    MoonInk private moon;

    // cycle
    uint time0 = 1652716800; // Mon May 16 2022 16:00:00 GMT+0000
    uint time1 = 1652803200; // Tue May 17 2022 16:00:00 GMT+0000
    uint time2 = 1652889600; // Wed May 18 2022 16:00:00 GMT+0000
    uint time3 = 1652976000; // Thu May 19 2022 16:00:00 GMT+0000
    uint time4 = 1653062400; // Fri May 20 2022 16:00:00 GMT+0000
    uint time5 = 1653148800; // Sat May 21 2022 16:00:00 GMT+0000
    uint time6 = 1653235200; // Sun May 22 2022 16:00:00 GMT+0000
    uint time7 = 1653321600; // Mon May 23 2022 16:00:00 GMT+0000
    uint time8 = 1653408000; // Tue May 24 2022 16:00:00 GMT+0000
    uint time9 = 1653494400; // Wed May 25 2022 16:00:00 GMT+0000
    uint time10 = 1653580800; // Thu May 26 2022 16:00:00 GMT+0000
    uint time11 = 1653667200; // Fri May 27 2022 16:00:00 GMT+0000
    uint time12 = 1653753600; // Sat May 28 2022 16:00:00 GMT+0000
    uint time13 = 1653840000; // Sun May 29 2022 16:00:00 GMT+0000
    uint time14 = 1653926400; // Mon May 30 2022 16:00:00 GMT+0000
    uint time15 = 1654012800; // Tue May 31 2022 16:00:00 GMT+0000
    uint time16 = 1654099200; // Wed Jun 01 2022 16:00:00 GMT+0000
    uint time17 = 1654185600; // Thu Jun 02 2022 16:00:00 GMT+0000
    uint time18 = 1654272000; // Fri Jun 03 2022 16:00:00 GMT+0000
    uint time19 = 1654358400; // Sat Jun 04 2022 16:00:00 GMT+0000
    uint time20 = 1654444800; // Sun Jun 05 2022 16:00:00 GMT+0000
    uint time21 = 1654531200; // Mon Jun 06 2022 16:00:00 GMT+0000
    uint time22 = 1654617600; // Tue Jun 07 2022 16:00:00 GMT+0000
    uint time23 = 1654704000; // Wed Jun 08 2022 16:00:00 GMT+0000
    uint time24 = 1654790400; // Thu Jun 09 2022 16:00:00 GMT+0000
    uint time25 = 1654876800; // Fri Jun 10 2022 16:00:00 GMT+0000
    uint time26 = 1654963200; // Sat Jun 11 2022 16:00:00 GMT+0000
    uint time27 = 1655049600; // Sun Jun 12 2022 16:00:00 GMT+0000

    // after cycle
    uint timeb0 = 1655136000; // Mon Jun 13 2022 16:00:00 GMT+0000
    uint timeb1 = 1655222400; // Tue Jun 14 2022 16:00:00 GMT+0000
    uint timeb2 = 1655308800; // Wed Jun 15 2022 16:00:00 GMT+0000

    // before cycle
    uint timec25 = 1657296000; // Fri Jul 08 2022 16:00:00 GMT+0000
    uint timec26 = 1657382400; // Sat Jul 09 2022 16:00:00 GMT+0000
    uint timec27 = 1657468800; // Sun Jul 10 2022 16:00:00 GMT+0000

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function setUp() public {
        moon = new MoonInk();
    }

    function testMetadata() public {
        assertEq(moon.name(), "Moon Ink");
        assertEq(moon.symbol(), "MOONINK");
    }

    function testInvalidTokenIDShouldFail() public {
        vm.expectRevert("INVALID_TOKEN");

        moon.tokenURI(0);
    }

    function testValidTokenID() public {
        moon.mint("");
        moon.tokenURI(0);
    }

    // 

    ////////////////////////////////////////////////
    ////////////////    Mint    ////////////////////
    ////////////////////////////////////////////////

    function testSuccessfulMintToMinter() public {
        moon.mint("");

        assertEq(moon.ownerOf(0), address(this));
    }

    function testSuccessfulMintToRecipient() public {
        moon.mint(address(1), "");

        assertEq(moon.ownerOf(0), address(1));
    }

    function testMintExpectEmitTransfer() public {
        vm.expectEmit(true, true, true, true);

        emit Transfer(address(0), address(this), 0);

        moon.mint("");
    }

    function testMintToExpectEmitTransfer() public {
        vm.expectEmit(true, true, true, true);

        emit Transfer(address(0), address(1), 0);

        moon.mint(address(1), "");
    }

    // 

    ////////////////////////////////////////////////
    ////////////////    Time    ////////////////////
    ////////////////////////////////////////////////

    function testCorrectPhasesForDay() public {
        assertEq(moon.getMoonPhaseForDay(0).name, "Full Moon");
        assertEq(moon.getMoonPhaseForDay(1).name, "Full Moon");
        assertEq(moon.getMoonPhaseForDay(2).name, "Waning Gibbous");
        assertEq(moon.getMoonPhaseForDay(3).name, "Waning Gibbous");
        assertEq(moon.getMoonPhaseForDay(4).name, "Waning Gibbous");
        assertEq(moon.getMoonPhaseForDay(5).name, "Waning Gibbous");
        assertEq(moon.getMoonPhaseForDay(6).name, "Waning Gibbous");        
        assertEq(moon.getMoonPhaseForDay(7).name, "Last Quarter");
        assertEq(moon.getMoonPhaseForDay(8).name, "Last Quarter");
        assertEq(moon.getMoonPhaseForDay(9).name, "Last Quarter");
        assertEq(moon.getMoonPhaseForDay(10).name, "Waning Crescent");
        assertEq(moon.getMoonPhaseForDay(11).name, "Waning Crescent");
        assertEq(moon.getMoonPhaseForDay(12).name, "Waning Crescent");
        assertEq(moon.getMoonPhaseForDay(13).name, "Waning Crescent");
        assertEq(moon.getMoonPhaseForDay(14).name, "New Moon");
        assertEq(moon.getMoonPhaseForDay(15).name, "New Moon");
        assertEq(moon.getMoonPhaseForDay(16).name, "New Moon");
        assertEq(moon.getMoonPhaseForDay(17).name, "Waxing Crescent");
        assertEq(moon.getMoonPhaseForDay(18).name, "Waxing Crescent");
        assertEq(moon.getMoonPhaseForDay(19).name, "Waxing Crescent");
        assertEq(moon.getMoonPhaseForDay(20).name, "Waxing Crescent");
        assertEq(moon.getMoonPhaseForDay(21).name, "First Quarter");
        assertEq(moon.getMoonPhaseForDay(22).name, "First Quarter");
        assertEq(moon.getMoonPhaseForDay(23).name, "First Quarter");
        assertEq(moon.getMoonPhaseForDay(24).name, "Waxing Gibbous");
        assertEq(moon.getMoonPhaseForDay(25).name, "Waxing Gibbous");
        assertEq(moon.getMoonPhaseForDay(26).name, "Waxing Gibbous");
        assertEq(moon.getMoonPhaseForDay(27).name, "Full Moon");
    }

    function testInvalidDayShouldFail() public {
        vm.expectRevert("INVALID_DAY");
        moon.getMoonPhaseForDay(28);
    }

    function testCorrectMoonPhasesForCurrentTime() public {
        assertEq(moon.getMoonPhaseForCurrentTime(time0).name, "Full Moon");
        assertEq(moon.getMoonPhaseForCurrentTime(time1).name, "Full Moon");
        assertEq(moon.getMoonPhaseForCurrentTime(time2).name, "Waning Gibbous");
        assertEq(moon.getMoonPhaseForCurrentTime(time3).name, "Waning Gibbous");
        assertEq(moon.getMoonPhaseForCurrentTime(time4).name, "Waning Gibbous");
        assertEq(moon.getMoonPhaseForCurrentTime(time5).name, "Waning Gibbous");
        assertEq(moon.getMoonPhaseForCurrentTime(time6).name, "Waning Gibbous");        
        assertEq(moon.getMoonPhaseForCurrentTime(time7).name, "Last Quarter");
        assertEq(moon.getMoonPhaseForCurrentTime(time8).name, "Last Quarter");
        assertEq(moon.getMoonPhaseForCurrentTime(time9).name, "Last Quarter");
        assertEq(moon.getMoonPhaseForCurrentTime(time10).name, "Waning Crescent");
        assertEq(moon.getMoonPhaseForCurrentTime(time11).name, "Waning Crescent");
        assertEq(moon.getMoonPhaseForCurrentTime(time12).name, "Waning Crescent");
        assertEq(moon.getMoonPhaseForCurrentTime(time13).name, "Waning Crescent");
        assertEq(moon.getMoonPhaseForCurrentTime(time14).name, "New Moon");
        assertEq(moon.getMoonPhaseForCurrentTime(time15).name, "New Moon");
        assertEq(moon.getMoonPhaseForCurrentTime(time16).name, "New Moon");
        assertEq(moon.getMoonPhaseForCurrentTime(time17).name, "Waxing Crescent");
        assertEq(moon.getMoonPhaseForCurrentTime(time18).name, "Waxing Crescent");
        assertEq(moon.getMoonPhaseForCurrentTime(time19).name, "Waxing Crescent");
        assertEq(moon.getMoonPhaseForCurrentTime(time20).name, "Waxing Crescent");
        assertEq(moon.getMoonPhaseForCurrentTime(time21).name, "First Quarter");
        assertEq(moon.getMoonPhaseForCurrentTime(time22).name, "First Quarter");
        assertEq(moon.getMoonPhaseForCurrentTime(time23).name, "First Quarter");
        assertEq(moon.getMoonPhaseForCurrentTime(time24).name, "Waxing Gibbous");
        assertEq(moon.getMoonPhaseForCurrentTime(time25).name, "Waxing Gibbous");
        assertEq(moon.getMoonPhaseForCurrentTime(time26).name, "Waxing Gibbous");
        assertEq(moon.getMoonPhaseForCurrentTime(time27).name, "Full Moon");

        assertEq(moon.getMoonPhaseForCurrentTime(timeb0).name, "Full Moon");
        assertEq(moon.getMoonPhaseForCurrentTime(timeb1).name, "Full Moon");
        assertEq(moon.getMoonPhaseForCurrentTime(timeb2).name, "Waning Gibbous");

        assertEq(moon.getMoonPhaseForCurrentTime(timec25).name, "Waxing Gibbous");
        assertEq(moon.getMoonPhaseForCurrentTime(timec26).name, "Waxing Gibbous");
        assertEq(moon.getMoonPhaseForCurrentTime(timec27).name, "Full Moon");
    }

    function testCorrectMoonPhasesForRandomTimes() public {
        uint rand0 = time0 + (3 * 60 * 60); // 3 hours
        assertEq(moon.getMoonPhaseForCurrentTime(rand0).name, "Full Moon");

        uint rand1 = time0 + (3 * 60 * 60) + (33 * 60); // 3 hours 33 minutes
        assertEq(moon.getMoonPhaseForCurrentTime(rand1).name, "Full Moon");

        uint rand2 = time0 + (3 * 60 * 60) + (33 * 60) + 13; // 3 hours 33 minutes 13 seconds
        assertEq(moon.getMoonPhaseForCurrentTime(rand2).name, "Full Moon");

        uint rand3 = time0 + (18 * 60 * 60); // 18 hours
        assertEq(moon.getMoonPhaseForCurrentTime(rand3).name, "Full Moon");
    }

    // TODO add fuzz testing for more random times

    ////////////////////////////////////////////////
    ////////////////    Words    ///////////////////
    ////////////////////////////////////////////////

    function testGetWords() public {
        uint256 tokenID = moon.mint("secret message");

        assertEq(moon.getWords(tokenID), "secret message");
    }

    function testGetWordsOnlyDuringFullMoonWhenFullMoon() public {
        uint256 tokenID = moon.mint("secret message");

        // TODO add warp to block during full moon

        assertEq(moon.getWords(tokenID), "secret message");
    }

    // TODO add sad paths when

    // TODO add ability to buy vial of moon beams

    // 

}
