output "aws_region" {
  description = "AWS region."
  value       = var.aws_region
}

output "cluster_name" {
  description = "Kubernetes cluster name."
  value       = module.cluster.cluster_id
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = module.cluster.cluster_arn
}
