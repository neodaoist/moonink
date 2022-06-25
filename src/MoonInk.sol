// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.13;

import {IMoonInk} from "./unbundled/IMoonInk.sol";
import {MoonPhase} from "./unbundled/MoonPhase.sol";
import {SecretMessage} from "./unbundled/SecretMessage.sol";

import {IERC20} from "./unbundled/IERC20.sol";
import {IERC721} from "./unbundled/IERC721.sol";
// import {ERC721} from "solmate/tokens/ERC721.sol";
import {ERC721} from "./unbundled/sol-ERC721.sol";
import {IERC165} from "./unbundled/IERC165.sol";
import {ERC165} from "./unbundled/ERC165.sol";

import {Base64} from "./unbundled/Base64.sol";
import {StringUtils} from "./unbundled/StringUtils.sol";

// import {svg} from "hot-chain-svg/SVG.sol";
import {svg} from "./unbundled/SVG.sol";
// import {utils} from "hot-chain-svg/Utils.sol";
import {utils} from "./unbundled/Utils.sol";

///////////////////////////////////////////////////////////////////////////////
//                                                                           //
//                                                                           //
//     ███▄ ▄███▓ ▒█████   ▒█████   ███▄    █       ██▓ ███▄    █  ██ ▄█▀    //
//    ▓██▒▀█▀ ██▒▒██▒  ██▒▒██▒  ██▒ ██ ▀█   █      ▓██▒ ██ ▀█   █  ██▄█▒     //
//    ▓██    ▓██░▒██░  ██▒▒██░  ██▒▓██  ▀█ ██▒     ▒██▒▓██  ▀█ ██▒▓███▄░     //
//    ▒██    ▒██ ▒██   ██░▒██   ██░▓██▒  ▐▌██▒     ░██░▓██▒  ▐▌██▒▓██ █▄     //
//    ▒██▒   ░██▒░ ████▓▒░░ ████▓▒░▒██░   ▓██░     ░██░▒██░   ▓██░▒██▒ █▄    //
//    ░ ▒░   ░  ░░ ▒░▒░▒░ ░ ▒░▒░▒░ ░ ▒░   ▒ ▒      ░▓  ░ ▒░   ▒ ▒ ▒ ▒▒ ▓▒    //
//    ░  ░      ░  ░ ▒ ▒░   ░ ▒ ▒░ ░ ░░   ░ ▒░      ▒ ░░ ░░   ░ ▒░░ ░▒ ▒░    //
//    ░      ░   ░ ░ ░ ▒  ░ ░ ░ ▒     ░   ░ ░       ▒ ░   ░   ░ ░ ░ ░░ ░     //
//           ░       ░ ░      ░ ░           ░       ░           ░ ░  ░       //
//                                                                           //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////

/**
 * @title MoonInk
 * @author neodaoist
 *
 * Inspired by Words.sol contract, originally written by MirrorXYZ
 * https://etherscan.io/address/0xa698713a3bc386970cdc95a720b5754cc0f96931#code
 */
contract MoonInk is IMoonInk, ERC721 {
    //
    uint256 public tokenID;

    uint256 private constant GENESIS_FULL_MOON = 1652716800;
    uint256 private constant MAX_LINE_LENGTH = 45;
    uint256 private constant BURN_GRACE_PERIOD = 28 days;

    mapping(uint256 => SecretMessage) public secretMessages;

    constructor() ERC721("Moon Ink", "MOONINK") {}

    ////////////////////////////////////////////////
    ////////////////    Time    ////////////////////
    ////////////////////////////////////////////////

    function getMoonPhaseForCurrentTime(uint256 currentTime_) public view returns (MoonPhase) {
        require(currentTime_ >= block.timestamp, "TIME_IN_PAST");

        return getMoonPhaseForDay(((currentTime_ - GENESIS_FULL_MOON) / 60 / 60 / 24) % 28);
    }

    function getMoonPhaseForDay(uint256 dayOfCycle_) public view returns (MoonPhase) {
        require(dayOfCycle_ <= 27, "INVALID_DAY");

        if ((0 <= dayOfCycle_ && dayOfCycle_ <= 1) || dayOfCycle_ == 27) {
            return MoonPhase.FullMoon;
        } else if (2 <= dayOfCycle_ && dayOfCycle_ <= 6) {
            return MoonPhase.WaningGibbous;
        } else if (7 <= dayOfCycle_ && dayOfCycle_ <= 9) {
            return MoonPhase.LastQuarter;
        } else if (10 <= dayOfCycle_ && dayOfCycle_ <= 13) {
            return MoonPhase.WaningCrescent;
        } else if (14 <= dayOfCycle_ && dayOfCycle_ <= 16) {
            return MoonPhase.NewMoon;
        } else if (17 <= dayOfCycle_ && dayOfCycle_ <= 20) {
            return MoonPhase.WaxingCrescent;
        } else if (21 <= dayOfCycle_ && dayOfCycle_ <= 23) {
            return MoonPhase.FirstQuarter;
        } else if (24 <= dayOfCycle_ && dayOfCycle_ <= 26) {
            return MoonPhase.WaxingGibbous;
        } else {
            //
        }
    }

    ////////////////////////////////////////////////
    ////////////////    Words    ///////////////////
    ////////////////////////////////////////////////

    function readSecretMessage(uint256 tokenID_) public view returns (string memory) {
        SecretMessage memory secretMessage = secretMessages[tokenID_];
        require(getMoonPhaseForCurrentTime(block.timestamp) == secretMessage.phase, "NOT_CORRECT_MOON_PHASE");

        return getWords(tokenID_);
    }

    function getWordsOnlyDuringFullMoon(uint256 tokenID_) public view returns (string memory) {
        require(getMoonPhaseForCurrentTime(block.timestamp) == MoonPhase.FullMoon, "NOT_FULL_MOON");

        return getWords(tokenID_);
    }

    function getWords(uint256 tokenID_) internal view returns (string memory) {
        return secretMessages[tokenID_].text;
    }

    ////////////////////////////////////////////////
    ////////////////    Access    //////////////////
    ////////////////////////////////////////////////

    function buyVialOfMoonBeams(uint256 tokenID_) public payable returns (string memory) {
        require(msg.value >= 0.01 ether, "NOT_ENOUGH_ETHER");

        return getWords(tokenID_);
    }

    function castConnexion(uint256 tokenID_) public view returns (string memory) {
        require(
            IERC721(0xa698713a3bc386970Cdc95A720B5754cC0f96931).balanceOf(msg.sender) >= 1 ||
                IERC721(0x8d3b078D9D9697a8624d4B32743B02d270334AF1).balanceOf(msg.sender) >= 1 ||
                IERC721(0x5180db8F5c931aaE63c74266b211F580155ecac8).balanceOf(msg.sender) >= 1 ||
                IERC20(0x20d4DB1946859E2Adb0e5ACC2eac58047aD41395).balanceOf(msg.sender) > 0,
            "NO_CONNEXIONS_FOUND"
        );

        return getWords(tokenID_);
    }

    ////////////////////////////////////////////////
    ////////////////    Mint    ////////////////////
    ////////////////////////////////////////////////

    function mint(string memory text_) external override returns (uint256) {
        _safeMint(msg.sender, tokenID);

        MoonPhase phase = getMoonPhaseForCurrentTime(block.timestamp);
        secretMessages[tokenID] = SecretMessage(phase, block.timestamp, msg.sender, text_);

        return tokenID++;
    }

    function mint(address recipient_, string memory text_) public override returns (uint256) {
        _safeMint(recipient_, tokenID);

        MoonPhase phase = getMoonPhaseForCurrentTime(block.timestamp);
        secretMessages[tokenID] = SecretMessage(phase, block.timestamp, msg.sender, text_);

        return tokenID++;
    }

    ////////////////////////////////////////////////
    ////////////////    Burn    ////////////////////
    ////////////////////////////////////////////////

    function burn(uint256 tokenID_) public {
        // TODO consider using more std access control for original message writer
        require(_isOriginalMessageWriter(tokenID_), "Only original writer can burn a message");
        require(_isWithinBurnGracePeriod(tokenID_), "Can't burn a message after a complete moon cycle passes");
        _burn(tokenID_);
    }

    function _isOriginalMessageWriter(uint256 tokenID_) internal view returns (bool) {
        return msg.sender == secretMessages[tokenID_].writer;
    }

    function _isWithinBurnGracePeriod(uint256 tokenID_) internal view returns (bool) {
        return block.timestamp - secretMessages[tokenID_].timestamp < BURN_GRACE_PERIOD;
    }

    ////////////////////////////////////////////////
    ////////////////    Render    //////////////////
    ////////////////////////////////////////////////

    // Mostly looted from Loot: https://etherscan.io/address/0xff9c1b15b16263c61d017ee9f65c50e4ae0113d7#code
    function tokenURI(uint256 tokenID_) public view virtual override returns (string memory) {
        require(ownerOf(tokenID_) != address(0), "INVALID_TOKEN");

        // OLD
        // string[3] memory parts;
        // parts[
        //     0
        // ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
        // parts[1] = secretMessages[tokenID_].text;
        // parts[2] = "</text></svg>";

        // string memory output = string(
        //     abi.encodePacked(parts[0], parts[1], parts[2])
        // );

        // NEW
        // string memory svgRender = render(tokenID_);
        // string memory json = Base64.encode(
        //     bytes(
        //         string(
        //             abi.encodePacked(
        //                 '{"name": "Moon Ink #',
        //                 StringUtils.toString(tokenID_),
        //                 '", "description": "XYZ", "image": "data:image/svg+xml;base64,',
        //                 Base64.encode(bytes(svgRender)),
        //                 '"}'
        //             )
        //         )
        //     )
        // );

        // return string(
        //     abi.encodePacked("data:application/json;base64,", json)
        // );

        // TODO fix me
        return "";
    }

    function render(uint256 tokenID_) public view returns (string memory) {
        SecretMessage memory secretMessage = secretMessages[tokenID_];

        return
            string.concat(
                // start
                // '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" />',
                '<svg xmlns="http://www.w3.org/2000/svg" width="300" height="300" style="background:#000">',
                // <style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" />

                // title and token ID
                svg.text(
                    string.concat(
                        svg.prop("x", "20"),
                        svg.prop("y", "40"),
                        svg.prop("font-size", "22"),
                        svg.prop("fill", "white")
                    ),
                    string.concat(svg.cdata("Moon Ink #"), utils.uint2str(tokenID_))
                ),
                // minted moon phase image
                svg.g(
                    string.concat(
                        svg.prop("transform", "translate(0.000000,300.000000) scale(0.182926829,-0.182926829)"),
                        svg.prop("fill", "none"),
                        svg.prop("stroke", "white"),
                        svg.prop("stroke-width", "3"),
                        svg.prop("stroke-dasharray", "3,3")
                    ),
                    getMoonImageForPhase(secretMessage.phase)
                ),
                // current moon phase image

                // secret message
                svg.text(
                    string.concat(
                        svg.prop("x", "20"),
                        svg.prop("y", "85"),
                        svg.prop("font-size", "16.5"),
                        svg.prop("fill", "black")
                    ),
                    string.concat(
                        // TODO fix wrapping — why does this break when including 'fill'=>'freeze' ???

                        // StringUtils.length(secretMessage.text) > MAX_LINE_LENGTH ?
                        //     StringUtils.wrapText(secretMessage.text) : secretMessage.text,
                        secretMessage.text,
                        svg.el(
                            "animate",
                            string.concat(
                                svg.prop("attributeName", "fill"),
                                svg.prop("from", "black"),
                                svg.prop("to", "grey"),
                                svg.prop("dur", "3s"),
                                svg.prop("fill", "freeze")
                            ),
                            utils.NULL
                        )
                    )
                ),
                // '<text x="10" y="20" class="base">',
                // secretMessages[tokenID_].text,
                // '</text>',

                // title/body separator
                svg.rect(
                    string.concat(
                        svg.prop("fill", "white"),
                        svg.prop("x", "20"),
                        svg.prop("y", "50"),
                        svg.prop("width", utils.uint2str(260)),
                        svg.prop("height", utils.uint2str(10))
                    ),
                    utils.NULL
                ),
                // end
                "</svg>"
            );
    }

    // TODO figure out why not all MoonPhase SVG images are rendering

    function getMoonImageForPhase(MoonPhase phase) internal pure returns (string memory) {
        bytes32 phaseBytes = keccak256(abi.encodePacked(phase));

        if (phaseBytes == keccak256(abi.encodePacked(MoonPhase.FullMoon))) {
            return
                string.concat(
                    svg.path(
                        svg.prop(
                            "d",
                            "M1 1243 c1 -240 5 -372 9 -333 13 109 62 256 81 244 5 -3 6 2 3 10 -7 18 61 130 122 202 113 132 308 236 489 263 41 6 -61 9 -322 10 l-383 1 1 -397z"
                        ),
                        utils.NULL
                    ),
                    svg.path(
                        svg.prop(
                            "d",
                            "M935 1629 c303 -44 554 -251 654 -541 17 -47 34 -115 39 -150 7 -45 10 46 11 320 l1 382 -382 -1 c-260 -1 -364 -4 -323 -10z"
                        ),
                        utils.NULL
                    ),
                    svg.path(
                        svg.prop(
                            "d",
                            "M250 1307 c-14 -17 -19 -28 -12 -24 7 5 12 3 12 -3 0 -11 -7 -14 -51 -24 -18 -4 -36 -23 -62 -67 -21 -34 -37 -68 -37 -75 0 -8 -3 -14 -7 -14 -5 0 -16 -14 -26 -31 -13 -23 -15 -35 -7 -44 8 -9 7 -14 -1 -17 -9 -3 -7 -12 6 -31 9 -15 15 -33 12 -42 -4 -8 -2 -17 4 -21 6 -3 8 -12 5 -20 -3 -8 0 -13 6 -11 6 1 11 -7 13 -18 1 -11 5 -31 10 -45 7 -22 6 -23 -9 -11 -14 12 -16 11 -16 -3 0 -9 4 -16 9 -16 5 0 12 -14 16 -30 4 -16 13 -30 20 -30 9 0 12 -6 9 -15 -4 -8 -1 -15 6 -15 6 0 8 -5 4 -12 -5 -8 -2 -9 11 -4 11 4 22 2 27 -6 6 -11 10 -10 17 1 10 15 -14 71 -31 71 -6 0 -3 9 6 19 10 11 15 25 11 30 -3 6 -1 11 4 11 6 0 11 -11 11 -25 0 -14 4 -25 9 -25 5 0 25 -16 45 -35 40 -38 47 -37 16 3 -11 14 -17 28 -13 31 4 3 13 16 20 28 17 30 -16 130 -41 125 -16 -3 -15 -1 1 16 10 10 21 17 25 15 4 -2 4 6 -1 19 -4 13 -18 24 -29 26 -17 3 -22 12 -24 45 -2 27 -7 41 -15 40 -20 -4 -15 15 5 20 13 2 8 8 -18 20 -19 10 -27 15 -17 12 25 -7 43 5 26 17 -11 8 -12 11 -1 15 17 7 52 44 52 55 0 5 -11 -4 -24 -19 -25 -29 -50 -26 -26 3 8 9 10 18 4 22 -20 15 -14 32 9 27 26 -7 64 26 52 45 -4 6 1 17 11 24 9 7 13 15 8 18 -5 3 -20 -8 -34 -25z"
                        ),
                        utils.NULL
                    ),
                    svg.path(
                        svg.prop(
                            "d",
                            "M1 393 l-1 -393 383 1 c277 1 364 4 317 11 -240 34 -467 190 -592 408 -37 65 -89 223 -98 299 -4 41 -8 -85 -9 -326z"
                        ),
                        utils.NULL
                    ),
                    svg.path(
                        svg.prop(
                            "d",
                            "M1630 733 c0 -94 -72 -283 -148 -385 -145 -197 -326 -303 -582 -342 -14 -2 147 -4 358 -5 l382 -1 0 385 c0 212 -2 385 -5 385 -3 0 -5 -17 -5 -37z"
                        ),
                        utils.NULL
                    )
                );
        } else if (phaseBytes == keccak256(abi.encodePacked(MoonPhase.WaningGibbous))) {
            return
                string.concat(
                    svg.path(
                        svg.prop(
                            "d",
                            "M1 1243 c1 -240 5 -372 9 -333 13 109 62 256 81 244 5 -3 6 2 3 10 -7 18 61 130 122 202 114 134 314 240 495 263 42 6 -69 9 -323 10 l-388 1 1 -397z"
                        ),
                        utils.NULL
                    ),
                    svg.path(
                        svg.prop(
                            "d",
                            "M843 1633 c29 -7 129 -62 141 -77 6 -8 34 -26 61 -41 28 -15 58 -36 68 -46 10 -11 29 -27 43 -36 14 -9 23 -22 20 -29 -5 -14 17 -37 27 -27 4 3 9 -1 13 -10 3 -9 20 -31 37 -50 30 -32 50 -67 82 -142 41 -97 42 -105 20 -105 -8 0 -22 16 -31 35 -21 45 -37 46 -18 0 25 -61 16 -71 -29 -30 -15 14 -28 23 -28 20 -1 -3 -2 -9 -3 -15 0 -5 -7 -15 -13 -22 -15 -14 -17 -38 -4 -38 5 0 11 7 15 15 3 8 10 15 16 15 15 0 12 -30 -4 -36 -8 -3 -12 -12 -9 -20 3 -8 9 -11 14 -8 5 3 7 9 4 14 -3 5 -1 11 5 15 6 3 10 -3 10 -15 0 -13 5 -20 13 -17 6 2 11 10 9 16 -1 6 2 11 8 11 5 0 10 7 10 15 0 22 26 29 49 13 14 -10 17 -18 10 -28 -12 -19 -12 -53 0 -45 16 10 23 -34 11 -71 -8 -23 -9 -39 -2 -47 6 -7 12 -46 15 -87 4 -57 2 -79 -9 -91 -10 -11 -12 -23 -6 -40 6 -16 4 -35 -6 -58 -8 -20 -16 -47 -19 -60 -2 -14 -10 -36 -18 -50 -7 -14 -16 -33 -20 -41 -3 -8 -17 -33 -30 -55 -13 -22 -33 -56 -44 -75 -49 -89 -274 -264 -361 -281 -19 -4 142 -7 358 -8 l392 -1 0 820 0 820 -407 -1 c-225 -1 -400 -3 -390 -6z"
                        ),
                        utils.NULL
                    ),
                    svg.path(
                        svg.prop(
                            "d",
                            "M250 1307 c-14 -17 -19 -28 -12 -24 7 5 12 3 12 -3 0 -11 -7 -14 -51 -24 -18 -4 -36 -23 -62 -67 -21 -34 -37 -68 -37 -75 0 -8 -3 -14 -7 -14 -5 0 -16 -14 -26 -31 -13 -23 -15 -35 -7 -44 8 -9 7 -14 -1 -17 -9 -3 -7 -12 6 -31 9 -15 15 -33 12 -42 -4 -8 -2 -17 4 -21 6 -3 8 -12 5 -20 -3 -8 0 -13 6 -11 6 1 11 -7 13 -18 1 -11 5 -31 10 -45 7 -22 6 -23 -9 -11 -14 12 -16 11 -16 -3 0 -9 4 -16 9 -16 5 0 12 -14 16 -30 4 -16 13 -30 20 -30 9 0 12 -6 9 -15 -4 -8 -1 -15 6 -15 6 0 8 -5 4 -12 -5 -8 -2 -9 11 -4 11 4 22 2 27 -6 6 -11 10 -10 17 1 10 15 -14 71 -31 71 -6 0 -3 9 6 19 10 11 15 25 11 30 -3 6 -1 11 4 11 6 0 11 -11 11 -25 0 -14 4 -25 9 -25 5 0 25 -16 45 -35 40 -38 47 -37 16 3 -11 14 -17 28 -13 31 4 3 13 16 20 28 17 30 -16 130 -41 125 -16 -3 -15 -1 1 16 10 10 21 17 25 15 4 -2 4 6 -1 19 -4 13 -18 24 -29 26 -17 3 -22 12 -24 45 -2 27 -7 41 -15 40 -20 -4 -15 15 5 20 13 2 8 8 -18 20 -19 10 -27 15 -17 12 25 -7 43 5 26 17 -11 8 -12 11 -1 15 17 7 52 44 52 55 0 5 -11 -4 -24 -19 -25 -29 -50 -26 -26 3 8 9 10 18 4 22 -20 15 -14 32 9 27 26 -7 64 26 52 45 -4 6 1 17 11 24 9 7 13 15 8 18 -5 3 -20 -8 -34 -25z"
                        ),
                        utils.NULL
                    ),
                    svg.path(
                        svg.prop(
                            "d",
                            "M1 393 l-1 -393 383 1 c277 1 364 4 317 11 -240 34 -467 190 -592 408 -37 65 -89 223 -98 299 -4 41 -8 -85 -9 -326z"
                        ),
                        utils.NULL
                    )
                );
            // } else if (phaseBytes == keccak256(abi.encodePacked(MoonPhase.LastQuarter))) {
            //     return string.concat(
            //         svg.path(
            //             svg.prop('d', 'M1 1243 c1 -240 5 -372 9 -333 13 109 62 256 81 244 5 -3 6 2 3 10 -7 18 61 130 122 202 114 134 314 240 495 263 42 6 -69 9 -323 10 l-388 1 1 -397z'),
            //             utils.NULL
            //         ),
            //         svg.path(
            //             svg.prop('d', 'M820 1623 c0 -10 -6 -29 -13 -43 -8 -14 -12 -37 -11 -50 9 -72 11 -121 3 -109 -13 22 -22 3 -9 -21 8 -15 8 -25 1 -34 -6 -8 -9 -20 -5 -29 3 -8 0 -18 -5 -22 -6 -3 -9 -11 -5 -16 3 -5 10 -7 15 -4 13 8 11 -9 -2 -22 -8 -8 -8 -21 -1 -45 19 -61 13 -125 -14 -150 -14 -13 -24 -35 -24 -50 0 -29 15 -38 23 -15 7 19 28 -43 22 -64 -4 -11 -15 -19 -26 -19 -10 0 -19 -6 -19 -14 0 -23 18 -28 29 -9 9 15 10 13 11 -12 0 -17 4 -46 10 -65 7 -24 6 -44 -2 -66 -9 -26 -9 -36 1 -48 10 -12 11 -19 2 -30 -8 -10 -9 -16 -1 -21 5 -3 10 -30 10 -58 -1 -29 1 -144 4 -257 3 -113 6 -238 6 -277 l0 -73 410 0 410 0 0 820 0 820 -410 0 c-384 0 -410 -1 -410 -17z'),
            //             utils.NULL
            //         ),
            //         svg.path(
            //             svg.prop('d', 'M250 1307 c-14 -17 -19 -28 -12 -24 7 5 12 3 12 -3 0 -11 -7 -14 -51 -24 -18 -4 -36 -23 -62 -67 -21 -34 -37 -68 -37 -75 0 -8 -3 -14 -7 -14 -5 0 -16 -14 -26 -31 -13 -23 -15 -35 -7 -44 8 -9 7 -14 -1 -17 -9 -3 -7 -12 6 -31 9 -15 15 -33 12 -42 -4 -8 -2 -17 4 -21 6 -3 8 -12 5 -20 -3 -8 0 -13 6 -11 6 1 11 -7 13 -18 1 -11 5 -31 10 -45 7 -22 6 -23 -9 -11 -14 12 -16 11 -16 -3 0 -9 4 -16 9 -16 5 0 12 -14 16 -30 4 -16 13 -30 20 -30 9 0 12 -6 9 -15 -4 -8 -1 -15 6 -15 6 0 8 -5 4 -12 -5 -8 -2 -9 11 -4 11 4 22 2 27 -6 6 -11 10 -10 17 1 10 15 -14 71 -31 71 -6 0 -3 9 6 19 10 11 15 25 11 30 -3 6 -1 11 4 11 6 0 11 -11 11 -25 0 -14 4 -25 9 -25 5 0 25 -16 45 -35 40 -38 47 -37 16 3 -11 14 -17 28 -13 31 4 3 13 16 20 28 17 30 -16 130 -41 125 -16 -3 -15 -1 1 16 10 10 21 17 25 15 4 -2 4 6 -1 19 -4 13 -18 24 -29 26 -17 3 -22 12 -24 45 -2 27 -7 41 -15 40 -20 -4 -15 15 5 20 13 2 8 8 -18 20 -19 10 -27 15 -17 12 25 -7 43 5 26 17 -11 8 -12 11 -1 15 17 7 52 44 52 55 0 5 -11 -4 -24 -19 -25 -29 -50 -26 -26 3 8 9 10 18 4 22 -20 15 -14 32 9 27 26 -7 64 26 52 45 -4 6 1 17 11 24 9 7 13 15 8 18 -5 3 -20 -8 -34 -25z'),
            //             utils.NULL
            //         ),
            //         svg.path(
            //             svg.prop('d', 'M1 393 l-1 -393 383 1 c277 1 364 4 317 11 -240 34 -467 190 -592 408 -37 65 -89 223 -98 299 -4 41 -8 -85 -9 -326z'),
            //             utils.NULL
            //         )
            //     );
            // } else if (phaseBytes == keccak256(abi.encodePacked(MoonPhase.WaningCrescent))) {
            //     return string.concat(
            //         svg.path(
            //             svg.prop('d', 'M1 1243 c1 -240 5 -372 9 -333 13 109 62 256 81 244 5 -3 6 2 3 10 -7 18 61 130 122 202 114 134 314 240 495 263 42 6 -69 9 -323 10 l-388 1 1 -397z'),
            //             utils.NULL
            //         ),
            //         svg.path(
            //             svg.prop('d', 'M767 1610 c-42 -15 -92 -35 -111 -44 -19 -9 -38 -16 -43 -16 -7 -1 -91 -74 -153 -133 -28 -27 -60 -69 -60 -78 0 -5 -10 -9 -22 -9 -18 0 -20 -2 -8 -10 11 -7 9 -11 -13 -19 -22 -9 -44 -38 -52 -71 0 -3 -6 -15 -13 -28 -7 -12 -12 -30 -10 -39 2 -10 -7 -22 -20 -29 -17 -8 -20 -13 -10 -17 10 -4 10 -8 -2 -16 -8 -6 -10 -11 -5 -11 6 0 2 -5 -8 -11 -11 -7 -23 -7 -35 0 -16 10 -15 10 3 11 16 0 17 2 6 9 -25 16 -20 53 11 79 15 13 28 29 28 35 0 6 -7 1 -16 -11 -8 -12 -25 -22 -36 -22 -21 0 -21 0 -2 15 12 9 15 18 9 22 -13 11 -17 33 -6 33 6 0 13 -5 16 -11 9 -13 57 30 51 45 -2 6 3 18 11 28 10 11 11 18 4 23 -6 3 -11 2 -11 -4 0 -6 -10 -20 -22 -32 -13 -12 -17 -19 -10 -15 6 4 12 2 12 -4 0 -11 -7 -14 -50 -24 -17 -4 -37 -25 -63 -66 -20 -34 -37 -68 -37 -76 0 -8 -3 -14 -7 -14 -5 0 -16 -14 -26 -31 -13 -23 -15 -35 -7 -44 8 -9 7 -14 -1 -17 -9 -3 -7 -12 6 -31 9 -15 15 -33 12 -42 -4 -8 -2 -17 4 -21 6 -3 8 -12 5 -20 -3 -8 0 -13 6 -11 6 1 11 -7 13 -18 1 -11 5 -31 10 -45 7 -22 6 -23 -9 -11 -14 12 -16 11 -16 -3 0 -9 4 -16 9 -16 5 0 12 -14 16 -30 4 -17 13 -30 20 -30 9 0 12 -6 9 -15 -4 -8 -1 -15 6 -15 6 0 9 -4 6 -8 -2 -4 3 -23 12 -42 16 -33 17 -33 22 -10 9 37 28 35 35 -4 4 -19 4 -39 0 -45 -3 -6 -2 -11 4 -11 5 0 12 8 14 17 4 15 5 15 6 -2 0 -11 9 -32 18 -45 10 -14 17 -27 17 -30 -1 -3 2 -16 7 -29 5 -13 7 -26 5 -29 -3 -2 9 -25 25 -49 17 -24 28 -47 25 -50 -14 -14 154 -210 201 -233 15 -8 47 -27 71 -43 23 -16 66 -40 95 -53 l52 -25 -64 6 c-136 11 -315 96 -437 208 -59 54 -112 121 -156 197 -37 65 -89 223 -98 299 -4 41 -8 -85 -9 -326 l-1 -393 820 0 820 0 0 820 0 820 -397 -1 -398 -2 -78 -27z'),
            //             utils.NULL
            //         )
            //     );
            // } else if (phaseBytes == keccak256(abi.encodePacked(MoonPhase.NewMoon))) {
            //     return svg.path(
            //         svg.prop('d', 'M0 820 l0 -820 820 0 820 0 0 820 0 820 -820 0 -820 0 0 -820z'),
            //         utils.NULL
            //     );
            // } else if (phaseBytes == keccak256(abi.encodePacked(MoonPhase.WaxingCrescent))) {
            //     return string.concat(
            //         svg.path(
            //             svg.prop('d', 'M0 820 l0 -820 820 0 820 0 -1 388 c-1 217 -5 362 -9 330 -11 -83 -28 -142 -70 -234 -106 -230 -311 -400 -557 -459 -67 -16 -125 -17 -78 -1 83 29 222 115 253 157 7 10 19 25 28 33 26 27 134 176 134 186 0 5 9 25 20 45 11 20 20 42 20 51 0 8 10 34 22 57 12 23 21 51 19 61 -2 14 2 17 13 13 14 -5 15 -3 6 13 -13 24 -13 67 0 75 6 3 10 15 10 26 0 11 7 19 16 19 13 0 15 8 11 48 -4 40 -2 50 14 60 14 9 19 9 19 0 0 -22 11 0 15 30 4 28 3 29 -21 18 -13 -6 -24 -17 -24 -24 0 -7 -5 -10 -10 -7 -20 12 -10 35 15 35 26 0 26 0 8 25 -22 30 -37 32 -30 5 3 -11 2 -18 -3 -15 -4 3 -11 20 -14 39 -4 19 -13 39 -20 45 -7 6 -19 31 -26 56 -7 25 -19 50 -26 56 -8 6 -11 15 -8 21 3 5 1 14 -4 21 -5 7 -12 24 -16 40 -3 15 -11 27 -16 27 -6 0 -10 6 -10 14 0 8 -7 16 -15 20 -8 3 -15 10 -15 15 0 16 -61 102 -76 108 -8 3 -14 11 -14 18 0 7 -19 28 -42 46 -24 17 -50 40 -59 50 -23 25 -133 78 -218 105 -72 24 -81 24 -477 24 l-404 0 0 -820z'),
            //             utils.NULL
            //         ),
            //         svg.path(
            //             svg.prop('d', 'M935 1629 c303 -44 554 -251 654 -541 17 -47 34 -115 39 -150 7 -45 10 46 11 320 l1 382 -382 -1 c-260 -1 -364 -4 -323 -10z'),
            //             utils.NULL
            //         )
            //     );
            // } else if (phaseBytes == keccak256(abi.encodePacked(MoonPhase.FirstQuarter))) {
            //     return string.concat(
            //         svg.path(
            //             svg.prop('d', 'M0 820 l0 -820 408 0 407 0 -2 137 c-1 76 -3 170 -4 210 -1 45 3 78 10 87 9 10 9 16 1 21 -6 4 -8 14 -4 24 4 9 8 30 9 47 1 17 5 36 10 43 4 7 3 16 -3 20 -7 4 -8 29 -3 76 5 39 7 96 6 128 -1 31 2 57 7 57 5 0 7 4 4 9 -4 5 -2 21 3 34 7 18 7 27 -2 30 -28 9 -9 97 21 97 6 0 13 -6 16 -12 6 -14 -4 29 -11 50 -3 6 -1 12 5 12 5 0 13 -11 16 -25 4 -17 13 -25 27 -25 15 0 19 5 15 16 -3 9 -6 22 -6 30 0 7 -17 22 -38 33 -23 12 -44 33 -55 56 -17 35 -17 39 -2 55 14 15 14 22 5 40 -8 15 -8 20 -1 16 6 -4 11 -3 11 3 0 5 -5 13 -12 17 -8 5 -6 11 5 19 15 10 15 17 5 46 -7 19 -13 76 -13 126 0 51 -3 93 -7 93 -5 0 -7 3 -6 8 1 4 -2 19 -6 35 l-8 27 -404 0 -404 0 0 -820z'),
            //             utils.NULL
            //         ),
            //         svg.path(
            //             svg.prop('d', 'M935 1629 c303 -44 554 -251 654 -541 17 -47 34 -115 39 -150 7 -45 10 46 11 320 l1 382 -382 -1 c-260 -1 -364 -4 -323 -10z'),
            //             utils.NULL
            //         ),
            //         svg.path(
            //             svg.prop('d', 'M1630 733 c0 -94 -72 -283 -148 -385 -145 -197 -326 -303 -582 -342 -14 -2 147 -4 358 -5 l382 -1 0 385 c0 212 -2 385 -5 385 -3 0 -5 -17 -5 -37z'),
            //             utils.NULL
            //         )
            //     );
            // } else if (phaseBytes == keccak256(abi.encodePacked(MoonPhase.WaxingGibbous))) {
            //     return string.concat(
            //         svg.path(
            //             svg.prop('d', 'M0 820 l0 -820 393 1 c239 1 378 4 357 10 -41 10 -92 35 -140 69 -48 34 -210 195 -210 209 0 6 -9 16 -20 23 -11 7 -20 19 -20 27 0 7 -7 19 -16 26 -9 6 -18 23 -19 38 -2 14 -12 39 -23 54 -11 15 -24 57 -30 93 -6 36 -13 73 -17 83 -7 17 7 23 44 18 8 -2 10 2 5 10 -12 21 -11 60 2 55 7 -3 10 2 7 14 -9 32 14 31 32 -3 16 -32 16 -32 10 -3 -4 19 -1 34 11 47 10 11 12 19 6 19 -7 0 -12 9 -12 20 0 11 -6 20 -14 20 -8 0 -22 3 -31 7 -17 6 -17 -3 2 -53 2 -6 -6 -14 -18 -17 -14 -4 -20 -11 -16 -21 3 -8 -1 -20 -9 -27 -12 -10 -14 -8 -12 12 2 13 5 26 8 29 25 25 28 50 12 101 -9 30 -21 57 -27 61 -5 4 -3 9 6 13 11 4 14 14 11 33 -5 24 -4 26 11 13 10 -8 17 -9 17 -3 0 6 -4 13 -9 16 -5 3 -7 20 -6 38 2 18 3 43 4 55 1 15 7 21 21 20 22 -1 27 -13 8 -19 -7 -3 -5 -7 6 -11 11 -5 15 -3 10 5 -5 8 3 9 29 5 33 -5 37 -3 37 15 0 17 -2 18 -15 8 -12 -10 -15 -9 -16 6 0 11 -3 14 -6 7 -7 -19 -31 -16 -43 6 -13 25 -13 42 1 18 8 -13 14 -15 29 -7 11 6 25 9 32 8 6 -2 12 2 13 9 0 22 15 26 15 5 0 -29 15 -28 17 0 3 33 -15 50 -38 37 -10 -5 -19 -16 -19 -24 0 -8 -4 -15 -10 -15 -16 0 -12 42 7 62 9 11 11 18 5 18 -7 0 -12 5 -12 11 0 5 5 7 11 3 6 -3 24 10 40 29 29 35 33 36 107 28 7 0 10 -6 7 -11 -4 -6 -14 -8 -24 -5 -9 3 -25 -1 -36 -8 -16 -13 -15 -14 19 -20 21 -3 49 -2 62 3 17 7 23 7 19 0 -12 -19 -14 -55 -5 -70 14 -23 20 -8 24 58 2 45 0 62 -10 62 -7 0 -15 -8 -17 -17 -4 -15 -5 -15 -6 -2 0 9 6 22 14 29 16 13 21 35 6 26 -4 -3 -17 1 -27 9 -20 15 -22 13 30 29 7 3 19 -1 25 -7 8 -8 11 -8 11 0 0 16 -49 45 -62 37 -6 -4 -17 1 -24 11 -12 16 -10 22 15 44 16 14 56 40 90 56 33 17 60 35 61 40 0 11 73 52 105 59 11 2 -163 4 -387 5 l-408 1 0 -820z'),
            //             utils.NULL
            //         ),
            //         svg.path(
            //             svg.prop('d', 'M935 1629 c303 -44 554 -251 654 -541 17 -47 34 -115 39 -150 7 -45 10 46 11 320 l1 382 -382 -1 c-260 -1 -364 -4 -323 -10z'),
            //             utils.NULL
            //         ),
            //         svg.path(
            //             svg.prop('d', 'M1630 733 c0 -94 -72 -283 -148 -385 -145 -197 -326 -303 -582 -342 -14 -2 147 -4 358 -5 l382 -1 0 385 c0 212 -2 385 -5 385 -3 0 -5 -17 -5 -37z'),
            //             utils.NULL
            //         )
            //     );
        } else {
            return "";
        }
    }

    // TODO remove, only for testing hot-chain-svg rendering
    function example() external returns (string memory) {
        // string memory long = "secret message secret message secret message secret message secret message secret message secret message secret message secret message secret message secret message secret message ";
        secretMessages[1] = SecretMessage(
            MoonPhase.FullMoon,
            block.timestamp,
            msg.sender,
            "secret message secret message"
        );

        return render(1);
    }
}
