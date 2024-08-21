// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./PriceConverter.sol";

error FundMe_NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 50 * 1e18;
    address[] public s_funders;
    mapping(address => uint256) public s_addressToAmountFunded;

    address private immutable i_owner;
    AggregatorV3Interface public immutable priceFeed;

    constructor(address priceFeedContract) {
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedContract);
    }

    function getPriceFeedVersion() external view returns (uint256) {
        return PriceConverter.getVersion(priceFeed);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(priceFeed) >= MINIMUM_USD, "Did not send enough USD!");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;

        for (uint256 i = 0; i < fundersLength; i++) {
            address funderAddress = s_funders[i];
            s_addressToAmountFunded[funderAddress] = 0;
        }

        s_funders = new address[](0); // resets array

        // msg.sender is of type address
        // payable(msg.sender) is of type payable address, payable needs to be added for to send native tokens (eth in our case) to an address

        // transfer funds stored in smart contract to the sender address (throws an error if fails)
        //payable(msg.sender).transfer(address(this).balance);

        // send the funds stored in smart contract to the sender address (returns false if fails)
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, "Send failed");

        // call
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not owner!");
        if (msg.sender != i_owner) revert FundMe_NotOwner();
        _; // The underscore means: Do everythin else on the function containing the modifier after executing the modifier
    }

    // What happens if someone sends this contract ETH without calling the fund function?
    // receive and fallback
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    // View/Pure functions to use as getters
    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
