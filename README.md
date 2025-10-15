Overview
========

This layer enables hardware assisted video decoding in Chromium via the Chromium
V4L2VideoDecoder + V4L2VideoDecoderBackendStateful, using the
[v4l-gst libv4l plugin](https://github.com/clear-code/v4l-gst) to connect it to
the H/W video decoder of Renesas RZ/G series available through GStreamer.

Currently, only H.264 & H.265 video codec are supported.

Building
========

1. Add this layer & meta-rz-codecs layer to your `bblayers.conf` file  
   e.g.)
   ```console
   $ bitbake-layers add-layer ../meta-rz-features/meta-rz-codecs
   $ bitbake-layers add-layer ../meta-browser-hwdecode
   ```
2. Build as usual  
   e.g.)
   ```console
   $ bitbake chromium-ozone-wayland
   ```

Configuration
=============

The settings file for the v4l-gst bridge is located at `/etc/xdg/libv4l-gst.conf`.
This file allows for specifying the GStreamer pipeline that the plugin will
attempt to use to decode the video frames that it receives from the V4L2
interface.

e.g.)
```ini
[libv4l-gst]
min-buffers=2

[H264]
pipeline=h264parse ! omxh264dec

[HEVC]
pipeline=h265parse ! omxh265dec
```

Running with Chromium
=====================

Run as usual:
```console
$ chromium file:///path/to/some/h264-video.html
```
