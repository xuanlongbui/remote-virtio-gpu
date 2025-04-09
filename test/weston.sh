#!/bin/bash
# export LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu/
#export LD_PRELOAD=/home/prdcv/Documents/virglrenderer-1.0.1/build/src/libvirglrenderer.so.1.8.9:/home/prdcv/Documents/libepoxy/build/src/libepoxy.so.0.0.0
export XDG_RUNTIME_DIR=/tmp 
weston --backend drm-backend.so --tty=2 --seat=seat_virtual -i 0 -Swayland-1
