// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {TokenPool} from "chainlink-ccip/chains/evm/contracts/pools/TokenPool.sol";

abstract contract RebaseTokenPool is TokenPool {}
