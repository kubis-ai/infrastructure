# terraform {
#   backend "s3" {
#     key = "global/terraform.tfstate"
#   }
# }

provider "aws" {
  region = var.aws_region
}

module "terraform_state" {
  source = "git@github.com:kubis-ai/terraform-modules.git//modules/data-stores/terraform-state"

  name              = var.state_store_name
  enable_versioning = var.enable_versioning
  force_destroy     = var.force_destroy
}

module "terraform_locks" {
  source = "git@github.com:kubis-ai/terraform-modules.git//modules/data-stores/terraform-locks"

  name = var.locks_table_name
}
