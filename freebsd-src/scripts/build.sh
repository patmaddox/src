#!/bin/sh
# https://patmaddox.com/file?name=infra/pdt/lib/pdt-src&ci=06fcb33c1bc90bd5

set -eu

main() {
    local srcdir
    srcdir="${1}"; shift

    local t
    for t in buildworld buildkernel distributeworld distributekernel packageworld packagekernel; do
	make -s \
	     -C ${srcdir} \
	     -D NO_ROOT \
	     -j $(sysctl -n hw.ncpu) \
	     DISTDIR=${BUILDDIR}/rel \
	     OBJTOP=${BUILDDIR}/obj \
	     SRCCONF=/dev/null \
	     TZ=UTC \
	     __MAKE_CONF=/dev/null \
	     ${t}
    done
}

main "${@}"
