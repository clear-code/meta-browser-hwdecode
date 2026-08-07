# Copyright (C) 2024-2026 ClearCode Inc.
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/:"

SRC_URI += " \
    file://0001-omx-Drop-empty-video-decoder-outputs.patch \
"

# The upstream FLUSH event handling now wakes the input port on FLUSH_START and
# restores it on FLUSH_STOP. Apply our older workaround only to sources that
# still have no sink_event handler for flushing.
python do_patch:prepend() {
    import os

    patch_uri = "file://0001-omxvideodec-Start-flushing-earlier-to-avoid-unstable.patch"
    source = os.path.join(d.getVar("S"), "omx", "gstomxvideodec.c")

    if not os.path.exists(source):
        return

    with open(source, encoding="utf-8") as source_file:
        source_text = source_file.read()

    if ("video_decoder_class->sink_event" in source_text or
            "GST_EVENT_FLUSH_START" in source_text):
        return

    if "video_decoder_class->flush = GST_DEBUG_FUNCPTR (gst_omx_video_dec_flush);" not in source_text:
        return

    src_uri = (d.getVar("SRC_URI") or "").split()
    if patch_uri not in src_uri:
        d.appendVar("SRC_URI", " %s" % patch_uri)
        bb.note("%s has the old flush handling; applying %s" %
                (d.getVar("PN"), patch_uri))
}
