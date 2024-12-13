// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script } from "forge-std/Script.sol";
import { MockV3Aggregator } from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // If we're on a local anvil, deploy mocks
    // Otherwise, grab existing address from live network

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8;

    constructor() {
        if (block.chainid == 1155111){
            activeNetworkConfig = getSepoliaConfig();
        } 
        else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed;
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        // Price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        // Price feed address

        if (activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }

        // 1. Deploy Mocks
        // 2. Return Mocks
        vm.startBroadcast();

        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);

        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });

        return anvilConfig;
    }
}