aws_region = "us-east-1"

################################################################################
# Terraform state store
################################################################################

state_store_name  = "terraform-state-kubis"
enable_versioning = true
force_destroy     = false

################################################################################
# Terraform locks table
################################################################################

locks_table_name = "terraform-locks-kubis"
