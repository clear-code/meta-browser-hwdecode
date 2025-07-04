#!/bin/sh

if [ $(id -u) -ne 0 ]; then
    echo "ERROR: run as root"
    exit 1
fi

function tweak_device_group()
{
    DEVICE=$1
    EXPECTED=$2
    echo "Checking $DEVICE group ..."
    if [ ! -f $DEVICE -a ! -c $DEVICE ]; then
        echo -e "[\e[35;1;40mERROR\e[0m] $DEVICE not found"
        touch $DEVICE
        chgrp video $DEVICE
        chmod 660 $DEVICE
        echo "Created $DEVICE"
    else
        device_group=$(ls -la $DEVICE | awk '{print $4}')
        if [ "$device_group" != "$EXPECTED" ]; then
            echo -e "[\e[35;1;40mERROR\e[0m] $DEVICE group is not video: $device_group"
            chgrp $EXPECTED $DEVICE
            chmod 660 $DEVICE
            echo "Fixed $DEVICE group to $EXPECTED"
        else
            echo -e "[\e[32;1;40mPASS\e[0m] $DEVICE group: $EXPECTED"
        fi
    fi
}

# tweak for weston user
tweak_device_group /dev/video-dec video
tweak_device_group /dev/videc-enc video
tweak_device_group /dev/image-proc video
tweak_device_group /dev/jpeg-dec video
tweak_device_group /dev/jpeg-enc video

tweak_device_group /dev/rgnmm video
tweak_device_group /dev/rgnmmbuf video

tweak_device_group /dev/uvcs video
tweak_device_group /dev/vspm_if video
