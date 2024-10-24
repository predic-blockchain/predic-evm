# PredicEVM

PredicEVM is a decentralized price prediction platform built on EVM-compatible blockchains. Users can make predictions about price movements of various assets and earn rewards for accurate predictions.

## Overview

This smart contract allows users to participate in price prediction games by betting on different price movement ranges. The system uses Pyth Network oracles for reliable price feeds and implements a reward distribution mechanism for successful predictions.

## Features

- Multiple prediction ranges: 100/-90%, 50/-50%, 25/-25%, 10/-10%, 5/-5%, 3/-3%, and Sideways
- Integration with Pyth Network for accurate price feeds
- Automated reward distribution system
- Signer-controlled administrative functions
- Limit of 500 predictions per round

## Contract Structure

The main components of the system include:

- `PredicCore`: The main contract handling predictions and rewards
- `Prediction`: Struct containing prediction details (holder, amount, direction)
- Price range functions for different percentage movements
- Reward distribution mechanism

## How It Works

1. Users make predictions by calling the `predic()` function with:
   - Amount to stake
   - Direction of price movement (UpDown enum)

2. When a round ends, the signer calls `reward()` which:
   - Fetches the latest price from Pyth
   - Calculates the percentage change
   - Determines winners based on prediction ranges
   - Distributes rewards to successful predictors

## Usage

### Prerequisites

- An EVM-compatible blockchain
- Pyth Network oracle integration
- ERC20 token for prediction/reward actions

### Deployment

1. Deploy with required parameters:
```solidity
constructor(address _pyth, address _token)
```

### Making Predictions

```solidity
function prediction(uint _amount, UpDown _updown) external payable;
```

### Administrative Functions

```solidity
function setSigner(address _signer) external;
function setIsActive(bool _isActive) external;
function reward() external payable isSigner
```

## Security Considerations

- Signer-controlled administrative functions
- Price feed reliability through Pyth Network
- Prediction limits to prevent overflow
- Automated reward distribution

## Dependencies

- Solidity ^0.8.13
- Pyth Network Oracle (@pythnetwork/pyth-sdk-solidity)

## License

This project is licensed under AGPL-3.0-or-later
