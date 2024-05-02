#!/usr/bin/env bash

set -e
set -o pipefail

if [[ $1 == "" ]]; then
    echo "Provide a plugin-config file"
    exit 1
fi

GPU_OPERATOR_NAMESPACE=${GPU_OPERATOR_NAMESPACE:-"nvidia-gpu-operator"}

oc delete configmap --ignore-not-found plugin-config -n $GPU_OPERATOR_NAMESPACE
oc create configmap plugin-config --from-file=plugin-config.yaml=$1 -n $GPU_OPERATOR_NAMESPACE
