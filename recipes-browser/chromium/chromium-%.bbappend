# Copyright (C) 2019, Fuzhou Rockchip Electronics Co., Ltd
# Copyright (C) 2024-2026, ClearCode Inc.
# SPDX-License-Identifier: MIT

MAJ_VER = "${@oe.utils.trim_version("${PV}", 3)}"
PATCHPATH = "${CURDIR}/chromium_${MAJ_VER}"
inherit auto-patch

PACKAGECONFIG ??= "use-egl ${@bb.utils.contains('COMBINED_FEATURES', 'hwh264dec', 'use-v4l2 proprietary-codecs', '', d)}"
PACKAGECONFIG[use-v4l2] = "use_v4l2_codec=true use_v4lplugin=true"
PACKAGECONFIG[use-v4l2-overlay] = ""

python __anonymous() {
    packageconfig = (d.getVar("PACKAGECONFIG") or "").split()
    if "use-v4l2-overlay" in packageconfig and "use-v4l2" not in packageconfig:
        packageconfig.append("use-v4l2")
        d.setVar("PACKAGECONFIG", " ".join(packageconfig))
}

def chromium_feature_arg(d, variable, option):
    features = []
    for feature in (d.getVar(variable) or "").replace(",", " ").split():
        if feature not in features:
            features.append(feature)

    if not features:
        return ""

    return "%s=%s" % (option, ",".join(features))

def chromium_has_upstream_v4l2_enable_features(d):
    try:
        major_version = int((d.getVar("PV") or "0").split(".", 1)[0])
    except ValueError:
        return False

    return major_version >= 138

def chromium_should_emit_enable_features(d):
    packageconfig = (d.getVar("PACKAGECONFIG") or "").split()
    return "use-v4l2-overlay" in packageconfig or \
           not chromium_has_upstream_v4l2_enable_features(d)

def chromium_enable_features_arg(d):
    if not chromium_should_emit_enable_features(d):
        return ""

    return chromium_feature_arg(d, "CHROMIUM_ENABLE_FEATURES",
                                "--enable-features")

def chromium_mali_dri_render_node_arg(d):
    if d.getVar("PREFERRED_PROVIDER_virtual/libgbm") != "mali-library":
        return ""

    # Need to escape '/' because this value is processed by sed with '/' delimiter.
    return " --render-node-override=\\/dev\\/dri\\/card0 "

def chromium_v4l2_no_scale_overlay_feature(d):
    if bb.utils.contains("BBFILE_COLLECTIONS", "meta-panfrost", True, False, d):
        # Need to escape '/' because this value is processed by sed with '/'
        # delimiter.
        return " V4L2NoScaleOverlay:panfrost_workarounds\\/true"

    return " V4L2NoScaleOverlay"

RDEPENDS:${PN} += "${@bb.utils.contains('PACKAGECONFIG', 'use-v4l2', 'v4l-gst', '', d)}"

GN_ARGS:append = " fatal_linker_warnings=false"

CHROMIUM_ENABLE_FEATURES = ""
CHROMIUM_DISABLE_FEATURES = ""
CHROMIUM_ENABLE_FEATURES:append = "${@bb.utils.contains('PACKAGECONFIG', 'use-v4l2', ' AcceleratedVideoDecoder AcceleratedVideoDecodeLinuxGL AcceleratedVideoDecodeLinuxZeroCopyGL', '', d)}"
CHROMIUM_ENABLE_FEATURES:append = "${@bb.utils.contains('PACKAGECONFIG', 'use-v4l2-overlay', chromium_v4l2_no_scale_overlay_feature(d), '', d)}"

CHROMIUM_UPSTREAM_V4L2_ENABLE_FEATURES_ARG = "--enable-features=AcceleratedVideoDecoder,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL"
CHROMIUM_EXTRA_ARGS:remove = "${@bb.utils.contains('PACKAGECONFIG', 'use-v4l2-overlay', d.getVar('CHROMIUM_UPSTREAM_V4L2_ENABLE_FEATURES_ARG'), '', d)}"

CHROMIUM_EXTRA_ARGS:append = "${@chromium_mali_dri_render_node_arg(d)}"
CHROMIUM_EXTRA_ARGS:append = " --in-process-gpu "
CHROMIUM_EXTRA_ARGS:append = " \
  ${@chromium_enable_features_arg(d)} \
  ${@chromium_feature_arg(d, 'CHROMIUM_DISABLE_FEATURES', '--disable-features')} \
  ${@bb.utils.contains('PACKAGECONFIG', 'use-v4l2', '--disable-v4l2-media-suspend', '', d)} \
"

# Fixup v8_qemu_wrapper library search path for component build
# see https://github.com/OSSystems/meta-browser/issues/314
do_configure:append() {
    WRAPPER=${B}/v8-qemu-wrapper.sh
    [ -e ${WRAPPER} ] && sed -i "s#\(LD_LIBRARY_PATH=\)#\1${B}:#" ${WRAPPER}
}

INSANE_SKIP:${PN} = "already-stripped"
