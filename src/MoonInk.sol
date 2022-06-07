// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.13;

import "./SVG.sol";
import "./Utils.sol";

import {IERC721Events} from "./unbundled/IERC721Events.sol";
import {IERC721Metadata} from "./unbundled/IERC721Metadata.sol";
import {IERC721Receiver} from "./unbundled/IERC721Receiver.sol";
import {IERC721} from "./unbundled/IERC721.sol";
import {IERC165} from "./unbundled/IERC165.sol";
import {ERC165} from "./unbundled/ERC165.sol";
import {ERC721} from "./unbundled/ERC721.sol";
import {IMoonInk} from "./unbundled/IMoonInk.sol";
import {MoonPhase} from "./unbundled/MoonPhase.sol";
import {SecretMessage} from "./unbundled/SecretMessage.sol";
import {Base64} from "./unbundled/Base64.sol";

/**
 * @title MoonInk
 * @author neodaoist
 *
 * Inspired by Words.sol contract, originally written by MirrorXYZ
 * https://etherscan.io/address/0xa698713a3bc386970cdc95a720b5754cc0f96931#code
 */ 
contract MoonInk is IMoonInk, ERC721, IERC721Metadata {

    string public override name = "Moon Ink";
    string public override symbol = "MOONINK";

    uint256 public tokenId;

    uint private genesisFullMoon = 1652716800;

    mapping(uint256 => SecretMessage) public secretMessages;

    constructor() {}

    ////////////////////////////////////////////////
    ////////////////    Time    ////////////////////
    ////////////////////////////////////////////////

    function getMoonPhaseForCurrentTime(uint currentTime_) public view returns (MoonPhase) {
        require(currentTime_ >= block.timestamp, "TIME_IN_PAST");

        return getMoonPhaseForDay(((currentTime_ - genesisFullMoon) / 60 / 60 / 24) % 28);
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
        require(
            getMoonPhaseForCurrentTime(block.timestamp) == secretMessage.phase,
            "NOT_CORRECT_MOON_PHASE"
        );

        return getWords(tokenID_);
    }

    function getWordsOnlyDuringFullMoon(uint256 tokenID_) public view returns (string memory) {
        require(
            getMoonPhaseForCurrentTime(block.timestamp) == MoonPhase.FullMoon,
            "NOT_FULL_MOON"
        );

        return getWords(tokenID_);
    }

    function getWords(uint256 tokenID_) internal view returns (string memory) {
        return secretMessages[tokenID_].text;
    }

    ////////////////////////////////////////////////
    ////////////////    Access    //////////////////
    ////////////////////////////////////////////////

    function buyVialOfMoonBeams(uint256 tokenID_) public payable returns (string memory) {
        require(
            msg.value >= 0.01 ether,
            "NOT_ENOUGH_ETHER"
        );

        return getWords(tokenID_);
    }

    function castConnexion(uint256 tokenID_) public view returns (string memory) {
        require(
            IERC721(0xa698713a3bc386970Cdc95A720B5754cC0f96931).balanceOf(msg.sender) >= 1 ||
            IERC721(0x8d3b078D9D9697a8624d4B32743B02d270334AF1).balanceOf(msg.sender) >= 1 ||
            IERC721(0x5180db8F5c931aaE63c74266b211F580155ecac8).balanceOf(msg.sender) >= 1,
            "NO_CONNEXIONS_FOUND"
        );

        return getWords(tokenID_);
    }

    ////////////////////////////////////////////////
    ////////////////    Mint    ////////////////////
    ////////////////////////////////////////////////

    function mint(string memory text_) external override returns (uint256) {
        _mint(msg.sender, tokenId);

        MoonPhase phase = getMoonPhaseForCurrentTime(block.timestamp);
        secretMessages[tokenId] = SecretMessage(phase, text_);

        return tokenId++;
    }

    function mint(address recipient_, string memory text_) public override returns (uint256) {
        _mint(recipient_, tokenId);

        MoonPhase phase = getMoonPhaseForCurrentTime(block.timestamp);
        secretMessages[tokenId] = SecretMessage(phase, text_);

        return tokenId++;
    }

    // Mostly looted from Loot: https://etherscan.io/address/0xff9c1b15b16263c61d017ee9f65c50e4ae0113d7#code
    function tokenURI(uint256 tokenID_)
        external
        view
        override
        returns (string memory)
    {
        require(_exists(tokenID_), "INVALID_TOKEN");

        // string[3] memory parts;
        // parts[
        //     0
        // ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
        // parts[1] = secretMessages[tokenID_].text;
        // parts[2] = "</text></svg>";

        // string memory output = string(
        //     abi.encodePacked(parts[0], parts[1], parts[2])
        // );

        string memory output = render(tokenID_);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Moon Ink #',
                        toString(tokenID_),
                        '", "description": "XYZ", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"}'
                    )
                )
            )
        );
        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return output;
    }

    function render(uint256 tokenID_) public view returns (string memory) {
        return string.concat(
            // start
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">',

            // secret message
            secretMessages[tokenID_].text,

            // end
            '</text></svg>'
        );
    }

    function example() external view returns (string memory) {
        return render(1);
    }

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
