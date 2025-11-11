//! REST API client example

use anyhow::Result;
use serde::{Deserialize, Serialize};

#[derive(Serialize)]
struct CreateEscrowRequest {
    seller: String,
    amount: String,
}

#[derive(Deserialize)]
struct CreateEscrowResponse {
    order_id: String,
    tx_hash: String,
}

#[derive(Deserialize)]
struct HealthResponse {
    status: String,
    version: String,
}

#[tokio::main]
async fn main() -> Result<()> {
    let client = reqwest::Client::new();
    let base_url = "http://localhost:3000";
    
    println!("Checking service health...");
    let health: HealthResponse = client
        .get(format!("{}/health", base_url))
        .send()
        .await?
        .json()
        .await?;
    
    println!("✓ Service status: {}", health.status);
    println!("  Version: {}\n", health.version);
    
    println!("Creating escrow...");
    let request = CreateEscrowRequest {
        seller: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb".to_string(),
        amount: "0.1".to_string(),
    };
    
    let response: CreateEscrowResponse = client
        .post(format!("{}/escrow", base_url))
        .json(&request)
        .send()
        .await?
        .json()
        .await?;
    
    println!("✓ Escrow created!");
    println!("  Order ID: {}", response.order_id);
    println!("  Tx Hash:  {}", response.tx_hash);
    
    Ok(())
}
