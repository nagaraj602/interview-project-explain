# =====================================================================================================================
# NON-PRODUCTION ENVIRONMENT (DEV + STAGING CONSOLIDATED)
# Cost-Optimized 2-Cluster Architecture:
# - 1 Shared VPC with single NAT Gateway (Saves ~$130/month)
# - 1 Shared EKS Kubernetes Cluster with Spot instances (Saves ~$73/month control plane + ~70% EC2)
# - Kubernetes Namespace Separation (risk-dev vs risk-staging) with NetworkPolicies and ResourceQuotas
# - Independent Dev and Staging PostgreSQL Databases (Single-AZ Graviton t4g for extreme cost efficiency)
# =====================================================================================================================

# ---------------------------------------------------------------------------------------------------------------------
# Module: Shared VPC Networking Tier
# ---------------------------------------------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr              = var.vpc_cidr
  environment           = var.environment
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  single_nat_gateway    = var.single_nat_gateway
  cluster_name          = var.cluster_name

  tags = {
    Environment = var.environment
    Tier        = "networking"
    Scope       = "shared-nonprod"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Module: Consolidated EKS Kubernetes Cluster (v1.35) - Hosts both Dev and Staging Workloads
# ---------------------------------------------------------------------------------------------------------------------
module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  environment        = var.environment
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  instance_types  = var.eks_instance_types
  capacity_type   = var.eks_capacity_type
  desired_size    = var.eks_desired_size
  min_size        = var.eks_min_size
  max_size        = var.eks_max_size
  max_unavailable = 1

  tags = {
    Environment = var.environment
    Tier        = "compute"
    Scope       = "shared-nonprod"
    Workloads   = "dev-and-staging"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Module: Dev PostgreSQL Database (Cost-Optimized Single-AZ ARM Graviton)
# ---------------------------------------------------------------------------------------------------------------------
module "rds_dev" {
  source = "../../modules/rds"

  environment                = "dev"
  vpc_id                     = module.vpc.vpc_id
  db_subnet_group_name       = module.vpc.db_subnet_group_name
  eks_node_security_group_id = module.eks.node_security_group_id

  db_name                 = "marketplaceriskdev"
  db_username             = "risk_dev_admin"
  engine_version          = var.rds_engine_version
  instance_class          = var.rds_dev_instance_class
  allocated_storage       = var.rds_allocated_storage
  max_allocated_storage   = var.rds_max_allocated_storage
  multi_az                = false
  backup_retention_period = var.backup_retention_period

  deletion_protection = var.rds_deletion_protection
  skip_final_snapshot = var.rds_skip_final_snapshot
  enable_blue_green_update = false

  tags = {
    Environment = "dev"
    Tier        = "database"
    Parent      = var.environment
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Module: Staging PostgreSQL Database (Pre-production testing Single-AZ ARM Graviton)
# ---------------------------------------------------------------------------------------------------------------------
module "rds_staging" {
  source = "../../modules/rds"

  environment                = "staging"
  vpc_id                     = module.vpc.vpc_id
  db_subnet_group_name       = module.vpc.db_subnet_group_name
  eks_node_security_group_id = module.eks.node_security_group_id

  db_name                 = "marketplaceriskstaging"
  db_username             = "risk_staging_admin"
  engine_version          = var.rds_engine_version
  instance_class          = var.rds_staging_instance_class
  allocated_storage       = var.rds_allocated_storage
  max_allocated_storage   = var.rds_max_allocated_storage
  multi_az                = var.rds_staging_multi_az
  backup_retention_period = var.backup_retention_period

  deletion_protection = var.rds_deletion_protection
  skip_final_snapshot = var.rds_skip_final_snapshot
  enable_blue_green_update = false

  tags = {
    Environment = "staging"
    Tier        = "database"
    Parent      = var.environment
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Module: CI/CD Deployment Credentials & IAM Instance Profile
# ---------------------------------------------------------------------------------------------------------------------
module "iam_secrets" {
  source = "../../modules/iam-secrets"

  environment = var.environment

  tags = {
    Environment = var.environment
    Tier        = "security"
    Scope       = "shared-nonprod"
  }
}
