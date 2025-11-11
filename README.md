# Inheritance Smart Contract

This project implements a Solidity smart contract that manages an inheritance system.
The contract allows the owner to withdraw Ether and resets an activity timer on interaction.
If the owner remains inactive for more than 30 days, the heir can take ownership and assign a new heir.

## Features

- Owner can withdraw Ether, including 0 ETH, to reset the inactivity timer.
- Owner can increase inheritance or update the heir at any time.
- Heir can take ownership after 30 days of inactivity.
- Direct payments are rejected to prevent unauthorized timer resets.
- Emits events for all significant actions.

## Commands

To run tests and deploy the contract using Foundry:

Run tests:
```bash
forge test
```

Deploy:
```bash
source .env && forge script script/Deploy.s.sol:DeployScript \
  --rpc-url $SEPOLIA_RPC_URL --broadcast --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY --chain-id 11155111
```
