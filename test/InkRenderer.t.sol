// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/InkRendererPractice.sol";

contract InkRendererTest is Test {
    //
    // using stdStorage for StdStorage;

    InkRendererPractice private renderer;

    event DebugLog(string message, uint256 tokenId);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function setUp() public {
        renderer = new InkRendererPractice();
    }

    // function testOne() public {
    //     assertEq(renderer.testFunction(), 1);
    // }
}
