// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./Bytes.sol";
import "./Base64.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CollectionNFT is ERC721Enumerable, IERC721Receiver {
    using Bytes for bytes;
    using Strings for uint256;
    using Counters for Counters.Counter;

    struct NFT {
        address contractAddress;
        uint256 tokenId;
    }

    // collections represents a mapping of CollectionNFT token IDs to the NFTs that are in the collection
    mapping(uint256 => NFT[]) private _collections;

    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
    {}

    function getNFTsInCollection(uint256 tokenId)
        public
        view
        returns (NFT[] memory)
    {
        return _collections[tokenId];
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        NFT[] memory nfts = _collections[tokenId];

        string memory output = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 15px; } .strong  { fill: white; font-family: serif; font-size: 19px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="strong">NFTs:</text><text x="10" y="50" class="base">'
            )
        );

        uint256 y = 80;
        for (uint256 i = 1; i < nfts.length * 2; i++) {
            if (i % 2 == 1) {
                NFT memory nft = nfts[(i - 1) / 2];
                IERC721Metadata token = IERC721Metadata(nft.contractAddress);
                output = string(
                    abi.encodePacked(
                        output,
                        token.name(),
                        " #",
                        nft.tokenId.toString()
                    )
                );
            } else {
                output = string(
                    abi.encodePacked(
                        output,
                        '</text><text x="10" y="',
                        y.toString(),
                        '" class="base">'
                    )
                );
                y += 30;
            }
            if (i == nfts.length * 2 - 1) {
                output = string(abi.encodePacked(output, "</text></svg>"));
            }
        }

        output = string(
            abi.encodePacked(
                '{"name": "Collection #',
                tokenId.toString(),
                '", "description": "This Collection represents a group of NFTs as a single tokenized NFT. When a Collection NFT is burned, the NFTs that are a part of the collection are unwrapped and sent to the burner.", "image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(output)),
                '"}'
            )
        );
        string memory json = Base64.encode(bytes(output));
        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return output;
    }

    function mint(address[] memory tokenContracts, uint256[] memory tokenIDs)
        public
        virtual
    {
        require(
            tokenContracts.length == tokenIDs.length,
            "CollectionNFT: tokenContracts and tokenIDs must be the same length"
        );

        uint256 id = totalSupply();
        _mint(_msgSender(), id);

        for (uint256 i = 0; i < tokenContracts.length; i++) {
            address tokenContract = tokenContracts[i];
            uint256 tokenID = tokenIDs[i];
            IERC721 token = IERC721(tokenContract);
            token.safeTransferFrom(_msgSender(), address(this), tokenID);
            _collections[id].push(NFT(tokenContract, tokenID));
        }
    }

    function burn(uint256 tokenId) public virtual {
        require(
            ownerOf(tokenId) == _msgSender(),
            "CollectionNFT: sender must be owner of token to burn"
        );
        NFT[] memory nfts = _collections[tokenId];

        for (uint256 i = 0; i < nfts.length; i++) {
            IERC721 token = IERC721(nfts[i].contractAddress);
            token.safeTransferFrom(
                address(this),
                _msgSender(),
                nfts[i].tokenId
            );
        }
        _burn(tokenId);
        delete _collections[tokenId];
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC721Receiver).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
