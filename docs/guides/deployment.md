# Deployment Guide

## Production Deployment Checklist

- [ ] Security audit completed
- [ ] All tests passing
- [ ] Monitoring configured

## Contract Deployment

```bash
export PRIVATE_KEY="..."
export RPC_URL="https://rpc.pulsechain.com"

forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast --verify
```

## Service Deployment

```bash
docker build -f docker/Dockerfile.service -t coreprover-service:latest .
docker-compose -f docker/docker-compose.yml up -d
```

## Verify Deployment

```bash
curl http://your-domain.com/health
```
