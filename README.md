# Infrastucture

This module constains the definitions for all infrastructure used in Kubis.

## How to install?

The infrastructure must be provisioned in two steps.

1. Create the remote backend for Terraform. This creates an S3 bucket where Terraform stores the state and a DynamoDB table where Terraform stores the lock. Once created, the parameters of this backend must be copied to `backend.hcl`.

```
cd global
terraform apply
```

2.  Right now the state associated with the remote backend resources is stored locally. Open the file `global/main.tf` and add a Terraform configuration block

```
terraform {
  backend "s3" {
    key = "global/terraform.tfstate"
  }
}
```

Then migrate the state to the remote backend by running the following command:

```
cd global
terraform init -migrate-state -backend-config=../backend.hcl
```

3. For every module check that the remote backend and any `terraform_remote_state` resources are properly configured. For instance in `cluster`:

```
terraform {
  backend "s3" {
    key = "cluster/terraform.tfstate"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-state-kubis"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}
```

4. Now the remaining infrastucture can be provisioned by running `hack/create.sh` and selecting the option 'All'. This script will bring up the whole production infrastructure and register the cluster with `kubectl`.

```
cd hack
bash create.sh
```

## How to uninstall?

Uninstalling is done in three steps:

1. Destroy the production infrastructure and deregister the cluster in `kubectl` by running `hack/destroy.sh` with the option 'All'. Only the infrastructure related to Terraform's remote backend will remain.

```
cd hack
bash destroy.sh
```

2. In order to destroy the infrastructure associated with the remote backend (S3 buckets and DynamoDB tables), we must first switch to a local backend. Open the file `global/main.tf` and comment out the `terraform` configuration block. Reinitialize terraform with

```
cd global
terraform init -migrate-state
```

and then destroy the backend infrastructure (you might first have to set `force_destroy = true` in `terraform.tfvars`):

```
terraform destroy
```

## What is not managed by Terraform?

- Firebase project used for authentication. At the time of development, Firebase did not exist in the Terraform GCP provider so the Firebase project was created manually. Only DNS records creation is included in Terraform.
- Route53: creation of a hosted zone with NS records associated with the domain. This was done manually after registering the domain with namecheap.com
- AWS Parameter Store: some of the parameters and secrets are added manually (for example, Google OAuth2 id and secret, GitHub tokens, etc).
- IAM User for Nathalia
- WorkMail organization and users (DNS records are managed by Terraform)
