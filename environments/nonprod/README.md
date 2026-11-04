# Non-Production Environment (Dev + Staging Consolidated)

## Overview
This environment implements the **Cost-Optimized 2-Cluster Architecture** for the Marketplace Risk Detection Platform.

Instead of provisioning two separate expensive EKS clusters and duplicate VPC NAT Gateways for `dev` and `staging`, both environments share:
1. **1 Shared VPC Network (`10.10.0.0/16`)** with a single NAT Gateway (saving ~$130/month vs multi-NAT).
2. **1 Shared EKS Kubernetes Cluster (`nonprod-risk-eks`)** running on Kubernetes v1.35 and utilizing Spot instances (saving ~$73/month control plane fee + up to 70% EC2 instance costs).

## Logical Separation in Kubernetes
Workloads are logically isolated using Kubernetes native controls:
* **Namespaces**:
  * `risk-dev`: Development workloads, testing, and continuous deployment.
  * `risk-staging`: Pre-production workloads, soak testing, and candidate builds.
* **Resource Quotas**: Hard CPU/Memory limits per namespace prevent developer runaway pods from impacting staging verification.
* **Network Policies**: Complete inter-namespace traffic blocking (pods in `risk-dev` cannot send traffic to `risk-staging`).
* **Databases**: Dedicated PostgreSQL databases (`marketplaceriskdev` and `marketplaceriskstaging`) to ensure zero database collision or schema interference.

## Directory Structure
```
environments/nonprod/
├── backend.tf                         # S3 backend pointing to marketplace-risk-tfstate-nonprod
├── versions.tf                        # Provider version constraints
├── main.tf                            # Shared VPC, consolidated EKS, Dev & Staging RDS
├── variables.tf                       # Nonprod configuration variables
├── terraform.tfvars                   # Cost-optimized defaults (Spot nodes, Single NAT GW)
├── outputs.tf                         # EKS and Database endpoints
└── k8s/
    ├── namespaces-and-quotas.yaml     # K8s namespaces, ResourceQuotas, and LimitRanges
    └── network-policies.yaml          # Zero-trust inter-namespace network policies
```

## Quick Start
```bash
# 1. Initialize and Validate
terraform init -backend=false
terraform validate

# 2. Deploy (requires bootstrap S3 backend created)
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# 3. Apply Kubernetes Namespace & Isolation Manifests
aws eks update-kubeconfig --region us-east-1 --name nonprod-risk-eks
kubectl apply -f k8s/namespaces-and-quotas.yaml
kubectl apply -f k8s/network-policies.yaml
```
