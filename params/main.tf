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

