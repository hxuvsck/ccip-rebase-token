// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

/**
 * @title Vault storage for Cross-Chain Rebase Tokens for storing ETH
 * @author Khuslen Ganbat
 * @notice
 */

contract Vault {
    // We need to pass the token address to the constructor
    // Create a deposit function that mints tokens to the user equal to the amount of ETH has sent
    // Create a redeem function that burns tokens from the user and sends the user ETH
    // Create a way to add rewards to the vault

    address private immutable i_rebaseToken;

    constructor(address _rebaseToken) {
        i_rebaseToken = _rebaseToken;
    }

    receive() external payable {}

    function getRebaseTokenAddress() external view returns (address) {
        return i_rebaseToken;
    }
}
