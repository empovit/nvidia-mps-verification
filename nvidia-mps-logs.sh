#!/usr/bin/env bash

set -ex
set -o pipefail

NAMESPACE=nvidia-gpu-operator

PODS=$(oc get pod -o name -n $NAMESPACE | grep 'nvidia-device-plugin-mps-control-daemon')
for pod in $PODS; do
    oc logs $pod -n $NAMESPACE
done