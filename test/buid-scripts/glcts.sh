 #!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
set -e
cd $DIR/../../
git submodule update --init --recursive
pushd $DIR/../../opengles-cts
set +e
patch -p1 -N < $DIR/patch/patch.diff
mkdir build; cd build
set -e
python3 $DIR/../../opengles-cts/external/fetch_sources.py --insecure
cmake .. -DDEQP_TARGET=wayland -DGLCTS_GTF_TARGET=gles3 -DCMAKE_BUILD_TYPE=Release
cmake --build external/openglcts/
popd
exit 0