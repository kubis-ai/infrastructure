variable "aws_region" {
  description = "AWS region."
  type        = string
}

################################################################################
# DNS (TLS certificates)
################################################################################

variable "domain" {
  description = "Domain name."
  type        = string
}

variable "subdomains" {
  description = "List of subdomains."
  type        = list(string)
}

variable "mymlops_domain" {
  description = "My MLOps tool domain"
  type        = string
}

variable "mymlops_subdomains" {
  description = "List of My MLOps subdomains."
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
    name                    = string
    instance_type           = string
    override_instance_types = list(string)
    asg_desired_capacity    = number
    asg_min_size            = number
    asg_max_size            = number
    spot_price              = string
    kubelet_extra_args      = string
  })
}

variable "kubeconfig_output_path" {
  description = "Where to save the Kubectl config file. Assumed to be a directory if the value ends with a forward slash /."
  type        = string
}
