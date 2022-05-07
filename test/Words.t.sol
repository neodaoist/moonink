// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/Words.sol";

contract WordsTest is DSTest {
    using stdStorage for StdStorage;

    Vm private vm = Vm(HEVM_ADDRESS);
    Words private words;
    StdStorage private stdstore;

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
}
