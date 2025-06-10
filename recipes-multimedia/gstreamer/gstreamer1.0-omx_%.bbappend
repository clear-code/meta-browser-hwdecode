SRC_URI:append = " \
    file://0001-omxvideodec-Try-to-mitigate-freeze-issue-on-flushing.patch \
"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/:"
