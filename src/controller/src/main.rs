mod config;
mod controller;
mod tgp;
mod prover_client;
mod x402_adapter;
mod telemetry;

use anyhow::Result;
use axum::{
    extract::State,
    http::StatusCode,
    routing::{get, post},
    Json, Router,
};
use serde_json::json;
use std::{net::SocketAddr, sync::Arc};
use tokio::net::TcpListener;
use tracing_subscriber::EnvFilter;

use controller::Controller;
use tgp::TgpMessage;

#[derive(Clone)]
struct AppState {
    controller: Controller,
}

#[tokio::main]
async fn main() -> Result<()> {
    // Initialize tracing / logging
    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env())
        .init();

    tracing::info!("Starting Transaction Border Controller...");

    // Load configuration and initialize controller
    let cfg = config::ControllerConfig::default();
    let ctrl = Controller::new(cfg.clone());

    let state = Arc::new(AppState { controller: ctrl });

    // Routes:
    // - GET  /healthz        -> "ok"
    // - POST /tgp/query      -> TGP QUERY -> OFFER
    // - POST /tgp/settle     -> TGP SETTLE notification
    let app = Router::new()
        .route("/healthz", get(|| async { "ok" }))
        .route("/tgp/query", post(handle_tgp_query))
        .route("/tgp/settle", post(handle_tgp_settle))
        .with_state(state);

    // Bind listener and start serving
    let addr: SocketAddr = cfg.listen_addr.parse()?;
    let listener = TcpListener::bind(addr).await?;
    tracing::info!("Controller listening on {}", listener.local_addr()?);

    axum::serve(listener, app).await?;

    Ok(())
}

async fn handle_tgp_query(
    State(state): State<Arc<AppState>>,
    Json(msg): Json<TgpMessage>,
) -> Result<Json<TgpMessage>, (StatusCode, String)> {
    match msg {
        TgpMessage::Query { .. } => {
            let offer = state
                .controller
                .handle_query(&msg)
                .map_err(|e| (StatusCode::BAD_REQUEST, e.to_string()))?;
            Ok(Json(offer))
        }
        _ => Err((
            StatusCode::BAD_REQUEST,
            "expected TGP message with phase=QUERY".to_string(),
        )),
    }
}

async fn handle_tgp_settle(
    State(state): State<Arc<AppState>>,
    Json(msg): Json<TgpMessage>,
) -> Result<Json<serde_json::Value>, (StatusCode, String)> {
    match msg {
        TgpMessage::Settle { .. } => {
            state
                .controller
                .handle_settle(&msg)
                .map_err(|e| (StatusCode::BAD_REQUEST, e.to_string()))?;

            Ok(Json(json!({
                "status": "ok",
                "phase": "SETTLE"
            })))
        }
        _ => Err((
            StatusCode::BAD_REQUEST,
            "expected TGP message with phase=SETTLE".to_string(),
        )),
    }
}