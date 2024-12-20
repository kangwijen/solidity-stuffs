// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Raffle
/// @author @kangwijen
/// @notice Contract for creating a raffle
/// @dev Implementing a raffle contract
contract Raffle {
    // Errors
    error Raffle__NotEnoughEthToEnterRaffle();

    uint256 private immutable i_entranceFee;
    // @dev Interval in seconds
    uint256 private immutable i_interval;
    address payable[] private s_players;

    uint256 private s_lastTimestamp;

    // Events
    event RaffleEntered(address indexed player);

    constructor(uint256 entranceFee, uint256 interval) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimestamp = block.timestamp;
    }

    function enterRaffle() external payable {
        // require(msg.value >= i_entranceFee, "Not enough ETH to enter the raffle");

        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughEthToEnterRaffle();
        }

        s_players.push(payable(msg.sender));

        emit RaffleEntered(msg.sender);
    }

    // 1. Get random number
    // 2. Use RNG to pick winner
    // 3. Transfer money to the winner automatically
    function pickWinner() external view {
        if ((block.timestamp - s_lastTimestamp) < i_interval) {
            revert();
        }

        // Get RNG from Chainlink
    }

    // Getter Functions
    function getEntranceFee() external view returns(uint256) {
        return i_entranceFee;
    }
}