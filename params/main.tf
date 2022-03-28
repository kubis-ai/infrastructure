terraform {
  backend "s3" {
    key = "params/terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
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

resource "aws_ssm_parameter" "cloud_service_private_endpoint" {
  name        = var.cloud_service_private_endpoint_path
  description = "The Cloud service private endpoint."
  type        = "String"
  value       = "cloud-service.cloud:80"
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

################################################################################
# Eventing
################################################################################

resource "aws_ssm_parameter" "kafka_address" {
  name        = var.kafka_address_path
  description = "Kafka address"
  type        = "String"
  value       = "kafka-cluster-kafka-bootstrap.strimzi.svc:9092"
}

resource "aws_ssm_parameter" "runtime_status_topic" {
  name        = var.runtime_status_topic_path
  description = "Kafka topic for runtime status events"
  type        = "String"
  value       = "aws.notebook.fct.runtime-status.0"
}
