aws_region = "us-east-1"

################################################################################
# Auth
################################################################################

service_token_shared_key_path    = "/prod/auth/service-token-shared-key"
firebase_mymlops_project_id_path = "/prod/auth/firebase-mymlops-project-id"

################################################################################
# Service endpoints
################################################################################

filesystem_service_public_endpoint_path = "/prod/filesystem/public-service-endpoint"
cloud_service_public_endpoint_path      = "/prod/cloud/public-service-endpoint"
notebook_service_public_endpoint_path   = "/prod/notebook/public-service-endpoint"
auth_service_public_endpoint_path       = "/prod/auth/public-service-endpoint"
billing_service_public_endpoint_path    = "/prod/billing/public-service-endpoint"

cloud_service_private_endpoint_path    = "/prod/cloud/private-service-endpoint"
notebook_service_private_endpoint_path = "/prod/notebook/private-service-endpoint"

################################################################################
# Analytics
################################################################################

mixpanel_project_id_path         = "/prod/analytics/mixpanel-project-id"
mixpanel_mymlops_project_id_path = "/prod/analytics/mixpanel-mymlops-project-id"
amplitude_mymlops_api_key_path   = "/prod/analytics/amplitude-mymlops-api-key"

################################################################################
# reCAPTCHA
################################################################################

mymlops_recaptcha_site_key_path = "/prod/recaptcha/mymlops-site-key"
