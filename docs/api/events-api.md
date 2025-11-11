# Events API Reference

## Events

### EscrowCreated

```solidity
event EscrowCreated(bytes32 indexed orderId, address buyer, address seller, uint256 amount)
```

### BothCommitted

```solidity
event BothCommitted(bytes32 indexed orderId)
```

### PaymentClaimed

```solidity
event PaymentClaimed(bytes32 indexed orderId, address seller, uint256 receiptId)
```
