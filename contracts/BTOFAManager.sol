// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IBTOFAToken is IERC721 {
    function isExpired(uint256 tokenId) external view returns (bool);
    function burn(uint256 tokenId) external;
    function getProfit(uint256 tokenId) external view returns(uint256);
}

contract BankManager is IERC721Receiver, Ownable {
    using SafeMath for uint256;

    IERC20 private _BTOFACurrency;
    IBTOFAToken private _BTOFAToken;

    constructor(address currency, address token) {
        _BTOFACurrency = IERC20(currency);
        _BTOFAToken = IBTOFAToken(token);
    }

    function buyToken(uint256 tokenId) external {
        uint256 price = _BTOFAToken.getProfit(tokenId);
        require(_BTOFACurrency.balanceOf(msg.sender) >= price, "BTOC: Insufficient amount of tokens.");
        _BTOFACurrency.transferFrom(msg.sender, owner(), price);
        _BTOFAToken.safeTransferFrom(owner(), msg.sender, tokenId);
    }

    function expireToken(uint256 tokenId) public onlyOwner {
        require(_BTOFAToken.isExpired(tokenId), "BTOT: Token with such ID hasn't expired yet.");
        uint256 price = _BTOFAToken.getProfit(tokenId);
        require(_BTOFACurrency.balanceOf(owner()) >= price, "BTOC: Insufficient amount of tokens.");
        _BTOFACurrency.transferFrom(owner(), _BTOFAToken.ownerOf(tokenId), price);
        _BTOFAToken.safeTransferFrom(_BTOFAToken.ownerOf(tokenId), owner(), tokenId);
        _BTOFAToken.burn(tokenId);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external override pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
