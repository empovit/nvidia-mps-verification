#!/usr/bin/env bash

set -e
set -o pipefail

GPU_OPERATOR_NAMESPACE=${GPU_OPERATOR_NAMESPACE:-"nvidia-gpu-operator"}

PODS=$(oc get pod -o name -n $GPU_OPERATOR_NAMESPACE | grep 'nvidia-driver-daemonset')
for pod in $PODS; do
    oc exec -ti $pod -n $GPU_OPERATOR_NAMESPACE -- nvidia-smi $*
done
