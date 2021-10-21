terraform {
  backend "s3" {
    key = "prod/terraform.tfstate"
  }

  # Added in order to use 'optional()' in variables.
  experiments = [module_variable_optional_attrs]
}

provider "aws" {
  region = var.aws_region
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

  alias = [
    {
      source  = var.domain,
      target  = module.nlb.dns_name
      zone_id = module.nlb.zone_id
    },
    {
      source  = var.cicd_domain
      target  = module.nlb.dns_name
      zone_id = module.nlb.zone_id
    },
    {
      source  = var.auth_domain,
      target  = module.auth.cloudfront_distribution_arn,
      zone_id = "Z2FDTNDATAQYW2" # This zone_id is fixed for cloudfront
    }
  ]
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

  domain           = var.domain
  email_identities = var.email_identities
  aws_region       = var.aws_region
}

################################################################################
# Authentication
################################################################################

module "auth" {
  source = "git@github.com:kubis-ai/terraform-modules.git//modules/auth"

  # Secrets and parameters
  cognito_client_id_path           = var.cognito_client_id_path
  cognito_user_pool_id_path        = var.cognito_user_pool_id_path
  cognito_custom_domain_path       = var.cognito_custom_domain_path
  google_oauth2_client_id_path     = var.google_oauth2_client_id_path
  google_oauth2_client_secret_path = var.google_oauth2_client_secret_path

  # Email
  from_email_address      = var.auth_from_email_address
  ses_domain_identity_arn = module.email.domain_identity_arn

  # Endpoints used in automatic emails
  account_validation_endpoint          = "https://${var.domain}/auth/account-verification"
  password_reset_confirmation_endpoint = "https://${var.domain}/auth/redefine-password"

  # Tokens
  id_token_validity      = "1"
  access_token_validity  = "1"
  refresh_token_validity = "24"

  # Domain for UI hosted by Amazon Cognito. Used for social identity providers
  custom_domain          = var.auth_domain
  domain_certificate_arn = module.dns.certificate_arn
}

################################################################################
# Container registry
################################################################################

module "container_registry" {
  source = "git@github.com:kubis-ai/terraform-modules.git//modules/container-registry"

  repository_list      = var.repository_list
  image_tag_mutability = "IMMUTABLE"
  enable_scan_on_push  = true
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

  create_iam_user            = true
  aws_access_key_id_path     = "/prod/tekton/aws-access-key-id"
  aws_access_key_secret_path = "/prod/tekton/aws-access-key-secret"

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
  aws_region              = var.aws_region
  oidc_provider_arn       = module.cluster.oidc_provider_arn
  cluster_oidc_issuer_url = module.cluster.cluster_oidc_issuer_url

  depends_on = [module.cert_manager]
}

