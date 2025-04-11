 #!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
echo "$DIR"
set -e
pushd $DIR/../opengles-cts
git checkout remotes/origin/opengl-es-cts-3.2.11
patch -p1 < $DIR/patch/patch.diff
python3 external/fetch_sources.py --insecure
mkdir build; cd build
cmake .. -DDEQP_TARGET=wayland -DGLCTS_GTF_TARGET=gles3 -DCMAKE_BUILD_TYPE=Release
cmake --build external/openglcts/
popd
exit 0