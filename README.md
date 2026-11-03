# Marketplace Risk Detection Platform - Terraform Infrastructure

Production-ready, highly available, and security-hardened Infrastructure as Code (IaC) for an enterprise Marketplace Risk Detection Platform on AWS.

## Architecture & Design Documentation
Detailed architectural specifications, networking topologies, and operational upgrade runbooks are documented in [ARCHITECTURE.md](ARCHITECTURE.md).

## Codebase Organization
Directory-based environment separation utilizing standardized modules:

```
.
├── ARCHITECTURE.md                  # Complete architectural & operational specification
├── environments/
│   ├── dev/                         # Development environment (single NAT GW, scalable sizing)
│   ├── staging/                     # Staging environment (pre-production parity)
│   └── prod/                        # Production environment (full 3-AZ Multi-NAT HA)
└── modules/
    ├── s3-backend/                  # Terraform 1.10+ native S3 state locking (No DynamoDB)
    ├── vpc/                         # 3-tier subnets across 3 AZs, NAT GWs, Flow Logs, locked SG
    ├── eks/                         # Private EKS 1.35, zero-downtime rolling node groups, IRSA
    ├── rds/                         # Multi-AZ Postgres 16, 14-day PITR, autoscaling, Secrets Manager
    └── iam-secrets/                 # CI/CD deployment credentials & scoped IAM Instance Profile
```

## Quick Start & Verification

### 1. Validate Formatting & Syntax
```bash
terraform fmt -check -recursive
```

### 2. Initialize and Validate an Environment
```bash
cd environments/prod
terraform init -backend=false
terraform validate
```

### 3. Deploy with Terraform 1.10+ Native Locking
```bash
cd environments/prod
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```
*(State locking is automatically handled natively by Amazon S3 via `use_lockfile = true` without requiring DynamoDB).*
