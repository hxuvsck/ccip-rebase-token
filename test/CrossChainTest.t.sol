// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {CCIPLocalSimulatorFork, Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";

import {RebaseToken} from "../src/RebaseToken.sol";
import {RebaseTokenPool} from "../src/RebaseTokenPool.sol";
import {Vault} from "../src/Vault.sol";

import {IRebaseToken} from "../src/interfaces/IRebaseToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {RegistryModuleOwnerCustom} from "@ccip/tokenAdminRegistry/RegistryModuleOwnerCustom.sol";

contract CrossChainTest is Test {
    address owner = makeAddr("owner");

    uint256 sepoliaFork;
    uint256 arbSepoliaFork;

    CCIPLocalSimulatorFork simulator;

    RebaseToken sepoliaToken;
    RebaseToken arbSepoliaToken;

    Vault vault;

    RebaseTokenPool sepoliaPool;
    RebaseTokenPool arbSepoliaPool;

    Register.NetworkDetails sepoliaNetworkDetails;
    Register.NetworkDetails arbSepoliaNetworkDetails;

    function setUp() public {
        sepoliaFork = vm.createSelectFork("sepolia_eth");
        arbSepoliaFork = vm.createFork("arb-sepolia");

        simulator = new CCIPLocalSimulatorFork();
        vm.makePersistent(address(simulator));

        // -------------------------------------------------
        // Sepolia
        // -------------------------------------------------
        sepoliaNetworkDetails = simulator.getNetworkDetails(block.chainid);

        vm.startPrank(owner);

        sepoliaToken = new RebaseToken();

        vault = new Vault(IRebaseToken(address(sepoliaToken)));

        new RebaseTokenPool(
            IERC20(address(sepoliaToken)),
            address(0),
            sepoliaNetworkDetails.rmnProxyAddress,
            sepoliaNetworkDetails.routerAddress
        );

        sepoliaToken.grantMintAndBurnRole(address(vault));
        sepoliaToken.grantMintAndBurnRole(address(sepoliaPool));

        vm.stopPrank();

        // -------------------------------------------------
        // Arbitrum Sepolia
        // -------------------------------------------------
        vm.selectFork(arbSepoliaFork);

        arbSepoliaNetworkDetails = simulator.getNetworkDetails(block.chainid);

        arbSepoliaToken = new RebaseToken();

        new RebaseTokenPool(
            IERC20(address(arbSepoliaToken)),
            address(0),
            arbSepoliaNetworkDetails.rmnProxyAddress,
            arbSepoliaNetworkDetails.routerAddress
        );

        arbSepoliaToken.grantMintAndBurnRole(address(arbSepoliaPool));
    }
}
