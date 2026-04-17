// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

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

import {ERC20} from "@openzeppelin/contracts/token";

    /**
     * @title RebaseToken
     * @author Khuslen G.
     * @notice This is a cross-chain rebase token that incentivises users to deposit into a vault and gain interest from it in rewards.
     * @notice The interest rate for this smart contracts can only decrease
     * @notice Each user will have their own interest rate that is the global interest rate at the time of depositing. 
     */
contract RebaseToken is ERC20 {

    /////////////
    // Errors ///
    /////////////

    error RebaseToken__InterestRateCanOnlyDecrease();

    //////////////////////
    // State Variables ///
    //////////////////////

    uint256 private s_interestRate = 5e10; //all tokens are 18 decimals position
    
    ////////////
    // Events //
    ////////////

    event interestRateSet(uint256 newInterestRate);

    constructor() ERC20("Rebase Token". "RBT") {}

    /// 
    /// @notice Set the interest rate in the contract
    /// @param _newInterestRate The new interest rate to set
    /// @dev The interest rate can only decrease
    ///
    function setInterestRate(uint256 _newInterestRate) external {
        // Set the interest rate
        if(_newInterestRate<s_interestRate) {
            revert RebaseToken__InterestRateCanOnlyDecrease(s_interestRate,_newInterestRate);
        }
        s_interestRate = _newInterestRate;
        emit interestRateSet(_newInterestRate);
    }
}
