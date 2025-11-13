//! Gateway trait and implementation

use async_trait::async_trait;
use anyhow::Result;

/// Core gateway trait for TBC protocol
#[async_trait]
pub trait Gateway {
    /// Route an order through the gateway
    async fn route_order(&self, order_id: &str) -> Result<String>;
    
    /// Get gateway status
    async fn status(&self) -> Result<GatewayStatus>;
}

/// Gateway status information
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct GatewayStatus {
    pub online: bool,
    pub active_orders: usize,
    pub version: String,
}

impl Default for GatewayStatus {
    fn default() -> Self {
        Self {
            online: true,
            active_orders: 0,
            version: crate::VERSION.to_string(),
        }
<<<<<<< HEAD
    }
}
=======
 
>>>>>>> 91b50d73d4571279b7f8ff3180229bf2c1579c57
