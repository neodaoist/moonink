// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "forge-std/Test.sol";
import "../src/MoonInk.sol";

contract MoonInkTest is Test {
    
    // using stdStorage for StdStorage;

    MoonInk private moon;

    event DebugLog(string message, uint256 tokenId);
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    function setUp() public {
        moon = new MoonInk();
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
        // emit DebugLog("Next token ID", moon.tokenId());

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

    function testCorrectPhases() public {
        assertEq(moon.getMoonPhaseForDay(0).name, "Full Moon");
        assertEq(moon.getMoonPhaseForDay(7).name, "First Quarter");
        assertEq(moon.getMoonPhaseForDay(14).name, "New Moon");
        assertEq(moon.getMoonPhaseForDay(21).name, "Last Quarter");
    }
}
