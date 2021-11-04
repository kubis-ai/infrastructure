aws_region = "us-east-1"

################################################################################
# DNS (TLS certificates)
################################################################################

domain     = "kubis.ai"
subdomains = ["*.kubis.ai"]

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
