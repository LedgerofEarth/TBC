# Escrow API Reference

## Contract Functions

### createEscrow

```solidity
function createEscrow(
    bytes32 orderId,
    address seller,
    uint256 commitmentWindow
) external payable returns (bytes32)
```

### sellerCommitEscrow

```solidity
function sellerCommitEscrow(bytes32 orderId) external payable
```

### sellerClaimPayment

```solidity
function sellerClaimPayment(bytes32 orderId) external returns (uint256)
```
