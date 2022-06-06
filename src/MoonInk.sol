// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.13;

interface IERC721Events {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );
}

interface IERC721Metadata {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// Inspired by WINTΞR's implementation of checking other NFT collections
// with simplified token interfact
//
// https://etherscan.io/address/0x555555551777611fd8eb00df11ea0904b560cf74#code#F1#L79
// https://twitter.com/w1nt3r_eth/status/1522669750848921600
// interface IERC721Ownership {
//     function balanceOf(address owner) external view returns (uint256);
// }

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

/**
 * Based on: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol
 */
contract ERC721 is ERC165, IERC721, IERC721Events {
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            owner != address(0),
            "ERC721: balance query for the zero address"
        );
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        address owner = _owners[tokenId];
        require(
            owner != address(0),
            "ERC721: owner query for nonexistent token"
        );
        return owner;
    }

    /**
     * @dev Base URI for computing {tokenURI}. Empty by default, can be overriden
     * in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        require(operator != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(
            ERC721.ownerOf(tokenId) == from,
            "ERC721: transfer of token that is not own"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (isContract(to)) {
            try
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    // solhint-disable-next-line no-inline-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/7f6a1666fac8ecff5dd467d0938069bc221ea9e0/contracts/utils/Address.sol
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

interface IMoonInk {
    function mint(string memory text_) external returns (uint256);
    function mint(address recipient_, string memory text_) external returns (uint256);
}

enum MoonPhase {
    FullMoon,
    WaningGibbous,
    LastQuarter,
    WaningCrescent,
    NewMoon,
    WaxingCrescent,
    FirstQuarter,
    WaxingGibbous
}

struct SecretMessage {
    MoonPhase phase;
    string text;
}

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
    function tokenURI(uint256 tokenId_)
        external
        view
        override
        returns (string memory)
    {
        require(_exists(tokenId_), "INVALID_TOKEN");

        string[3] memory parts;
        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
        parts[1] = secretMessages[tokenId_].text;
        parts[2] = "</text></svg>";

        string memory output = string(
            abi.encodePacked(parts[0], parts[1], parts[2])
        );
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "TokenId #',
                        toString(tokenId_),
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

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(input, 0x3F))), 0xFF)
                )
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}