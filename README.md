# Transaction Border Controller (TBC) Monorepo

**Organization:** Ledger of Earth  
**Version:** 0.1-draft  
**Status:** Active Development  

—

## Overview

This monorepo houses both the **protocol specifications** and the **reference implementation**
for the **Transaction Border Controller (TBC)** — a Layer-8 appliance that routes and enforces
policy for cross-ledger settlements using the **Transaction Gateway Protocol (TGP-00)** and
related standards.

The TBC functions as the **economic control plane** for blockchain systems, analogous to a
Session Border Controller in telecom architecture.

—

## Directory Layout

| Path | Purpose |
|——|-———|
| `specs/` | Normative specifications (TxIP-00, TGP-00, X402-EXT, appendices). |
| `src/controller/` | Rust implementation of the Transaction Border Controller appliance. |
| `src/coreprover/` | CoreProver library for escrow and proof-of-settlement receipts. |
| `tests/` | Integration and simulation harnesses. |
| `docs/` | Architecture, system topology, roadmap, and context for AI agents. |
| `.anthropic/` | AI agent configuration for Claude MCP and related tools. |

—

## Build Instructions

```bash
# Build everything
cargo build

# Run the controller (development mode)
cargo run --package controller

# Run tests
cargo test --workspace

#Controller Messaging Tests/Demo.

1.Open Codespace and from the terminal;

2.Start the controller.

cargo run —package controller

3. Send a QUERY message to the controller

curl -X POST http://127.0.0.1:8080/tgp \
  -H “Content-Type: application/json” \
  -d ‘{
    “phase”: “QUERY”,
    “id”: “q-demo001”,
    “from”: “buyer://alice.wallet”,
    “to”: “seller://bob.service”,
    “asset”: “USDC”,
    “amount”: 1000000,
    “escrow_from_402”: true,
    “escrow_contract_from_402”: “0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb”,
    “zk_profile”: “OPTIONAL”
  }’
  
  4. Observe the OFFER is returned from the Controller
  
  {
  “phase”: “OFFER”,
  “id”: “offer-demo001”,
  “query_id”: “q-demo001”,
  “asset”: “USDC”,
  “amount”: 1000000,
  “coreprover_contract”: “0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb”,
  “session_id”: “sess-demo001”,
  “zk_required”: false,
  “economic_envelope”: { “max_fees_bps”: 50, “expiry”: “2025-11-10T23:59:59Z” } 
}

  5. Send a TGP.SETTLE Message.
  
curl -X POST http://127.0.0.1:8080/tgp \
  -H “Content-Type: application/json” \
  -d ‘{
    “phase”: “SETTLE”,
    “id”: “settle-demo001”,
    “query_or_offer_id”: “offer-demo001”,
    “success”: true,
    “source”: “buyer-notify”,
    “layer8_tx”: “0xDEADBEEF”,
    “session_id”: “sess-demo001”
  }’ 
  
   6. Observe the Ok response from the Controller.