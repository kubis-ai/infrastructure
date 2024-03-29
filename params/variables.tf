variable "aws_region" {
  description = "AWS region."
  type        = string
}

################################################################################
# Auth
################################################################################

variable "service_token_shared_key_path" {
  description = "The path to the service token shared key in the AWS Parameter Store."
  type        = string
}

variable "firebase_mymlops_project_id_path" {
  description = "The path to MyMLOps firebase project id."
  type        = string
}

################################################################################
# Service endpoints
################################################################################

variable "filesystem_service_public_endpoint_path" {
  description = "The path to the AWS Filesystem service public endpoint param in the AWS Parameter Store."
  type        = string
}

variable "cloud_service_public_endpoint_path" {
  description = "The path to the AWS Cloud service public endpoint param in the AWS Parameter Store."
  type        = string
}

variable "notebook_service_public_endpoint_path" {
  description = "The path to the AWS Notebook service public endpoint param in the AWS Parameter Store."
  type        = string
}

variable "auth_service_public_endpoint_path" {
  description = "The path to the AWS Auth service public endpoint param in the AWS Parameter Store."
  type        = string
}

variable "billing_service_public_endpoint_path" {
  description = "The path to the AWS Billing service public endpoint param in the AWS Parameter Store."
  type        = string
}

variable "cloud_service_private_endpoint_path" {
  description = "The path to the AWS Cloud service private endpoint param in the AWS Parameter Store."
  type        = string
}

variable "notebook_service_private_endpoint_path" {
  description = "The path to the AWS Notebook service private endpoint param in the AWS Parameter Store."
  type        = string
}

################################################################################
# Analytics
################################################################################

variable "mixpanel_project_id_path" {
  description = "The path to the Mixpanel project id param in the AWS Parameter Store."
  type        = string
}

variable "mixpanel_mymlops_project_id_path" {
  description = "The path to the Mixpanel My MLOps project id param in the AWS Parameter Store."
  type        = string
}

variable "amplitude_mymlops_api_key_path" {
  description = "The path to the Amplitude My MLOps API key param in the AWS Parameter Store."
  type        = string
}

################################################################################
# reCAPTCHA
################################################################################

variable "mymlops_recaptcha_site_key_path" {
  description = "The path to the reCAPTCHA site key param in the AWS Parameter Store."
  type        = string
}
