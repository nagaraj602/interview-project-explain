output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  value       = aws_vpc.main.cidr_block
}

output "default_security_group_id" {
  description = "The ID of the default security group (hardened/locked down with zero inbound/outbound rules)."
  value       = aws_default_security_group.default.id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets."
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of public subnets."
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets (EKS nodes/workloads)."
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of private subnets."
  value       = aws_subnet.private[*].cidr_block
}

output "database_subnet_ids" {
  description = "List of IDs of database subnets."
  value       = aws_subnet.database[*].id
}

output "database_subnet_cidrs" {
  description = "List of CIDR blocks of database subnets."
  value       = aws_subnet.database[*].cidr_block
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group for RDS PostgreSQL."
  value       = aws_db_subnet_group.database.name
}

output "db_subnet_group_arn" {
  description = "The ARN of the DB subnet group for RDS PostgreSQL."
  value       = aws_db_subnet_group.database.arn
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs."
  value       = aws_nat_gateway.nat[*].id
}

output "nat_gateway_public_ips" {
  description = "List of Elastic IPs allocated for the NAT Gateways."
  value       = aws_eip.nat[*].public_ip
}

output "availability_zones" {
  description = "List of Availability Zones utilized by the VPC."
  value       = local.azs
}

output "flow_log_id" {
  description = "The ID of the VPC Flow Log."
  value       = try(aws_flow_log.main[0].id, null)
}

output "flow_log_destination_arn" {
  description = "The ARN of the CloudWatch Log Group for VPC Flow Logs."
  value       = try(aws_cloudwatch_log_group.flow_logs[0].arn, null)
}
