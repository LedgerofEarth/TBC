# CoreProver Specification

## Overview

CoreProver is a dual-commitment escrow settlement layer.

## Core Design Principles

### 1. Dual-Commitment Security

Claims only unlock when BOTH parties commit.

### 2. Seller Commitment Options

**Option A: Counter-Escrow**
- Seller locks matching funds

**Option B: Legal Signature**
- No funds locked
- Legally-binding signature

### 3. Payment Profiles

Seller-defined transaction parameters.

## Settlement Flows

### Flow 1: Digital Goods
1. Buyer commits
2. Seller commits
3. Instant delivery
4. Seller claims

### Flow 2: Physical Goods
1. Buyer commits
2. Seller counter-escrow
3. Tracking submitted
4. Delivery
5. Claims processed

### Flow 3: Timed Release
1. Buyer commits
2. Seller commits
3. Service performed
4. Auto-release after timer
