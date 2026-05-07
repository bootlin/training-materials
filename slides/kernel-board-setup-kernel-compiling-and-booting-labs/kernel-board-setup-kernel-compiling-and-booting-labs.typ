#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme 

#setuplabframe([Kernel compiling and booting],[ 1st lab: board and
bootloader setup:

- Prepare the board and access its serial port

- Configure its bootloader to use TFTP

2nd lab: kernel compiling and booting:

- Set up a cross-compiling environment

- Cross-compile a kernel for an ARM target platform

- Boot this kernel from a directory on your workstation, accessed by the
  board through NFS

])
