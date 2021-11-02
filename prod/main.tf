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
  local_domain          = "localhost:3000"
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
      source  = var.api_domain
      target  = module.nlb.dns_name
      zone_id = module.nlb.zone_id
    },
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
# Authentication (Firebase)
################################################################################

// Records needed for using custom domain in e-mails sent by Firebase
// and for custom domain hosting using in OAuth flows
data "aws_route53_zone" "kubis" {
  name = var.domain
}

resource "aws_route53_record" "firebase_cname_1" {
  zone_id = data.aws_route53_zone.kubis.zone_id
  name    = "firebase1._domainkey.kubis.ai"
  type    = "CNAME"
  ttl     = "5"

  records = ["mail-kubis-ai.dkim1._domainkey.firebasemail.com."]
}

resource "aws_route53_record" "firebase_cname_2" {
  zone_id = data.aws_route53_zone.kubis.zone_id
  name    = "firebase2._domainkey.kubis.ai"
  type    = "CNAME"
  ttl     = "5"

  records = ["mail-kubis-ai.dkim2._domainkey.firebasemail.com."]
}

resource "aws_route53_record" "firebase_txt" {
  zone_id = data.aws_route53_zone.kubis.zone_id
  name    = "kubis.ai"
  type    = "TXT"
  ttl     = "5"

  records = [
    "v=spf1 include:_spf.firebasemail.com ~all",
    "firebase=aerial-ceremony-330017",
    "google-site-verification=9QIbZRfgIYgDTW_KPR73dxSVTFYOxJrS__oduUlG6Pg"
  ]
}

resource "aws_route53_record" "firebase_auth_domain" {
  zone_id = data.aws_route53_zone.kubis.zone_id
  name    = var.auth_domain
  type    = "A"
  ttl     = "5"

  records = ["199.36.158.100"]
}

resource "aws_ssm_parameter" "firebase_auth_domain" {
  name        = var.firebase_auth_domain_path
  description = "The custom domain used by Firebase for authentication."
  type        = "String"
  value       = var.auth_domain
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

################################################################################
# Filesystem service
################################################################################

resource "aws_s3_bucket" "filesystem_object_store" {
  bucket = var.filesystem_bucket_name

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  force_destroy = false

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}


resource "aws_iam_user" "filesystem" {
  name = "FilesystemService"
}

resource "aws_iam_access_key" "filesystem" {
  user = aws_iam_user.filesystem.name
}


resource "aws_iam_user_policy" "filesystem_policy" {
  name = "S3AccessForFilesystemService"
  user = aws_iam_user.filesystem.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::*/*",
        "arn:aws:s3:::${aws_s3_bucket.filesystem_object_store.id}"
      ]
    }
  ]
}
EOF
}

resource "aws_ssm_parameter" "filesystem_bucket_name" {
  name        = var.filesystem_bucket_name_path
  description = "The name of the S3 bucket for the Filesystem service."
  type        = "String"
  value       = aws_s3_bucket.filesystem_object_store.id
}

resource "aws_ssm_parameter" "filesystem_endpoint" {
  name        = var.filesystem_endpoint_path
  description = "The S3 endpoint for the Filesystem service."
  type        = "String"
  value       = "s3.${aws_s3_bucket.filesystem_object_store.region}.amazonaws.com"
}


resource "aws_ssm_parameter" "filesystem_access_key_id" {
  name        = var.filesystem_access_key_id_path
  description = "The AWS access key id for the Filesystem service."
  type        = "String"
  value       = aws_iam_access_key.filesystem.id
}

resource "aws_ssm_parameter" "filesystem_access_key_secret" {
  name        = var.filesystem_access_key_secret_path
  description = "The AWS access key secret for the Filesystem service."
  type        = "SecureString"
  value       = aws_iam_access_key.filesystem.secret
}

