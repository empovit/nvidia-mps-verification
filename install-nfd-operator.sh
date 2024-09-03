#!/usr/bin/env bash

set -e
set -o pipefail

NFD_OPERATOR_NAMESPACE=openshift-nfd

oc apply -f nfd-operator.yaml

timeout 120s bash -c "until oc get csv -n ${NFD_OPERATOR_NAMESPACE} -o name; do sleep 10; done"
CSV_NAME=$(oc get csv -n ${NFD_OPERATOR_NAMESPACE} -o name)
oc wait --for=jsonpath='{.status.reason}'=InstallSucceeded --timeout=360s -n ${NFD_OPERATOR_NAMESPACE} ${CSV_NAME}

timeout 60s bash -c "until oc get deployment nfd-controller-manager -n ${NFD_OPERATOR_NAMESPACE} -o name; do sleep 10; done"
oc rollout status deployment nfd-controller-manager -n ${NFD_OPERATOR_NAMESPACE}

NFD_INSTANCE=$(oc get ${CSV_NAME} -n ${NFD_OPERATOR_NAMESPACE} -o jsonpath='{.metadata.annotations.alm-examples}' | jq -r 'map(select(.kind == "NodeFeatureDiscovery")) | .[0]')
oc apply -f - <<EOF
$NFD_INSTANCE
EOF
