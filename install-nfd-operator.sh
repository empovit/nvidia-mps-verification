#!/usr/bin/env bash

set -e
set -o pipefail

NFD_OPERATOR_NAMESPACE=openshift-nfd

oc apply -f nfd-operator.yaml

sleep 20
CSV_NAME=$(oc get csv -n ${NFD_OPERATOR_NAMESPACE} -o name)

oc wait --for=jsonpath='{.status.phase}'=Succeeded --timeout=360s -n ${NFD_OPERATOR_NAMESPACE} ${CSV_NAME}

NFD_INSTANCE=$(oc get ${CSV_NAME} -n ${NFD_OPERATOR_NAMESPACE} -o jsonpath='{.metadata.annotations.alm-examples}' | jq -r 'map(select(.kind == "NodeFeatureDiscovery")) | .[0]')
oc apply -f - <<EOF
$NFD_INSTANCE
EOF
