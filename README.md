# Infrastucture

This module constains the definitions for all infrastructure used in Kubis.

## How to install?

The infrastructure must be provisions in two steps.

1. Create the remote backend for Terraform. This creates an S3 bucket where Terraform stores the state and a DynamoDB table where Terraform stores the lock. Once created, the parameters of this backend must be copied to `backend-prod.hcl`. The creation of these modules is done locally. After the remote backend is ready, it must be used so that the state is copied.

2. Once the `backend-prod.hcl` file is created, the remaining infrastucture can be provisioned by running `hack/create-cluster.sh`. This script will not only initialize the backend, it will create the infrastructure and register the cluster with `kubectl`.

## How to uninstall?

Uninstalling of the main infrastructure can be done with `hack/destroy-cluster.sh`. Only the infrastructure related to Terraform's remote backend will remain. First, we must switch to a local backend so we can destroy the S3 buckets and DynamoDB tables.
