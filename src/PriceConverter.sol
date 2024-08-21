// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

     function getPrice(AggregatorV3Interface priceFeed) internal view returns(uint256) {
          // We need the ABI of the contract that it's going to give us the price
          // The Address of the contract 0x694AA1769357215DE4FAC081bf1f309aDC325306
          (, int256 price,,,) = priceFeed.latestRoundData();
          uint8 decimals = priceFeed.decimals();

          return uint256(price) * 10**(18 - decimals); // Return how man
     }

     function getVersion(AggregatorV3Interface priceFeed) internal view returns(uint256) {
          return priceFeed.version();
     }

     function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
          uint256 ethPrice = getPrice(priceFeed);
          uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
          return ethAmountInUsd;
     }

}