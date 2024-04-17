#!/usr/bin/env bash

set -e
set -o pipefail

NAMESPACE=nvidia-gpu-operator

oc delete catalogsource gpu-operator-certified-catalog -n $NAMESPACE --ignore-not-found
oc delete subscription gpu-operator-certified-v23-9-2-sub -n $NAMESPACE --ignore-not-found
oc delete operatorgroup nvidia-gpu-operator -n $NAMESPACE --ignore-not-found
oc delete namespaces $NAMESPACE --ignore-not-found
