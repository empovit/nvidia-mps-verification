#!/usr/bin/env bash

set -ex
set -o pipefail

NAMESPACE=nvidia-gpu-operator

PODS=$(oc get pod -o name -n $NAMESPACE | grep 'nvidia-device-plugin-mps-control-daemon')
for pod in $PODS; do
    oc exec -ti $pod -n $NAMESPACE -- /bin/sh -c "export CUDA_MPS_PIPE_DIRECTORY=/mps/nvidia.com/gpu/pipe; echo \"$@\" | nvidia-cuda-mps-control"
done