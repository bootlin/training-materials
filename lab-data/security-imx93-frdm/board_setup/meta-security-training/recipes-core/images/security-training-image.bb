# Build a simple, minimal root filesystem.
#
# This recipe is a simplified form of core-image-minimal.

SUMMARY = "A simple, minimal image"

WKS_FILE = "${IMAGE_BASENAME}.${MACHINE}.wks.in"

IMAGE_INSTALL = "packagegroup-core-boot openssh-sftp-server openssh-sshd"

# Add various software components used during labs
IMAGE_INSTALL += " \
    atftpd \
    e2fsprogs \
    iputils-ping \
    libcap \
    libp11 \
    libseccomp \
    opensc \
    optee-client \
    optee-os-ta \
    rauc \
    strace \
    packagegroup-core-selinux \
    "

# Make it a bit more user friendly
IMAGE_INSTALL += "bash"

IMAGE_LINGUAS = " "

inherit core-image
