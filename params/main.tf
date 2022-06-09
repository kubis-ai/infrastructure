terraform {
  backend "s3" {
    key = "params/terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}

################################################################################
# Auth
################################################################################

resource "random_password" "auth_shared_key" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "service_token_shared_key" {
  name        = var.service_token_shared_key_path
  description = "The shared key for signing id tokens for service accounts."
  type        = "SecureString"
  value       = random_password.auth_shared_key.result
}

resource "aws_ssm_parameter" "firebase_mymlops_project_id" {
  name        = var.firebase_mymlops_project_id_path
  description = "The firebase project id for MyMLOps."
  type        = "String"
  value       = "mymlops-f828d"
}

################################################################################
# Service endpoints
################################################################################
# These service endpoints should be manually synced with the Kubernetes configurations
# for each of these services

resource "aws_ssm_parameter" "filesystem_service_public_endpoint" {
  name        = var.filesystem_service_public_endpoint_path
  description = "The Filesystem service public endpoint."
  type        = "String"
  value       = "api.kubis.ai/filesystem"
}

resource "aws_ssm_parameter" "cloud_service_public_endpoint" {
  name        = var.cloud_service_public_endpoint_path
  description = "The Cloud service public endpoint."
  type        = "String"
  value       = "api.kubis.ai/cloud"
}

resource "aws_ssm_parameter" "notebook_service_public_endpoint" {
  name        = var.notebook_service_public_endpoint_path
  description = "The Notebook service public endpoint."
  type        = "String"
  value       = "api.kubis.ai/notebook"
}

resource "aws_ssm_parameter" "auth_service_public_endpoint" {
  name        = var.auth_service_public_endpoint_path
  description = "The Auth service public endpoint."
  type        = "String"
  value       = "api.kubis.ai/auth"
}

resource "aws_ssm_parameter" "billing_service_public_endpoint" {
  name        = var.billing_service_public_endpoint_path
  description = "The Billing service public endpoint."
  type        = "String"
  value       = "api.kubis.ai/billing"
}

resource "aws_ssm_parameter" "cloud_service_private_endpoint" {
  name        = var.cloud_service_private_endpoint_path
  description = "The Cloud service private endpoint."
  type        = "String"
  value       = "cloud-service.cloud:80"
}

resource "aws_ssm_parameter" "notebook_service_private_endpoint" {
  name        = var.notebook_service_private_endpoint_path
  description = "The Notebook service private endpoint."
  type        = "String"
  value       = "notebook-service.notebook:80"
}

################################################################################
# Analytics
################################################################################

resource "aws_ssm_parameter" "mixpanel_project_id" {
  name        = var.mixpanel_project_id_path
  description = "Project id for Mixpanel."
  type        = "String"
  value       = "2da9599fca04547821c9cb5eb3193868"
}

resource "aws_ssm_parameter" "mixpanel_mymlops_project_id" {
  name        = var.mixpanel_mymlops_project_id_path
  description = "My MLOps project id for Mixpanel."
  type        = "String"
  value       = "61c3b6128972fb63b3b7114ec656559f"
}

resource "aws_ssm_parameter" "amplitude_mymlops_api_key" {
  name        = var.amplitude_mymlops_api_key_path
  description = "My MLOps API key for Amplitude."
  type        = "String"
  value       = "2c7adf40adb7c057c81305b9c7989cd7"
}

################################################################################
# reCAPTCHA
################################################################################

resource "aws_ssm_parameter" "mymlops_recaptcha_site_key" {
  name        = var.mymlops_recaptcha_site_key_path
  description = "My MLOps reCAPTCHA site key."
  type        = "String"
  value       = "6LdN9D4gAAAAAOZREBhYDOXhS2Xs54o1EM07dYfy"
}
