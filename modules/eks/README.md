# Enterprise EKS Module (Kubernetes 1.35)

This module provisions an enterprise, CIS-hardened Amazon Elastic Kubernetes Service (EKS) cluster running **Kubernetes 1.35** with Managed Node Groups engineered for zero-downtime rolling upgrades and maximum isolation.

## Security & Architecture Highlights

- **Strictly Private Control Plane**:
  - `endpoint_public_access = false`
  - `endpoint_private_access = true`
  - Cluster API is completely invisible to the public internet; accessible solely via VPN, Direct Connect, or internal bastion / SSM jumpboxes.
- **KMS Envelope Encryption**: Kubernetes Secrets are encrypted at rest using an automated rotating AWS KMS Customer Managed Key (CMK).
- **IMDSv2 Enforced**: Launch template enforces `http_tokens = required` with hop limit 1, mitigating SSRF risks and container credential theft.
- **Root Volume Encryption**: Worker node EBS root volumes are formatted as `gp3` and encrypted with a dedicated KMS Customer Managed Key.
- **Zero-Downtime Rolling Updates**:
  - `update_config` specifies `max_unavailable = 1` (configurable) ensuring graceful pod eviction and draining.
  - Paired with `create_before_destroy = true` on the launch template.
- **Native OIDC & IRSA**: Automatically provisions the cluster OIDC identity provider and includes a scoped example role for Marketplace Risk Detection microservice pods (`system:serviceaccount:risk-detection:risk-engine-sa`).

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `cluster_name` | Name of the EKS cluster | `string` | n/a | yes |
| `environment` | Deployment environment name | `string` | n/a | yes |
| `kubernetes_version` | Kubernetes version | `string` | `"1.35"` | no |
| `vpc_id` | ID of the VPC | `string` | n/a | yes |
| `private_subnet_ids` | Subnets for cluster ENIs & nodes | `list(string)` | n/a | yes |
| `instance_types` | EC2 instance types for nodes | `list(string)` | `["m6i.xlarge"]` | no |
| `capacity_type` | ON_DEMAND or SPOT | `string` | `"ON_DEMAND"` | no |
| `desired_size` | Initial desired worker count | `number` | `3` | no |
| `min_size` | Autoscaling minimum | `number` | `3` | no |
| `max_size` | Autoscaling maximum | `number` | `10` | no |
| `max_unavailable` | Max nodes offline during upgrades | `number` | `1` | no |
| `disk_size_gb` | Root gp3 disk size in GiB | `number` | `100` | no |
| `cluster_log_retention_days` | CloudWatch log retention | `number` | `90` | no |
| `tags` | Tags applied to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | EKS cluster identifier |
| `cluster_name` | Cluster name |
| `cluster_arn` | EKS cluster ARN |
| `cluster_endpoint` | Private Kubernetes API Server endpoint |
| `cluster_version` | Active Kubernetes control plane version |
| `cluster_security_group_id` | Control plane security group ID |
| `node_security_group_id` | Node group security group ID |
| `oidc_provider_arn` | OIDC IAM Provider ARN for IRSA |
| `oidc_provider_url` | Issuer URL for IRSA trust policies |
| `risk_engine_irsa_role_arn` | Example service account IAM role ARN |
