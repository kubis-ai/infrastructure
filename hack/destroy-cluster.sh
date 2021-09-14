#! /usr/bin/env bash

ROOT_FOLDER="../prod"
cd $ROOT_FOLDER

echo '[+] Deleting kubectl cluster credentials...'
kubectl config delete-cluster $(terraform output -raw cluster_arn)
kubectl config delete-context $(terraform output -raw cluster_arn)
kubectl config delete-user $(terraform output -raw cluster_arn)

echo '[+] Destroying cluster...'
terraform destroy