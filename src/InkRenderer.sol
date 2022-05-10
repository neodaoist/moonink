// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.13;

import "./SVG.sol";
import "./Utils.sol";

struct MoonPhase {
    string name;
    string svgImage;
}

contract InkRenderer {

    mapping(uint256 => MoonPhase) public moonPhases;

    constructor() {
        moonPhases[0] = MoonPhase('Full Moon', '');
        moonPhases[3] = MoonPhase('Waning Gibbous', '');
        moonPhases[7] = MoonPhase('Last Quarter', '');
        moonPhases[10] = MoonPhase('Waning Crescent', '');
        moonPhases[14] = MoonPhase('New Moon', '');
        moonPhases[17] = MoonPhase('Waxing Crescent', '');
        moonPhases[21] = MoonPhase('First Quarter', '');
        moonPhases[24] = MoonPhase('Waxing Gibbous', '');
    }

    function render(uint256 _tokenId) public view returns (string memory) {
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
                            svg.cdata('Moon Ink #'),
                            utils.uint2str(456)
                        )
                    ),

                    svg.text(
                        string.concat(
                            svg.prop('x', '20'),
                            svg.prop('y', '90'),
                            svg.prop('font-size', '22'),
                            svg.prop('fill', 'grey') // adjust so as to fade in and out
                        ),
                        'secret message written'
                    ),

                    svg.g(
                        string.concat(
                            svg.prop('transform', 'translate(0.000000,300.000000) scale(0.182926829,-0.182926829)'),
                            svg.prop('fill', 'none'),
                            svg.prop('stroke', 'white')
                        ),
                        svg.path(
                        svg.prop('d', 'M0 820 l0 -820 820 0 820 0 -1 388 c-1 217 -5 362 -9 330 -11 -83 -28 -142 -70 -234 -85 -184 -250 -345 -429 -418 -67 -27 -102 -34 -64 -13 54 30 181 226 234 362 33 86 58 178 58 220 1 94 6 133 14 128 5 -3 6 4 2 16 -4 14 -2 21 6 21 10 0 10 3 1 12 -16 16 -15 39 2 32 9 -4 14 3 14 22 0 14 6 30 13 35 7 4 10 11 6 15 -3 4 -15 -4 -26 -17 l-19 -24 5 63 c4 40 2 62 -5 62 -14 0 -9 30 8 40 9 6 6 12 -13 24 -25 17 -40 48 -38 77 1 9 -5 19 -14 22 -8 4 -15 13 -15 22 0 8 -4 23 -9 33 -5 9 -19 40 -30 67 -12 28 -26 57 -31 65 -5 8 -19 32 -30 53 -27 50 -183 207 -206 207 -9 0 -15 3 -11 6 8 8 140 -32 192 -58 137 -69 272 -193 346 -318 46 -79 95 -215 107 -302 7 -45 10 46 11 320 l1 382 -820 0 -820 0 0 -820z'),
                            utils.NULL
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

        function example() external view returns (string memory) {
            return render(1);
        }
}
