#!/usr/bin/env bash

set -e
set -o pipefail

if [[ $1 == "" ]]; then
    echo "Provide a plugin-config file"
    exit 1
fi

NAMESPACE=nvidia-gpu-operator
oc delete configmap --ignore-not-found plugin-config -n $NAMESPACE
oc create configmap plugin-config --from-file=plugin-config.yaml=$1 -n $NAMESPACE
