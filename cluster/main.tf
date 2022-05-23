terraform {
  backend "s3" {
    key = "cluster/terraform.tfstate"
  }

  # Added in order to use 'optional()' in variables.
  experiments = [module_variable_optional_attrs]
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-state-kubis"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  http_node_port        = 32080
  https_node_port       = 32443
  health_check_port     = 32021
  health_check_path     = "/healthz/ready"
  health_check_protocol = "HTTP"
}

################################################################################
# Cluster
################################################################################

module "cluster" {
  source             = "git@github.com:kubis-ai/terraform-modules.git//modules/cluster"
  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnets

  enable_irsa = true

  allow_traffic_from_alb = true
  alb_security_group_id  = module.alb.security_group_id
  application_ports      = [local.http_node_port, local.https_node_port, local.health_check_port]

  write_kubeconfig       = true
  kubeconfig_output_path = var.kubeconfig_output_path

  worker_groups_launch_template = [{
    name                    = var.spot_workers.name
    instance_type           = var.spot_workers.instance_type
    override_instance_types = var.spot_workers.override_instance_types,
    asg_desired_capacity    = var.spot_workers.asg_desired_capacity
    asg_min_size            = var.spot_workers.asg_min_size
    asg_max_size            = var.spot_workers.asg_max_size
    spot_price              = var.spot_workers.spot_price
    kubelet_extra_args      = var.spot_workers.kubelet_extra_args,
    target_group_arns       = values(module.alb.target_group_arns)
  }]
}

################################################################################
# DNS (TLS certificates)
################################################################################

module "dns" {
  source = "git@github.com:kubis-ai/terraform-modules.git//modules/dns"

  domain             = var.domain
  subdomains         = var.subdomains
  create_certificate = true
}

module "mymlops_dns" {
  source = "git@github.com:kubis-ai/terraform-modules.git//modules/dns"

  domain             = var.mymlops_domain
  subdomains         = var.mymlops_subdomains
  create_certificate = true
}

################################################################################
# Application Load Balancer
################################################################################

module "alb" {
  source = "git@github.com:kubis-ai/terraform-modules.git//modules/alb"
  name   = "alb"

  vpc_id     = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.network.outputs.public_subnets

  enable_tls          = true
  tls_certificate_arn = module.dns.certificate_arn

  idle_timeout = 1200

  applications = {
    http = {
      protocol              = "HTTP",
      protocol_version      = "HTTP1"
      path_pattern          = "*",
      node_port             = local.http_node_port,
      health_check_path     = local.health_check_path,
      health_check_port     = local.health_check_port,
      health_check_protocol = local.health_check_protocol,
    },
    https = {
      protocol              = "HTTPS",
      protocol_version      = "HTTP1"
      path_pattern          = "*",
      node_port             = local.https_node_port,
      health_check_path     = local.health_check_path,
      health_check_port     = local.health_check_port,
      health_check_protocol = local.health_check_protocol,
    },
  }
}

module "mymlops_alb" {
  source = "git@github.com:kubis-ai/terraform-modules.git//modules/alb"
  name   = "mymlops-alb"

  vpc_id     = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.network.outputs.public_subnets

  enable_tls          = true
  tls_certificate_arn = module.mymlops_dns.certificate_arn

  idle_timeout = 1200

  applications = {
    http = {
      protocol              = "HTTP",
      protocol_version      = "HTTP1"
      path_pattern          = "*",
      node_port             = local.http_node_port,
      health_check_path     = local.health_check_path,
      health_check_port     = local.health_check_port,
      health_check_protocol = local.health_check_protocol,
    },
    https = {
      protocol              = "HTTPS",
      protocol_version      = "HTTP1"
      path_pattern          = "*",
      node_port             = local.https_node_port,
      health_check_path     = local.health_check_path,
      health_check_port     = local.health_check_port,
      health_check_protocol = local.health_check_protocol,
    },
  }
}
