# Copyright (C) 2019, Fuzhou Rockchip Electronics Co., Ltd
# Released under the MIT license (see COPYING.MIT for the terms)

MAJ_VER = "${@oe.utils.trim_version("${PV}", 3)}"
PATCHPATH = "${CURDIR}/chromium_${MAJ_VER}"
inherit auto-patch

PACKAGECONFIG ??= "use-egl use-linux-v4l2 proprietary-codecs"
PACKAGECONFIG[use-linux-v4l2] = "use_v4l2_codec=true use_v4lplugin=true use_linux_v4l2_only=true"

GN_ARGS:append = " fatal_linker_warnings=false"

# Switch to ANGLE, since the newer ozone requires passthrough command decoder.
# See:
# https://issues.chromium.org/issues/40135856
#CHROMIUM_EXTRA_ARGS:remove = "--use-gl=egl"
#CHROMIUM_EXTRA_ARGS:append = " --use-gl=angle --use-angle=gles-egl --use-cmd-decoder=passthrough"

# Add these options by default to unify development emviroments.
# In production enviroment, the need for these options are case by case.
CHROMIUM_EXTRA_ARGS:append = " --no-sandbox --in-process-gpu "

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Fixup v8_qemu_wrapper library search path for component build
# see https://github.com/OSSystems/meta-browser/issues/314
do_configure:append() {
	WRAPPER=${B}/v8-qemu-wrapper.sh
	[ -e ${WRAPPER} ] &&
		sed -i "s#\(LD_LIBRARY_PATH=\)#\1${B}:#" ${WRAPPER}
}

INSANE_SKIP:${PN} = "already-stripped"
