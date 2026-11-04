aws_region  = "us-east-1"
environment = "prod"

# VPC Settings (Full 3-AZ Multi-NAT High Availability)
vpc_cidr              = "10.0.0.0/16"
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
database_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
single_nat_gateway    = false # Dedicated NAT Gateway in each of the 3 AZs

# EKS Settings (Kubernetes 1.35)
cluster_name       = "prod-risk-eks"
kubernetes_version = "1.35"
eks_instance_types = ["m6i.xlarge"]
eks_desired_size   = 3
eks_min_size       = 3
eks_max_size       = 15

# RDS Settings (Multi-AZ Standby, Storage Autoscaling, 14-Day Backups)
rds_instance_class        = "db.r6g.xlarge"
rds_multi_az              = true
rds_allocated_storage     = 50
rds_max_allocated_storage = 500
backup_retention_period   = 14
rds_deletion_protection   = false
rds_skip_final_snapshot   = true
