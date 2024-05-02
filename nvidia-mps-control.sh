#!/usr/bin/env bash

set -e
set -o pipefail

GPU_OPERATOR_NAMESPACE=${GPU_OPERATOR_NAMESPACE:-"nvidia-gpu-operator"}

PODS=$(oc get pod -o name -n $GPU_OPERATOR_NAMESPACE | grep 'nvidia-device-plugin-mps-control-daemon')
for pod in $PODS; do
    oc exec -ti $pod -n $GPU_OPERATOR_NAMESPACE -- /bin/sh -c "export CUDA_MPS_PIPE_DIRECTORY=/mps/nvidia.com/gpu/pipe; echo \"$@\" | nvidia-cuda-mps-control"
done