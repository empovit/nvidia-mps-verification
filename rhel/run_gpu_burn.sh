#!/usr/bin/env bash

# Requires GPU burn binaries
# https://github.com/wilicc/gpu-burn

COUNT=${COUNT:-1}
DURATION=${DURATION:-120}
MEM_FACTOR=${MEM_FACTOR:-1}
MEM=$((100/COUNT*MEM_FACTOR))

echo "Requested memory: ${MEM}%"

for i in $(seq 1 $COUNT)
do
	echo
	echo "=== client $i ==="
	./gpu_burn -m ${MEM}% ${DURATION}  &
	sleep 5
done
wait