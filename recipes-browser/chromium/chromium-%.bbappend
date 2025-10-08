# Copyright (C) 2019, Fuzhou Rockchip Electronics Co., Ltd
# Copyright (C) 2024-2025, ClearCode Inc.
# Released under the MIT license (see COPYING.MIT for the terms)

MAJ_VER = "${@oe.utils.trim_version("${PV}", 3)}"
PATCHPATH = "${CURDIR}/chromium_${MAJ_VER}"
inherit auto-patch

PACKAGECONFIG ??= "use-egl use-linux-v4l2 proprietary-codecs"
PACKAGECONFIG[use-linux-v4l2] = "use_v4l2_codec=true use_v4lplugin=true use_linux_v4l2_only=true"

GN_ARGS:append = " fatal_linker_warnings=false"

# Need to escape '/' because this value is proccessed by sed with '/' delimiter
CHROMIUM_EXTRA_ARGS:append:rzg3e-family = " --dri-render-node-path=\/dev\/dri\/card0 "
CHROMIUM_EXTRA_ARGS:append = " --in-process-gpu "
CHROMIUM_EXTRA_ARGS:append = " --enable-features=AcceleratedVideoDecoder,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL "
CHROMIUM_EXTRA_ARGS:append = " --disable-background-media-suspend "

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Fixup v8_qemu_wrapper library search path for component build
# see https://github.com/OSSystems/meta-browser/issues/314
do_configure:append() {
	WRAPPER=${B}/v8-qemu-wrapper.sh
	[ -e ${WRAPPER} ] &&
		sed -i "s#\(LD_LIBRARY_PATH=\)#\1${B}:#" ${WRAPPER}
}

INSANE_SKIP:${PN} = "already-stripped"
