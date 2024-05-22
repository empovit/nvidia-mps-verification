#!/usr/bin/env bash

set -e
set -o pipefail

GPU_OPERATOR_NAMESPACE=${GPU_OPERATOR_NAMESPACE:-"nvidia-gpu-operator"}

help_text="Usage: $0 \"<command>\"
Some available get commands:

* get_server_list
* get_server_status PID
* get_client_list PID
* get_device_client_list PID
* get_default_active_thread_percentage
* get_active_thread_percentage PID
* get_default_device_pinned_mem_limit dev
* get_default_device_pinned_mem_limit PID dev
* get_default_client_priority

Full list of available commands can be found at https://docs.nvidia.com/deploy/mps/index.html#nvidia-cuda-mps-control"

if [[ "$@" == "" ]]; then
    echo "$help_text"
    exit 1
fi

PODS=$(oc get pod -o name -n $GPU_OPERATOR_NAMESPACE | grep 'nvidia-device-plugin-mps-control-daemon')
for pod in $PODS; do
    oc exec -ti $pod -n $GPU_OPERATOR_NAMESPACE -c mps-control-daemon-ctr -- /bin/sh -c "export CUDA_MPS_PIPE_DIRECTORY=/mps/nvidia.com/gpu/pipe; echo \"$@\" | nvidia-cuda-mps-control"
done