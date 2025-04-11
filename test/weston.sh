#!/bin/bash
set -e
export XDG_RUNTIME_DIR=/tmp 
weston --backend drm-backend.so --tty=2 --seat=seat_virtual -i 0 -Swayland-test
