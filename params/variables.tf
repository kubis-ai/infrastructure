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