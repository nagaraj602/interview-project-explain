# Highly Available VPC Network Module

This module provisions an enterprise, multi-tier VPC spanning 3 Availability Zones designed for mission-critical risk analytics and transactional workloads.

## Key Features

- **3-Tier Subnet Topology**:
  - **Public Subnets**: Houses NAT Gateways and external Application Load Balancers. Tagged with `kubernetes.io/role/elb = 1`.
  - **Private Subnets**: Houses EKS Managed Node Groups and internal microservices. Tagged with `kubernetes.io/role/internal-elb = 1` and `karpenter.sh/discovery`.
  - **Database Subnets**: Dedicated, isolated subnets for Multi-AZ RDS PostgreSQL with no direct Internet routes.
- **Configurable NAT Gateway Topologies**:
  - Single NAT Gateway for cost-effective lower environments (`dev`/`staging`).
  - Dedicated Multi-AZ NAT Gateways (1 per AZ) for high-availability production environments (`prod`).
- **Default Security Group Baseline**: Completely revokes all ingress and egress rules on the VPC default security group to comply with CIS AWS Foundations Benchmark 5.4.
- **S3 Gateway VPC Endpoint**: Attached to private and database route tables, reducing egress costs and keeping S3 state/artifact traffic within the AWS private backbone.
- **VPC Flow Logs**: Sends comprehensive IP traffic telemetry to CloudWatch Logs with configurable retention (default: 90 days) for security posture monitoring and compliance auditing.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `environment` | Deployment environment name | `string` | n/a | yes |
| `vpc_cidr` | Primary CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| `cluster_name` | Name of the EKS cluster for subnet tagging | `string` | n/a | yes |
| `availability_zones` | List of 3 AZs (auto-detected if empty) | `list(string)` | `[]` | no |
| `public_subnet_cidrs` | 3 public subnet CIDRs | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]` | no |
| `private_subnet_cidrs` | 3 private subnet CIDRs | `list(string)` | `["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]` | no |
| `database_subnet_cidrs` | 3 database subnet CIDRs | `list(string)` | `["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]` | no |
| `single_nat_gateway` | Deploy 1 NAT GW vs 1 per AZ | `bool` | `false` | no |
| `enable_flow_logs` | Enable VPC Flow Logs | `bool` | `true` | no |
| `flow_logs_retention_days`| CloudWatch retention in days | `number` | `90` | no |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | ID of the VPC |
| `vpc_cidr_block` | VPC CIDR block |
| `default_security_group_id` | Isolated default SG ID |
| `public_subnet_ids` | IDs of public subnets |
| `private_subnet_ids` | IDs of private subnets |
| `database_subnet_ids` | IDs of database subnets |
| `db_subnet_group_name` | RDS DB subnet group name |
| `nat_gateway_ids` | IDs of deployed NAT Gateways |
| `nat_gateway_public_ips` | Elastic IP addresses of NAT Gateways |
