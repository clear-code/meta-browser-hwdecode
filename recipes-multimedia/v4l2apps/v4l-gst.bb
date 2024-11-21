SECTION = "libs"
LICENSE = "LGPL-2.1"
LIC_FILES_CHKSUM = "file:///${COMMON_LICENSE_DIR}/LGPL-2.1;md5=1a6d268fd218675ffea8be556788b780"

SECTION = "libs"

DEPENDS = "gstreamer1.0 v4l-utils gstreamer1.0-plugins-base"

SRC_URI = "git://github.com/clear-code/v4l-gst.git;protocol=https;branch=try-rzg2l-support \
	   file://libv4l-gst.conf \
          "

SRCREV = "806cbb11d58f66e19f8746d1abe8e45f8964bf7d"

S = "${WORKDIR}/git"

inherit autotools pkgconfig

EXTRA_OECONF += "--enable-chromium-compatibility"

do_install_append () {
	install -d ${D}/usr/local/include
	install -m 0644 ${S}/lib/include/libv4l-gst-bufferpool.h ${D}/usr/local/include
	install -m 0644 -D ${WORKDIR}/libv4l-gst.conf ${D}/etc/xdg/libv4l-gst.conf
}

FILES_${PN}-dbg += "\
	${libdir}/libv4l/plugins/.debug \
	${libdir}/libv4l/plugins/.debug/*.so \
"

FILES_${PN}-dev += "\
	${libdir}/libv4l/plugins/*.la \
"

FILES_${PN}-headers = "/usr/local/include"

FILES_${PN} += "\
	${libdir}/libv4l/plugins/*.so \
"

PACKAGES += "\
	${PN}-headers \
"

