terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs       = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 3)
  nat_count = var.single_nat_gateway ? 1 : 3
}

# ---------------------------------------------------------------------------------------------------------------------
# VPC Core Infrastructure
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-vpc"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Security Baseline: Lockdown Default Security Group (CIS AWS Foundations Benchmark 5.4)
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  # Leaving ingress and egress empty explicitly denies all inbound and outbound traffic
  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-default-sg-isolated"
      Environment = var.environment
      Description = "Isolated default security group - all ingress/egress blocked"
      ManagedBy   = "Terraform"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Internet Gateway
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-igw"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Subnets: Public (ALBs / Ingress / NAT Gateways)
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name                                        = "${var.environment}-public-${local.azs[count.index]}"
      Environment                                 = var.environment
      Tier                                        = "public"
      "kubernetes.io/role/elb"                    = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      ManagedBy                                   = "Terraform"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Subnets: Private (EKS Worker Nodes, Pods, Application Services)
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    var.tags,
    {
      Name                                        = "${var.environment}-private-${local.azs[count.index]}"
      Environment                                 = var.environment
      Tier                                        = "private"
      "kubernetes.io/role/internal-elb"           = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "karpenter.sh/discovery"                    = var.cluster_name
      ManagedBy                                   = "Terraform"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Subnets: Database (Isolated RDS PostgreSQL, no direct internet egress)
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "database" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-database-${local.azs[count.index]}"
      Environment = var.environment
      Tier        = "database"
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_db_subnet_group" "database" {
  name        = "${var.environment}-db-subnet-group"
  description = "Isolated database subnet group for Multi-AZ RDS PostgreSQL"
  subnet_ids  = aws_subnet.database[*].id

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-db-subnet-group"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# NAT Gateways & Elastic IPs
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_eip" "nat" {
  count  = local.nat_count
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-nat-eip-${count.index + 1}"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  count         = local.nat_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-nat-gw-${count.index + 1}"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  depends_on = [aws_internet_gateway.igw]
}

# ---------------------------------------------------------------------------------------------------------------------
# Routing Tables & Associations
# ---------------------------------------------------------------------------------------------------------------------
# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-public-rt"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Tables
resource "aws_route_table" "private" {
  count  = local.nat_count
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-private-rt-${count.index + 1}"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_route" "private_nat" {
  count                  = local.nat_count
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[count.index].id
}

# Database Route Table (Isolated, no external routes)
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-database-rt"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_route_table_association" "database" {
  count          = 3
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

# ---------------------------------------------------------------------------------------------------------------------
# Gateway VPC Endpoints (S3) to avoid NAT Gateway data processing charges
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    [aws_route_table.public.id, aws_route_table.database.id],
    aws_route_table.private[*].id
  )

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-s3-gateway-endpoint"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# VPC Flow Logs (CloudWatch Logs)
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc-flow-logs/${var.environment}"
  retention_in_days = var.flow_logs_retention_days

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-vpc-flow-logs"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${var.environment}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VpcFlowLogsAssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-vpc-flow-logs-role"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${var.environment}-vpc-flow-logs-policy"
  role  = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowFlowLogsToCloudWatch"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.flow_logs[0].arn}:*"
      }
    ]
  })
}

resource "aws_flow_log" "main" {
  count           = var.enable_flow_logs ? 1 : 0
  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-vpc-flow-log"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
