//! Escrow type definitions

use ethers::prelude::*;
use serde::{Deserialize, Serialize};
<<<<<<< HEAD
use ethers::types::Address;
=======
>>>>>>> 91b50d73d4571279b7f8ff3180229bf2c1579c57

/// Escrow state enum
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum EscrowState {
    None,
    BuyerCommitted,
    SellerCommitted,
    BothCommitted,
    SellerClaimed,
    BuyerClaimed,
    BothClaimed,
    Disputed,
    Expired,
<<<<<<< HEAD
    Settled,
    Cancelled,
=======
>>>>>>> 91b50d73d4571279b7f8ff3180229bf2c1579c57
}

impl Default for EscrowState {
    fn default() -> Self {
        Self::None
    }
}

<<<<<<< HEAD
/// Escrow mode enum — determines if it's a simple purchase or mutual swap
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum EscrowMode {
    Purchase, // One-sided: buyer → seller
    Swap,     // Two-sided: buyer ↔ seller
}

impl Default for EscrowMode {
    fn default() -> Self {
        Self::Purchase
    }
}

/// Escrow structure
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Escrow {
    pub order_id: [u8; 32],          // External system reference
=======
/// Escrow structure
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Escrow {
>>>>>>> 91b50d73d4571279b7f8ff3180229bf2c1579c57
    pub buyer: Address,
    pub seller: Address,
    pub buyer_amount: U256,
    pub seller_amount: U256,
    pub state: EscrowState,
<<<<<<< HEAD
    pub mode: EscrowMode,
=======
>>>>>>> 91b50d73d4571279b7f8ff3180229bf2c1579c57
    pub created_at: u64,
}

impl Default for Escrow {
    fn default() -> Self {
        Self {
<<<<<<< HEAD
            order_id: [0u8; 32],
=======
>>>>>>> 91b50d73d4571279b7f8ff3180229bf2c1579c57
            buyer: Address::zero(),
            seller: Address::zero(),
            buyer_amount: U256::zero(),
            seller_amount: U256::zero(),
            state: EscrowState::None,
<<<<<<< HEAD
            mode: EscrowMode::default(),
=======
>>>>>>> 91b50d73d4571279b7f8ff3180229bf2c1579c57
            created_at: 0,
        }
    }
}