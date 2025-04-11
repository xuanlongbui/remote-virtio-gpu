#!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
PW=1
LIB_PATH="$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH=$LIB_PATH
CAPSET_PATH=/tmp/virgl-test.capset
WL_DIS=wayland-test
PORT_TEST=55668 
GLCTS_LOCATION=${DIR}/..

/opengles-cts/build/external/openglcts/modules
set -e

exit_handler() {
    pid=$(pgrep -x "weston")
    echo $PW| sudo -S  kill -9 $pid
    echo $PW| sudo -S  pkill rvgpu-proxy*
    sleep 2
    echo $PW| sudo -S  pkill rvgpu-renderer*
    sleep 1
}

trap exit_handler SIGINT EXIT SIGTERM SIGALRM
$DIR/../build/src/rvgpu-renderer/rvgpu-renderer -b 1280x720@0,0 -p 55668  -c $CAPSET_PATH &
sleep 1
echo $PW| sudo -S modprobe virtio-gpu
echo $PW| sudo -S modprobe virtio-lo
echo run proxy
echo $PW| sudo -S ${DIR}/proxy.sh &
echo "run rvgpu-proxy"
sleep 1

echo $PW| sudo -S  pkill rvgpu-proxy*
sleep 2

echo $PW| sudo -S ${DIR}/proxy.sh $CAPSET_PATH&
echo "run rvgpu-proxy"
sleep 1

echo run weston
echo $PW| sudo -S "${DIR}/weston.sh" &
sleep 2

echo $PW| sudo -S bash -c "cd $GLCTS_LOCATION; WAYLAND_DISPLAY=$WL_DIS XDG_RUNTIME_DIR=/tmp  ${GLCTS_LOCATION}/cts-runner --type=es3"
exit 0