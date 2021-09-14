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

  worker_groups_launch_template = [{
    name                    = var.worker_group_launch_template.name
    instance_type           = var.worker_group_launch_template.instance_type
    override_instance_types = var.worker_group_launch_template.override_instance_types
    asg_desired_capacity    = var.worker_group_launch_template.asg_desired_capacity
    asg_min_size            = var.worker_group_launch_template.asg_min_size
    asg_max_size            = var.worker_group_launch_template.asg_max_size
    spot_price              = var.worker_group_launch_template.spot_price
    target_group_arns       = []
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

################################################################################
# Jenkins Operator
################################################################################

module "jenkins_operator" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/jenkins-operator"
  namespace     = "jenkins-operator"
  chart_version = "0.5.3"
}
