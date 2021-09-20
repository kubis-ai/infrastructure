variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "domain" {
  description = "Domain name."
  type        = string
}

variable "subdomains" {
  description = "List of subdomains."
  type        = list(string)
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

variable "cluster_name" {
  description = "Kubernetes cluster name."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
}

variable "spot_workers" {
  description = "Configuration for spot workers."
  type = object({
    name                 = string
    instance_type        = string
    asg_desired_capacity = number
    asg_min_size         = number
    asg_max_size         = number
    spot_price           = string
    kubelet_extra_args   = string
  })
}

variable "kubeconfig_output_path" {
  description = "Where to save the Kubectl config file. Assumed to be a directory if the value ends with a forward slash /."
  type        = string
}

################################################################################
# Application load balancer
################################################################################

variable "applications" {
  description = "Map of applications and their configuration."
  type = map(object({
    node_port = number,
    protocol  = string
  }))
}

variable "enable_tls" {
  description = "Whether to enable secure communication over HTTPS. When enabled, HTTP redirects to HTTPS."
  type        = bool
}
