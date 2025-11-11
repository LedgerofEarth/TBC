# CoreProver Makefile

.PHONY: help build test clean docker-up docker-down deploy-local

help:
	@echo "Available targets:"
	@echo "  build         - Build all workspace crates"
	@echo "  test          - Run all tests"
	@echo "  contracts     - Build and test contracts"
	@echo "  docker-up     - Start Docker services"
	@echo "  docker-down   - Stop Docker services"
	@echo "  deploy-local  - Deploy to local Anvil"
	@echo "  clean         - Clean build artifacts"

build:
	cargo build --workspace

test:
	cargo test --workspace
	cd crates/coreprover-contracts && forge test

contracts:
	cd crates/coreprover-contracts && forge build && forge test -vvv

docker-up:
	docker-compose -f docker/docker-compose.dev.yml up -d

docker-down:
	docker-compose -f docker/docker-compose.dev.yml down

deploy-local: docker-up
	@echo "Waiting for Anvil..."
	@sleep 5
	cd crates/coreprover-contracts && forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast

clean:
	cargo clean
	cd crates/coreprover-contracts && forge clean

fmt:
	cargo fmt --all
	cd crates/coreprover-contracts && forge fmt

lint:
	cargo clippy --workspace --all-features -- -D warnings

docs:
	cargo doc --workspace --no-deps --open
