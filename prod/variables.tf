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
# Email
################################################################################

variable "email_identities" {
  description = "List of email identities to be registered with SES."
  type        = list(string)
}

################################################################################
# Authentication
################################################################################

variable "auth_domain" {
  description = "The domain for the auth service."
  type        = string
}

variable "auth_from_email_address" {
  description = "Sender’s email address or sender’s display name with their email address."
  type        = string
}

variable "cognito_client_id_path" {
  description = "The name for exporting the cognito client id to the AWS Parameter Store."
  type        = string
}

variable "cognito_user_pool_id_path" {
  description = "The name for exporting the cognito user pool id to the AWS Parameter Store."
  type        = string
}


variable "cognito_custom_domain_path" {
  description = "The custom domain used for UIs hosted by Amazon Cognito. Used for social identity."
  type        = string
}

variable "google_oauth2_client_id_path" {
  description = "The Google OAuth2 client id name stored in AWS Parameter Store."
  type        = string
}

variable "google_oauth2_client_secret_path" {
  description = "The Google OAuth2 client secret name stored in AWS Parameter Store."
  type        = string
}

################################################################################
# Container registry
################################################################################

variable "repository_list" {
  description = "List of repositories to be created"
  type        = list(string)
  default     = []
}

################################################################################
# CI/CD
################################################################################

variable "cicd_domain" {
  description = "Domain used for CI/CD. Used, for instance, for setting up webhook endpoints"
  type        = string
}
