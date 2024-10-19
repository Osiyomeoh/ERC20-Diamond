// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/LibDiamond.sol";

contract PresaleFacet {
    uint256 public constant PRICE_PER_TOKEN = 0.033333333333333333 ether; // 1 ETH = 30 NFTs
    uint256 public constant MIN_PURCHASE = 0.01 ether;

    bool public presaleActive;

    event TokensPurchased(address indexed buyer, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == LibDiamond.contractOwner(), "Only owner can call this function");
        _;
    }

    function startPresale() external onlyOwner {
        presaleActive = true;
    }

    function endPresale() external onlyOwner {
        presaleActive = false;
    }

    function buyTokens() external payable {
        require(presaleActive, "Presale is not active");
        require(msg.value >= MIN_PURCHASE, "Minimum purchase not met");

        uint256 tokensToBuy = msg.value / PRICE_PER_TOKEN;
        require(tokensToBuy > 0, "Not enough ETH sent");

        for (uint256 i = 0; i < tokensToBuy; i++) {
            // Call the mint function from ERC721Facet
            (bool success, ) = address(this).delegatecall(
                abi.encodeWithSignature("mint(address)", msg.sender)
            );
            require(success, "Minting failed");
        }

        // Refund excess ETH
        uint256 excess = msg.value - (tokensToBuy * PRICE_PER_TOKEN);
        if (excess > 0) {
            payable(msg.sender).transfer(excess);
        }

        emit TokensPurchased(msg.sender, tokensToBuy);
    }
}