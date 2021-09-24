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
  subnet_ids = module.vpc.public_subnets

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
# NGINX Ingress Controller
################################################################################

module "nginx_ingress" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/ingress-nginx-nginxcorp"
  chart_version = "0.10.0"

  service_type    = "NodePort"
  controller_kind = "daemonset"

  http_node_port    = local.http_node_port
  https_node_port   = local.https_node_port
  health_check_path = local.health_check_path

  depends_on = [module.cluster]
}

################################################################################
# Tekton Pipelines
################################################################################

module "tekton_pipelines" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/tekton-pipelines"
  chart_version = "0.27.3"

  depends_on = [module.cluster]
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
# ArgoCD
################################################################################

module "argocd" {
  source    = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/argocd"
  namespace = "argocd"

  variant       = "argocd"
  chart_version = "3.17.5"

  depends_on = [module.cluster]
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
}

################################################################################
# cert-manager
################################################################################

module "cert_manager" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/cert-manager"
  chart_version = "1.1.1"

  depends_on = [module.cluster]
}
