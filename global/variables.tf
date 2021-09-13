variable "aws_region" {
  description = "AWS region."
  type        = string
}

################################################################################
# Terraform state store
################################################################################

variable "state_store_name" {
  description = "Name for Terraform state store."
  type        = string
}

variable "enable_versioning" {
  description = "Whether to enable versioning."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Whether all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

################################################################################
# Terraform locks table
################################################################################

variable "locks_table_name" {
  description = "Name for Terraform locks table."
  type        = string
}
