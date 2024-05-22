#!/usr/bin/env bash

set -e
set -o pipefail

export GPU_OPERATOR_NAMESPACE="nvidia-gpu-operator"
MPS_CONFIG_FILE=${MPS_CONFIG_FILE:-"mps-configs/plugin-config-10.yaml"}

oc apply -f gpu-operator.yaml


read -p "Deploy MPS config and cluster policy (y/n)? " deploy_cp
case ${deploy_cp:0:1} in
    y|Y|yes|Yes )
        sleep 20
        CSV_NAME=$(oc get csv -n ${GPU_OPERATOR_NAMESPACE} -o name)
        oc wait --for=jsonpath='{.status.phase}'=Succeeded --timeout=360s -n ${GPU_OPERATOR_NAMESPACE} ${CSV_NAME}
        ./update-mps-config.sh ${MPS_CONFIG_FILE}
        ./update-cluster-policy.sh
    ;;
    * )
        echo "Skipped creating a cluster policy with MPS"
    ;;
esac
