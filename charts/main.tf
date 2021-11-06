terraform {
  backend "s3" {
    key = "charts/terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    config_path = data.terraform_remote_state.cluster.outputs.kubeconfig_path
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "terraform-state-kubis"
    key    = "cluster/terraform.tfstate"
    region = "us-east-1"
  }
}

################################################################################
# cert-manager
################################################################################

module "cert_manager" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/cert-manager"
  chart_version = "v1.6.1"
}

################################################################################
# NGINX Ingress Controller
################################################################################

module "nginx_ingress" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/nginx-ingress"
  chart_version = "0.10.0"

  service_type    = "NodePort"
  controller_kind = "daemonset"

  http_node_port    = data.terraform_remote_state.cluster.outputs.http_node_port
  https_node_port   = data.terraform_remote_state.cluster.outputs.https_node_port
  health_check_path = data.terraform_remote_state.cluster.outputs.health_check_path

  depends_on = [module.cert_manager]
}

################################################################################
# Istio
################################################################################

module "istio_base" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/istio-base"
  chart_version = "1.11.4"
}

module "istio_discovery" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/istio-discovery"
  chart_version = "1.11.4"
  depends_on    = [module.istio_base]
}

################################################################################
# Kiali
################################################################################

module "kiali_operator" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/kiali-operator"
  chart_version = "1.42.0"
  depends_on    = [module.istio_discovery]
}

################################################################################
# External Secrets
################################################################################

module "external_secrets" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/external-secrets"
  chart_version = "8.3.0"

  enable_irsa             = true
  aws_region              = var.aws_region
  oidc_provider_arn       = data.terraform_remote_state.cluster.outputs.oidc_provider_arn
  cluster_oidc_issuer_url = data.terraform_remote_state.cluster.outputs.cluster_oidc_issuer_url

  depends_on = [module.cert_manager]
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

  depends_on = [module.cert_manager]
}

################################################################################
# Tekton Triggers
################################################################################

module "tekton_triggers" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/tekton-triggers"
  chart_version = "0.16.1"

  depends_on = [module.tekton_pipelines]
}

################################################################################
# Tekton Dashboard
################################################################################

module "tekton_dashboard" {
  source        = "git@github.com:kubis-ai/terraform-modules.git//modules/apps/tekton-dashboard"
  chart_version = "0.20.0"

  depends_on = [module.tekton_pipelines]
}
