# Copyright (C) 2026, ClearCode Inc.
# SPDX-License-Identifier: MIT

FILESEXTRAPATHS:prepend := "${THISDIR}/llvm-project-source:"

python __anonymous() {
    pv = d.getVar('PV', True) or ''
    if not pv.startswith('20.'):
        import bb
        bb.note('Skipping llvm-project-source_20.x.bbappend for PV=%s' % pv)
        return

    src_uri = d.getVar('SRC_URI', True) or ''
    patch = 'file://0001-libclc-allow-existing-prepare-builtins-in-standalone.patch'
    if patch not in src_uri:
        if src_uri.strip():
            d.setVar('SRC_URI', src_uri + ' ' + patch)
        else:
            d.setVar('SRC_URI', patch)
}