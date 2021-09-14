variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "cluster_name" {
  description = "Kubernetes cluster name."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster."
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

variable "worker_group_launch_template" {
  description = "Configuration for worker group one."
  type = object({
    name                    = string
    instance_type           = string
    asg_desired_capacity    = number
    asg_min_size            = number
    asg_max_size            = number
    spot_price              = string
    override_instance_types = optional(list(string))
    on_demand_base_capacity = optional(string)
    target_group_arns       = optional(list(string))
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
