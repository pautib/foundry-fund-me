// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    address public ethUsdPriceFeed;

    function run() external returns (FundMe) {
        // Before start broadCasting means is not a real transaction
        HelperConfig helperConfig = new HelperConfig();
        ethUsdPriceFeed = helperConfig.activeNConfig();
        // After start broadCasting means real transaction
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();

        return fundMe;
    }
}
