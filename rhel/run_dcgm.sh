#!/usr/bin/env bash

#========================================================
# Copy from nvcr.io/nvidia/cloud-native/dcgm:3.3.3-1-ubi9
# and add to PATH:
# - /usr/bin/dcgmproftester12
# - /usr/lib64/libdcgm*
#========================================================

COUNT=${COUNT:-1}
DURATION=${DURATION:-180}
DCGM_ARGS=(${DCGM_ARGS:---duration $DURATION --mode "generate load" --no-dcgm-validation -t 1004})

echo "Arguments: ${DCGM_ARGS[@]}"

for i in $(seq 1 $COUNT)
do
	echo
	echo "=== client $i ==="
        ./dcgmproftester12 "${DCGM_ARGS[@]}" &
	sleep 5
done

sleep ${DURATION}
killall -9 dcgmproftester12
