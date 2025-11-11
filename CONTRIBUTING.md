# Contributing to CoreProver

Thank you for your interest in contributing!

## Development Setup

1. Fork the repository
2. Clone your fork
3. Install dependencies
4. Run tests

```bash
git clone your-fork-url
cd transaction-border-controller
cargo build --workspace
cargo test --workspace
```

## Code Style

- Run `cargo fmt` before committing
- Run `cargo clippy` and fix warnings
- Write tests for new features
- Update documentation

## Pull Request Process

1. Create a feature branch
2. Make your changes
3. Add tests
4. Update documentation
5. Submit PR with clear description

## Commit Messages

Use conventional commits:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `test:` Tests
- `refactor:` Code refactoring

## Testing

```bash
# Rust tests
cargo test --workspace

# Contract tests
cd crates/coreprover-contracts
forge test -vvv

# Integration tests
cargo test --test integration_tests
```
