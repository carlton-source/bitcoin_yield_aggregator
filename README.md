# Bitcoin Yield Aggregator Smart Contract

A sophisticated yield optimization platform built for BTC-based assets, enabling automated yield farming and portfolio management across multiple DeFi protocols on the Stacks blockchain.

## Overview

The Bitcoin Yield Aggregator is a smart contract system that automatically maximizes yields for Bitcoin-based assets by dynamically allocating funds across various DeFi protocols. It implements a secure, efficient, and flexible architecture for managing deposits, calculating rewards, and optimizing returns while maintaining strong security guarantees.

## Features

### Core Functionality

- **Multi-Protocol Yield Optimization**: Automatically distributes funds across different protocols based on APY
- **Dynamic APY Tracking**: Real-time monitoring and adjustment of yield strategies
- **SIP-010 Token Support**: Compatible with any Bitcoin-based token implementing the SIP-010 standard
- **Flexible Protocol Management**: Support for adding, updating, and managing multiple yield protocols
- **Emergency Controls**: Built-in emergency shutdown mechanism for risk management

### Security Features

- **Token Whitelisting**: Only approved tokens can interact with the contract
- **Deposit Limits**: Configurable minimum and maximum deposit amounts
- **Owner Controls**: Protected administrative functions
- **Safe Transfer Mechanisms**: Secure token transfer implementation
- **Protocol Validation**: Comprehensive validation for all protocol interactions

### Yield Management

- **Automated Rebalancing**: Smart rebalancing of funds across protocols
- **Weighted APY Calculation**: Sophisticated APY calculations based on protocol allocations
- **Reward Distribution**: Fair and efficient reward calculation and distribution system
- **Platform Fee Management**: Configurable platform fees with upper limits

## Technical Architecture

### Constants

```clarity
ERR-NOT-AUTHORIZED (u1000)
ERR-INVALID-AMOUNT (u1001)
ERR-INSUFFICIENT-BALANCE (u1002)
...
```

### Data Structures

#### Maps

- **user-deposits**: Tracks user deposit amounts and timestamps
- **user-rewards**: Manages pending and claimed rewards
- **protocols**: Stores protocol configurations and status
- **strategy-allocations**: Manages protocol allocation percentages
- **whitelisted-tokens**: Tracks approved tokens

#### Variables

- **total-tvl**: Total Value Locked in the contract
- **platform-fee-rate**: Current platform fee percentage
- **min-deposit**: Minimum allowed deposit amount
- **max-deposit**: Maximum allowed deposit amount
- **emergency-shutdown**: Emergency shutdown status

## Core Functions

### Deposit Management

```clarity
(define-public (deposit (token-trait <sip-010-trait>) (amount uint)))
(define-public (withdraw (token-trait <sip-010-trait>) (amount uint)))
```

- Handles user deposits and withdrawals
- Validates token and amount constraints
- Updates TVL and user balances
- Triggers protocol rebalancing when needed

### Protocol Management

```clarity
(define-public (add-protocol (protocol-id uint) (name (string-ascii 64)) (initial-apy uint)))
(define-public (update-protocol-status (protocol-id uint) (active bool)))
(define-public (update-protocol-apy (protocol-id uint) (new-apy uint)))
```

- Manages protocol configurations
- Updates protocol status and APY
- Handles protocol allocation strategies

### Reward Distribution

```clarity
(define-public (claim-rewards (token-trait <sip-010-trait>)))
```

- Calculates user rewards based on deposit amount and time
- Handles reward distribution
- Updates reward tracking

## Administrative Functions

### Platform Management

```clarity
(define-public (set-platform-fee (new-fee uint)))
(define-public (set-emergency-shutdown (shutdown bool)))
(define-public (whitelist-token (token principal)))
```

- Controls platform parameters
- Manages emergency situations
- Handles token whitelisting

## Usage Guidelines

### For Users

1. Ensure your tokens are whitelisted
2. Deposit funds within the min/max limits
3. Monitor your rewards using the provided getter functions
4. Claim rewards when desired
5. Withdraw funds with proper validation

### For Administrators

1. Manage protocol configurations
2. Monitor and update APY rates
3. Handle emergency situations
4. Manage platform fees
5. Maintain token whitelist

## Error Handling

The contract implements comprehensive error handling with specific error codes:

- `ERR-NOT-AUTHORIZED (u1000)`: Unauthorized access attempt
- `ERR-INVALID-AMOUNT (u1001)`: Invalid amount specified
- `ERR-INSUFFICIENT-BALANCE (u1002)`: Insufficient funds
- And more...

## Security Considerations

### Best Practices

- Always verify token whitelist status
- Monitor protocol allocations
- Regular APY verification
- Maintain safe deposit limits

### Risk Management

- Emergency shutdown capability
- Deposit/withdrawal limits
- Protocol validation
- Safe transfer mechanisms

## Integration Guide

### Required Interfaces

- SIP-010 Token Interface
- Protocol-specific interfaces

### Implementation Steps

1. Deploy contract
2. Configure initial protocols
3. Set platform parameters
4. Whitelist tokens
5. Monitor and maintain

## License

This project is licensed under the MIT License.

## Contributing

We welcome contributions from the community. To get started, fork this repository, make your changes, and submit a pull request. For significant changes, please open an issue first to discuss the proposed changes.
