terraform {
  backend "s3" {
    key = "prod/terraform.tfstate"
  }

  # Added in order to use 'optional()' in variables.
  experiments = [module_variable_optional_attrs]
}

provider "aws" {
  region = var.default_aws_region
}

provider "aws" {
  alias  = "email"
  region = var.email_aws_region
}

provider "helm" {
  kubernetes {
    config_path = module.cluster.kubeconfig_filename
  }
}

locals {
  http_node_port        = 32080
  https_node_port       = 32443
  health_check_path     = "/healthz"
  health_check_port     = 32080
  health_check_protocol = "HTTP"
}

data "aws_availability_zones" "available" {}

################################################################################
# VPC
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.66.0"

  name                 = "${var.cluster_name}-vpc"
  cidr                 = var.cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

################################################################################
# Cluster
################################################################################

module "cluster" {
  source             = "git@github.com:kubis-ai/terraform-modules.git//modules/cluster"
  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  allow_traffic_from_nlb = true
  cidr_blocks            = ["0.0.0.0/0"]
  node_ports             = [local.http_node_port, local.https_node_port, local.health_check_port]

  write_kubeconfig       = true
  kubeconfig_output_path = var.kubeconfig_output_path

  worker_groups = [{
    name                 = var.spot_workers.name
    asg_desired_capacity = var.spot_workers.asg_desired_capacity
    asg_max_size         = var.spot_workers.asg_max_size
    asg_min_size         = var.spot_workers.asg_min_size
    instance_type        = var.spot_workers.instance_type
    spot_price           = var.spot_workers.spot_price
    target_group_arns    = module.nlb.target_group_arns
  }]
}

################################################################################
# DNS
################################################################################

module "dns" {
  source = "git@github.com:kubis-ai/terraform-modules.git//modules/dns"

  domain             = var.domain
  subdomains         = var.subdomains
  create_certificate = var.enable_tls
  enable_aliasing    = true
  alias = {
    dns_name = module.nlb.dns_name
    zone_id  = module.nlb.zone_id
  }
}

################################################################################
# Network Load Balancer
################################################################################

module "nlb" {
  source = "git@github.com:kubis-ai/terraform-modules.git//modules/nlb"
  name   = "${var.cluster_name}-nlb"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  http_node_port      = local.http_node_port
  https_node_port     = local.https_node_port
  tls_certificate_arn = module.dns.certificate_arn

  health_check_path     = local.health_check_path
  health_check_port     = local.health_check_port
  health_check_protocol = local.health_check_protocol

  enable_access_logs      = true
  access_logs_bucket_name = "nlb-access-logs-kubis-prod"
}

################################################################################
# Email
################################################################################

module "email" {
  source = "git@github.com:kubis-ai/terraform-modules.git//modules/email"
  providers = {
    aws = aws.email
  }

  domain           = var.domain
  email_identities = var.email_identities
  aws_region       = var.email_aws_region
}

################################################################################
# Authentication
################################################################################

data "aws_ssm_parameter" "google_oauth2_client_secret" {
  name = var.google_oauth2_client_secret_name
}

data "aws_ssm_parameter" "google_oauth2_client_id" {
  name = var.google_oauth2_client_id_name
}

resource "aws_cognito_user_pool" "users" {
  name = "users"

  auto_verified_attributes = ["email"]

  alias_attributes = ["email", "phone_number"]

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }

  email_configuration {
    email_sending_account = "DEVELOPER"
    source_arn            = module.email.domain_identity_arn
    from_email_address    = var.auth_from_email_address
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = false
    temporary_password_validity_days = 7
  }

  username_configuration {
    case_sensitive = false
  }

  schema {
    name                     = "name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }
}

resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.users.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "profile email openid"
    client_id        = data.aws_ssm_parameter.google_oauth2_client_id.value
    client_secret    = data.aws_ssm_parameter.google_oauth2_client_secret.value
  }

  attribute_mapping = {
    email       = "email"
    family_name = "family_name"
    given_name  = "given_name"
    name        = "name"
    picture     = "picture"
    username    = "sub"
  }
}

resource "aws_cognito_user_pool_client" "website" {
  name         = "kubis-website"
  user_pool_id = aws_cognito_user_pool.users.id

  id_token_validity       = "1"
  access_token_validity   = "1"
  refresh_token_validity  = "24"
  enable_token_revocation = true

  token_validity_units {
    id_token      = "hours"
    access_token  = "hours"
    refresh_token = "hours"
  }

  generate_secret = true

  supported_identity_providers         = [aws_cognito_identity_provider.google.provider_name]
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = [
    "aws.cognito.signin.user.admin",
    "email",
    "openid",
    "profile",
  ]
  callback_urls = ["http://localhost:3000"]
  logout_urls   = ["http://localhost:3000"]

  prevent_user_existence_errors = "ENABLED"
}

resource "aws_ssm_parameter" "cognito_client_id" {
  name        = "/prod/auth/cognito-website-client-id"
  description = "The id for the website client giving access to Cognito."
  type        = "String"
  value       = aws_cognito_user_pool_client.website.id
}

resource "aws_ssm_parameter" "cognito_client_secret" {
  name        = "/prod/auth/cognito-website-client-secret"
  description = "The secret for the website client giving access to Cognito."
  type        = "SecureString"
  value       = aws_cognito_user_pool_client.website.client_secret
}

################################################################################
# cert-manager
################################################################################

module "cert_manager" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/cert-manager"
  chart_version = "1.1.1"

  depends_on = [module.cluster]
}

################################################################################
# NGINX Ingress Controller
################################################################################

module "nginx_ingress" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/nginx-ingress"
  chart_version = "0.10.0"

  service_type    = "NodePort"
  controller_kind = "daemonset"

  http_node_port    = local.http_node_port
  https_node_port   = local.https_node_port
  health_check_path = local.health_check_path

  depends_on = [module.cluster, module.cert_manager]
}

################################################################################
# Tekton Pipelines
################################################################################

module "tekton_pipelines" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/tekton-pipelines"
  chart_version = "0.27.3"

  depends_on = [module.cluster, module.cert_manager]
}

################################################################################
# Tekton Triggers
################################################################################

module "tekton_triggers" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/tekton-triggers"
  chart_version = "0.16.1"

  depends_on = [module.cluster, module.tekton_pipelines]
}

################################################################################
# Tekton Dashboard
################################################################################

module "tekton_dashboard" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/tekton-dashboard"
  chart_version = "0.20.0"

  depends_on = [module.cluster, module.tekton_pipelines]
}

################################################################################
# External Secrets
################################################################################

module "external_secrets" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/external-secrets"
  chart_version = "8.3.0"

  enable_irsa             = true
  aws_region              = var.default_aws_region
  oidc_provider_arn       = module.cluster.oidc_provider_arn
  cluster_oidc_issuer_url = module.cluster.cluster_oidc_issuer_url

  depends_on = [module.cert_manager]
}

################################################################################
# Kratos
################################################################################

module "kratos_db" {
  source = "git@github.com:kubis-ai/terraform-modules.git//modules/data-stores/kratos-data-store"

  name                   = "kratosdb"
  instance_class         = "db.t4g.micro"
  allocated_storage      = 5
  password_secret_name   = var.kratos_db_password_secret_name
  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [module.cluster.worker_security_group_id]
  deletion_protection    = false
}

module "kratos" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/kratos"
  chart_version = "0.19.5"
  release_tag   = "v0.7.6-alpha.1"

  log_level = "debug"

  host                 = var.auth_domain
  path                 = "/"
  cors_allowed_origins = "{http://localhost:3000}"

  default_browser_return_url       = var.domain
  identity_default_schema_filepath = abspath(var.identity_default_schema_filepath)

  smtp_connection_uri     = "${module.email.smtp_email_send_uri}/?skip_ssl_verify=false"
  database_connection_uri = "${module.kratos_db.connection_uri}?max_conns=20&max_idle_conns=4"

  enable_password = true
  enable_oidc     = true

  enable_google_oauth2          = true
  google_oauth2_client_id       = data.aws_ssm_parameter.google_oauth2_client_id.value
  google_oauth2_client_secret   = data.aws_ssm_parameter.google_oauth2_client_secret.value
  google_oauth2_mapper_filepath = abspath(var.google_oauth2_mapper_filepath)
  google_oauth2_scope           = var.google_oauth2_scope

  depends_on = [module.cluster, module.cert_manager]
}
