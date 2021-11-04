#! /usr/bin/env bash

ROOT="$(dirname $(dirname $(realpath $0)) )"

NETWORK="${ROOT}/network"
CLUSTER="${ROOT}/cluster"
CHARTS="${ROOT}/charts"
SERVICES="${ROOT}/services"

BACKEND="${ROOT}/backend.hcl"
TFVARS="./prod.tfvars"
