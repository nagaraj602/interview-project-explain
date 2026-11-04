# Marketplace Risk Detection Platform - Terraform Infrastructure

Production-ready, highly available, and security-hardened Infrastructure as Code (IaC) for an enterprise Marketplace Risk Detection Platform on AWS.

## Architecture & Design Documentation
Detailed architectural specifications, networking topologies, and operational upgrade runbooks are documented in [ARCHITECTURE.md](ARCHITECTURE.md).

## Codebase Organization
Cost-optimized 2-Cluster architecture with directory-based environment separation:

```
.
├── ARCHITECTURE.md                  # Complete architectural & operational specification
├── environments/
│   ├── bootstrap/                   # Independent state backend provisioning (S3 + KMS)
│   ├── nonprod/                     # Consolidated Dev + Staging cluster (Single NAT GW, Spot nodes, K8s namespace isolation)
│   └── prod/                        # Dedicated Production cluster (3-AZ Multi-NAT HA, Multi-AZ RDS)
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

### 2. Bootstrap Remote S3 Backend Buckets
To resolve the chicken-and-egg dependency, provision the remote state buckets and KMS keys first:
```bash
cd environments/bootstrap
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 3. Initialize and Validate an Environment
```bash
cd ../prod
terraform init -backend=false
terraform validate
```

### 4. Deploy with Terraform 1.10+ Native Locking
Once backend buckets exist, initialize the remote backend and deploy:
```bash
cd ../prod
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```
*(State locking is automatically handled natively by Amazon S3 via `use_lockfile = true` in `backend.tf` without requiring DynamoDB).*
