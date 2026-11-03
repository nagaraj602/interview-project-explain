aws_region  = "us-east-1"
environment = "dev"

# VPC Settings
vpc_cidr              = "10.20.0.0/16"
public_subnet_cidrs   = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
private_subnet_cidrs  = ["10.20.11.0/24", "10.20.12.0/24", "10.20.13.0/24"]
database_subnet_cidrs = ["10.20.21.0/24", "10.20.22.0/24", "10.20.23.0/24"]
single_nat_gateway    = true

# EKS Settings
cluster_name       = "dev-risk-eks"
kubernetes_version = "1.35"
eks_instance_types = ["m6i.large"]
eks_desired_size   = 2
eks_min_size       = 1
eks_max_size       = 4

# RDS Settings
rds_instance_class        = "db.t4g.medium"
rds_multi_az              = false
rds_allocated_storage     = 50
rds_max_allocated_storage = 200
backup_retention_period   = 14
