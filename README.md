Overview
========

This layer enables hardware assisted video decoding in Chromium via the Chromium
V4L2VDA, using the [v4l-gst libv4l plugin](https://github.com/igel-oss/v4l-gst)
to connect it to the Renesas H/W video decoder available through GStreamer.

Currently, only the H.264 & H.265 video codec is supported.

Building
========

1. Add this layer to your `bblayers.conf` file

2. Add the following packages to your `IMAGE_INSTALL:append` variable in your `local.conf`
   * v4l-gst

3. `bitbake` as usual.


Configuration
=============

The settings file for the v4l-gst bridge is located at ```/etc/xdg/libv4l-gst.conf```.
This file allows for specifying the GStreamer pipeline that the plugin will
attempt to use to decode the video frames that it receives from the V4L2
interface.
