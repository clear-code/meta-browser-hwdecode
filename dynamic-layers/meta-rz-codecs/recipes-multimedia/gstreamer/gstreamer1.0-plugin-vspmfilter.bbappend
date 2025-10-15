FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-Increase-MAX_BUFFERS.patch"

ERROR_QA:remove = "patch-fuzz"
