# Copyright (C) 2026, ClearCode Inc.
# SPDX-License-Identifier: MIT

python __anonymous() {
    pv = d.getVar('PV', True) or ''
    if not pv.startswith('20.'):
        import bb
        bb.note('Skipping libclc_20.x.bbappend for PV=%s' % pv)
        d.setVar('RZ_BROWSER_LIBCLC_SKIP_20', '1')
}

B_NATIVE = "${B}-native"

EXTRA_OECMAKE:append:class-target = \
    " -DPREPARE_BUILTINS=${B_NATIVE}/prepare_builtins"

EXTRA_OECMAKE:append:class-nativesdk = \
    " -DPREPARE_BUILTINS=${B_NATIVE}/prepare_builtins"

do_generate_native_toolchain_file() {
    native_cc="${BUILD_CC% }"
    native_cxx="${BUILD_CXX% }"

    cat > ${WORKDIR}/toolchain-native.cmake <<EOF
set(CMAKE_C_COMPILER "${native_cc}")
set(CMAKE_CXX_COMPILER "${native_cxx}")
set(CMAKE_ASM_COMPILER "${native_cc}")

set(CMAKE_AR "${BUILD_AR}" CACHE FILEPATH "Archiver")
set(CMAKE_RANLIB "${BUILD_RANLIB}" CACHE FILEPATH "Archive Indexer")
set(CMAKE_NM "${BUILD_NM}" CACHE FILEPATH "Symbol Lister")

set(CMAKE_C_FLAGS "${native_cc_ARCH} ${BUILD_CFLAGS}" CACHE STRING "CFLAGS")
set(CMAKE_CXX_FLAGS "${native_cc_ARCH} ${BUILX_CXXFLAGS}" CACHE STRING "CXXFLAGS")

set(CMAKE_EXE_LINKER_FLAGS "${native_cc_ARCH} ${BUILD_LDFLAGS}" CACHE STRING "LDFLAGS")
set(CMAKE_SHARED_LINKER_FLAGS "${native_cc_ARCH} ${BUILD_LDFLAGS}" CACHE STRING "LDFLAGS")

set(CMAKE_FIND_ROOT_PATH "${STAGING_DIR_NATIVE}")
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

list(APPEND CMAKE_MODULE_PATH "${STAGING_DATADIR_NATIVE}/cmake/Modules/")
EOF
}

do_build_prepare_builtins() {
    do_generate_native_toolchain_file

    cmake --fresh -G Ninja \
        -S ${OECMAKE_SOURCEPATH} \
        -B ${B_NATIVE} \
        -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${WORKDIR}/toolchain-native.cmake \
        -DLIBCLC_TARGETS_TO_BUILD=

    cmake --build ${B_NATIVE} --target prepare_builtins
}

do_build_prepare_builtins:class-native() {
    :
}

python __anonymous_do_configure() {
    pv = d.getVar('PV', True) or ''
    skip = d.getVar('RZ_BROWSER_LIBCLC_SKIP_20', True) or ''
    if pv.startswith('20.') and not skip:
        do_cfg = d.getVar('do_configure[prefuncs]', True) or ''
        if 'do_build_prepare_builtins' not in do_cfg:
            if do_cfg:
                d.setVar('do_configure[prefuncs]', do_cfg + ' do_build_prepare_builtins')
            else:
                d.setVar('do_configure[prefuncs]', 'do_build_prepare_builtins')
}
