//! Simple integration example

use anyhow::Result;
use coreprover_sdk::EscrowBuilder;

#[tokio::main]
async fn main() -> Result<()> {
    println!("Simple CoreProver Integration Example\n");
    
    let escrow = EscrowBuilder::new()
        .with_buyer("0x1111111111111111111111111111111111111111")
        .with_seller("0x2222222222222222222222222222222222222222")
        .with_amount(100_000_000)
        .build()
        .await?;
    
    println!("✓ Escrow created successfully!");
    println!("  Buyer:  {}", escrow.buyer);
    println!("  Seller: {}", escrow.seller);
    println!("  Amount: {} USDC", escrow.amount as f64 / 1_000_000.0);
    
    Ok(())
}
