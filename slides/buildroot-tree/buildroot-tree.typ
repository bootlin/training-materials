#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Buildroot source and build trees

== Source tree
<source-tree>

===  Source tree (1/5)

- `Makefile`

  - top-level `Makefile`, handles the configuration and general
    orchestration of the build

- `Config.in`

  - top-level `Config.in`, main/general options. Includes many other
    `Config.in` files

- `arch/`

  - `Config.in.*` files defining the architecture variants (processor
    type, ABI, floating point, etc.)

  - `Config.in`, `Config.in.arm`, `Config.in.x86`,
    `Config.in.microblaze`, etc.

===  Source tree (2/5)

- `toolchain/`

  - packages for generating or using toolchains

  - `toolchain/` virtual package that depends on either
    `toolchain-buildroot` or `toolchain-external`

  - `toolchain-buildroot/` virtual package to build the internal
    toolchain

  - `toolchain-external/` virtual package to download/import the
    external toolchain

- `system/`

  - `skeleton/` the rootfs skeleton

  - `Config.in`, options for system-wide features like init system,
    `/dev` handling, etc.

- `linux/`

  - `linux.mk`, the Linux kernel package

===  Source tree (3/5)

- `package/`

  - all the user space packages (3200+)

  - `busybox/`, `gcc/`, `qt5/`, etc.

  - `pkg-generic.mk`, core package infrastructure

  - `pkg-cmake.mk`, `pkg-autotools.mk`, `pkg-perl.mk`, etc. Specialized
    package infrastructures

- `fs/`

  - logic to generate filesystem images in various formats

  - `common.mk`, common logic

  - `cpio/`, `ext2/`, `squashfs/`, `tar/`, `ubifs/`, etc.

- `boot/`

  - bootloader packages

  - `at91bootstrap3/`, `barebox/`, `grub2/`, `syslinux/`, `uboot/`, etc.

===  Source tree (4/5)

- `configs/`

  - default configuration files for various platforms

  - similar to kernel defconfigs

  - `atmel_xplained_defconfig`, `beaglebone_defconfig`,
    `raspberrypi_defconfig`, etc.

- `board/`

  - board-specific files (kernel configuration files, kernel patches,
    image flashing scripts, etc.)

  - typically go together with a _defconfig_ in `configs/`

- `support/`

  - misc utilities (kconfig code, libtool patches, download helpers, and
    more.)

===  Source tree (5/5)

- `utils/`

  - Various utilities useful to Buildroot developers

  - `brmake`, make wrapper, with logging

  - `docker-run`, wrapper to run the build under a Docker container
    provided by Buildroot

  - `get-developers`, to know to whom patches should be sent

  - `test-pkg`, to validate that a package builds properly

  - `scanpipy`, `scancpan` to generate Python/Perl package `.mk` files

  - ...

- `docs/`

  - Buildroot documentation

  - Written in AsciiDoc, can generate HTML, PDF, TXT versions: `make manual`

  - ≈ 142 pages PDF document

  - Also available pre-generated online.

  - #link("https://buildroot.org/downloads/manual/manual.html")

== Build tree
<build-tree>

===  Build tree: `$(O)`

- `output/`

- Global output directory

- Can be customized for out-of-tree build by passing `O=<dir>`

- Variable: `O` (as passed on the command line)

- Variable: `BASE_DIR` (as an absolute path)

===  Build tree: `$(O)/build`

- `output/`

  - `build/`

    - `buildroot-config/`

    - `busybox-1.22.1/`

    - `host-pkgconf-0.8.9/`

    - `kmod-1.18/`

    - `build-time.log`

  - Where all source tarballs are extracted

  - Where the build of each package takes place

  - In addition to the package sources and object files, _stamp_
    files are created by Buildroot

  - Variable: `BUILD_DIR`

===  Build tree: `$(O)/host`

- `output/`

  - `host/`

    - `lib`

    - `bin`

    - `sbin`

    - `<tuple>/sysroot/bin`

    - `<tuple>/sysroot/lib`

    - `<tuple>/sysroot/usr/lib`

    - `<tuple>/sysroot/usr/bin`

  - Contains both the tools built for the host (cross-compiler, etc.)
    and the _sysroot_ of the toolchain

  - Variable: `HOST_DIR`

  - Host tools are directly in `host/`

  - The _sysroot_ is in `host/<tuple>/sysroot/usr`

  - `<tuple>` is an identifier of the architecture, vendor, operating
    system, C library and ABI. E.g: `arm-unknown-linux-gnueabihf`.

  - Variable for the _sysroot_: `STAGING_DIR`

===  Build tree: `$(O)/staging`

- `output/`

  - `staging/`

  - Just a symbolic link to the _sysroot_, i.e. to
    `host/<tuple>/sysroot/`.

  - Available for convenience

===  Build tree: `$(O)/target`

- `output/`

  - `target/`

    - `bin/`

    - `etc/`

    - `lib/`

    - `usr/bin/`

    - `usr/lib/`

    - `usr/share/`

    - `usr/sbin/`

    - `THIS_IS_NOT_YOUR_ROOT_FILESYSTEM`

    - ...

  - The target root filesystem

  - Usual Linux hierarchy

  - Not completely ready for the target: permissions, device files, etc.

  - Buildroot does not run as root: all files are owned by the user
    running Buildroot, not _setuid_, etc.

  - Used to generate the final root filesystem images in `images/`

  - Variable: `TARGET_DIR`

===  Build tree: `$(O)/images`

- `output/`

  - `images/`

    - `zImage`

    - `armada-370-mirabox.dtb`

    - `rootfs.tar`

    - `rootfs.ubi`

  - Contains the final images: kernel image, bootloader image, root
    filesystem image(s)

  - Variable: `BINARIES_DIR`

===  Build tree: `$(O)/graphs`

- `output/`

  - `graphs/`

  - Visualization of Buildroot operation: dependencies between packages,
    time to build the different packages

  - `make graph-depends`

  - `make graph-build`

  - `make graph-size`

  - Variable: `GRAPHS_DIR`

  - See the section _Analyzing the build_ later in this training.

===  Build tree: `$(O)/legal-info`

- `output/`

  - `legal-info/`

    - `manifest.csv`

    - `host-manifest.csv`

    - `licenses/`

    - `sources/`

    - ...

  - Legal information: license of all packages, and their source code,
    plus a licensing manifest

  - Useful for license compliance

  - `make legal-info`

  - Variable: `LEGAL_INFO_DIR`
