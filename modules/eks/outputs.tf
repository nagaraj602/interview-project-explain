output "cluster_id" {
  description = "The ID of the EKS cluster."
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster."
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "The private endpoint URL for the Kubernetes API server."
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_version" {
  description = "The Kubernetes control plane version running on the cluster."
  value       = aws_eks_cluster.main.version
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster."
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS control plane ENIs."
  value       = aws_security_group.cluster.id
}

output "node_security_group_id" {
  description = "Security group ID attached to worker nodes in the managed node group."
  value       = aws_security_group.node.id
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider for IAM Roles for Service Accounts (IRSA)."
  value       = aws_iam_openid_connect_provider.oidc.arn
}

output "oidc_provider_url" {
  description = "The URL of the OIDC Provider (without https:// scheme)."
  value       = replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
}

output "node_group_id" {
  description = "The identifier of the Managed Node Group."
  value       = aws_eks_node_group.main.id
}

output "node_group_arn" {
  description = "The ARN of the Managed Node Group."
  value       = aws_eks_node_group.main.arn
}

output "node_role_arn" {
  description = "IAM Role ARN attached to worker nodes."
  value       = aws_iam_role.node.arn
}

output "risk_engine_irsa_role_arn" {
  description = "IAM Role ARN for the Marketplace Risk Detection microservice service account."
  value       = aws_iam_role.risk_engine_irsa.arn
}
