variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "cluster_name" {
  description = "Kubernetes cluster name."
  type        = string
}


################################################################################
# VPC
################################################################################

variable "cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "private_subnets" {
  description = "List of cluster VPC private subnets."
  type        = list(string)
}

variable "public_subnets" {
  description = "List of cluster VPC public subnets."
  type        = list(string)
}

################################################################################
# Cluster
################################################################################

variable "worker_group" {
  description = "Configuration for worker group one."
  type = object({
    name             = string
    instance_type    = string
    desired_capacity = number
    min_capacity     = number
    max_capacity     = number
    spot_price       = string
  })
}

variable "kubeconfig_output_path" {
  description = "Where to save the Kubectl config file. Assumed to be a directory if the value ends with a forward slash /."
  type        = string
}

################################################################################
# Application load balancer
################################################################################

variable "enable_tls" {
  description = "Whether to enable secure communication over HTTPS. When enabled, HTTP redirects to HTTPS."
  type        = bool
}
