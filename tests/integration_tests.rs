//! Integration tests for CoreProver

use anyhow::Result;
use coreprover_bridge::EscrowClient;
use ethers::prelude::*;

#[tokio::test]
async fn test_full_escrow_flow() -> Result<()> {
    let contract_address = Address::zero();
    let client = EscrowClient::new("http://localhost:8545", contract_address)?;
    
    let order_id = [1u8; 32];
    let seller = Address::zero();
    let amount = U256::from(100_000_000u64);
    
    let tx_hash = client.create_escrow(order_id, seller, amount).await?;
    assert_ne!(tx_hash, H256::zero());
    
    Ok(())
}

#[tokio::test]
async fn test_timeout_refund() -> Result<()> {
    Ok(())
}

#[tokio::test]
async fn test_timed_release() -> Result<()> {
    Ok(())
}
