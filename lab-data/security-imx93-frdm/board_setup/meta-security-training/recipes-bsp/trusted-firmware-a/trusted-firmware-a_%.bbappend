FILESEXTRAPATHS:prepend := "${THISDIR}/trusted-firmware-a:"

# This file must be generated as part of the "Exploring secure world" lab.
SRC_URI:append:freiheit93 = " file://0001-Bootlin-Security-Training.patch"

EXTRA_OEMAKE:append:freiheit93 = " LOG_LEVEL=40"
