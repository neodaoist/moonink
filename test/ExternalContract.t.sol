// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import "forge-std/Test.sol";

// contract ExternalContractTest is Test {

//     address contractWITCH = 0x5180db8F5c931aaE63c74266b211F580155ecac8;
//     address contractMOONIE = 0x20d4DB1946859E2Adb0e5ACC2eac58047aD41395;

//     function testOwnerOf() public {
//         assertEq(
//             IERC721Ownership(contractWITCH).ownerOf(3394),
//             0x4BBa239C9cC83619228457502227D801e4738bA0
//         );
//     }

//     // function testBalanceOf() public {
//     //     assertEq(IERC721Ownership(0x5180db8F5c931aaE63c74266b211F580155ecac8).balanceOf(0x4bba239c9cc83619228457502227d801e4738ba0), 1);
//     // }

// }

// // TODO can this work also with ERC20 balanceOf at the same time ?

// interface IERC721Ownership {
//     function ownerOf(uint256 tokenId) external returns (address);
// }

// interface IERC721OwnershipB {
//     function balanceOf(address owner) external returns (uint256);
// }
