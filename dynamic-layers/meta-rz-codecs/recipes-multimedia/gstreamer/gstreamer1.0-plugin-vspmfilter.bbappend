# Copyright (C) 2025-2026 ClearCode Inc.
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

ERROR_QA:remove = "patch-fuzz"

# The upstream buffer-pool rework makes the buffer count configurable and moves
# MAX_BUFFERS to gstvspmfilter.h. Apply our patch only to the old fixed-5
# implementation.
python do_patch:prepend() {
    import os

    patch_uri = "file://0001-Increase-MAX_BUFFERS.patch"
    source = os.path.join(d.getVar("S"), "gstvspmfilter.c")

    if not os.path.exists(source):
        return

    with open(source, encoding="utf-8") as source_file:
        source_text = source_file.read()

    if "#define MAX_BUFFERS (5)" not in source_text:
        return

    src_uri = (d.getVar("SRC_URI") or "").split()
    if patch_uri not in src_uri:
        d.appendVar("SRC_URI", " %s" % patch_uri)
        bb.note("%s has the old MAX_BUFFERS value; applying %s" %
                (d.getVar("PN"), patch_uri))
}
