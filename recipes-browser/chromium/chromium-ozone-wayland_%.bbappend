# Copyright (C) 2024, Rockchip Electronics Co., Ltd
# Copyright (C) 2025, ClearCode Inc.
# SPDX-License-Identifier: MIT

def chromium_wayland_text_input_version_arg(d):
    try:
        major_version = int((d.getVar("PV") or "0").split(".", 1)[0])
    except ValueError:
        return ""

    if major_version < 135:
        return ""

    return " --wayland-text-input-version=1"

CHROMIUM_EXTRA_ARGS:append = " --enable-wayland-ime"
CHROMIUM_EXTRA_ARGS:append = "${@chromium_wayland_text_input_version_arg(d)}"
GN_ARGS:append = " use_system_libwayland=true "
