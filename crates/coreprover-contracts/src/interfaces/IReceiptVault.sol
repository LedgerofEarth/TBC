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