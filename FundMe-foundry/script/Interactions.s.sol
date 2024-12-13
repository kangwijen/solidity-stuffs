// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console } from "forge-std/Script.sol";
import { DevOpsTools } from "../lib/foundry-devops/src/DevOpsTools.sol";
import { FundMe } from "../src/FundMe.sol";

contract SendFundMe is Script {
    function sendFundMe(address mostRecentDeployment) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployment)).sendFunding{value: 1 * 1e18}();
        vm.stopBroadcast();
        console.log("Sent 1 ETH to", mostRecentDeployment);
    }

    function run () external {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        sendFundMe(mostRecentDeployment);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentDeployment) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeployment)).withdrawFunding();
        vm.stopBroadcast();
        console.log("Withdrew funds from", mostRecentDeployment);
    }

    function run () external {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentDeployment);
    }
}