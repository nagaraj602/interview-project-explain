Act as a Senior Infrastructure Engineer. Generate a complete, production-ready Terraform codebase for a Marketplace Risk Detection Platform. Structure the code using Terraform modules. The architecture requires three environments (dev, staging, prod). All infrastructure must be deployed strictly in the us-east-1 region. Use directory-based environment separation (e.g., /environments/prod, /environments/staging) referencing standard modules.

Generate the following:
1. Architecture Documentation: A markdown file (ARCHITECTURE.md) detailing the directory structure, networking topology in us-east-1, and upgrade strategies.
2. S3 Native Backend: A module to provision an S3 bucket in us-east-1 with versioning enabled, configured for Terraform 1.10+ native S3 state locking (do NOT use DynamoDB).
3. VPC Network: A highly available VPC in us-east-1 with public and private subnets across 3 Availability Zones, NAT Gateways, and strict security group baselines.
4. EKS Cluster: An EKS cluster (version 1.35) deployed in the private subnets. Include an EKS Managed Node Group configured for zero-downtime rolling updates, OIDC integration, and IAM Roles for Service Accounts (IRSA).
5. RDS PostgreSQL: A Multi-AZ RDS Postgres instance deployed in private subnets, configured with a 14-day backup retention period, storage autoscaling, and Secrets Manager integration.
6. IAM/Secrets Manager: A module provisioning a Secrets Manager secret to hold CI/CD deployment credentials, and a highly restricted IAM Instance Profile that only allows 'secretsmanager:GetSecretValue' for this specific secret.

Provide the main.tf, variables.tf, and outputs.tf for each module, and show the exact directory structure. Ensure all code adheres to AWS security best practices, explicitly disabling public endpoints for EKS and RDS.


Once done, push it to github. 
