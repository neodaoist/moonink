// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.13;

import {IERC165} from "./IERC165.sol";

abstract contract ERC165 is IERC165 {
    //
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
