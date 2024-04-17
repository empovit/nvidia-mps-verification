#!/usr/bin/env bash

set -e
set -o pipefail

NODE=$(oc get node -o name | head -1)
oc debug $NODE
