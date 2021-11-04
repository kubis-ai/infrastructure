#!/bin/bash

################################################
# Helpers
################################################

load_paths() {
    . ./paths.sh
}

destroy() {
    cd $1
    echo '[+] Executing terraform destroy'
    terraform destroy -var-file=$TFVARS
}

delete_cluster_credentials() {
    cd $1
    kubectl config delete-cluster $(terraform output -raw cluster_arn)
    kubectl config delete-context $(terraform output -raw cluster_arn)
    kubectl config delete-user $(terraform output -raw cluster_arn)
}

################################################
# Module scoped-functions
################################################

destroy_network() {
    echo '[+] Destroying network'
    destroy $NETWORK
}

destroy_cluster() {
    echo '[+] Deleting kubectl cluster credentials'
    delete_cluster_credentials $CLUSTER

    echo '[+] Destroying cluster'
    destroy $CLUSTER 
}

destroy_charts() {
    echo '[+] Destroying charts'
    destroy $CHARTS
}

destroy_services() {
    echo '[+] Destroying services'
    destroy $SERVICES
}

################################################
# Menu
################################################

load_paths

while true; do
    options=("Network" "Cluster" "Charts" "Services" "All")

    echo "Select a module to destroy: "
    select opt in "${options[@]}"; do
        case $opt in
            "Network")
                destroy_network
                break
                ;;
            "Cluster")
                destroy_cluster
                break
                ;;
            "Charts")
                destroy_charts
                break
                ;;
            "Services")
                destroy_services
                break
                ;;
            "All")
                destroy_network
                destroy_cluster
                destroy_charts
                destroy_services
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
done
