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

output "kubeconfig_filename" {
  description = "Kubeconfig filename."
  value       = module.cluster.kubeconfig_filename
}

output "target_group_arns" {
  description = "ARN of the target group representing the EKS worker nodes."
  value       = module.alb.target_group_arns
}
