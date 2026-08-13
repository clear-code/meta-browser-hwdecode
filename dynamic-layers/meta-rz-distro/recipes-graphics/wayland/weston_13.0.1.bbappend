FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
        file://0001-backend-drm-keep-NV12-overlays-under-software-cursor.patch \
"

