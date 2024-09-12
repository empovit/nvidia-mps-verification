#!/usr/bin/env bash

COUNT=${COUNT:-1}
DURATION=${DURATION:-180}
DCGM_ARGS=(${DCGM_ARGS:---duration $DURATION --mode "generate load" --no-dcgm-validation -t 1004})
CUDA_MPS_PIPE_DIRECTORY=${CUDA_MPS_PIPE_DIRECTORY:-"/tmp/nvidia-mps"}

echo "Arguments: ${DCGM_ARGS[@]}"

for i in $(seq 1 $COUNT)
do
	echo
	echo "=== client $i ==="
	podman run -ti --privileged --rm \
		--name "dcgmproftester-$i" \
		--device nvidia.com/gpu=all --security-opt=label=disable \
		-v "${CUDA_MPS_PIPE_DIRECTORY}":/tmp/nvidia-mps \
		--entrypoint /usr/bin/dcgmproftester12  nvcr.io/nvidia/cloud-native/dcgm:3.3.3-1-ubi9 \
		"${DCGM_ARGS[@]}" &
	sleep 5
done

sleep ${DURATION}
for c in $(podman ps -f name=dcgmproftester- --noheading --format {{.Names}})
do
	echo "Stopping container \"$c\" after about $DURATION seconds"
	podman stop $c
done
