#!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
PW=1
LIB_PATH="$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH=$LIB_PATH
CAPSET_PATH=/tmp/virgl-test.capset
WL_DIS=wayland-test
PORT_TEST=55668 
GLCTS_LOCATION=${DIR}/../opengles-cts/build/external/openglcts/modules
set -e

pids=()
exit_handler() {
    for p in "${pids[@]}"; do
        echo $PW| sudo -S  kill -9  "$p"
        echo "Process $p finished."
    done
    wt_pid=$(pgrep -x "weston")
    echo $PW| sudo -S  kill -9 $wt_pid
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
sleep 1
echo $PW| sudo -S  pkill rvgpu-renderer*
sleep 1
$DIR/../build/src/rvgpu-renderer/rvgpu-renderer -b 1280x720@0,0 -p 55668 &

echo $PW| sudo -S ${DIR}/proxy.sh $CAPSET_PATH&
echo "run rvgpu-proxy"
sleep 1

echo run weston
echo $PW| sudo -S "${DIR}/weston.sh" &
sleep 2
set +e
echo $PW| sudo -S bash -c "cd $GLCTS_LOCATION; rm *.qpa"
echo $PW| sudo -S bash -c "cd $GLCTS_LOCATION; WAYLAND_DISPLAY=$WL_DIS XDG_RUNTIME_DIR=/tmp  ${GLCTS_LOCATION}/cts-runner --type=es3 --summary"
echo $?

function execute_test_file(){
    local TMP_FILE=$(mktemp)
    cfg=$1
    echo "Run: $cfg"
    echo ""
    cat ${GLCTS_LOCATION}/${cfg}* | grep "commandLineParameters" > $TMP_FILE
    cat $TMP_FILE
    option=$(cat $TMP_FILE| sed -n 's/.*"\(.*\)".*/\1/p' | sed 's/--deqp-log-images=disable/--deqp-log-images=enable/' | sed 's/--deqp-log-shader-sources=disable/--deqp-log-shader-sources=enable/' | sed 's/--deqp-log-images=disable/--deqp-log-images=enable/'  | sed -E "s/--deqp-log-filename=[^ ]+/--deqp-log-filename=${cfg}.qpa/")
    echo $option
    echo $PW| sudo -S bash -c " cd $GLCTS_LOCATION; WAYLAND_DISPLAY=$WL_DIS XDG_RUNTIME_DIR=/tmp ${GLCTS_LOCATION}/glcts $option" &
    pids+=($!)
}
execute_test_file "config-egl-main-cfg-1-" 
execute_test_file "config-gles2-main-cfg-1-" 
execute_test_file "config-gles2-khr-main-cfg-1-" 
execute_test_file "config-gles3-khr-main-cfg-1-" 
execute_test_file "config-gles3-multisample-cfg-1-" 
execute_test_file "config-gles3-main-cfg-1-"

for pid in "${pids[@]}"; do
    wait "$pid"
    echo "Process $pid finished."
done

exit 0