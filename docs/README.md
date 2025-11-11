# CoreProver Documentation

Complete documentation for the Transaction Border Controller (TBC) with CoreProver integration.

## Documentation Structure

- **[Specifications](specs/)** - Technical specifications and architecture
- **[Guides](guides/)** - Step-by-step tutorials and deployment guides
- **[API Documentation](api/)** - REST API and contract interface documentation

## Quick Links

- [Quick Start Guide](guides/quickstart.md)
- [Architecture Overview](specs/architecture.md)
- [CoreProver Specification](specs/coreprover.md)
- [Deployment Guide](guides/deployment.md)
- [API Reference](api/README.md)

## Core Concepts

### Dual-Commitment Model

Both buyer and seller must commit before any claims are possible.

### No Buyer Acknowledgment

Seller can claim payment without buyer confirmation.

### Privacy-First Receipts

Receipt NFTs stay in immutable vault, accessed via ZK proofs.
