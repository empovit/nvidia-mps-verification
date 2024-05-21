#!/usr/bin/env bash

set -e
set -o pipefail

oc apply -f nfd-operator.yaml
CSV_NAME=$(oc get csv -n openshift-nfd -o name)
oc wait --for=jsonpath='{.status.phase}'=Succeeded --timeout=360s -n openshift-nfd ${CSV_NAME}
oc apply -f nfd-instance.yaml
