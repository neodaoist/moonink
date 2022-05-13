// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MoonInk.sol";

contract MoonInkTest is Test {
    
    // using stdStorage for StdStorage;

    MoonInk private moon;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function setUp() public {
        moon = new MoonInk();
    }

    function testMetadata() public {
        assertEq(moon.name(), "Moon Ink");
        assertEq(moon.symbol(), "MOONINK");
    }

    function testFailOnInvalidTokenID() public {
        moon.tokenURI(0);
    }

    function testValidTokenID() public {
        moon.mint("");
        moon.tokenURI(0);
    }

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

    function testFailOnInvalidDay() public {
        moon.getMoonPhaseForDay(28);
    }
}
