# us-east-1 was chosen because:
# (a) cloudfront certicates used to register custom domains in
# cognito can only be created in us-east-1
# (b) Cognito requires that SES be configured in one of these regions:
# eu-west-1, us-east-1, us-west-2
aws_region = "us-east-1"

################################################################################
# Domains
################################################################################

domain     = "kubis.ai"
subdomains = ["*.kubis.ai"]

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

email_identities = ["noreply@kubis.ai", "mdc.nathalia@gmail.com", "tanel.sarnet@gmail.com"]

################################################################################
# Authentication (Firebase)
################################################################################

auth_domain               = "auth.kubis.ai"
firebase_auth_domain_path = "/prod/auth/firebase-auth-domain"

################################################################################
# Container registry
################################################################################

repository_list = ["website"]

################################################################################
# CI/CD
################################################################################

cicd_domain = "cicd.kubis.ai"

