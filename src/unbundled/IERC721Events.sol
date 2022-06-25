// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.13;

interface IERC721Events {
    //
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
}
