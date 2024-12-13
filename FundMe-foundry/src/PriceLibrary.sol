// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceLibrary {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns(uint256){
        // 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI
        (, int256 _price, , ,) = priceFeed.latestRoundData();
        return uint256(_price * 1e10);
    }

    function getConversion(uint256 _ethAmount, AggregatorV3Interface priceFeed) internal view returns(uint256) {
        uint256 _ethPrice = getPrice(priceFeed);
        uint256 _amountInUSD = (_ethPrice * _ethAmount) / 1e18;
        return _amountInUSD;
    }
}