SECTION = "libs"
LICENSE = "LGPL-2.1"
LIC_FILES_CHKSUM = "file:///${COMMON_LICENSE_DIR}/LGPL-2.1-only;md5=1a6d268fd218675ffea8be556788b780"

SECTION = "libs"

DEPENDS = "gstreamer1.0 v4l-utils gstreamer1.0-plugins-base"

SRC_URI = "git://github.com/clear-code/v4l-gst.git;protocol=https;branch=try-rzg2l-v4.0-support \
	   file://libv4l-gst.conf \
	   file://v4l-gst.service \
	   file://setup-v4l-gst.sh \
          "

SRCREV = "e140c8c99dacabe0b9f17b985a924aa73e504e94"

S = "${WORKDIR}/git"

inherit autotools pkgconfig systemd

EXTRA_OECONF += "--enable-chromium-compatibility"

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN} = "v4l-gst.service"

do_install:append () {
	install -d ${D}/usr/local/include
	install -m 0644 ${S}/lib/include/libv4l-gst-bufferpool.h ${D}/usr/local/include
	install -m 0644 -D ${WORKDIR}/libv4l-gst.conf ${D}/etc/xdg/libv4l-gst.conf
	install -d ${D}/${systemd_unitdir}/system
	install -m 0644 -D ${WORKDIR}/v4l-gst.service ${D}/${systemd_unitdir}/system
	localbindir=/usr/local/bin
	install -d ${D}${localbindir}
	install -m 0755 -D ${WORKDIR}/setup-v4l-gst.sh ${D}${localbindir}/setup-v4l-gst.sh
}

FILES:${PN}-dbg += "\
	${libdir}/libv4l/plugins/.debug \
	${libdir}/libv4l/plugins/.debug/*.so \
"

FILES:${PN}-dev += "\
	${libdir}/libv4l/plugins/*.la \
"

FILES:${PN}-headers = "/usr/local/include"

FILES:${PN} += "\
	${libdir}/libv4l/plugins/*.so \
	${systemd_unitdir}/system/v4l-gst.service \
	/usr/local/bin/setup-v4l-gst.sh \
"

PACKAGES += "\
	${PN}-headers \
"

