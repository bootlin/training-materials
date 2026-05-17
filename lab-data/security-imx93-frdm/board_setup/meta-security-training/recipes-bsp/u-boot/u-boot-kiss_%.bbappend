FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot-kiss:"

SRC_URI:append:freiheit93 = " \
    file://0001-imx93_frdm-Disable-selinux-enforcement-by-default.patch \
    file://0002-Switch-to-FIT-image.patch \
    file://0003-Move-to-raw-FIT-images.patch \
    file://0004-imx93_frdm_defconfig-Move-env-to-SD-card-user-area.patch \
    file://0005-SPSDK-2975-Add-command-for-raw-ELE-message-call.patch \
    file://0006-imx93_frdm.h-Move-heap-to-fix-AHAB-boot.patch \
    file://0007-configs-imx93_frdm_defconfig-Add-AHAB-options.patch \
    file://0008-Boot-from-rootfs-A-in-A-B-setup.patch \
    file://0009-Add-FIT-signature.patch \
    file://secure-boot.dtsi \
"

do_compile:prepend() {
    cp ${WORKDIR}/secure-boot.dtsi ${S}/arch/arm/dts/
}
