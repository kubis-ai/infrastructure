aws_region = "us-east-2"

################################################################################
# Terraform state store
################################################################################

state_store_name  = "terraform-state-kubis-prod"
enable_versioning = true
force_destroy     = false

################################################################################
# Terraform locks table
################################################################################

locks_table_name = "terraform-locks-kubis-prod"
