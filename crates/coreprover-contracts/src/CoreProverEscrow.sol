// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/ICoreProverEscrow.sol";

/// @title CoreProverEscrow
/// @notice Dual-commitment escrow with seller counter-escrow or legal signature
/// @dev Both buyer and seller must commit before any claims are possible
contract CoreProverEscrow is ICoreProverEscrow {
    /// @notice Escrow state machine
    enum EscrowState {
        NONE,
        BUYER_COMMITTED,
        SELLER_COMMITTED,
        BOTH_COMMITTED,
        SELLER_CLAIMED,
        BUYER_CLAIMED,
        BOTH_CLAIMED,
        DISPUTED,
        EXPIRED
    }

    /// @notice Escrow data structure
    struct Escrow {
        address buyer;
        address seller;
        uint256 buyerAmount;
        uint256 sellerAmount;
        EscrowState state;
        uint256 createdAt;
        uint256 commitmentDeadline;
        uint256 claimDeadline;
        bool allowsTimedRelease;
        uint256 timedReleaseTime;
    }

    /// @notice Legal signature commitment data
    struct LegalSignature {
        bytes signature;
        string businessName;
        string businessLicense;
        bytes32 documentHash;
        uint256 timestamp;
    }

    /// @notice Mapping of order IDs to escrows
    mapping(bytes32 => Escrow) public escrows;

    /// @notice Mapping of order IDs to legal signatures
    mapping(bytes32 => LegalSignature) public legalSignatures;

    /// @notice Events
    event EscrowCreated(
        bytes32 indexed orderId,
        address indexed buyer,
        address indexed seller,
        uint256 amount
    );
    event BothCommitted(bytes32 indexed orderId);
    event PaymentClaimed(bytes32 indexed orderId, address indexed seller, uint256 receiptId);
    event CounterEscrowClaimed(bytes32 indexed orderId, address indexed buyer, uint256 amount);
    event TimedReleaseTriggered(bytes32 indexed orderId);
    event RefundProcessed(bytes32 indexed orderId, address indexed buyer, uint256 amount);

    /// @notice Create a new escrow
    /// @param orderId Unique order identifier
    /// @param seller Seller's address
    /// @param commitmentWindow Time window for seller to commit (seconds)
    /// @param claimWindow Time window for claims (seconds)
    /// @param allowsTimedRelease Whether timed release is enabled
    /// @param timedReleaseDelay Delay for timed release (seconds)
    function createEscrow(
        bytes32 orderId,
        address seller,
        uint256 commitmentWindow,
        uint256 claimWindow,
        bool allowsTimedRelease,
        uint256 timedReleaseDelay
    ) external payable returns (bytes32) {
        require(msg.value > 0, "Must send payment");
        require(seller != address(0), "Invalid seller");
        require(escrows[orderId].state == EscrowState.NONE, "Escrow already exists");

        uint256 commitmentDeadline = block.timestamp + commitmentWindow;

        escrows[orderId] = Escrow({
            buyer: msg.sender,
            seller: seller,
            buyerAmount: msg.value,
            sellerAmount: 0,
            state: EscrowState.BUYER_COMMITTED,
            createdAt: block.timestamp,
            commitmentDeadline: commitmentDeadline,
            claimDeadline: commitmentDeadline + claimWindow,
            allowsTimedRelease: allowsTimedRelease,
            timedReleaseTime: allowsTimedRelease ? commitmentDeadline + timedReleaseDelay : 0
        });

        emit EscrowCreated(orderId, msg.sender, seller, msg.value);
        return orderId;
    }

    /// @notice Seller commits via counter-escrow
    /// @param orderId Order identifier
    function sellerCommitEscrow(bytes32 orderId) external payable {
        Escrow storage escrow = escrows[orderId];
        require(escrow.state == EscrowState.BUYER_COMMITTED, "Invalid state");
        require(msg.sender == escrow.seller, "Not seller");
        require(block.timestamp <= escrow.commitmentDeadline, "Commitment deadline passed");

        escrow.sellerAmount = msg.value;
        escrow.state = EscrowState.BOTH_COMMITTED;

        emit BothCommitted(orderId);
    }

    /// @notice Seller commits via legal signature
    /// @param orderId Order identifier
    /// @param signature ECDSA signature
    /// @param businessName Business name
    /// @param businessLicense Business license number
    /// @param documentHash Hash of legal document
    function sellerCommitSignature(
        bytes32 orderId,
        bytes memory signature,
        string memory businessName,
        string memory businessLicense,
        bytes32 documentHash
    ) external {
        Escrow storage escrow = escrows[orderId];
        require(escrow.state == EscrowState.BUYER_COMMITTED, "Invalid state");
        require(msg.sender == escrow.seller, "Not seller");
        require(block.timestamp <= escrow.commitmentDeadline, "Commitment deadline passed");

        legalSignatures[orderId] = LegalSignature({
            signature: signature,
            businessName: businessName,
            businessLicense: businessLicense,
            documentHash: documentHash,
            timestamp: block.timestamp
        });

        escrow.state = EscrowState.BOTH_COMMITTED;

        emit BothCommitted(orderId);
    }

    /// @notice Seller claims payment
    /// @param orderId Order identifier
    /// @return receiptId Receipt token ID
    function sellerClaimPayment(bytes32 orderId) external returns (uint256) {
        Escrow storage escrow = escrows[orderId];
        require(escrow.state == EscrowState.BOTH_COMMITTED, "Not both committed");
        require(msg.sender == escrow.seller, "Not seller");
        require(block.timestamp <= escrow.claimDeadline, "Claim deadline passed");

        escrow.state = EscrowState.SELLER_CLAIMED;
        payable(escrow.seller).transfer(escrow.buyerAmount);

        uint256 receiptId = uint256(orderId);
        emit PaymentClaimed(orderId, escrow.seller, receiptId);

        return receiptId;
    }

    /// @notice Buyer claims counter-escrow
    /// @param orderId Order identifier
    /// @return amount Amount claimed
    function buyerClaimCounterEscrow(bytes32 orderId) external returns (uint256) {
        Escrow storage escrow = escrows[orderId];
        require(
            escrow.state == EscrowState.BOTH_COMMITTED || escrow.state == EscrowState.SELLER_CLAIMED,
            "Invalid state"
        );
        require(msg.sender == escrow.buyer, "Not buyer");
        require(escrow.sellerAmount > 0, "No counter-escrow");
        require(block.timestamp <= escrow.claimDeadline, "Claim deadline passed");

        uint256 amount = escrow.sellerAmount;
        escrow.sellerAmount = 0;

        if (escrow.state == EscrowState.SELLER_CLAIMED) {
            escrow.state = EscrowState.BOTH_CLAIMED;
        } else {
            escrow.state = EscrowState.BUYER_CLAIMED;
        }

        payable(escrow.buyer).transfer(amount);

        emit CounterEscrowClaimed(orderId, escrow.buyer, amount);
        return amount;
    }

    /// @notice Trigger timed release
    /// @param orderId Order identifier
    function triggerTimedRelease(bytes32 orderId) external {
        Escrow storage escrow = escrows[orderId];
        require(escrow.state == EscrowState.BOTH_COMMITTED, "Not both committed");
        require(escrow.allowsTimedRelease, "Timed release not enabled");
        require(block.timestamp >= escrow.timedReleaseTime, "Too early for timed release");

        escrow.state = EscrowState.SELLER_CLAIMED;
        payable(escrow.seller).transfer(escrow.buyerAmount);

        emit TimedReleaseTriggered(orderId);
        emit PaymentClaimed(orderId, escrow.seller, uint256(orderId));
    }

    /// @notice Refund buyer if seller never commits
    /// @param orderId Order identifier
    function refundBuyerTimeout(bytes32 orderId) external {
        Escrow storage escrow = escrows[orderId];
        require(escrow.state == EscrowState.BUYER_COMMITTED, "Invalid state");
        require(block.timestamp > escrow.commitmentDeadline, "Commitment deadline not passed");

        escrow.state = EscrowState.EXPIRED;
        payable(escrow.buyer).transfer(escrow.buyerAmount);

        emit RefundProcessed(orderId, escrow.buyer, escrow.buyerAmount);
    }

    /// @notice Get escrow details
    /// @param orderId Order identifier
    /// @return Escrow data
    function getEscrow(bytes32 orderId) external view returns (Escrow memory) {
        return escrows[orderId];
    }

    /// @notice Get legal signature details
    /// @param orderId Order identifier
    /// @return LegalSignature data
    function getLegalSignature(bytes32 orderId) external view returns (LegalSignature memory) {
        return legalSignatures[orderId];
    }
}