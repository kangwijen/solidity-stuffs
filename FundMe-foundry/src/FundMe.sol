// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { PriceLibrary } from "./PriceLibrary.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__notOwner();

contract FundMe {
    /* 
    1. Get funds from users
    2. Withdraw funds
    3. Set minimum funding
    */
    using PriceLibrary for uint256;

    address public immutable i_contractOwner;
    uint256 public constant MINIMUM_USD = 1 * 1e18;
    address[] public fundersList;
    mapping(address funderAddress => uint256 amountFunded) public fundersToAmount;

    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_contractOwner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function sendFunding() public payable {
        // Allow users to send money
        // Have a minimum $ sent
        require(msg.value.getConversion(s_priceFeed) >= MINIMUM_USD, "Minimum donation not met.");

        // If new funder
        if (fundersToAmount[msg.sender] == 0) {
            fundersList.push(msg.sender);
        }

        fundersToAmount[msg.sender] += msg.value;
    }

    function withdrawFunding() public onlyOwner {
        // Only owner can withdraw
        // require(msg.sender == contractOwner, "Withdraw only for owner.");

        // Set all to 0
        for(uint256 funderIndex = 0; funderIndex < fundersList.length; funderIndex++){
            address funder = fundersList[funderIndex];
            fundersToAmount[funder] = 0;
        }

        fundersList = new address[](0);

        // payable(msg.sender).transfer(address(this).balance);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Withdraw failed.");
    }

    function getVersion() public view returns(uint256){
        return s_priceFeed.version();
    }

    modifier onlyOwner() {
        // require(msg.sender == i_contractOwner, "Only owner only function.");
        if(msg.sender != i_contractOwner){
            revert FundMe__notOwner();
        }
        _;
    }

    receive() external payable {
        sendFunding();
    }

    fallback() external payable {
        sendFunding();
    }
}