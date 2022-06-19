// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MoonInk.sol";

contract MoonInkTest is Test {
    
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

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    function setUp() public {
        moon = new MoonInk();
    }

    function testMetadata() public {
        assertEq(moon.name(), "Moon Ink");
        assertEq(moon.symbol(), "MOONINK");
    }

    function testInvalidTokenIDShouldFail() public {
        vm.expectRevert("NOT_MINTED");

        moon.tokenURI(0);
    }

    function testValidTokenID() public {
        vm.warp(time0);
        moon.mint("");

        moon.tokenURI(0);
    }

    // 

    ////////////////////////////////////////////////
    ////////////////    Mint    ////////////////////
    ////////////////////////////////////////////////

    function testSuccessfulMintToMinter() public {
        vm.warp(time0);
        moon.mint("");

        assertEq(moon.ownerOf(0), address(this));
    }

    function testSuccessfulMintToRecipient() public {
        vm.warp(time0);
        moon.mint(address(1), "");

        assertEq(moon.ownerOf(0), address(1));
    }

    function testMintExpectEmitTransfer() public {
        vm.warp(time0);
        vm.expectEmit(true, true, true, true);

        emit Transfer(address(0), address(this), 0);

        moon.mint("");
    }

    function testMintToExpectEmitTransfer() public {
        vm.warp(time0);
        vm.expectEmit(true, true, true, true);

        emit Transfer(address(0), address(1), 0);

        moon.mint(address(1), "");
    }

    // 

    ////////////////////////////////////////////////
    ////////////////    Burn    ////////////////////
    ////////////////////////////////////////////////

    function testBurn() public {
        vm.warp(time0);
        moon.mint("");

        assertEq(moon.ownerOf(0), address(this));

        moon.burn(0);

        vm.expectRevert("NOT_MINTED");

        moon.ownerOf(0);
    }

    function testBurnWhenNotOriginalWriterShouldFail() public {
        vm.warp(time0);
        moon.mint("");

        vm.expectRevert("Only original writer can burn a message");

        vm.prank(address(0xBABE));
        moon.burn(0);
    }

    function testBurnWhenMoonCycleAlreadyPassedShouldFail() public {
        vm.warp(time0);
        moon.mint("");

        vm.warp(timeb1);

        vm.expectRevert("Can't burn a message after a complete moon cycle passes");

        moon.burn(0);
    }

    // TODO add fuzz tests to exercise temporal edge cases

    ////////////////////////////////////////////////
    ////////////////    Time    ////////////////////
    ////////////////////////////////////////////////

    function testCorrectPhasesForDay() public {
        assertEq(moon.getMoonPhaseForDay(0), MoonPhase.FullMoon);
        assertEq(moon.getMoonPhaseForDay(1), MoonPhase.FullMoon);
        assertEq(moon.getMoonPhaseForDay(2), MoonPhase.WaningGibbous);
        assertEq(moon.getMoonPhaseForDay(3), MoonPhase.WaningGibbous);
        assertEq(moon.getMoonPhaseForDay(4), MoonPhase.WaningGibbous);
        assertEq(moon.getMoonPhaseForDay(5), MoonPhase.WaningGibbous);
        assertEq(moon.getMoonPhaseForDay(6), MoonPhase.WaningGibbous);        
        assertEq(moon.getMoonPhaseForDay(7), MoonPhase.LastQuarter);
        assertEq(moon.getMoonPhaseForDay(8), MoonPhase.LastQuarter);
        assertEq(moon.getMoonPhaseForDay(9), MoonPhase.LastQuarter);
        assertEq(moon.getMoonPhaseForDay(10), MoonPhase.WaningCrescent);
        assertEq(moon.getMoonPhaseForDay(11), MoonPhase.WaningCrescent);
        assertEq(moon.getMoonPhaseForDay(12), MoonPhase.WaningCrescent);
        assertEq(moon.getMoonPhaseForDay(13), MoonPhase.WaningCrescent);
        assertEq(moon.getMoonPhaseForDay(14), MoonPhase.NewMoon);
        assertEq(moon.getMoonPhaseForDay(15), MoonPhase.NewMoon);
        assertEq(moon.getMoonPhaseForDay(16), MoonPhase.NewMoon);
        assertEq(moon.getMoonPhaseForDay(17), MoonPhase.WaxingCrescent);
        assertEq(moon.getMoonPhaseForDay(18), MoonPhase.WaxingCrescent);
        assertEq(moon.getMoonPhaseForDay(19), MoonPhase.WaxingCrescent);
        assertEq(moon.getMoonPhaseForDay(20), MoonPhase.WaxingCrescent);
        assertEq(moon.getMoonPhaseForDay(21), MoonPhase.FirstQuarter);
        assertEq(moon.getMoonPhaseForDay(22), MoonPhase.FirstQuarter);
        assertEq(moon.getMoonPhaseForDay(23), MoonPhase.FirstQuarter);
        assertEq(moon.getMoonPhaseForDay(24), MoonPhase.WaxingGibbous);
        assertEq(moon.getMoonPhaseForDay(25), MoonPhase.WaxingGibbous);
        assertEq(moon.getMoonPhaseForDay(26), MoonPhase.WaxingGibbous);
        assertEq(moon.getMoonPhaseForDay(27), MoonPhase.FullMoon);
    }

    function testInvalidDayShouldFail() public {
        vm.expectRevert("INVALID_DAY");

        moon.getMoonPhaseForDay(28);
    }

    function testCorrectMoonPhasesForCurrentTime() public {
        assertEq(moon.getMoonPhaseForCurrentTime(time0), MoonPhase.FullMoon);
        assertEq(moon.getMoonPhaseForCurrentTime(time1), MoonPhase.FullMoon);
        assertEq(moon.getMoonPhaseForCurrentTime(time2), MoonPhase.WaningGibbous);
        assertEq(moon.getMoonPhaseForCurrentTime(time3), MoonPhase.WaningGibbous);
        assertEq(moon.getMoonPhaseForCurrentTime(time4), MoonPhase.WaningGibbous);
        assertEq(moon.getMoonPhaseForCurrentTime(time5), MoonPhase.WaningGibbous);
        assertEq(moon.getMoonPhaseForCurrentTime(time6), MoonPhase.WaningGibbous);        
        assertEq(moon.getMoonPhaseForCurrentTime(time7), MoonPhase.LastQuarter);
        assertEq(moon.getMoonPhaseForCurrentTime(time8), MoonPhase.LastQuarter);
        assertEq(moon.getMoonPhaseForCurrentTime(time9), MoonPhase.LastQuarter);
        assertEq(moon.getMoonPhaseForCurrentTime(time10), MoonPhase.WaningCrescent);
        assertEq(moon.getMoonPhaseForCurrentTime(time11), MoonPhase.WaningCrescent);
        assertEq(moon.getMoonPhaseForCurrentTime(time12), MoonPhase.WaningCrescent);
        assertEq(moon.getMoonPhaseForCurrentTime(time13), MoonPhase.WaningCrescent);
        assertEq(moon.getMoonPhaseForCurrentTime(time14), MoonPhase.NewMoon);
        assertEq(moon.getMoonPhaseForCurrentTime(time15), MoonPhase.NewMoon);
        assertEq(moon.getMoonPhaseForCurrentTime(time16), MoonPhase.NewMoon);
        assertEq(moon.getMoonPhaseForCurrentTime(time17), MoonPhase.WaxingCrescent);
        assertEq(moon.getMoonPhaseForCurrentTime(time18), MoonPhase.WaxingCrescent);
        assertEq(moon.getMoonPhaseForCurrentTime(time19), MoonPhase.WaxingCrescent);
        assertEq(moon.getMoonPhaseForCurrentTime(time20), MoonPhase.WaxingCrescent);
        assertEq(moon.getMoonPhaseForCurrentTime(time21), MoonPhase.FirstQuarter);
        assertEq(moon.getMoonPhaseForCurrentTime(time22), MoonPhase.FirstQuarter);
        assertEq(moon.getMoonPhaseForCurrentTime(time23), MoonPhase.FirstQuarter);
        assertEq(moon.getMoonPhaseForCurrentTime(time24), MoonPhase.WaxingGibbous);
        assertEq(moon.getMoonPhaseForCurrentTime(time25), MoonPhase.WaxingGibbous);
        assertEq(moon.getMoonPhaseForCurrentTime(time26), MoonPhase.WaxingGibbous);
        assertEq(moon.getMoonPhaseForCurrentTime(time27), MoonPhase.FullMoon);

        assertEq(moon.getMoonPhaseForCurrentTime(timeb0), MoonPhase.FullMoon);
        assertEq(moon.getMoonPhaseForCurrentTime(timeb1), MoonPhase.FullMoon);
        assertEq(moon.getMoonPhaseForCurrentTime(timeb2), MoonPhase.WaningGibbous);

        assertEq(moon.getMoonPhaseForCurrentTime(timec25), MoonPhase.WaxingGibbous);
        assertEq(moon.getMoonPhaseForCurrentTime(timec26), MoonPhase.WaxingGibbous);
        assertEq(moon.getMoonPhaseForCurrentTime(timec27), MoonPhase.FullMoon);
    }

    function testCorrectMoonPhasesForRandomTimes() public {
        uint rand0 = time0 + (3 * 60 * 60); // 3 hours
        assertEq(moon.getMoonPhaseForCurrentTime(rand0), MoonPhase.FullMoon);

        uint rand1 = time0 + (3 * 60 * 60) + (33 * 60); // 3 hours 33 minutes
        assertEq(moon.getMoonPhaseForCurrentTime(rand1), MoonPhase.FullMoon);

        uint rand2 = time0 + (3 * 60 * 60) + (33 * 60) + 13; // 3 hours 33 minutes 13 seconds
        assertEq(moon.getMoonPhaseForCurrentTime(rand2), MoonPhase.FullMoon);

        uint rand3 = time0 + (18 * 60 * 60); // 18 hours
        assertEq(moon.getMoonPhaseForCurrentTime(rand3), MoonPhase.FullMoon);
    }

    // TODO add fuzz testing for more times

    ////////////////////////////////////////////////
    ////////////////    Words    ///////////////////
    ////////////////////////////////////////////////

    function testReadSecretMessageWhenCorrectPhase() public {
        vm.warp(time0);
        uint256 tokenID = moon.mint("secret message");

        vm.warp(timeb0);
        
        assertEq(moon.readSecretMessage(tokenID), "secret message");
    }

    function testReadSecretMessageWhenNotCorrectPhaseShouldFail() public {
        vm.warp(time0);
        uint256 tokenID = moon.mint("secret message");

        vm.warp(time13);

        vm.expectRevert("NOT_CORRECT_MOON_PHASE");
        moon.readSecretMessage(tokenID);
    }

    // TODO add fuzz testing for more times

    function testGetWordsOnlyDuringFullMoonWhenFullMoon() public {
        vm.warp(time0);
        uint256 tokenID = moon.mint("secret message");

        assertEq(moon.getWordsOnlyDuringFullMoon(tokenID), "secret message");

        vm.warp(time27);
        assertEq(moon.getWordsOnlyDuringFullMoon(tokenID), "secret message");

        vm.warp(timeb0);
        assertEq(moon.getWordsOnlyDuringFullMoon(tokenID), "secret message");

        vm.warp(timec27);
        assertEq(moon.getWordsOnlyDuringFullMoon(tokenID), "secret message");
    }

    function testGetWordsOnlyDuringFullMoonWhenNotFullMoonShouldFail() public {
        vm.warp(time0);
        uint256 tokenID = moon.mint("secret message");

        vm.warp(time2);
        vm.expectRevert("NOT_FULL_MOON");
        moon.getWordsOnlyDuringFullMoon(tokenID);
    }

    ////////////////////////////////////////////////
    ////////////////    Access    //////////////////
    ////////////////////////////////////////////////

    function testReadWithBuyVialOfMoonBeams() public {
        vm.warp(time0);
        uint256 tokenID = moon.mint("secret message");

        vm.warp(time14);

        assertEq(moon.buyVialOfMoonBeams{value: 0.01 ether}(tokenID), "secret message");
    }

    function testReadWithBuyVialOfMoonBeamsWhenNotEnoughEtherShouldFail() public {
        vm.warp(time0);
        uint256 tokenID = moon.mint("secret message");

        vm.warp(time14);

        vm.expectRevert("NOT_ENOUGH_ETHER");

        moon.buyVialOfMoonBeams{value: 0.009 ether}(tokenID);
    }

    function testReadWithCastConnexionWhenWords() public {
        vm.mockCall(
            0xa698713a3bc386970Cdc95A720B5754cC0f96931, // Words contract addr
            abi.encodeWithSelector(IERC721.balanceOf.selector, address(this)),
            abi.encode(1)
        );
        vm.mockCall(
            0x8d3b078D9D9697a8624d4B32743B02d270334AF1, // Watchfaces World contract addr
            abi.encodeWithSelector(IERC721.balanceOf.selector, address(this)),
            abi.encode(0)
        );
        vm.mockCall(
            0x5180db8F5c931aaE63c74266b211F580155ecac8, // Crypto Coven contract addr
            abi.encodeWithSelector(IERC721.balanceOf.selector, address(this)),
            abi.encode(0)
        );

        vm.warp(time0);
        uint256 tokenID = moon.mint("secret message");

        vm.warp(time14);

        assertEq(moon.castConnexion(tokenID), "secret message");
    }

    function testReadWithCastConnexionWhenWatchfaces() public {
        vm.mockCall(
            0xa698713a3bc386970Cdc95A720B5754cC0f96931, // Words contract addr
            abi.encodeWithSelector(IERC721.balanceOf.selector, address(this)),
            abi.encode(0)
        );
        vm.mockCall(
            0x8d3b078D9D9697a8624d4B32743B02d270334AF1, // Watchfaces World contract addr
            abi.encodeWithSelector(IERC721.balanceOf.selector, address(this)),
            abi.encode(1)
        );
        vm.mockCall(
            0x5180db8F5c931aaE63c74266b211F580155ecac8, // Crypto Coven contract addr
            abi.encodeWithSelector(IERC721.balanceOf.selector, address(this)),
            abi.encode(0)
        );

        vm.warp(time0);
        uint256 tokenID = moon.mint("secret message");

        vm.warp(time14);

        assertEq(moon.castConnexion(tokenID), "secret message");        
    }

    function testReadWithCastConnexionWhenCoven() public {
        vm.mockCall(
            0xa698713a3bc386970Cdc95A720B5754cC0f96931, // Words contract addr
            abi.encodeWithSelector(IERC721.balanceOf.selector, address(this)),
            abi.encode(0)
        );
        vm.mockCall(
            0x8d3b078D9D9697a8624d4B32743B02d270334AF1, // Watchfaces World contract addr
            abi.encodeWithSelector(IERC721.balanceOf.selector, address(this)),
            abi.encode(0)
        );
        vm.mockCall(
            0x5180db8F5c931aaE63c74266b211F580155ecac8, // Crypto Coven contract addr
            abi.encodeWithSelector(IERC721.balanceOf.selector, address(this)),
            abi.encode(1)
        );

        vm.warp(time0);
        uint256 tokenID = moon.mint("secret message");

        vm.warp(time14);

        assertEq(moon.castConnexion(tokenID), "secret message");
    }

    function testReadWithCastConnexionWhenNotConnectedShouldFail() public {
        vm.mockCall(
            0xa698713a3bc386970Cdc95A720B5754cC0f96931, // Words contract addr
            abi.encodeWithSelector(IERC721.balanceOf.selector, address(this)),
            abi.encode(0)
        );
        vm.mockCall(
            0x8d3b078D9D9697a8624d4B32743B02d270334AF1, // Watchfaces World contract addr
            abi.encodeWithSelector(IERC721.balanceOf.selector, address(this)),
            abi.encode(0)
        );
        vm.mockCall(
            0x5180db8F5c931aaE63c74266b211F580155ecac8, // Crypto Coven contract addr
            abi.encodeWithSelector(IERC721.balanceOf.selector, address(this)),
            abi.encode(0)
        );

        vm.warp(time0);
        uint256 tokenID = moon.mint("secret message");

        vm.warp(time14);

        vm.expectRevert("NO_CONNEXIONS_FOUND");

        moon.castConnexion(tokenID);
    }

    // DONE add Connexion mechanic (Words, Watchfaces World, Crypto Coven)
    // DONE store which phase and check against that, not Full Moon
    // TODO consider switching to safe mint
    // TODO practice deploying contract to vanity address 11111111
    // TODO determine if moon phases work out 1,000 years
    // TODO add back in token ID (for easier reading)
    // TODO consider switching from openzep to solmate

    // TODO fix broken moon phase SVGs
    // TODO add second moon image based on current phase, with animation

    // TODO sketch mint page in Figma, reach out to designers
    // TODO experiment with how to setup scaffold-eth as the mint page
    // 

    ////////////////////////////////////////////////
    ////////////////    Assertion Helpers    ///////
    ////////////////////////////////////////////////

    function assertEq(MoonPhase phaseA, MoonPhase phaseB) internal {
        bytes memory a = abi.encodePacked(phaseA);
        bytes memory b = abi.encodePacked(phaseB);

        if (keccak256(a) != keccak256(abi.encodePacked(b))) {
            emit log            ("Error: a == b not satisfied [bytes]");
            emit log_named_bytes("  Expected", b);
            emit log_named_bytes("    Actual", a);
            fail();
        }
    }
}
