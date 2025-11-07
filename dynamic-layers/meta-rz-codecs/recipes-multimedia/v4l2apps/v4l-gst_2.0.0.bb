SECTION = "libs"
LICENSE = "LGPL-2.1-or-later"
LIC_FILES_CHKSUM = "file:///${COMMON_LICENSE_DIR}/LGPL-2.1-or-later;md5=2a4f4fd2128ea2f65047ee63fbca9f68"

SECTION = "libs"

DEPENDS = "gstreamer1.0 v4l-utils gstreamer1.0-plugins-base"

V4L_GST_CONF_SRC = "${@bb.utils.contains('COMBINED_FEATURES', 'hwh265dec', 'libv4l-gst-h265.conf', 'libv4l-gst.conf', d)}"

SRC_URI = "git://github.com/clear-code/v4l-gst.git;protocol=https;branch=main \
	   file://${V4L_GST_CONF_SRC} \
	   file://v4l-gst.service \
	   file://setup-v4l-gst.sh \
          "

SRCREV = "2cb1e07423cb943036397576769cd2e0b4d2d239"

PV .= "+git"

S = "${WORKDIR}/git"

inherit autotools pkgconfig systemd

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "v4l-gst.service"

do_install:append () {
	install -d ${D}${includedir}
	install -m 0644 ${S}/lib/include/libv4l-gst-bufferpool.h ${D}${includedir}
	install -m 0644 -D ${WORKDIR}/${V4L_GST_CONF_SRC} ${D}/etc/xdg/libv4l-gst.conf
	install -d ${D}/${systemd_unitdir}/system
	install -m 0644 -D ${WORKDIR}/v4l-gst.service ${D}/${systemd_unitdir}/system
	install -d ${D}${libexecdir}
	install -m 0755 -D ${WORKDIR}/setup-v4l-gst.sh ${D}${libexecdir}/v4l-gst/setup-v4l-gst.sh
}

FILES:${PN}-dbg += "\
	${libdir}/libv4l/plugins/.debug \
	${libdir}/libv4l/plugins/.debug/*.so \
"

FILES:${PN}-dev += "\
	${libdir}/libv4l/plugins/*.la \
"

FILES:${PN}-headers = "${includedir}"

FILES:${PN} += "\
	${libdir}/libv4l/plugins/*.so \
	${systemd_unitdir}/system/v4l-gst.service \
	${libexecdir}/v4l-gst/setup-v4l-gst.sh \
"

PACKAGES += "\
	${PN}-headers \
"

