#!/usr/bin/env bash

set -e
set -o pipefail

oc apply -f nfd-operator.yaml

CSV_NAME=$(oc get csv -n openshift-nfd -o name)

oc wait --for=jsonpath='{.status.phase}'=Succeeded --timeout=360s -n openshift-nfd ${CSV_NAME}

NFD_INSTANCE=$(oc get ${CSV_NAME} -n openshift-nfd -o jsonpath='{.metadata.annotations.alm-examples}' | jq -r 'map(select(.kind == "NodeFeatureDiscovery")) | .[0]')
oc apply -f - <<EOF
$NFD_INSTANCE
EOF
