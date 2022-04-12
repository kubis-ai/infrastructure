aws_region = "us-east-1"

################################################################################
# Domains
################################################################################

domain       = "kubis.ai"
cicd_domain  = "cicd.kubis.ai"
api_domain   = "api.kubis.ai"
auth_domain  = "auth.kubis.ai"
docs_domain  = "docs.kubis.ai"
admin_domain = "admin.kubis.ai"

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

repository_list = ["website", "docs", "admin", "auth", "billing", "filesystem", "cloud", "notebook"]

################################################################################
# Filesystem service
################################################################################

filesystem_bucket_name = "filesystem-kubis-prod"

filesystem_db_instance_class            = "db.t4g.micro"
filesystem_db_deletion_protection       = true
filesystem_db_allocated_storage         = 10
filesystem_db_final_snapshot_identifier = "filesystem-db-final-snapshot"

filesystem_endpoint_path                = "/prod/filesystem/object-storage-endpoint"
filesystem_bucket_name_path             = "/prod/filesystem/object-storage-bucket-name"
filesystem_access_key_id_path           = "/prod/filesystem/object-storage-access-key-id"
filesystem_secret_access_key_path       = "/prod/filesystem/object-storage-secret-access-key"
filesystem_database_connection_uri_path = "/prod/filesystem/database-connection-uri"


################################################################################
# Cloud service
################################################################################

cloud_db_instance_class            = "db.t4g.micro"
cloud_db_deletion_protection       = true
cloud_db_allocated_storage         = 10
cloud_db_final_snapshot_identifier = "cloud-db-final-snapshot"

cloud_database_connection_uri_path = "/prod/cloud/database-connection-uri"
cloud_access_key_id_path           = "/prod/cloud/aws-sdk-access-key-id"
cloud_secret_access_key_path       = "/prod/cloud/aws-sdk-secret-access-key"
cloud_aws_cpu_machine_image_path   = "/prod/cloud/aws-cpu-machine-image"
cloud_aws_gpu_machine_image_path   = "/prod/cloud/aws-gpu-machine-image"
cloud_redis_connection_uri_path    = "/prod/cloud/redis-connection-uri"

################################################################################
# Notebook service
################################################################################

notebook_db_instance_class            = "db.t4g.micro"
notebook_db_deletion_protection       = true
notebook_db_allocated_storage         = 10
notebook_db_final_snapshot_identifier = "notebook-db-final-snapshot"

notebook_database_connection_uri_path = "/prod/notebook/database-connection-uri"
notebook_redis_connection_uri_path    = "/prod/notebook/redis-connection-uri"
