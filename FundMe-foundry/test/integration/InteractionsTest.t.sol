// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, console } from "forge-std/Test.sol";
import { FundMe } from "../../src/FundMe.sol";
import { DeployFundMe } from "../../script/DeployFundMe.s.sol";
import { SendFundMe, WithdrawFundMe } from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    address USER = makeAddr("USER");

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 * 1e18);
    }

    function testUserCanFundInteractions() public {
        SendFundMe sendFundMe = new SendFundMe();
        sendFundMe.sendFundMe(address(fundMe));

        vm.prank(USER);
        fundMe.sendFunding{value: 1 * 1e18}();
        
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}