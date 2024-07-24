#!/usr/bin/env bash

set -e
set -o pipefail

GPU_OPERATOR_NAMESPACE=${GPU_OPERATOR_NAMESPACE:-"nvidia-gpu-operator"}

operator-sdk cleanup gpu-operator-certified -n $GPU_OPERATOR_NAMESPACE
oc delete namespace $GPU_OPERATOR_NAMESPACE
