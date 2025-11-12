// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ReceiptVault
/// @notice Immutable receipt NFT storage
/// @dev Receipts never leave the vault - accessed via ZK proofs
contract ReceiptVault {
    /// @notice Receipt data structure
    struct Receipt {
        bytes32 orderId;
        address seller;
        address buyer;
        uint256 timestamp;
        bytes32 fulfillmentDataHash;
        bytes32 legalSignatureHash;
        bool wasCounterEscrowed;
        string metadataURI;
    }

    /// @notice Mapping of token IDs to receipts
    mapping(uint256 => Receipt) public receipts;

    /// @notice Next token ID
    uint256 public nextTokenId = 1;

    /// @notice Events
    event ReceiptMinted(
        uint256 indexed tokenId,
        bytes32 indexed orderId,
        address indexed buyer,
        address seller
    );

    /// @notice Mint a new receipt
    /// @param orderId Order identifier
    /// @param buyer Buyer's address (can be ephemeral/ZK address)
    /// @param seller Seller's address
    /// @param fulfillmentDataHash Hash of fulfillment data
    /// @param legalSignatureHash Hash of legal signature (if used)
    /// @param wasCounterEscrowed Whether counter-escrow was used
    /// @param metadataURI Optional metadata URI
    /// @return tokenId Receipt token ID
    function mintReceipt(
        bytes32 orderId,
        address buyer,
        address seller,
        bytes32 fulfillmentDataHash,
        bytes32 legalSignatureHash,
        bool wasCounterEscrowed,
        string calldata metadataURI
    ) external returns (uint256) {
        uint256 tokenId = nextTokenId++;

        receipts[tokenId] = Receipt({
            orderId: orderId,
            seller: seller,
            buyer: buyer,
            timestamp: block.timestamp,
            fulfillmentDataHash: fulfillmentDataHash,
            legalSignatureHash: legalSignatureHash,
            wasCounterEscrowed: wasCounterEscrowed,
            metadataURI: metadataURI
        });

        emit ReceiptMinted(tokenId, orderId, buyer, seller);
        return tokenId;
    }

    /// @notice Get receipt details
    /// @param tokenId Receipt token ID
    /// @return Receipt data
    function getReceipt(uint256 tokenId) external view returns (Receipt memory) {
        require(tokenId > 0 && tokenId < nextTokenId, "Invalid token ID");
        return receipts[tokenId];
    }

    /// @notice Verify buyer ownership via ZK proof
    /// @param tokenId Receipt token ID
    /// @param zkProof Zero-knowledge proof
    /// @return bool Whether proof is valid
    function verifyBuyerOwnership(uint256 tokenId, bytes calldata zkProof)
        external
        view
        returns (bool)
    {
        require(tokenId > 0 && tokenId < nextTokenId, "Invalid token ID");
        // ZK proof verification placeholder
        // In production, this would verify a zk-SNARK proof
        return zkProof.length > 0;
    }
}
```

-----

## Interfaces

### `crates/coreprover-contracts/src/interfaces/ICoreProverEscrow.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ICoreProverEscrow
/// @notice Interface for CoreProver escrow contract
interface ICoreProverEscrow {
    function createEscrow(
        bytes32 orderId,
        address seller,
        uint256 commitmentWindow,
        uint256 claimWindow,
        bool allowsTimedRelease,
        uint256 timedReleaseDelay
    ) external payable returns (bytes32);

    function sellerCommitEscrow(bytes32 orderId) external payable;

    function sellerCommitSignature(
        bytes32 orderId,
        bytes memory signature,
        string memory businessName,
        string memory businessLicense,
        bytes32 documentHash
    ) external;

    function sellerClaimPayment(bytes32 orderId) external returns (uint256);

    function buyerClaimCounterEscrow(bytes32 orderId) external returns (uint256);

    function triggerTimedRelease(bytes32 orderId) external;

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
    function mintReceipt(
        bytes32 orderId,
        address buyer,
        address seller,
        bytes32 fulfillmentDataHash,
        bytes32 legalSignatureHash,
        bool wasCounterEscrowed,
        string calldata metadataURI
    ) external returns (uint256);

    function verifyBuyerOwnership(uint256 tokenId, bytes calldata zkProof)
        external
        view
        returns (bool);
}