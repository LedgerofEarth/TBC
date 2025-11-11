use serde::{Deserialize, Serialize};

/// Whether and how the Buyer is requesting ZK / CoreProver involvement.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "UPPERCASE")]
pub enum ZkProfile {
    None,
    Optional,
    Required,
}

/// Who is reporting settlement back to the Controller.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "kebab-case")]
pub enum SettleSource {
    /// Buyer (or its local agent/extension) notifying the controller.
    BuyerNotify,
    /// Controller inferred settlement via its own CoreProver watcher / indexer.
    ControllerWatcher,
    /// Some external CoreProver indexer notifying the controller.
    CoreproverIndexer,
}

/// Minimal economic envelope information for Stage-1.
/// Later this can expand to multi-asset, slippage, regulatory constraints, etc.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct EconomicEnvelope {
    /// Maximum total fees in basis points (e.g. 50 = 0.50%).
    pub max_fees_bps: u32,
    /// Optional expiry time (RFC3339) after which the offer is no longer valid.
    pub expiry: Option<String>,
}

/// Stage-1 TGP messages.
///
/// These are JSON-encoded and sent either over HTTP (to the Controller)
/// or embedded in other protocols (e.g. x402 metadata) in later stages.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(tag = "phase", rename_all = "UPPERCASE")]
pub enum TgpMessage {
    /// Buyer asks a Controller for a route / envelope, usually after receiving a 402.
    Query {
        id: String,
        from: String,
        to: String,
        asset: String,
        amount: u64,

        /// Whether the 402 explicitly requested escrow/CoreProver.
        escrow_from_402: bool,

        /// CoreProver contract address advertised in the 402, if any.
        escrow_contract_from_402: Option<String>,

        /// Buyer's preference for ZK / CoreProver involvement.
        zk_profile: ZkProfile,
    },

    /// Controller responds with route / envelope and optional CoreProver details.
    Offer {
        id: String,
        /// Correlates back to the original QUERY id.
        query_id: String,
        asset: String,
        amount: u64,

        /// CoreProver contract to use for escrow (if any).
        coreprover_contract: Option<String>,

        /// Session or route id to be provided to CoreProver onchain.
        session_id: Option<String>,

        /// Whether ZK/CoreProver use is required under policy.
        zk_required: bool,

        /// Basic economic envelope for this offer.
        economic_envelope: EconomicEnvelope,
    },

    /// Settlement report back to the Controller.
    ///
    /// This can be sent by the Buyer, an indexer, or synthesized by the Controller
    /// itself when it observes CoreProver events.
    Settle {
        id: String,

        /// Correlates this settlement back to a QUERY or OFFER.
        query_or_offer_id: String,

        /// Whether settlement ultimately succeeded.
        success: bool,

        /// Who is telling the Controller about this settlement.
        source: SettleSource,

        /// Optional Layer-8 transaction hash (CoreProver tx, x402 session id, etc.).
        layer8_tx: Option<String>,

        /// Optional session id that was used with CoreProver, if known.
        session_id: Option<String>,
    },

    /// Generic error around processing QUERY/OFFER/SETTLE on the control plane.
    Error {
        id: String,
        code: String,
        message: String,
        /// Correlation id (e.g. original QUERY or OFFER id), if applicable.
        correlation_id: Option<String>,
    },
}

#[derive(thiserror::Error, Debug)]
pub enum TgpError {
    #[error("invalid utf-8 in TGP message: {0}")]
    Utf8(#[from] std::str::Utf8Error),

    #[error("JSON parse error in TGP message: {0}")]
    Json(#[from] serde_json::Error),
}

/// Parse a TGP message from bytes (JSON for Stage-1).
pub fn parse_message(raw: &[u8]) -> Result<TgpMessage, TgpError> {
    let s = std::str::from_utf8(raw)?;
    let msg: TgpMessage = serde_json::from_str(s)?;
    Ok(msg)
}

/// Encode a TGP message to bytes (JSON for Stage-1).
pub fn encode_message(msg: &TgpMessage) -> Result<Vec<u8>, TgpError> {
    let json = serde_json::to_vec(msg)?;
    Ok(json)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn roundtrip_query_message() {
        let msg = TgpMessage::Query {
            id: "q-1".into(),
            from: "buyer://alice".into(),
            to: "seller://bob".into(),
            asset: "USDC".into(),
            amount: 42,
            escrow_from_402: true,
            escrow_contract_from_402: Some("0xCoreProver".into()),
            zk_profile: ZkProfile::Required,
        };

        let bytes = encode_message(&msg).expect("encode should succeed");
        let parsed = parse_message(&bytes).expect("parse should succeed");

        assert_eq!(msg, parsed);
    }
}