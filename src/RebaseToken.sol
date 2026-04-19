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
    mapping (address=>uint256) private s_userInterestRate; // Need to set the personal interest rate for mint function
    
    ////////////
    // Events //
    ////////////

    event interestRateSet(uint256 newInterestRate);

    constructor() ERC20("Rebase Token". "RBT") {}

    /**
    * @notice Set the interest rate in the contract
    * @param _newInterestRate The new interest rate to set
    * @dev The interest rate can only decrease
    */

    ////////////////////////////
    //// External Functions ////
    ////////////////////////////

    function setInterestRate(uint256 _newInterestRate) external {
        // Set the interest rate
        if(_newInterestRate<s_interestRate) {
            revert RebaseToken__InterestRateCanOnlyDecrease(s_interestRate,_newInterestRate);
        }
        s_interestRate = _newInterestRate;
        emit interestRateSet(_newInterestRate);
    }

    /**
     * @notice
     */

    function mint(address _to, uint256 _amount) external {
        // Minted nor not minted, interest rate of accumulated must be stacked up for calculating
        _mintAccruedInterest(_to);
        // Get the personal user interest rate to calculate how much should be calculated for certain users.
        // Because when user deposits more amount into their wallet, the calculated amount of previous interest should be updated to a new amount calculation in balance.
        s_userInterestRate[_to]=s_interestRate;
        _mint(_to,_amount);
    }

    ////////////////////////////
    //// Internal Functions ////
    ////////////////////////////

    function _mintAccruedInterest(address _user) internal {
        // Find their current balance of rebase tokens that have been minted to them already.
        // Calculate their current balance including any interest.
    }

    //////////////////////////
    //// Getter Functions ////
    //////////////////////////

    /**
     * @notice Get the user interest rate
     * @param _user The user to get the user interest rate for
     * @return The interest rate for the users
     */
    function getUserInterestRate(address _user) external view returns (uint256) {
        return s_userInterestRate[_user];
    }
    
}
