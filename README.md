# Overview

This layer provides browser integration for Renesas RZ/G platforms.

It extends the vendor BSP with packages, configuration, and workarounds
required to build and run a modern web browser environment. The current
implementation is based on Chromium, but the layer is intended to provide
general browser integration rather than being Chromium-specific.

The layer includes:

* Browser package groups for RZ/G platforms
* Browser runtime packages and configuration
* Browser-specific BSP workarounds when required
* Hardware-assisted video decoding support using the Chromium V4L2 video
  decoder and the v4l-gst bridge

Currently, hardware-assisted video decoding supports H.264 and H.265 through
GStreamer-based vendor decoders.

# Building

Assuming the Renesas BSP has already been set up, clone the required layers.

The Chromium recipe depends on external layers such as `meta-clang` and
`meta-lts-mixins`. Since Chromium is sensitive to layer revisions, we recommend
using the tested revision combination below.

## Supported layer combination

```console
$ (git clone https://github.com/kraj/meta-clang.git && \
   cd meta-clang && \
   git checkout eea5ec23155cfd47781599fdc9a92c21e4caffc8)
$ (git clone https://git.yoctoproject.org/meta-lts-mixins && \
   cd meta-lts-mixins && \
   git checkout a8046d5ec53b1856169ac795aa87cb0d5db84c04)
$ git clone --branch rzg-scarthgap/chromium132-20260508 --single-branch \
  https://github.com/clear-code/meta-browser.git
$ git clone \
  https://github.com/clear-code/meta-rz-browser.git
```

Then initialize the build environment:
```console
$ source poky/oe-init-build-env
$ bitbake-layers add-layer ../meta-clang
$ bitbake-layers add-layer ../meta-lts-mixins
$ bitbake-layers add-layer ../meta-browser/meta-chromium
$ bitbake-layers add-layer ../meta-rz-browser
```

Build the image:
```console
$ MACHINE=<your-machine> bitbake core-image-weston
```

The layer automatically extends the vendor BSP through dynamic layers when the
corresponding RZ/G layers are present.

## Additional build configuration

### `use-v4l2-overlay`

To additionally enable the experimental V4L2 no-scale hardware overlay path,
add the following to your `conf/local.conf`:

```conf
PACKAGECONFIG:append:pn-chromium-ozone-wayland = " use-v4l2-overlay"
```

The `use-v4l2-overlay` option is intended for RZ/G Wayland/Weston systems where
decoded NV12 dmabufs can be promoted to a KMS plane without scaling or cropping.
It is kept separate from `use-v4l2` because it can affect composition behavior,
such as drawing video above overlapping HTML controls. Enabling
`use-v4l2-overlay` also enables `use-v4l2`.

### Disabling Chromium managed policy

By default, this layer installs a Chromium managed policy file that suppresses
startup dialogs commonly undesirable in embedded environments, including the
command-line flag security warning shown when the `--no-sandbox` is used and the
browser sign-in prompt.

To restore the default Chromium behavior, add the following to your
`conf/local.conf`:

```conf
RDEPENDS:packagegroup-rz-browser:remove = "chromiumpolicy"
```

# Running

Build and boot the generated image as usual.

Chromium can be started normally, for example:

```console
$ chromium
```

Hardware-assisted video decoding is enabled automatically when the required
multimedia components are available.

If you want to launch Chromium as the root user (e.g. via serial console), you
need the `--no-sandbox` option:

```console
# chromium --no-sandbox
```

# License

Unless otherwise noted, this repository is licensed under the MIT License.

Files with separate copyright or license notices are governed by those notices.
Patch files may be governed by the license of the upstream project to which they
apply.

New code and documentation added by ClearCode Inc. are Copyright (C) 2024-2026
ClearCode Inc. and licensed under the MIT License.
