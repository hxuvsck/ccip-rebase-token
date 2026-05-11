// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.20;
import {TokenPool} from "chainlink-ccip/chains/evm/contracts/pools/TokenPool.sol";
import {Pool} from "chainlink-ccip/chains/evm/contracts/libraries/Pool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IRebaseToken} from "../src/interfaces/IRebaseToken.sol";
import {FinalityCodec} from "chainlink-ccip/chains/evm/contracts/libraries/FinalityCodec.sol";

abstract contract RebaseTokenPool is TokenPool {
    constructor(IERC20 _token, address _advancedPoolHooks, address _rmnProxy, address _router)
        TokenPool(_token, 18, _advancedPoolHooks, _rmnProxy, _router)
    {}

    function lockOrBurn(Pool.LockOrBurnInV1 calldata lockOrBurnIn)
        public
        virtual
        override
        returns (Pool.LockOrBurnOutV1 memory lockOrBurnOut)
    {
        _validateLockOrBurn(lockOrBurnIn, bytes4(0), "", 0);
        address originalSender = lockOrBurnIn.originalSender;
        uint256 userInterestRate = IRebaseToken(address(i_token)).getUserInterestRate(lockOrBurnIn.originalSender);
        IRebaseToken(address(i_token)).burn(address(this), lockOrBurnIn.amount);
        lockOrBurnOut = Pool.LockOrBurnOutV1({
            destTokenAddress: getRemoteToken(lockOrBurnIn.remoteChainSelector),
            destPoolData: abi.encode(userInterestRate)
        });
    }

    function releaseOrMint(Pool.ReleaseOrMintInV1 calldata releaseOrMintIn)
        public
        virtual
        override
        returns (Pool.ReleaseOrMintOutV1 memory)
    {
        _validateReleaseOrMint(releaseOrMintIn, releaseOrMintIn.sourceDenominatedAmount, bytes4(0));

        address originalSender = abi.decode(releaseOrMintIn.originalSender, (address));

        uint256 userInterestRate = IRebaseToken(address(i_token)).getUserInterestRate(originalSender);

        IRebaseToken(address(i_token)).mint(releaseOrMintIn.receiver, releaseOrMintIn.sourceDenominatedAmount);

        return Pool.ReleaseOrMintOutV1({destinationAmount: releaseOrMintIn.sourceDenominatedAmount});
    }
}
