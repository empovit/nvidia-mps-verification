#!/usr/bin/env bash

set -ex
set -o pipefail

NAMESPACE=nvidia-gpu-operator
BUNDLE=registry.gitlab.com/nvidia/kubernetes/gpu-operator/staging/gpu-operator-bundle:master-latest

oc create namespace $NAMESPACE
# oc label namespace $NAMESPACE pod-security.kubernetes.io/enforce=privileged  --overwrite
operator-sdk run bundle --timeout=20m -n $NAMESPACE --install-mode OwnNamespace ${BUNDLE}