#!/usr/bin/env bash

# Install DCGM:
# https://docs.nvidia.com/datacenter/dcgm/latest/user-guide/getting-started.html#installation

COUNT=${COUNT:-1}
DURATION=${DURATION:-120}
DCGM_ARGS=(${DCGM_ARGS:---duration $DURATION --mode "generate load" --no-dcgm-validation -t 1004})

echo "Arguments: ${DCGM_ARGS[@]}"

for i in $(seq 1 $COUNT)
do
	echo
	echo "=== client $i ==="
	/usr/bin/dcgmproftester12 "${DCGM_ARGS[@]}" &
	sleep 5
done
wait