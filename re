You’re right! Let me provide the interface files clearly with their exact paths:

-----

## Contract Interfaces

### `crates/coreprover-contracts/src/interfaces/ICoreProverEscrow.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ICoreProverEscrow
/// @notice Interface for CoreProver escrow contract
interface ICoreProverEscrow {
    /// @notice Create a new escrow
    function createEscrow(
        bytes32 orderId,
        address seller,
        uint256 commitmentWindow,
        uint256 claimWindow,
        bool allowsTimedRelease,
        uint256 timedReleaseDelay
    ) external payable returns (bytes32);

    /// @notice Seller commits via counter-escrow
    function sellerCommitEscrow(bytes32 orderId) external payable;

    /// @notice Seller commits via legal signature
    function sellerCommitSignature(
        bytes32 orderId,
        bytes memory signature,
        string memory businessName,
        string memory businessLicense,
        bytes32 documentHash
    ) external;

    /// @notice Seller claims payment
    function sellerClaimPayment(bytes32 orderId) external returns (uint256);

    /// @notice Buyer claims counter-escrow
    function buyerClaimCounterEscrow(bytes32 orderId) external returns (uint256);

    /// @notice Trigger timed release
    function triggerTimedRelease(bytes32 orderId) external;

    /// @notice Refund buyer if seller never commits
    function refundBuyerTimeout(bytes32 orderId) external;
}
```

### `crates/coreprover-contracts/src/interfaces/IReceiptVault.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IReceiptVault
/// @notice Interface for receipt vault contract
interface IReceiptVault {
    /// @notice Mint a new receipt NFT
    function mintReceipt(
        bytes32 orderId,
        address buyer,
        address seller,
        bytes32 fulfillmentDataHash,
        bytes32 legalSignatureHash,
        bool wasCounterEscrowed,
        string calldata metadataURI
    ) external returns (uint256);

    /// @notice Get receipt details
    function getReceipt(uint256 tokenId) external view returns (
        bytes32 orderId,
        address seller,
        address buyer,
        uint256 timestamp,
        bytes32 fulfillmentDataHash,
        bytes32 legalSignatureHash,
        bool wasCounterEscrowed,
        string memory metadataURI
    );

    /// @notice Verify buyer ownership via ZK proof
    function verifyBuyerOwnership(uint256 tokenId, bytes calldata zkProof)
        external
        view
        returns (bool);
}
```

-----

These interface files should be placed in the `crates/coreprover-contracts/src/interfaces/` directory alongside the main contracts and libraries.​​​​​​​​​​​​​​​​