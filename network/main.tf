terraform {
  backend "s3" {
    key = "network/terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

###############################################################################
# Network
###############################################################################

module "network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.66.0"

  name                 = "network"
  cidr                 = var.cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
