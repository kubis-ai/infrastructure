#! /usr/bin/env bash

ROOT_FOLDER="../"
cd $ROOT_FOLDER

echo '[+] Initializing Terraform...'
terraform init -backend-config=../backend-prod.hcl

echo '[+] Creating cluster...'
terraform apply

echo '[+] Saving kubectl cluster credentials...'
# Workaround to avoid failure when there are currently no clusters or contexts in config
# See https://github.com/aws/aws-cli/issues/4843
sed -i 's/: null/: []/g' ~/.kube/config && \
aws eks update-kubeconfig --name $(terraform output -raw cluster_name) --region $(terraform output -raw aws_region)  