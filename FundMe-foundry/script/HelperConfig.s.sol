// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script } from "forge-std/Script.sol";

contract HelperConfig is Script {
    // If we're on a local anvil, deploy mocks
    // Otherwise, grab existing address from live network

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 1155111){
            activeNetworkConfig = getSepoliaConfig();
        } 
        else {
            activeNetworkConfig = getAnvilConfig();
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

    function getAnvilConfig() public pure returns (NetworkConfig memory) {
        // Price feed address

    }
}