variable "aws_region" {
  description = "AWS region."
  type        = string
}

################################################################################
# Domains
################################################################################

variable "domain" {
  description = "Domain name."
  type        = string
}

variable "subdomains" {
  description = "List of subdomains."
  type        = list(string)
}

variable "auth_domain" {
  description = "The domain for the auth service used by Kratos."
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
# DNS
################################################################################

variable "enable_tls" {
  description = "Whether to enable secure communication over HTTPS. When enabled, HTTP redirects to HTTPS."
  type        = bool
}

################################################################################
# Kratos
################################################################################

variable "kratos_db_username" {
  description = "Username for database used by Kratos."
  type        = string
}

variable "kratos_db_password_secret_name" {
  description = "Username for database password used by Kratos."
  type        = string
}

variable "identity_default_schema_filepath" {
  description = "The filepath for the default identity schema."
  type        = string
}


variable "google_oauth2_client_id" {
  description = "The client ID registered on Google OAuth2"
  type        = string
}

variable "google_oauth2_client_secret_name" {
  description = "The Google OAuth2 client secret name stored in AWS Secrets Manager."
  type        = string
}

variable "google_oauth2_mapper_filepath" {
  description = "Path to Jsonnet claims mapper to map Google claims to user identity's traits."
  type        = string
}

variable "google_oauth2_scope" {
  description = "List of scopes to be requested, separated by comma. Ex: \"{a, b, c}\""
  type        = string
}
