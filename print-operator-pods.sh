#!/usr/bin/env bash

set -e
set -o pipefail

NAMESPACE=nvidia-gpu-operator
oc get pod -n $NAMESPACE
