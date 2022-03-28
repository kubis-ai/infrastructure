variable "aws_region" {
  description = "AWS region."
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

variable "cloud_service_private_endpoint_path" {
  description = "The path to the AWS Cloud service private endpoint param in the AWS Parameter Store."
  type        = string
}

################################################################################
# Analytics
################################################################################

variable "mixpanel_project_id_path" {
  description = "The path to the Mixpanel project id param in the AWS Parameter Store."
  type        = string
}

################################################################################
# Eventing
################################################################################

variable "kafka_address_path" {
  description = "The path to the Kafka address in the AWS Parameter Store."
  type        = string
}

variable "runtime_status_topic_path" {
  description = "The path to the Kafka topic for runtime status updates in the AWS Parameter Store."
  type        = string
}
