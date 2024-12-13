// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, console } from "forge-std/Test.sol";
import { FundMe } from "../src/FundMe.sol";
import { DeployFundMe } from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("USER");

    modifier funded(){
        vm.prank(USER);
        vm.deal(USER, 10 * 1e18);
        _;
    }

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 * 1e18);
    }

    function testMinFund() public view {
        assertEq(fundMe.MINIMUM_USD(), 1 * 1e18);
    }

    function testOwner() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailIfNotEnough () public {
        vm.expectRevert();
        fundMe.sendFunding();
    }

    function testFundSuccess () public funded {
        fundMe.sendFunding{value: 1 * 1e18}();
        uint256 amountFunded = fundMe.getAddressToAmount(USER);
        assertEq(amountFunded, 1 * 1e18);
    }

    function testAddFunderToArrayOfFunders () public funded {
        fundMe.sendFunding{value: 1 * 1e18}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerAndWithdrawNotOwner () public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdrawFunding();
    }

    function testOnlyOwnerAndWithdrawOwner () public funded {
        fundMe.sendFunding{value: 1 * 1e18}();
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingContractBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdrawFunding();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingContractBalance = address(fundMe).balance;

        assertEq(endingContractBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingContractBalance);
    }

    function testWithdrawFromMultipleFunders() public {
        uint160 fundersAmount = 10;
        uint160 startingFundersIndex = 2;
        for (uint256 i = startingFundersIndex; i < fundersAmount; i++) {
            hoax(address(uint160(i)), 1 * 1e18);
            fundMe.sendFunding{value: 1 * 1e18}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingContractBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdrawFunding();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingContractBalance = address(fundMe).balance;

        assertEq(endingContractBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingContractBalance);
    }

    function testCheaperWithdrawFromMultipleFunders() public {
        uint160 fundersAmount = 10;
        uint160 startingFundersIndex = 2;
        for (uint256 i = startingFundersIndex; i < fundersAmount; i++) {
            hoax(address(uint160(i)), 1 * 1e18);
            fundMe.sendFunding{value: 1 * 1e18}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingContractBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingContractBalance = address(fundMe).balance;

        assertEq(endingContractBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingContractBalance);
    }
}