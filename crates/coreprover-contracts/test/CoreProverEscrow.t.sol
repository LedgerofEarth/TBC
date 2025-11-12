// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CoreProverEscrow.sol";

contract CoreProverEscrowTest is Test {
    CoreProverEscrow public escrow;
    address public buyer = address(0x1);
    address public seller = address(0x2);

    function setUp() public {
        escrow = new CoreProverEscrow();
    }

    function testCreateEscrow() public {
        vm.deal(buyer, 1 ether);
        vm.prank(buyer);

        bytes32 orderId = keccak256("order1");
        escrow.createEscrow{value: 0.1 ether}(orderId, seller, 3600, 86400, false, 0);

        (address _buyer,,,,,,,,,) = escrow.escrows(orderId);
        assertEq(_buyer, buyer);
    }

    function testSellerCommitEscrow() public {
        vm.deal(buyer, 1 ether);
        vm.deal(seller, 1 ether);

        bytes32 orderId = keccak256("order2");

        vm.prank(buyer);
        escrow.createEscrow{value: 0.1 ether}(orderId, seller, 3600, 86400, false, 0);

        vm.prank(seller);
        escrow.sellerCommitEscrow{value: 0.1 ether}(orderId);

        (,,,, uint8 state,,,,,) = escrow.escrows(orderId);
        assertEq(state, 3); // BOTH_COMMITTED
    }

    function testSellerCommitSignature() public {
        vm.deal(buyer, 1 ether);

        bytes32 orderId = keccak256("order3");

        vm.prank(buyer);
        escrow.createEscrow{value: 0.1 ether}(orderId, seller, 3600, 86400, false, 0);

        bytes memory signature = new bytes(65);
        vm.prank(seller);
        escrow.sellerCommitSignature(
            orderId, signature, "Pizza Hut", "LICENSE-123", keccak256("terms")
        );

        (,,,, uint8 state,,,,,) = escrow.escrows(orderId);
        assertEq(state, 3); // BOTH_COMMITTED
    }

    function testSellerClaimPayment() public {
        vm.deal(buyer, 1 ether);
        vm.deal(seller, 1 ether);

        bytes32 orderId = keccak256("order4");

        vm.prank(buyer);
        escrow.createEscrow{value: 0.5 ether}(orderId, seller, 3600, 86400, false, 0);

        vm.prank(seller);
        escrow.sellerCommitEscrow{value: 0.5 ether}(orderId);

        uint256 balanceBefore = seller.balance;

        vm.prank(seller);
        escrow.sellerClaimPayment(orderId);

        assertEq(seller.balance, balanceBefore + 0.5 ether);
    }

    function testRefundBuyerTimeout() public {
        vm.deal(buyer, 1 ether);

        bytes32 orderId = keccak256("order5");

        vm.prank(buyer);
        escrow.createEscrow{value: 0.1 ether}(orderId, seller, 3600, 86400, false, 0);

        // Fast forward past commitment deadline
        vm.warp(block.timestamp + 3601);

        uint256 balanceBefore = buyer.balance;

        escrow.refundBuyerTimeout(orderId);

        assertEq(buyer.balance, balanceBefore + 0.1 ether);
    }

    function testTimedRelease() public {
        vm.deal(buyer, 1 ether);

        bytes32 orderId = keccak256("order6");

        vm.prank(buyer);
        escrow.createEscrow{value: 0.1 ether}(orderId, seller, 1800, 86400, true, 3600);

        bytes memory signature = new bytes(65);
        vm.prank(seller);
        escrow.sellerCommitSignature(
            orderId, signature, "Pizza Hut", "LICENSE-123", keccak256("terms")
        );

        // Fast forward past timed release
        vm.warp(block.timestamp + 5401);

        uint256 balanceBefore = seller.balance;

        escrow.triggerTimedRelease(orderId);

        assertEq(seller.balance, balanceBefore + 0.1 ether);
    }
}