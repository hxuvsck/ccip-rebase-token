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
     * @notice If you want to make it more modified, as changing symbols, decimals, totalSupply etc... Please go checkout ERC20.sol of OpenZeppelin library which installed in lib/
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

    uint256 private constant PRECISION_FACTOR = 1e18;
    uint256 private s_interestRate = 5e10; //all tokens are 18 decimals position
    mapping (address=>uint256) private s_userInterestRate; // Need to set the personal interest rate for mint function
    mapping (address=>uint256) private s_userLastUpdatedTimestamp; 
    
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
     * @notice Mint the user tokens when they deposit into the vault
     * @param _to The user to mint the tokens to
     * @param _amount The amount of tokens to mint
     */
    function mint(address _to, uint256 _amount) external {
        // Minted nor not minted, interest rate of accumulated must be stacked up for calculating
        _mintAccruedInterest(_to);
        // Get the personal user interest rate to calculate how much should be calculated for certain users.
        // Because when user deposits more amount into their wallet, the calculated amount of previous interest should be updated to a new amount calculation in balance.
        s_userInterestRate[_to]=s_interestRate;
        _mint(_to,_amount);
    }

    /**
     * @notice Burn the user tokens when they withdraw from the vault
     * @param _from The user to burn the tokens from
     * @param _amount The amount of tokens to burn
     */
    function burn(address _from, uint256 _amount) external {
        //   Handle Maximum Amount (Dust Mitigation):
        // A common convention in DeFi is to use type(uint256).max as an input _amount to signify an intent to interact with the user's entire balance. This helps solve the "dust" problem: tiny, fractional amounts of tokens (often from interest) that might accrue between the moment a user initiates a transaction (like a full withdrawal) and the time it's actually executed on the blockchain due to network latency or block confirmation times.
        // If _amount is type(uint256).max, we update _amount to be the user's current total balance, including any just-in-time accrued interest. This is fetched using our overridden balanceOf(_from) function.
        if(_amount==type(uint256).max){
            _amount = balanceOf(_from);
        }
        _mintAccruedInterest(_from);
        _burn(_from, _amount);
    }

    /**
     * @notice Calculate the balance for the user including the interest that has accumulated since the last update
     * @dev (principle balance) + some interest that has accrued
     * @param _user The user to calculate the balance of
     * @return The balance of the user including the interest that has accumulated since the last update
     */
    function balanceOf(address _user) public view override returns(uint256) {
        // Get the current principle balance of the user (the number of tokens that have actually been minted to the user)
        // Multiply the principle balance by the interest that has accumulated in the time since the balance was updated
        return super.balanceOf(_user) * _calculateUserAccumulatedInterestSinceLastUpdate(_user)/PRECISION_FACTOR;
    }

    /**
     * 
     * @param _user 
     */
    function transfer(address _recipient, uint256 _amount) external public override returns(bool) {} // "n transfer" to search for function named transfer as n is for last spell of function *hack*

    ////////////////////////////
    //// Internal Functions ////
    ////////////////////////////

    /**
     * @notice Calculate the interest that has accumulated since the last update
     * @param _user The user to calculate the interest accumulated for
     * @return The interest that has accumulated since the last update
     */
    function _calculateUserAccumulatedInterestSinceLastUpdate(address _user) internal view returns(uint256 linearInterest) {
        // We need to calculate the interest that has accumulated since the last update
        // This is going to be linear growth with time
        // 1. Calculate the time since the last update
        // 2. Calculate the amount of linear growth
        // principal amount(1 * interest rate * time elapsed)
        // deposit: 10 tokens
        // interest rate 0.5 token per second
        // time elapsed is 2 seconds
        // 10 + (10 * 0.5 * 2)

        uint256 timeElapsed = block.timestamp - s_userLastUpdatedTimestamp[_user];
        linearInterest = (PRECISION_FACTOR + (s_interestRate[_user] * timeElapsed));
    }

    /**
     * @notice Mint the accrued interest to the user since the last time they interacted with the protocol (e.g. burn, mint, transfer)
     * @param _user The user to mint the accrued interest to
     */
    function _mintAccruedInterest(address _user) internal {
        // (1) Find their current balance of rebase tokens that have been minted to them already. -> principle balance
        uint256 previousPrincipleBalance = super.balanceOf(_user);
        // (2) Calculate their current balance including any interest. -> from balanceOf()
        uint256 currentBalance = balanceOf(_user);
        // Calculate the number of tokens that need to be minted to the user -> (2) - (1)
        uint256 balanceIncrease = currentBalance - previousPrincipleBalance;
        // Set the last updated timestamp
        s_userLastUpdatedTimestamp[_user] = block.timestamp;
        // Call _mint() to mint the tokens to the user
        _mint(_user, balanceIncrease);
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
