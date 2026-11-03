aws_region  = "us-east-1"
environment = "staging"

# VPC Settings
vpc_cidr              = "10.10.0.0/16"
public_subnet_cidrs   = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
private_subnet_cidrs  = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
database_subnet_cidrs = ["10.10.21.0/24", "10.10.22.0/24", "10.10.23.0/24"]
single_nat_gateway    = false # Multi-AZ NAT Gateways for staging validation

# EKS Settings
cluster_name       = "staging-risk-eks"
kubernetes_version = "1.35"
eks_instance_types = ["m6i.xlarge"]
eks_desired_size   = 3
eks_min_size       = 2
eks_max_size       = 6

# RDS Settings
rds_instance_class        = "db.r6g.large"
rds_multi_az              = true
rds_allocated_storage     = 50
rds_max_allocated_storage = 500
backup_retention_period   = 14
