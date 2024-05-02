#!/usr/bin/env bash

set -e
set -o pipefail

GPU_OPERATOR_NAMESPACE=${GPU_OPERATOR_NAMESPACE:-"nvidia-gpu-operator"}

oc delete catalogsource gpu-operator-certified-catalog -n $GPU_OPERATOR_NAMESPACE --ignore-not-found
oc delete subscription gpu-operator-certified-v23-9-2-sub -n $GPU_OPERATOR_NAMESPACE --ignore-not-found
oc delete operatorgroup nvidia-gpu-operator -n $GPU_OPERATOR_NAMESPACE --ignore-not-found
oc delete namespaces $GPU_OPERATOR_NAMESPACE --ignore-not-found
