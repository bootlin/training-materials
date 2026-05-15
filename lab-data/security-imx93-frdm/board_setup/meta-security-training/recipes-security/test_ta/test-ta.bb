DESCRIPTION = "Simple application to print some ARMv8 info"
LICENSE = "CLOSED"

inherit deploy python3native

DEPENDS = "python3-pyelftools-native optee-os-tadevkit optee-client python3-cryptography-native "

SRC_URI = " \
        file://Makefile \
        file://ta \
        file://host \
"

S = "${WORKDIR}"

TA_DEV_KIT_DIR = "${STAGING_INCDIR}/optee/export-user_ta"
EXTRA_OEMAKE += ' \
    TA_DEV_KIT_DIR=${TA_DEV_KIT_DIR} \
    TA_CROSS_COMPILE=${TARGET_PREFIX} \
    CROSS_COMPILE=${TARGET_PREFIX} \
    CFG_ARM64_ta_arm64=y \
    CFG_TEE_TA_LOG_LEVEL=4 \
    CFG_TA_DEBUG=y \
    CFLAGS="${CFLAGS} -Wno-unused-parameter --sysroot=${STAGING_DIR_HOST}" \
'

do_compile:prepend() {
    export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
