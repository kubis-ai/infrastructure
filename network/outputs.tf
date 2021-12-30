output "vpc_id" {
  description = "The VPC id."
  value       = module.network.vpc_id
}

output "cidr" {
  description = "Network CIDR block."
  value       = module.network.vpc_cidr_block
}

output "public_subnets" {
  description = "List of network private subnets."
  value       = module.network.public_subnets
}

output "private_subnets" {
  description = "List of network private subnets."
  value       = module.network.private_subnets
}

output "vpc_security_group_id" {
  description = "The ID of the security group created by default on VPC creation."
  value       = module.network.default_security_group_id
}
