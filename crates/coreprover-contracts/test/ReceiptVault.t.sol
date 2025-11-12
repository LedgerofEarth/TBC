// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ReceiptVault.sol";

contract ReceiptVaultTest is Test {
    ReceiptVault public vault;

    function setUp() public {
        vault = new ReceiptVault();
    }

    function testMintReceipt() public {
        bytes32 orderId = keccak256("order1");
        address buyer = address(0x1);
        address seller = address(0x2);
        bytes32 fulfillmentHash = keccak256("fulfillment");
        bytes32 signatureHash = keccak256("signature");

        uint256 tokenId = vault.mintReceipt(
            orderId, buyer, seller, fulfillmentHash, signatureHash, false, "ipfs://metadata"
        );

        assertEq(tokenId, 1);

        (bytes32 _orderId,,,,,,,) = vault.receipts(tokenId);
        assertEq(_orderId, orderId);
    }

    function testGetReceipt() public {
        bytes32 orderId = keccak256("order2");
        address buyer = address(0x3);
        address seller = address(0x4);

        uint256 tokenId = vault.mintReceipt(
            orderId, buyer, seller, bytes32(0), bytes32(0), true, ""
        );

        ReceiptVault.Receipt memory receipt = vault.getReceipt(tokenId);

        assertEq(receipt.orderId, orderId);
        assertEq(receipt.buyer, buyer);
        assertEq(receipt.seller, seller);
        assertTrue(receipt.wasCounterEscrowed);
    }

    function testVerifyBuyerOwnership() public {
        bytes32 orderId = keccak256("order3");
        uint256 tokenId =
            vault.mintReceipt(orderId, address(0x5), address(0x6), bytes32(0), bytes32(0), false, "");

        bytes memory zkProof = new bytes(128);
        bool isValid = vault.verifyBuyerOwnership(tokenId, zkProof);

        assertTrue(isValid);
    }
}
```

### `crates/coreprover-contracts/test/integration/FullFlow.t.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/CoreProverEscrow.sol";
import "../../src/ReceiptVault.sol";

contract FullFlowTest is Test {
    CoreProverEscrow public escrow;
    ReceiptVault public vault;

    address public buyer = address(0x1);
    address public seller = address(0x2);

    function setUp() public {
        escrow = new CoreProverEscrow();
        vault = new ReceiptVault();

        vm.deal(buyer, 10 ether);
        vm.deal(seller, 10 ether);
    }

    function testCompleteDigitalGoodsFlow() public {
        bytes32 orderId = keccak256("digital-goods-order");

        // 1. Buyer creates escrow
        vm.prank(buyer);
        escrow.createEscrow{value: 0.1 ether}(orderId, seller, 3600, 86400, false, 0);

        // 2. Seller commits with signature (no counter-escrow)
        bytes memory signature = new bytes(65);
        vm.prank(seller);
        escrow.sellerCommitSignature(
            orderId, signature, "SaaS Company", "LICENSE-456", keccak256("terms")
        );

        // 3. Seller claims payment
        vm.prank(seller);
        uint256 receiptId = escrow.sellerClaimPayment(orderId);

        // 4. Mint receipt
        vault.mintReceipt(
            orderId, buyer, seller, keccak256("download-link"), keccak256("signature"), false, ""
        );

        // Verify final state
        assertGt(receiptId, 0);
        assertEq(seller.balance, 10.1 ether);
    }

    function testCompletePhysicalGoodsFlow() public {
        bytes32 orderId = keccak256("physical-goods-order");

        // 1. Buyer creates escrow
        vm.prank(buyer);
        escrow.createEscrow{value: 1 ether}(orderId, seller, 86400, 604800, false, 0);

        // 2. Seller commits with counter-escrow
        vm.prank(seller);
        escrow.sellerCommitEscrow{value: 1 ether}(orderId);

        // 3. [Goods delivered off-chain with tracking]

        // 4. Buyer claims counter-escrow
        vm.prank(buyer);
        uint256 claimedAmount = escrow.buyerClaimCounterEscrow(orderId);
        assertEq(claimedAmount, 1 ether);

        // 5. Seller claims payment
        vm.prank(seller);
        escrow.sellerClaimPayment(orderId);

        // Verify balances
        assertEq(buyer.balance, 10 ether); // Got counter-escrow back
        assertEq(seller.balance, 10 ether); // Got payment
    }

    function testCompletePizzaDeliveryFlow() public {
        bytes32 orderId = keccak256("pizza-order");

        // 1. Buyer creates escrow with timed release
        vm.prank(buyer);
        escrow.createEscrow{value: 0.03 ether}(orderId, seller, 1800, 7200, true, 3600);

        // 2. Seller commits with signature
        bytes memory signature = new bytes(65);
        vm.prank(seller);
        escrow.sellerCommitSignature(
            orderId, signature, "Pizza Hut #4521", "LICENSE-789", keccak256("order-details")
        );

        // 3. [Pizza delivered off-chain]

        // 4. Fast forward 1 hour and trigger timed release
        vm.warp(block.timestamp + 5401);
        escrow.triggerTimedRelease(orderId);

        // Verify seller received payment automatically
        assertEq(seller.balance, 10.03 ether);
    }
}