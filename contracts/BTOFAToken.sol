// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BTOFAToken is ERC721, ERC721Burnable, ERC721Enumerable, Ownable {
    using SafeMath for uint256;

    struct TokenListing {
        uint256 serialNumber;
        uint256 expirationTime;
        uint256 price;
        uint256 profit;
        bool isPresented;
    }

    mapping(uint256 => TokenListing) mintedTokens;

    constructor() ERC721("BTOFAToken", "BTOT") {}

    function emitTokens(uint256 tokenId, uint256 amount, TokenListing memory data) external onlyOwner {
        for (uint256 i = tokenId; i < tokenId + amount; ++i) {
            _safeMint(msg.sender, i);
            mintedTokens[i] = data;
        }
    }

    function isExpired(uint256 tokenId) external view returns (bool) {
        require(mintedTokens[tokenId].isPresented, "BTOT: Token with such ID doesn't exist.");
        return mintedTokens[tokenId].expirationTime <= block.timestamp;
    }

    function getPrice(uint256 tokenId) public view returns(uint256) {
        require(mintedTokens[tokenId].isPresented, "BTOT: Token with such ID doesn't exist.");
        return mintedTokens[tokenId].price;
    }

    function getProfit(uint256 tokenId) public view returns(uint256) {
        require(mintedTokens[tokenId].isPresented, "BTOT: Token with such ID doesn't exist.");
        return mintedTokens[tokenId].profit;
    }

    function getToken(uint256 tokenId) external view returns(TokenListing memory) {
        require(mintedTokens[tokenId].isPresented, "BTOT: Token with such ID doesn't exist.");
        return mintedTokens[tokenId];
    }

    function burn(uint256 tokenId) override public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "BTOT: This function is allowed only for owner.");
        _burn(tokenId);
        delete mintedTokens[tokenId];
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
    internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId) public view
    override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
