#!/usr/bin/env bash

for i in $(ps -C gpu_burn | grep -v PID | awk '{print $1}')
do
	kill -9 $i
done