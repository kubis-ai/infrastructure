variable "aws_region" {
  description = "AWS region."
  type        = string
}

################################################################################
# Service endpoints
################################################################################

variable "filesystem_service_endpoint_path" {
  description = "The path to the AWS Filesystem service endpoint param in the AWS Parameter Store."
  type        = string
}

variable "cloud_service_endpoint_path" {
  description = "The path to the AWS Cloud service endpoint param in the AWS Parameter Store."
  type        = string
}

variable "notebook_service_endpoint_path" {
  description = "The path to the AWS Notebook service endpoint param in the AWS Parameter Store."
  type        = string
}
