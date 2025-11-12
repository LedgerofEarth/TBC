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