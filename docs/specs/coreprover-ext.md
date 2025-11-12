# TGP Extension: CoreProver Redirection (`coreprover-ext.md`)

**Status:** Draft  
**Author:** Ledger of Earth  
**Version:** 0.1  
**Last Updated:** 2025-11-09  

---

## Overview

This extension allows buyers or agents to suggest an alternate CoreProver escrow contract for settlement, rather than using the default contract bound to the TBC's local domain.

The pattern is inspired by SIP media redirection: signaling and negotiation occur via the TBC, but value settlement may be delegated to a trusted third-party escrow contract (CoreProver).

---

## New Field: `coreprover_hint`

```json
{
  "coreprover_hint": "coreprover.ledgerofearth.eth"
}
```

- Can be an ENS name, contract address, or metadata URI
- Resolved by the TBC during the `SessionInit` phase
- Optional: default is domain-local CoreProver

---

## Resolution & Policy Controls

TBCs may:
- **Accept** the redirect (if policy allows)
- **Override** with their own escrow contract
- **Reject** the session with an error

Policy checks may include:
- Allowlist of ENS names or addresses
- Signature binding or proof-of-trust
- Geo/domain restrictions
- Rate limiting

Example PEL snippet:

```pel
ALLOW coreprover_hint IF domain in ["ledgerofearth.eth", "coinbase.eth"] AND payment_profile == "pizza-v1"
```

---

## Receipt Binding

The receipt NFT and TDR metadata **must reflect the actual CoreProver contract used**, including:
- Contract address
- Version hash
- Settlement results

---

## ZK Implications

- Buyer proofs may need to commit to the `coreprover_contract` field
- Circuits should include `contract_address` as public input

---

## Security Considerations

- Prevent misuse via unknown contracts (require registration)
- Validate that contracts follow CoreProver ABI
- Limit redirection scope to prevent phishing or exfiltration

---

## Future Work

- SDK fallback behavior
- Multi-hop settlement delegation
- Inter-CoreProver receipt verification
