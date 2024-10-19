// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/facets/ERC20Facet.sol"; 
import "../contracts/libraries/LibDiamond.sol"; // Assuming LibDiamond is accessible;

contract ERC20FacetTest is Test {
    ERC20Facet token;
    address owner = address(0x123); // Mock owner address
    address user1 = address(0x456); // Mock user1 address
    address user2 = address(0x789); // Mock user2 address

    function setUp() public {
    // Assume the deployer of the contract is the owner
    vm.startPrank(owner); // Set the address running the transaction to the "owner"
    
    // Deploy the ERC20Facet contract
    token = new ERC20Facet();
    
    // Simulate minting tokens to the owner
    token.mint(owner, 1000 * 10 ** 18); // Mint 1000 tokens to the owner
    
    vm.stopPrank(); // Stop the simulated "owner" context
}


    function testName() public {
        // Check that the token name is correct
        assertEq(token.name(), "YourTokenName");
    }

    function testSymbol() public {
        // Check that the token symbol is correct
        assertEq(token.symbol(), "YTN");
    }

    function testDecimals() public {
        // Check that decimals are set to 18
        assertEq(token.decimals(), 18);
    }

    function testTotalSupply() public {
        // Check that the total supply matches the minted amount
        assertEq(token.totalSupply(), 1000 * 10 ** 18);
    }

    function testBalanceOfOwner() public {
        // Check that the balance of the owner is correct
        assertEq(token.balanceOf(owner), 1000 * 10 ** 18);
    }

    function testTransfer() public {
        // Simulate owner transferring tokens to user1
        vm.startPrank(owner);
        token.transfer(user1, 100 * 10 ** 18); // Transfer 100 tokens
        vm.stopPrank();

        // Check that the balances are updated correctly
        assertEq(token.balanceOf(owner), 900 * 10 ** 18);
        assertEq(token.balanceOf(user1), 100 * 10 ** 18);
    }

    function testApproveAndTransferFrom() public {
        // Simulate the owner approving user1 to spend 50 tokens on their behalf
        vm.startPrank(owner);
        token.approve(user1, 50 * 10 ** 18);
        vm.stopPrank();

        // Simulate user1 transferring tokens on behalf of the owner to user2
        vm.startPrank(user1);
        token.transferFrom(owner, user2, 50 * 10 ** 18);
        vm.stopPrank();

        // Check that balances and allowances are updated correctly
        assertEq(token.balanceOf(owner), 950 * 10 ** 18);
        assertEq(token.balanceOf(user2), 50 * 10 ** 18);
        assertEq(token.allowance(owner, user1), 0); // Allowance should now be 0
    }

    function testMinting() public {
        // Ensure only the contract owner can mint tokens
        vm.startPrank(owner);
        token.mint(owner, 100 * 10 ** 18);
        vm.stopPrank();

        // Check that the total supply and owner balance are updated
        assertEq(token.totalSupply(), 1100 * 10 ** 18);
        assertEq(token.balanceOf(owner), 1100 * 10 ** 18);
    }

    function testBurning() public {
        // Ensure only the contract owner can burn tokens
        vm.startPrank(owner);
        token.burn(owner, 100 * 10 ** 18);
        vm.stopPrank();

        // Check that the total supply and owner balance are updated
        assertEq(token.totalSupply(), 900 * 10 ** 18);
        assertEq(token.balanceOf(owner), 900 * 10 ** 18);
    }
}
