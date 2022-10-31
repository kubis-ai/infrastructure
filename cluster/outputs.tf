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

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider."
  value       = module.cluster.oidc_provider_arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer."
  value       = module.cluster.cluster_oidc_issuer_url
}

output "http_node_port" {
  description = "Node port of the target group where HTTP requests should be directed to."
  value       = local.http_node_port
}

output "https_node_port" {
  description = "Node port of the target group where HTTPS requests should be directed to. When provided, HTTPS will be enabled and a TLS certificate must be provided."
  value       = local.https_node_port
}

output "health_check_port" {
  description = "The port for the health check endpoint."
  value       = local.health_check_port
}

output "health_check_path" {
  description = "The path for the health check endpoint."
  value       = local.health_check_path
}

output "kubeconfig_path" {
  description = "The absolute path to the kubeconfig file"
  value       = abspath(module.cluster.kubeconfig_filename)
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.alb.dns_name
}

output "alb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = module.alb.zone_id
}

output "mymlops_alb_dns_name" {
  description = "The DNS name of MyMLOps load balancer."
  value       = module.mymlops_alb.dns_name
}

output "mymlops_alb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = module.mymlops_alb.zone_id
}

output "nathaliacampos_alb_dns_name" {
  description = "The DNS name of nathaliacampos.me load balancer."
  value       = module.nathaliacampos_alb.dns_name
}

output "nathaliacampos_alb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = module.nathaliacampos_alb.zone_id
}

output "acm_certificate_arn" {
  description = "The ARN of the domain certificate issued by AWS Certificate Manager."
  value       = module.dns.certificate_arn
}

output "mymlops_acm_certificate_arn" {
  description = "The ARN of the domain certificate issued by AWS Certificate Manager."
  value       = module.mymlops_dns.certificate_arn
}

output "nathaliacampos_acm_certificate_arn" {
  description = "The ARN of the domain certificate issued by AWS Certificate Manager."
  value       = module.nathaliacampos_dns.certificate_arn
}

output "worker_security_group_id" {
  description = "Security group id attached to the worker groups."
  value       = module.cluster.worker_security_group_id
}
