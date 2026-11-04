aws_region  = "us-east-1"
environment = "nonprod"

# Shared VPC Settings (Single NAT Gateway saves ~$130/month vs multi-NAT)
vpc_cidr              = "10.10.0.0/16"
public_subnet_cidrs   = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
private_subnet_cidrs  = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
database_subnet_cidrs = ["10.10.21.0/24", "10.10.22.0/24", "10.10.23.0/24"]
single_nat_gateway    = true

# Consolidated EKS Settings (Kubernetes 1.36 on Spot Instances for ~70% EC2 savings)
cluster_name       = "nonprod-risk-eks"
kubernetes_version = "1.36"
eks_instance_types = ["m6i.large"]
eks_capacity_type  = "SPOT"
eks_desired_size   = 2
eks_min_size       = 1
eks_max_size       = 8

# Dev Database (Cost-optimized Single-AZ ARM Graviton)
rds_dev_instance_class = "db.t4g.medium"
rds_engine_version     = "16.5"

# Staging Database (Performance testing Single-AZ ARM Graviton)
rds_staging_instance_class = "db.t4g.large"
rds_staging_multi_az       = false

# Shared Storage and Backup Policies
rds_allocated_storage     = 50
rds_max_allocated_storage = 200
backup_retention_period   = 7
rds_deletion_protection   = false
rds_skip_final_snapshot   = true
