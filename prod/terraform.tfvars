default_aws_region = "us-east-2"

################################################################################
# Domains
################################################################################

domain      = "kubis.ai"
subdomains  = ["*.kubis.ai"]
auth_domain = "auth.kubis.ai"

################################################################################
# VPC
################################################################################

cidr = "10.0.0.0/16"

private_subnets = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]

public_subnets = [
  "10.0.4.0/24",
  "10.0.5.0/24",
  "10.0.6.0/24"
]

################################################################################
# Cluster
################################################################################

cluster_name = "kubis-prod"

kubernetes_version = "1.21"

spot_workers = {
  name                 = "spot"
  instance_type        = "m5.large"
  asg_desired_capacity = 2
  asg_min_size         = 2
  asg_max_size         = 3
  spot_price           = "0.1"
  kubelet_extra_args   = "--node-labels=node.kubernetes.io/lifecycle=spot"
}

kubeconfig_output_path = "./prod.kubeconfig"

################################################################################
# DNS
################################################################################

enable_tls = true

################################################################################
# Email
################################################################################

email_aws_region = "us-east-1"
email_identities = ["noreply@kubis.ai"]

################################################################################
# Authentication
################################################################################

auth_from_email_address = "Kubis <noreply@kubis.ai>"

################################################################################
# Kratos
################################################################################

kratos_db_username             = "kratos"
kratos_db_password_secret_name = "prod/kratos/db-password"

identity_default_schema_filepath = "./config/user.schema.json"
google_oauth2_mapper_filepath    = "./config/oidc.google.jsonnet"

google_oauth2_client_id          = "468602998216-dqeit9si4d034ehmbovq16hr3c8c0i2m.apps.googleusercontent.com"
google_oauth2_client_id_name     = "/prod/auth/google-oauth2-client-id"
google_oauth2_client_secret_name = "/prod/auth/google-oauth2-client-secret"
google_oauth2_scope              = "{email, profile}"
