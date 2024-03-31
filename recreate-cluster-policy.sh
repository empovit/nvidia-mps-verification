#!/usr/bin/env bash

set -ex
set -o pipefail

oc delete clusterpolicy gpu-cluster-policy --ignore-not-found
sleep 30
oc apply -f cluster-policy.yaml
