#!/usr/bin/env bash

set -ex
set -o pipefail

NAMESPACE=nvidia-gpu-operator

PODS=$(oc get pod -o name -n $NAMESPACE | grep 'nvidia-driver-daemonset')
for pod in $PODS; do
    oc exec -ti $pod -n $NAMESPACE -- nvidia-smi
done
