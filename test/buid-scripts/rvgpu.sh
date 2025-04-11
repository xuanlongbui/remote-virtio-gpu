#!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
set -e
pushd $DIR/../..
# cd remote-virtio-gpu
cmake -B build -DCMAKE_BUILD_TYPE=Release
make -C build
popd
exit 0