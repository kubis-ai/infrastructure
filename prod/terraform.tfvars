aws_region = "us-east-2"
domain     = "kubis.ai"

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
# Application load balancer
################################################################################

applications = {}

enable_tls = false
