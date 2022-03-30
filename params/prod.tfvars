aws_region = "us-east-1"

################################################################################
# Auth
################################################################################

service_token_shared_key_path = "/prod/auth/service-token-shared-key"

################################################################################
# Service endpoints
################################################################################

filesystem_service_public_endpoint_path = "/prod/filesystem/public-service-endpoint"
cloud_service_public_endpoint_path      = "/prod/cloud/public-service-endpoint"
notebook_service_public_endpoint_path   = "/prod/notebook/public-service-endpoint"
cloud_service_private_endpoint_path     = "/prod/cloud/private-service-endpoint"

################################################################################
# Analytics
################################################################################

mixpanel_project_id_path = "/prod/analytics/mixpanel-project-id"

################################################################################
# Eventing
################################################################################

kafka_address_path        = "/prod/eventing/kafka-address"
runtime_status_topic_path = "/prod/eventing/runtime-status-topic"
