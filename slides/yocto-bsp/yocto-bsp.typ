#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= BSP Layers

== Introduction to BSP layers in the Yocto Project
<introduction-to-bsp-layers-in-the-yocto-project>

=== BSP layers

#align(center, [#image("yocto-bsp-overview.pdf", height: 90%)])

=== BSP layers overview

- BSP layers are a subset of the layers.

- They hold metadata with the purpose of supporting a specific class of
  hardware devices.

- They usually provide:

  - Hardware configuration files (`machines`)

  - Custom kernel and bootloader recipes and configurations

  - Modules and drivers to enable specific hardware features (e.g.
    multimedia accelerators)

  - Pre-built user binaries and firmware

- A good practice is to name it `meta-<bsp_name>`.

- Examples:
  #link("https://git.yoctoproject.org/meta-ti/tree/meta-ti-bsp")[`meta-ti-bsp`],
  #link("https://github.com/STMicroelectronics/meta-st-stm32mp")[`meta-st-stm32mp`].

== Hardware configuration files
<hardware-configuration-files>

=== Overview 1/2

- A layer provides one machine file (hardware configuration file) per
  machine it supports.

- These configuration files are stored under \
  `meta-<bsp_name>/conf/machine/*.conf`

- The file names correspond to the values set in the `MACHINE`
  configuration variable.

  - `meta-ti/meta-ti-bsp/conf/machine/beaglebone.conf`

  - `MACHINE = "beaglebone"`

- Each machine should be described in the `README` file of the BSP.

=== Overview 2/2

- The hardware configuration file contains configuration variables
  related to the architecture and to the machine features.

- Some other variables help customize the kernel image or the
  filesystems used.

=== Machine configuration

- #yoctovar("TARGET_ARCH"): The architecture of the device being
  built.

- #yoctovar("PREFERRED_PROVIDER")`_virtual/kernel`: The default
  kernel.

- #yoctovar("MACHINE_FEATURES"): List of hardware features provided
  by the machine, e.g. `usbgadget usbhost screen wifi`

- #yoctovar("SERIAL_CONSOLES"): Speed and device for the serial
  consoles to attach. Used to configure `getty`, e.g. `115200;ttyS0`

- #yoctovar("KERNEL_IMAGETYPE"): The type of kernel image to build,
  e.g. `zImage`

=== `MACHINE_FEATURES`

- Lists the hardware features provided by the machine.

- These features are used by package recipes to enable or disable
  functionalities.

- Some packages are automatically added to the resulting root filesystem
  depending on the feature list.

  - The machine feature `keyboard` adds the `keymaps` to the image.

=== `conf/machine/include/cfa10036.inc`

#text(size: 17pt)[
  ```sh
  # Common definitions for cfa-10036 boards
  include conf/machine/include/imx-base.inc
  include conf/machine/include/tune-arm926ejs.inc

  SOC_FAMILY = "mxs:mx28:cfa10036"

  PREFERRED_PROVIDER_virtual/kernel ?= "linux-cfa"
  PREFERRED_PROVIDER_virtual/bootloader ?= "barebox"
  IMAGE_BOOTLOADER = "barebox"
  BAREBOX_BINARY = "barebox"
  IMAGE_FSTYPES:mxs = "tar.bz2 barebox.mxsboot-sdcard sdcard.gz"
  IMXBOOTLETS_MACHINE = "cfa10036"

  KERNEL_IMAGETYPE = "zImage"
  KERNEL_DEVICETREE = "imx28-cfa10036.dtb"
  # we need the kernel to be installed in the final image
  IMAGE_INSTALL:append = " kernel-image kernel-devicetree"
  SDCARD_ROOTFS ?= "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.ext3"
  SERIAL_CONSOLES = "115200;ttyAMA0"
  MACHINE_FEATURES = "usbgadget usbhost vfat"
  ```]

=== `conf/machine/cfa10057.conf`

```sh
#@TYPE: Machine
#@NAME: Crystalfontz CFA-10057
#@SOC: i.MX28
#@DESCRIPTION: Machine configuration for CFA-10057, also called CFA-920
#@MAINTAINER: Alexandre Belloni <alexandre.belloni@bootlin.com>

require conf/machine/include/cfa10036.inc

KERNEL_DEVICETREE += "imx28-cfa10057.dtb"

MACHINE_FEATURES += "touchscreen"
```

== Bootloader
<bootloader>

=== Default bootloader 1/2

- By default (on ARM) the bootloader used is the mainline version of
  `U-Boot`, with a fixed version (per Poky release).

- All the magic is done in `meta/recipes-bsp/u-boot/u-boot.inc`

- Some configuration variables used by the U-Boot recipe can be
  customized, in the machine file.

=== Default bootloader 2/2

- #yoctovar("SPL_BINARY"): If an SPL is built, describes the name of
  the output binary. Defaults to an empty string.

- #yoctovar("UBOOT_SUFFIX"): `bin` (default) or `img`.

- #yoctovar("UBOOT_MACHINE"): The target used to build the
  configuration.

- #yoctovar("UBOOT_ENTRYPOINT"): The bootloader entry point.

- #yoctovar("UBOOT_LOADADDRESS"): The bootloader load address.

- #yoctovar("UBOOT_MAKE_TARGET"): Make target when building the
  bootloader. Defaults to `all`.

=== Customize the bootloader

- It is possible to support a custom U-Boot by creating an extended
  recipe and to append extra metadata to the original one.

- This works well when using a mainline version of U-Boot.

- Otherwise it is possible to create a custom recipe.

  - Try to still use `meta/recipes-bsp/u-boot/u-boot.inc`

== Kernel
<kernel>

=== Linux kernel recipes in Yocto

- There are mainly two ways of compiling a kernel:

  - By creating a custom kernel recipe, inheriting `kernel.bbclass`

  - By using the `linux-yocto` packages, provided in Poky, for very
    complex needs

- The kernel used is selected in the machine file thanks to: \
  #yoctovar("PREFERRED_PROVIDER")`_virtual/kernel`

- Its version is defined with:
  #yoctovar("PREFERRED_VERSION")`_<kernel_provider>`

=== Linux Yocto 1/3

- `linux-yocto` is a set of recipes with advanced features to build a mainline kernel
- `PREFERRED_PROVIDER_virtual/kernel = "linux-yocto"`
- `PREFERRED_VERSION_linux-yocto = "5.14%"`

=== Linux Yocto 2/3

- Automatically applies configuration fragments listed in
  #yoctovar("SRC_URI") with a `.cfg` extension

#v(0.5em)

```sh
SRC_URI += "file://defconfig \
            file://nand-support.cfg \
            file://ethernet-support.cfg"
```

=== Linux Yocto 3/3

- Another way of configuring `linux-yocto` is by using _Advanced
  Metadata_.

- It is a powerful way of splitting the configuration and the patches
  into several pieces.

- It is designed to provide a very configurable kernel, at the cost of
  higher complexity.

- The full documentation can be found at \
  #link(
    "https://docs.yoctoproject.org/kernel-dev/advanced.html#working-with-advanced-metadata-yocto-kernel-cache",
  )[https://docs.yoctoproject.org/kernel-dev/advanced.html#working-with-advanced-metadata-yocto-kernel-cache]

=== Linux Yocto: Kernel Metadata 1/2

- Kernel Metadata is a way to organize and to split the kernel
  configuration and patches in little pieces each providing support for
  one feature.

- Two main configuration variables help taking advantage of this:

  - #yoctovar("LINUX_KERNEL_TYPE"): `standard` (default), `tiny` or
    `preempt-rt`

    - `standard`: generic Linux kernel policy.

    - `tiny`: bare minimum configuration, for small kernels.

    - `preempt-rt`: applies the `PREEMPT_RT` patch.

  - #yoctovar("KERNEL_FEATURES"): List of features to enable.
    Features are sets of patches and configuration fragments.

=== Linux Yocto: Kernel Metadata 2/2

- Kernel Metadata description files have their own syntax to describe an
  optional kernel feature

- A basic feature is defined as a patch to apply and a configuration
  fragment to add

- Simple example, `features/nunchuk.scc`

#v(0.5em)

```sh
define KFEATURE_DESCRIPTION "Enable Nunchuk driver"

kconf hardware enable-nunchuk-driver.cfg patch
Add-nunchuk-driver.patch
```
#v(0.5em)

- To integrate the feature into the kernel image: \
  `KERNEL_FEATURES += "features/nunchuk.scc"`
