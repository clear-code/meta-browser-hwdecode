do_install:append() {
    if [ "${USE_MALI}" = "1" ]; then
	rm -f ${D}/${includedir}/KHR/*
    fi
}
