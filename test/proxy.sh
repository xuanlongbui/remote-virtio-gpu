#!/bin/bash
set -e
DIR="$( cd "$( dirname "$0" )" && pwd )"
if [ -z "$1" ]; then
	CAPSET_ARG=""
else
	CAPSET_PATH=$1
	CAPSET_ARG="-c $CAPSET_PATH"
fi
$DIR/../build/src/rvgpu-proxy/rvgpu-proxy -s 1280x720@0,0 -n 127.0.0.1:55668 $CAPSET_ARG
