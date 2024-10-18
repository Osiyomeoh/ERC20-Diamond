// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/LibDiamond.sol";
import "../interfaces/IERC721.sol";

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

    function buyTokens(uint256 amount) external payable {
        require(presaleActive, "Presale is not active");
        require(msg.value >= MIN_PURCHASE, "Minimum purchase not met");
        require(amount > 0, "Amount must be greater than 0");

        uint256 totalCost = amount * PRICE_PER_TOKEN;
        require(msg.value >= totalCost, "Not enough ETH sent");

        for (uint256 i = 0; i < amount; i++) {
            // Call the mint function from ERC721Facet
            (bool success, ) = address(this).delegatecall(
                abi.encodeWithSignature("mint(address,uint256)", msg.sender, LibDiamond.diamondStorage().totalSupply + 1)
            );
            require(success, "Minting failed");
            LibDiamond.diamondStorage().totalSupply++;
        }

        // Refund excess ETH
        uint256 excess = msg.value - totalCost;
        if (excess > 0) {
            payable(msg.sender).transfer(excess);
        }

        emit TokensPurchased(msg.sender, amount);
    }
}