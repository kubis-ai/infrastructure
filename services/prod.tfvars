aws_region = "us-east-1"

################################################################################
# Domains
################################################################################

domain       = "kubis.ai"
cicd_domain  = "cicd.kubis.ai"
api_domain   = "api.kubis.ai"
auth_domain  = "auth.kubis.ai"
docs_domain  = "docs.kubis.ai"
blog_domain  = "blog.kubis.ai"
admin_domain = "admin.kubis.ai"

mymlops_domain      = "mymlops.com"
mymlops_api_domain  = "api.mymlops.com"
mymlops_auth_domain = "auth.mymlops.com"

nathaliacampos_domain = "nathaliacampos.me"

################################################################################
# Email (SES)
################################################################################

email_identities = ["noreply@kubis.ai"]

################################################################################
# Email (SES) - MyMLOps
################################################################################

mymlops_email_identities = ["noreply@mymlops.com"]

################################################################################
# Authentication (Firebase)
################################################################################

firebase_auth_domain_path = "/prod/auth/firebase-auth-domain"

################################################################################
# MyMLOps Authentication (Firebase)
################################################################################

firebase_mymlops_auth_domain_path = "/prod/auth/firebase-mymlops-auth-domain"

################################################################################
# Container registry
################################################################################

repository_list = ["website", "docs", "blog", "admin", "auth", "billing", "filesystem", "cloud", "notebook", "mymlops", "mymlops-backend", "personal-website"]

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

################################################################################
# Billing service
################################################################################

billing_db_instance_class            = "db.t4g.micro"
billing_db_deletion_protection       = true
billing_db_allocated_storage         = 10
billing_db_final_snapshot_identifier = "billing-db-final-snapshot"

billing_database_connection_uri_path = "/prod/billing/database-connection-uri"

################################################################################
# MyMLOps backend service
################################################################################

mymlops_tooling_db_instance_class            = "db.t4g.micro"
mymlops_tooling_db_deletion_protection       = true
mymlops_tooling_db_allocated_storage         = 10
mymlops_tooling_db_final_snapshot_identifier = "mymlops-tooling-db-final-snapshot"

mymlops_billing_db_instance_class            = "db.t4g.micro"
mymlops_billing_db_deletion_protection       = true
mymlops_billing_db_allocated_storage         = 10
mymlops_billing_db_final_snapshot_identifier = "mymlops-billing-db-final-snapshot"

mymlops_workspaces_db_instance_class            = "db.t4g.micro"
mymlops_workspaces_db_deletion_protection       = true
mymlops_workspaces_db_allocated_storage         = 10
mymlops_workspaces_db_final_snapshot_identifier = "mymlops-workspaces-db-final-snapshot"

mymlops_tooling_database_connection_uri_path    = "/prod/mymlops-backend/tooling-database-connection-uri"
mymlops_billing_database_connection_uri_path    = "/prod/mymlops-backend/billing-database-connection-uri"
mymlops_workspaces_database_connection_uri_path = "/prod/mymlops-backend/workspaces-database-connection-uri"
mymlops_workspaces_redis_connection_uri_path    = "/prod/mymlops-backend/workspaces-redis-connection-uri"
mymlops_contact_role_arn_path                   = "/prod/mymlops-backend/contact-aws-role-arn"
mymlops_workspaces_role_arn_path                = "/prod/mymlops-backend/workspaces-aws-role-arn"
mymlops_workspaces_subnet_id_path               = "/prod/mymlops-backend/workspaces-subnet-id"
mymlops_workspaces_security_group_id_path       = "/prod/mymlops-backend/workspaces-security-group-id"
mymlops_backend_access_key_id_path              = "/prod/mymlops-backend/aws-access-key-id"
mymlops_backend_secret_access_key_path          = "/prod/mymlops-backend/aws-secret-access-key"
