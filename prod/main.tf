terraform {
  backend "s3" {
    key = "prod/terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    config_path = module.cluster.kubeconfig_filename
  }
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
  enable_nat_gateway   = false
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

  write_kubeconfig       = true
  kubeconfig_output_path = var.kubeconfig_output_path

  worker_groups = [{
    name              = var.worker_group.name
    instance_type     = var.worker_group.instance_type
    desired_capacity  = var.worker_group.desired_capacity
    min_capacity      = var.worker_group.min_capacity
    max_capacity      = var.worker_group.max_capacity
    target_group_arns = []
  }]
}

################################################################################
# Application load balancer
################################################################################

module "alb" {
  source = "git@github.com:kubis-ai/terraform-modules.git//modules/alb"
  name   = "${var.cluster_name}-alb"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  enable_irsa             = true
  oidc_provider_arn       = module.cluster.oidc_provider_arn
  cluster_oidc_issuer_url = module.cluster.cluster_oidc_issuer_url

  enable_tls = var.enable_tls
}

################################################################################
# ArgoCD (argocd-vault-plugin)
################################################################################

module "argocd" {
  source    = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/argocd"
  namespace = "argocd"

  variant       = "argocd-vault-plugin"
  chart_version = "1.3.1"
}

################################################################################
# Vault
################################################################################

module "vault" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/vault"
  namespace     = "vault"
  chart_version = "0.15.0"
}
