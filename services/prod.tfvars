aws_region = "us-east-1"

################################################################################
# Domains
################################################################################

domain      = "kubis.ai"
cicd_domain = "cicd.kubis.ai"
api_domain  = "api.kubis.ai"
auth_domain = "auth.kubis.ai"

################################################################################
# Email
################################################################################

email_identities = ["noreply@kubis.ai"]

################################################################################
# Authentication (Firebase)
################################################################################

firebase_auth_domain_path = "/prod/auth/firebase-auth-domain"

################################################################################
# Container registry
################################################################################

repository_list = ["website", "filesystem", "cloud"]

################################################################################
# Filesystem service
################################################################################

filesystem_bucket_name = "filesystem-kubis-prod"

filesystem_endpoint_path          = "/prod/filesystem/object-storage-endpoint"
filesystem_bucket_name_path       = "/prod/filesystem/object-storage-bucket-name"
filesystem_access_key_id_path     = "/prod/filesystem/object-storage-access-key-id"
filesystem_access_key_secret_path = "/prod/filesystem/object-storage-access-key-secret"

################################################################################
# Cloud service
################################################################################

cloud_db_instance_class            = "db.t4g.micro"
cloud_db_deletion_protection       = true
cloud_db_allocated_storage         = 10
cloud_db_final_snapshot_identifier = "cloud-db-final-snapshot"

cloud_database_name_path     = "/prod/cloud/database-name"
cloud_database_user_path     = "/prod/cloud/database-user"
cloud_database_password_path = "/prod/cloud/database-password"
