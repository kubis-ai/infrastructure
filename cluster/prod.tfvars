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
  name                    = "spot"
  instance_type           = "m5.large"
  override_instance_types = ["m5.large", "m5a.large", "m5d.large", "m5ad.large"]
  asg_desired_capacity    = 3
  asg_min_size            = 3
  asg_max_size            = 4
  spot_price              = "0.1"
  kubelet_extra_args      = "--node-labels=node.kubernetes.io/lifecycle=spot"
}

kubeconfig_output_path = "./prod.kubeconfig"
