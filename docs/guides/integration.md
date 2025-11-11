# Integration Guide

## Using the SDK

```rust
use coreprover_sdk::EscrowBuilder;

let escrow = EscrowBuilder::new()
    .with_buyer(&buyer)
    .with_seller(&seller)
    .with_amount(amount)
    .build()
    .await?;
```

## Direct Contract Integration

```rust
use coreprover_bridge::EscrowClient;

let client = EscrowClient::new(rpc_url, contract_address)?;
let tx = client.create_escrow(order_id, seller, profile).await?;
```

## REST API Integration

```javascript
const response = await fetch('http://api-url/escrow', {
  method: 'POST',
  body: JSON.stringify({ seller: '0x...', amount: '0.1' })
});
```
