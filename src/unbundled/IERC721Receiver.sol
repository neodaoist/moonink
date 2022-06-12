// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.13;

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
