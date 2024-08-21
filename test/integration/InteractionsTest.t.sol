// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract InteractionsTest is Test {

    uint256 public constant ETH_1 = 1 ether;
    address public USER = makeAddr("user"); // fake address to use as sender of all contract calls
    uint256 constant USER_STARTING_BALANCE = 20 ether;
    uint256 constant GAS_PRICE = 1;
    FundMe public fundMe;

    function setUp() external {
        console.log("The chain to use: ", block.chainid);
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        //address mostRecentlyDeployed = address(0x35a89e0327E88e1E7F9967Ea6D1e0afaCfA25C91);
        console.log("Most recently deployed address: ", mostRecentlyDeployed);
        fundMe = FundMe(payable(mostRecentlyDeployed));
        console.log("Owner ", FundMe(payable(mostRecentlyDeployed)).getOwner()); // It fails here
        vm.deal(USER, USER_STARTING_BALANCE);
    }

    function test_user_can_fund_and_owner_withdraw_interactions() public {
        uint256 startingUserBalance = address(USER).balance;
        uint256 startingOwnerBalance = address(fundMe.getOwner()).balance;

        vm.prank(USER);
        fundMe.fund{value: ETH_1}();

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingUserBalance = address(USER).balance;
        uint256 endingOwnerBalance = address(fundMe.getOwner()).balance;

        assertEq(address(fundMe).balance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + ETH_1);
        assertEq(endingUserBalance + ETH_1, startingUserBalance);
    }

}