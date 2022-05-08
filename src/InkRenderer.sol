// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.13;

import "./SVG.sol";
import "./Utils.sol";

contract InkRenderer {
  function render(uint256 _tokenId) public pure returns (string memory) {
        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" width="300" height="300" style="background:#000">',
                svg.text(
                    string.concat(
                        svg.prop('x', '20'),
                        svg.prop('y', '40'),
                        svg.prop('font-size', '22'),
                        svg.prop('fill', 'white')
                    ),
                    string.concat(
                        svg.cdata('Moon Phase '),
                        utils.uint2str(_tokenId)
                    )
                ),
                svg.rect(
                    string.concat(
                        svg.prop('fill', 'white'),
                        svg.prop('x', '20'),
                        svg.prop('y', '50'),
                        svg.prop('width', utils.uint2str(260)),
                        svg.prop('height', utils.uint2str(10))
                    ),
                    utils.NULL
                ),
                '</svg>'
            );
    }

    function example() external pure returns (string memory) {
        return render(1);
    }
}
