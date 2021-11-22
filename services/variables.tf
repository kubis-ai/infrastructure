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

variable "auth_domain" {
  description = "The domain for the auth service."
  type        = string
}

variable "cicd_domain" {
  description = "Domain used for CI/CD. Used, for instance, for setting up webhook endpoints"
  type        = string
}

variable "api_domain" {
  description = "Domain used for APIs."
  type        = string
}

################################################################################
# Email
################################################################################

variable "email_identities" {
  description = "List of email identities to be registered with SES."
  type        = list(string)
}

################################################################################
# Authentication (Firebase)
################################################################################

variable "firebase_auth_domain_path" {
  description = "The custom domain used by Firebase for authentication."
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
# Filesystem service
################################################################################

variable "filesystem_bucket_name" {
  description = "The name of the S3 bucket used by the Filesystem service."
  type        = string
}

variable "filesystem_bucket_name_path" {
  description = "The path to the bucket name param in the AWS Parameter Store."
  type        = string
}

variable "filesystem_endpoint_path" {
  description = "The path to the S3 endpoint param in the AWS Parameter Store."
  type        = string
}

variable "filesystem_access_key_id_path" {
  description = "The path to the AWS access key id param in the AWS Parameter Store."
  type        = string
}

variable "filesystem_access_key_secret_path" {
  description = "The path to the AWS access key secret param in the AWS Parameter Store."
  type        = string
}