#!/bin/bash

################################################
# Helpers
################################################

load_paths() {
    . ./paths.sh
}

run_terraform_init() {
    cd $1
    echo '[+] Executing terraform init'
    terraform init -backend-config=$BACKEND
}

run_terraform_apply() {
    cd $1
    echo '[+] Executing terraform apply'
    terraform apply -var-file=$TFVARS
}

create() {
    run_terraform_init $1
    run_terraform_apply $1
}

save_cluster_credentials() {
    cd $1
    # Workaround to avoid failure when there are currently no clusters or contexts in config
    # See https://github.com/aws/aws-cli/issues/4843
    sed -i 's/: null/: []/g' ~/.kube/config && \
    aws eks update-kubeconfig --name $(terraform output -raw cluster_name) --region $(terraform output -raw aws_region)  
}

################################################
# Module scoped-functions
################################################

create_network() {
    echo '[+] Creating network'
    create $NETWORK
}

create_cluster() {
    echo '[+] Creating cluster'
    create $CLUSTER

    echo '[+] Saving kubectl cluster credentials'
    save_cluster_credentials $CLUSTER
}

create_charts() {
    echo '[+] Creating charts'
    create $CHARTS
}

create_services() {
    echo '[+] Creating services'
    create $SERVICES
}

################################################
# Menu
################################################

load_paths

while true; do
    options=("Network" "Cluster" "Charts" "Services" "All")

    echo "Select a module to create: "
    select opt in "${options[@]}"; do
        case $opt in
            "Network")
                create_network
                break
                ;;
            "Cluster")
                create_cluster
                break
                ;;
            "Charts")
                create_charts
                break
                ;;
            "Services")
                create_services
                break
                ;;
            "All")
                create_network
                create_cluster
                create_charts
                create_services
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
done
