FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://0001-ELE-dirty-fix-includes.patch"

# It looks like the ELE does not actually embed any Non-Volatile Memory.
# It stores persistent keys wrapped in an extenal NVM.
# To do so, it requires a userland daemon, which is implemented in
# imx-secure-enclave, "nvm_daemon".
# This can be started automatically by systemd, but is disabled by default
# in the imx-secure-enclave recipe in meta-freescale.
SYSTEMD_AUTO_ENABLE = "enable"

# Only compile the library, to avoid having to handle the OpenSSL and
# MbedTLS dependencies. 
#   https://github.com/nxp-imx/imx-secure-enclave/blob/lf-6.12.34_2.1.0/README#L169
#   https://github.com/nxp-imx/imx-secure-enclave/blob/lf-6.12.34_2.1.0/README#L322
do_compile() {
    oe_runmake libs
}
