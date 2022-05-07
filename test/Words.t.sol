// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "forge-std/Test.sol";
import "../src/Words.sol";

contract WordsTest is Test {
    
    // using stdStorage for StdStorage;

    Words private words;

    event DebugLog(string message, uint256 tokenId);
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    function setUp() public {
        words = new Words();
    }

    function testFailOnInvalidTokenID() public {
        words.tokenURI(0);
    }

    function testValidTokenID() public {
        words.mint("");
        words.tokenURI(0);
    }

    function testSuccessfulMintToMinter() public {
        words.mint("");
        // emit DebugLog("Next token ID", words.tokenId());

        assertEq(words.ownerOf(0), address(this));
    }

    function testSuccessfulMintToRecipient() public {
        words.mint(address(1), "");

        assertEq(words.ownerOf(0), address(1));
    }

    function testMintExpectEmitTransfer() public {
        vm.expectEmit(true, true, true, true);

        emit Transfer(address(0), address(this), 0);

        words.mint("");
    }

    function testMintToExpectEmitTransfer() public {
        vm.expectEmit(true, true, true, true);

        emit Transfer(address(0), address(1), 0);

        words.mint(address(1), "");
    }
}
