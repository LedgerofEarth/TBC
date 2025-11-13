//! CoreProver ZK - Zero-knowledge proof system

pub mod prover;
pub mod verifier;
<<<<<<< HEAD
pub mod zk_types;

pub use prover::Prover;
pub use verifier::Verifier;
pub use zk_types::{ZkBuyerInput, ZkSellerInput, ZkExchangeInput};
=======

pub use prover::Prover;
pub use verifier::Verifier;
>>>>>>> 91b50d73d4571279b7f8ff3180229bf2c1579c57

/// ZK module version
pub const VERSION: &str = env!("CARGO_PKG_VERSION");

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_version() {
        assert!(!VERSION.is_empty());
    }
}