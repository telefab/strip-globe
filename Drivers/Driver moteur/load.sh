#!/bin/sh

/sbin/insmod ./custom_module.ko $* || exit 1

speed_major=`cat /proc/devices | awk "\\$2==\"speed\" {print \\$1}"`


rm -f /dev/speed
mknod /dev/speed c $speed_major 129









