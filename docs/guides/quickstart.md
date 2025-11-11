# Quick Start Guide

## Prerequisites

- Rust 1.75+
- Foundry
- Docker & Docker Compose

## Step 1: Clone and Build

```bash
git clone <repo-url>
cd transaction-border-controller
cargo build --workspace
```

## Step 2: Start Local Environment

```bash
./scripts/setup-dev.sh
```

## Step 3: Deploy Contracts

```bash
cd crates/coreprover-contracts
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

## Step 4: Start the Service

```bash
cargo run -p coreprover-service
```

## Step 5: Create Your First Escrow

```bash
coreprover escrow create --seller 0xSeller... --amount 0.1
```
