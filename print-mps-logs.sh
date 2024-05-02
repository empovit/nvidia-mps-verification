#!/usr/bin/env bash

set -e
set -o pipefail

GPU_OPERATOR_NAMESPACE=${GPU_OPERATOR_NAMESPACE:-"nvidia-gpu-operator"}

PODS=$(oc get pod -o name -n $GPU_OPERATOR_NAMESPACE | grep 'nvidia-device-plugin-mps-control-daemon')
for pod in $PODS; do
    oc logs $pod -n $GPU_OPERATOR_NAMESPACE
done