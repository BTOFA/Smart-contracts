// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IBTOFAToken is IERC721 {
    function isExpired(uint256 tokenId) external view returns (bool);
    function burn(uint256 tokenId) external;
    function getPrice(uint256 tokenId) external view returns(uint256);
    function getProfit(uint256 tokenId) external view returns(uint256);
}

contract BankManager is IERC721Receiver, Ownable {

    IERC20 private _BTOFACurrency;
    IBTOFAToken private _BTOFAToken;

    constructor(address currency, address token) {
        _BTOFACurrency = IERC20(currency);
        _BTOFAToken = IBTOFAToken(token);
    }

    function buyToken(uint256 startId, uint256 endId) external {
        require(startId <= endId, "BANK MANAGER: Right ID's bound is less than left one.");
        uint256 price = 0;
        
        for (uint256 tokenId = startId; tokenId <= endId; ++tokenId) {
            price += _BTOFAToken.getPrice(tokenId);
            require(msg.sender != _BTOFAToken.ownerOf(tokenId),
                    string(abi.encodePacked("BTOT: User already is an owner of token with ID ", Strings.toString(tokenId), ".")));
        }

        require(_BTOFACurrency.balanceOf(msg.sender) >= price, "BTOC: Insufficient amount of tokens.");
        require(_BTOFACurrency.allowance(msg.sender, address(this)) >= price, "BTOC: Insufficient allowed amount of tokens to spend.");
        _BTOFACurrency.transferFrom(msg.sender, owner(), price);
        
        for (uint256 tokenId = startId; tokenId <= endId; ++tokenId) {
            _BTOFAToken.safeTransferFrom(owner(), msg.sender, tokenId);
        }
    }

    function expireToken(uint256 startId, uint256 endId) public onlyOwner {
        uint256 price = 0;
        require(startId <= endId, "BANK MANAGER: Right ID's bound is less than left one.");
        
        for (uint256 tokenId = startId; tokenId <= endId; ++tokenId) {
            price += _BTOFAToken.getProfit(tokenId);
            require(owner() != _BTOFAToken.ownerOf(tokenId),
                    string(abi.encodePacked("BTOT: User already is an owner of token with ID ", Strings.toString(tokenId), ".")));
            require(_BTOFAToken.isExpired(tokenId), "BTOT: Token with such ID hasn't expired yet.");
        }

        require(_BTOFACurrency.balanceOf(owner()) >= price, "BTOC: Insufficient amount of tokens.");
        require(_BTOFACurrency.allowance(owner(), address(this)) >= price, "BTOC: Insufficient allowed amount of tokens to spend.");
        _BTOFACurrency.transferFrom(owner(), _BTOFAToken.ownerOf(startId), price);
        
        for (uint256 tokenId = startId; tokenId <= endId; ++tokenId) {
            _BTOFAToken.safeTransferFrom(_BTOFAToken.ownerOf(tokenId), owner(), tokenId);
            _BTOFAToken.burn(tokenId);
        }
    }

    function onERC721Received(address, address, uint256, bytes calldata) external override pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
