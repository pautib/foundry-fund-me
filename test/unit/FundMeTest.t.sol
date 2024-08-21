// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;
    uint256 public constant ETH_1 = 1 ether;
    address public USER = makeAddr("user"); // fake address to use as sender of all contract calls
    uint256 constant USER_STARTING_BALANCE = 20 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, USER_STARTING_BALANCE);
    }

    function test_minimum_dollar_is_fifty() public view {
        assertEq(fundMe.MINIMUM_USD(), 50 * 1e18);
    }

    function test_owner_is_msgSender() public view {
        console.log("The FundMe instance owner: ", fundMe.getOwner());
        console.log("The sender (Me): ", msg.sender);
        console.log("The contract address: ", address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function test_PriceFeed_Version() public view {
        assertEq(fundMe.getPriceFeedVersion(), 4);
    }

    function test_fund_fails_not_enough_eth() public {
        vm.expectRevert(); // expects that the next line will fail
        fundMe.fund(); // Send 0 value
    }

    modifier funded() {
        vm.prank(USER); // means that the nex TX will be sent by USER
        fundMe.fund{value: ETH_1}();
        _;
    }

    function test_fund_updates_funders_array() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, ETH_1);
    }

    function test_add_funder_to_funders_array() public funded {
        assertEq(USER, fundMe.getFunder(0));
    }

    function test_only_owner_can_withdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function test_withdraw_with_single_funder() public funded {
        // Set the initial test information
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        
        // Call the function to test
        
        //uint256 gasStart = gasleft();
        //vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //uint256 gasEnd = gasleft();
        //uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        //console.log(gasUsed);
        
        // Assert values
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function test_withdraw_with_multiple_funders() public {
        // Set the initial test information
        uint160 numOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i <= numOfFunders; i++) {
            hoax(address(i), ETH_1);
            fundMe.fund{value: ETH_1}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }

}
