# Copyright (C) 2024, Rockchip Electronics Co., Ltd
# Copyright (C) 2025, ClearCode Inc.
# Released under the MIT license (see COPYING.MIT for the terms)

CHROMIUM_EXTRA_ARGS:append = " --enable-wayland-ime"
GN_ARGS:append = " use_system_libwayland=true "
