#!/usr/bin/env bash

set -e
set -o pipefail

GPU_OPERATOR_NAMESPACE=${GPU_OPERATOR_NAMESPACE:-"nvidia-gpu-operator"}
BUNDLE=${BUNDLE:-"registry.gitlab.com/nvidia/kubernetes/gpu-operator/staging/gpu-operator-bundle:master-latest"}

oc create namespace $GPU_OPERATOR_NAMESPACE

# echo "WARNING: Will apply 'pod-security.kubernetes.io/enforce=privileged' label to the namespace"
# oc label namespace $GPU_OPERATOR_NAMESPACE pod-security.kubernetes.io/enforce=privileged  --overwrite

operator-sdk run bundle --timeout=20m -n $GPU_OPERATOR_NAMESPACE --install-mode OwnNamespace ${BUNDLE}