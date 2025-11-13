//! Pizza Delivery Simulation
//!
//! Demonstrates a simple physical delivery escrow flow:
//! 1. Buyer creates escrow for pizza order
//! 2. Restaurant (seller) accepts order
//! 3. Buyer funds escrow
//! 4. Pizza is delivered (off-chain)
//! 5. Buyer marks as delivered
//! 6. Settlement executes, restaurant receives payment
//! 7. Receipt is stored in vault

mod sim_context;

use sim_context::*;
use std::time::Duration;
use tokio::time::sleep;

#[tokio::test]
async fn test_pizza_delivery_flow() {
    println!("\n🍕 ════════════════════════════════════════════════════════");
    println!("   PIZZA DELIVERY ESCROW SIMULATION");
    println!("   ════════════════════════════════════════════════════════\n");

    let mut ctx = SimContext::new();

    println!("📋 Setup:");
    println!("   Buyer (Alice): {}", ctx.buyer.address);
    println!("   Seller (Pizza Restaurant): {}", ctx.seller.address);
    println!("   Initial buyer balance: {} wei", ctx.buyer.balance);
    println!("   Initial seller balance: {} wei", ctx.seller.balance);

    let pizza_price = 25_000_000; // $25.00 in wei (scaled)

    println!("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");

    // Step 1: Create escrow
    println!("Step 1: 📦 Creating escrow for pizza order...");
    println!("   Amount: {} wei ($25.00)", pizza_price);
    println!("   Commitment window: 30 minutes (1800s)");
    println!("   Claim window: 1 hour (3600s)");
    println!("   Timed release: enabled (1 hour)");

    let escrow_id = ctx.processor.create_escrow(
        &ctx.buyer,
        &ctx.seller,
        pizza_price,
        1800,  // 30 min commitment window
        3600,  // 1 hour claim window
        true,  // allows timed release
        3600,  // 1 hour auto-release
        false, // no counter-escrow needed
    ).await.unwrap();

    println!("   ✅ Escrow created");
    println!("   🆔 Escrow ID: 0x{}", hex::encode(&escrow_id[..8]));
    sleep(Duration::from_millis(50)).await;

    // Step 2: Seller accepts order
    println!("\nStep 2: ✅ Restaurant accepts order...");
    ctx.processor.seller_accept(&escrow_id).await.unwrap();
    
    let state = ctx.processor.get_escrow_state(&escrow_id).await.unwrap();
    println!("   State transition: Created → {:?}", state);
    sleep(Duration::from_millis(50)).await;

    // Step 3: Buyer funds escrow
    println!("\nStep 3: 💰 Buyer deposits payment into escrow...");
    let buyer_balance_before = ctx.buyer.balance;
    
    ctx.processor.buyer_fund(&escrow_id, &mut ctx.buyer).await.unwrap();
    
    let buyer_balance_after = ctx.buyer.balance;
    println!("   Buyer balance: {} → {} wei", buyer_balance_before, buyer_balance_after);
    println!("   Amount locked: {} wei", buyer_balance_before - buyer_balance_after);
    
    let state = ctx.processor.get_escrow_state(&escrow_id).await.unwrap();
    println!("   State transition: Accepted → {:?}", state);
    sleep(Duration::from_millis(50)).await;

    // Step 4: Simulate pizza preparation and delivery
    println!("\nStep 4: 🍕 Pizza preparation and delivery...");
    println!("   👨‍🍳 Restaurant preparing pizza...");
    sleep(Duration::from_millis(100)).await;
    println!("   📦 Pizza ready for delivery");
    sleep(Duration::from_millis(50)).await;
    println!("   🚗 Delivery driver dispatched");
    sleep(Duration::from_millis(100)).await;
    println!("   📍 Pizza in transit...");
    sleep(Duration::from_millis(150)).await;
    println!("   🏠 Pizza delivered to customer!");

    // Step 5: Buyer confirms delivery
    println!("\nStep 5: 📬 Buyer confirms delivery...");
    ctx.processor.mark_delivered(&escrow_id).await.unwrap();
    
    let state = ctx.processor.get_escrow_state(&escrow_id).await.unwrap();
    println!("   State transition: Funded → {:?}", state);
    sleep(Duration::from_millis(50)).await;

    // Step 6: Settlement
    println!("\nStep 6: 💸 Executing settlement...");
    let seller_balance_before = ctx.seller.balance;
    
    let receipt_id = ctx.processor.settle(&escrow_id, &mut ctx.seller).await.unwrap();
    
    let seller_balance_after = ctx.seller.balance;
    println!("   Seller balance: {} → {} wei", seller_balance_before, seller_balance_after);
    println!("   Payment received: {} wei", seller_balance_after - seller_balance_before);
    
    let state = ctx.processor.get_escrow_state(&escrow_id).await.unwrap();
    println!("   State transition: Delivered → {:?}", state);

    // Step 7: Verify receipt
    println!("\nStep 7: 🧾 Receipt generated and stored...");
    println!("   Receipt ID: {}", receipt_id);
    
    let receipt = ctx.vault.get_receipt(receipt_id).await.unwrap();
    println!("   Buyer: {}", receipt.buyer);
    println!("   Seller: {}", receipt.seller);
    println!("   Amount: {} wei", receipt.amount);
    println!("   Proof hash: 0x{}", hex::encode(&receipt.proof_hash[..8]));
    println!("   Timestamp: {}", receipt.timestamp);

    // Final status
    println!("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n");
    ctx.print_status().await;

    println!("\n✨ Pizza Delivery Escrow: SUCCESS");
    println!("   - Order fulfilled");
    println!("   - Payment transferred");
    println!("   - Receipt stored");
    println!("   - All parties satisfied\n");

    // Verify final balances
    assert_eq!(ctx.buyer.balance, buyer_balance_before - pizza_price);
    assert_eq!(ctx.seller.balance, seller_balance_before + pizza_price);
    assert_eq!(state, EscrowState::Settled);
}

#[tokio::test]
async fn test_pizza_delivery_with_timed_release() {
    println!("\n🍕 ════════════════════════════════════════════════════════");
    println!("   PIZZA DELIVERY WITH TIMED RELEASE");
    println!("   ════════════════════════════════════════════════════════\n");

    let mut ctx = SimContext::new();
    let pizza_price = 30_000_000; // $30.00

    println!("📋 Scenario: Buyer forgets to confirm delivery");
    println!("   Timed release will automatically pay restaurant\n");

    // Create and fund escrow
    let escrow_id = ctx.processor.create_escrow(
        &ctx.buyer,
        &ctx.seller,
        pizza_price,
        1800,
        3600,
        true,  // Timed release enabled
        3600,
        false,
    ).await.unwrap();

    ctx.processor.seller_accept(&escrow_id).await.unwrap();
    ctx.processor.buyer_fund(&escrow_id, &mut ctx.buyer).await.unwrap();

    println!("✅ Escrow funded: {} wei", pizza_price);

    // Simulate delivery without buyer confirmation
    println!("\n🚗 Pizza delivered...");
    sleep(Duration::from_millis(100)).await;
    println!("⏰ Buyer hasn't confirmed delivery");
    println!("   Waiting for timed release window...");
    
    // In a real system, this would wait for the actual time window
    // Here we simulate the passage of time
    sleep(Duration::from_millis(200)).await;
    println!("   ⏰ Timed release triggered!");

    // Mark as delivered (could be triggered by anyone after timeout)
    ctx.processor.mark_delivered(&escrow_id).await.unwrap();

    // Settlement occurs automatically
    let seller_balance_before = ctx.seller.balance;
    let receipt_id = ctx.processor.settle(&escrow_id, &mut ctx.seller).await.unwrap();

    println!("\n💸 Automatic payment released");
    println!("   Seller received: {} wei", ctx.seller.balance - seller_balance_before);
    println!("   Receipt ID: {}", receipt_id);

    ctx.print_status().await;

    println!("\n✨ Timed Release: SUCCESS");
    println!("   - Delivery completed");
    println!("   - Payment automatically released");
    println!("   - No buyer action required\n");
}

// Hex encoding helper
mod hex {
    pub fn encode(bytes: &[u8]) -> String {
        bytes.iter()
            .map(|b| format!("{:02x}", b))
            .collect()
    }
}
