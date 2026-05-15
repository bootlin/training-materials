DESCRIPTION = ""
LICENSE = "CLOSED"

inherit deploy

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DEPENDS = " imx-secure-enclave"

SRC_URI = " \
  file://ele-test.c \
  file://Makefile \
"

S = "${WORKDIR}"

do_compile() {
    ${CC} ${LDFLAGS} ele-test.c -o ele-test -lele_hsm -lele_nvm
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ele-test ${D}${bindir}
}
