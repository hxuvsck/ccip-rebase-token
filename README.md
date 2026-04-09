# Cross-Chain Rebase Token

1. A protocol that allows user to deposit into a vault and in return, receive rebase tokens that represent their underlying balance.
2. Rebase token -> balanceOf function is dynamic to show the increasing balance with time.
    — Balance increase linearly with time
    — Mint tokens to our users everytime they perform an action (minting, burning, transferring, bridging)
3. Interest rate
    — Individually set an interest rate or each user based on some global interest rate of the protocol at the time the user deposits into the vault.
    — This global interest can only decrease to incentivise/reward early adopters. (Administrator can reduce it)
    — # ccip-rebase-token
