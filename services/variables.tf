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

variable "docs_domain" {
  description = "Domain used for the Docs."
  type        = string
}

variable "blog_domain" {
  description = "Domain used for the Blog."
  type        = string
}

variable "admin_domain" {
  description = "Domain used for the Admin dashboard."
  type        = string
}

variable "mymlops_domain" {
  description = "My MLOps domain name."
  type        = string
}

variable "mymlops_api_domain" {
  description = "My MLOps API domain name."
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

variable "filesystem_secret_access_key_path" {
  description = "The path to the AWS secret access key param in the AWS Parameter Store."
  type        = string
}

variable "filesystem_db_instance_class" {
  description = "The instance class for the Filesystem service database."
  type        = string
}

variable "filesystem_db_deletion_protection" {
  description = "Whether to protect the database against deletion."
  type        = bool
}

variable "filesystem_db_allocated_storage" {
  description = "The allocated storage in gibibytes."
  type        = number
}

variable "filesystem_db_final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB instance is deleted."
  type        = string
}


variable "filesystem_database_connection_uri_path" {
  description = "The path to the Filesystem service database connection URI param in the AWS Parameter Store."
  type        = string
}

################################################################################
# Cloud service
################################################################################

variable "cloud_db_instance_class" {
  description = "The instance class for the Cloud service database."
  type        = string
}

variable "cloud_db_deletion_protection" {
  description = "Whether to protect the database against deletion."
  type        = bool
}

variable "cloud_db_allocated_storage" {
  description = "The allocated storage in gibibytes."
  type        = number
}

variable "cloud_db_final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB instance is deleted."
  type        = string
}

variable "cloud_database_connection_uri_path" {
  description = "The path to the Cloud service database connection URI param in the AWS Parameter Store."
  type        = string
}

variable "cloud_access_key_id_path" {
  description = "The path to the AWS access key id param in the AWS Parameter Store."
  type        = string
}

variable "cloud_secret_access_key_path" {
  description = "The path to the AWS secret access key param in the AWS Parameter Store."
  type        = string
}

variable "cloud_aws_cpu_machine_image_path" {
  description = "The path to the AWS CPU machine image in the AWS Parameter Store."
  type        = string
}

variable "cloud_aws_gpu_machine_image_path" {
  description = "The path to the AWS GPU machine image in the AWS Parameter Store."
  type        = string
}

variable "cloud_redis_connection_uri_path" {
  description = "The path to the Cloud service Redis connection URI param in the AWS Parameter Store."
  type        = string
}


################################################################################
# Notebook service
################################################################################

variable "notebook_db_instance_class" {
  description = "The instance class for the Notebook service database."
  type        = string
}

variable "notebook_db_deletion_protection" {
  description = "Whether to protect the database against deletion."
  type        = bool
}

variable "notebook_db_allocated_storage" {
  description = "The allocated storage in gibibytes."
  type        = number
}

variable "notebook_db_final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB instance is deleted."
  type        = string
}

variable "notebook_database_connection_uri_path" {
  description = "The path to the Notebook service database connection URI param in the AWS Parameter Store."
  type        = string
}

variable "notebook_redis_connection_uri_path" {
  description = "The path to the Notebook service Redis connection URI param in the AWS Parameter Store."
  type        = string
}

################################################################################
# Billing service
################################################################################

variable "billing_db_instance_class" {
  description = "The instance class for the Billing service database."
  type        = string
}

variable "billing_db_deletion_protection" {
  description = "Whether to protect the database against deletion."
  type        = bool
}

variable "billing_db_allocated_storage" {
  description = "The allocated storage in gibibytes."
  type        = number
}

variable "billing_db_final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB instance is deleted."
  type        = string
}

variable "billing_database_connection_uri_path" {
  description = "The path to the Billing service database connection URI param in the AWS Parameter Store."
  type        = string
}

################################################################################
# MyMLOps backend service
################################################################################

variable "mymlops_backend_db_instance_class" {
  description = "The instance class for the MyMLOps backend service database."
  type        = string
}

variable "mymlops_backend_db_deletion_protection" {
  description = "Whether to protect the database against deletion."
  type        = bool
}

variable "mymlops_backend_db_allocated_storage" {
  description = "The allocated storage in gibibytes."
  type        = number
}

variable "mymlops_backend_db_final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB instance is deleted."
  type        = string
}

variable "mymlops_backend_database_connection_uri_path" {
  description = "The path to the MyMLOps backend service database connection URI param in the AWS Parameter Store."
  type        = string
}

variable "mymlops_backend_iam_role_arn_path" {
  description = "The path to the MyMLOps backend service IAM role ARN param in the AWS Parameter Store."
  type        = string
}

