use crate::config::ControllerConfig;
use crate::tgp::{EconomicEnvelope, SettleSource, TgpMessage, ZkProfile};

#[derive(Clone, Debug)]
pub struct Controller {
    pub config: ControllerConfig,
}

impl Controller {
    pub fn new(config: ControllerConfig) -> Self {
        Self { config }
    }

    /// Handle a TGP QUERY and synthesize a simple OFFER.
    ///
    /// Stage-1 behavior:
    /// - Echoes basic asset/amount.
    /// - Copies escrow contract from 402 if present.
    /// - Mints a synthetic session_id.
    /// - Sets zk_required based on requested profile.
    pub fn handle_query(&self, msg: &TgpMessage) -> Result<TgpMessage, ControllerError> {
        let (id, asset, amount, escrow_contract_from_402, zk_profile) = match msg {
            TgpMessage::Query {
                id,
                asset,
                amount,
                escrow_contract_from_402,
                zk_profile,
                ..
            } => (id, asset, amount, escrow_contract_from_402, zk_profile),
            _ => {
                return Err(ControllerError::WrongPhase(
                    "expected QUERY message".to_string(),
                ))
            }
        };

        let offer_id = format!("offer-{}", id);
        let session_id = Some(format!("sess-{}", id));

        let zk_required = matches!(zk_profile, ZkProfile::Required);

        let env = EconomicEnvelope {
            max_fees_bps: 50, // 0.50% as placeholder
            expiry: None,     // Stage-1: no explicit expiry
        };

        let offer = TgpMessage::Offer {
            id: offer_id,
            query_id: id.clone(),
            asset: asset.clone(),
            amount: *amount,
            coreprover_contract: escrow_contract_from_402.clone(),
            session_id,
            zk_required,
            economic_envelope: env,
        };

        tracing::info!(
            query_id = %id,
            "synthesized OFFER for TGP QUERY"
        );

        Ok(offer)
    }

    /// Handle a TGP SETTLE notification.
    ///
    /// Stage-1 behavior:
    /// - Logs the settlement.
    /// - In future stages, will update routing/telemetry state.
    pub fn handle_settle(&self, msg: &TgpMessage) -> Result<(), ControllerError> {
        match msg {
            TgpMessage::Settle {
                id,
                query_or_offer_id,
                success,
                source,
                layer8_tx,
                session_id,
            } => {
                tracing::info!(
                    settle_id = %id,
                    correlation = %query_or_offer_id,
                    %success,
                    ?source,
                    ?layer8_tx,
                    ?session_id,
                    "received TGP SETTLE"
                );
                Ok(())
            }
            _ => Err(ControllerError::WrongPhase(
                "expected SETTLE message".to_string(),
            )),
        }
    }
}

#[derive(thiserror::Error, Debug)]
pub enum ControllerError {
    #[error("wrong TGP phase for this handler: {0}")]
    WrongPhase(String),
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::tgp::{TgpMessage, ZkProfile};

    #[test]
    fn handle_tgp_query_smoke_test() {
        let cfg = ControllerConfig::default();
        let ctrl = Controller::new(cfg);

        let query = TgpMessage::Query {
            id: "q-test".into(),
            from: "buyer://alice".into(),
            to: "seller://bob".into(),
            asset: "USDC".into(),
            amount: 100,
            escrow_from_402: true,
            escrow_contract_from_402: Some("0xCoreProver".into()),
            zk_profile: ZkProfile::Optional,
        };

        let offer = ctrl
            .handle_query(&query)
            .expect("controller should handle basic QUERY");

        match offer {
            TgpMessage::Offer { query_id, .. } => {
                assert_eq!(query_id, "q-test");
            }
            _ => panic!("expected OFFER message"),
        }
    }
}