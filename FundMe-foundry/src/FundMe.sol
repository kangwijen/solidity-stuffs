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

    address private immutable i_contractOwner;
    uint256 public constant MINIMUM_USD = 1 * 1e18;
    address[] private s_fundersList;
    mapping(address funderAddress => uint256 amountFunded) private s_fundersToAmount;
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
        if (s_fundersToAmount[msg.sender] == 0) {
            s_fundersList.push(msg.sender);
        }

        s_fundersToAmount[msg.sender] += msg.value;
    }

    function cheaperWithdraw() public onlyOwner() {
        uint256 fundersAmount = s_fundersList.length;

        for(uint256 funderIndex = 0; funderIndex < fundersAmount; funderIndex++){
            address funder = s_fundersList[funderIndex];
            s_fundersToAmount[funder] = 0;
        }

        s_fundersList = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Withdraw failed.");
    }

    function withdrawFunding() public onlyOwner {
        // Only owner can withdraw
        // require(msg.sender == contractOwner, "Withdraw only for owner.");

        // Set all to 0
        for(uint256 funderIndex = 0; funderIndex < s_fundersList.length; funderIndex++){
            address funder = s_fundersList[funderIndex];
            s_fundersToAmount[funder] = 0;
        }

        s_fundersList = new address[](0);

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

    function getAddressToAmount(address funderAddress) external view returns(uint256){
        return s_fundersToAmount[funderAddress];
    }

    function getFunder(uint256 index) external view returns(address){
        return s_fundersList[index];
    }

    function getOwner() external view returns(address){
        return i_contractOwner;
    }
}