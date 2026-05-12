#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Managing the Linux kernel configuration

=== Kernel version

#[
  #set list(spacing: 0.3em)
  - Most packages in Buildroot have a version fixed in their corresponding
    Buildroot package

  - Some packages are more hardware-related, and there is a need to
    configure their version in a custom way

    - Linux kernel, bootloaders, firmware, etc.

  - Linux kernel version options:

    - Latest version

    - Latest CIP SLTS

    - Latest CIP RT SLTS

    - Custom version

    - Custom Git repository

    - Custom Mercurial repository

    - Custom Subversion repository

  - Using a custom version is recommended → ensures that upgrading
    Buildroot doesn't imply a change in the kernel version

  - No relationship between Buildroot version and kernel version
]

=== Kernel version configuration

#align(center, [#image("kernel-version.png", width: 80%)])

=== Kernel configuration vs. Buildroot configuration

- The Linux kernel itself uses _kconfig_ to define its
  configuration

- Buildroot cannot replicate all Linux kernel configuration options in
  its `menuconfig`

- Defining the Linux kernel configuration therefore needs to be done in
  a special way.

- Note: while described with the example of the Linux kernel, this
  discussion is also valid for other packages using _kconfig_:
  `barebox`, `uclibc`, `busybox` and `uboot`.

=== Defining the configuration

- In the `Kernel` menu in `menuconfig`, 3 possibilities to configure the
  kernel:

  + `Use a defconfig`

    - Will use a _defconfig_ provided within the kernel sources

    - Available in `arch/<ARCH>/configs` in the kernel sources

    - Used unmodified by Buildroot

    - Good starting point

  + `Use a custom config file`

    - Allows to give the path to either a full `.config`, or a minimal
      _defconfig_

    - Usually what you will use, so that you can have a custom
      configuration

  + `Use the architecture default configuration`

    - Use the _defconfig_ provided by the architecture in the
      kernel source tree. Some architectures (e.g ARM64) have a single
      _defconfig_.

- Configuration can be further tweaked with `Additional fragments`

  - Allows to pass a list of configuration file fragments.

  - They can complement or override configuration options specified in a
    _defconfig_ or a full configuration file.

=== Examples of kernel configuration

#[ #show raw.where(block: true): set text(size: 13pt)

  #text(size: 14pt)[`stm32mp157a_dk1_defconfig`: custom configuration file]
  #v(-0.3em)
  ```
  BR2_LINUX_KERNEL_USE_CUSTOM_CONFIG=y
  BR2_LINUX_KERNEL_CUSTOM_CONFIG_FILE="board/stmicroelectronics/stm32mp157a-dk1/linux.config"
  ```
  #v(0.5em)
  #text(size: 14pt)[`ts4900_defconfig`: standard kernel defconfig]
  #v(-0.3em)
  ```
  BR2_LINUX_KERNEL_DEFCONFIG="imx_v6_v7"
  ```
  #v(0.5em)
  #text(size: 14pt)[`warpboard_defconfig`: standard kernel defconfig + fragment]
  #v(-0.3em)
  ```
  BR2_LINUX_KERNEL_DEFCONFIG="imx_v6_v7"
  BR2_LINUX_KERNEL_CONFIG_FRAGMENT_FILES="board/freescale/warpboard/linux.fragment"
  ```
  #v(0.5em)
  #text(size: 14pt)[`linux.fragment`: contains extra kernel options]
  #v(-0.3em)
  ```
  CONFIG_CFG80211_WEXT=y
  ```
]

=== Changing the configuration

- Running one of the Linux kernel configuration interfaces:

  - `make linux-menuconfig`

  - `make linux-nconfig`

  - `make linux-xconfig`

  - `make linux-gconfig`

- Will load either the defined kernel _defconfig_ or custom
  configuration file, and start the corresponding Linux kernel
  configuration interface.

- Changes made are only made in `$(O)/build/linux-<version>/`, i.e.
  they are not preserved across a clean rebuild.

- To save them:

  - `make linux-update-config`, to save a full config file

  - `make linux-update-defconfig`, to save a minimal defconfig

  - Only works if a _custom configuration file_ is used

=== Typical flow

+ `make menuconfig`

  - Start with a _defconfig_ from the kernel, say
    `mvebu_v7_defconfig`

+ Run `make linux-menuconfig` to customize the configuration

+ Do the build, test, tweak the configuration as needed.

+ You cannot do `make linux-update-config,defconfig`, since the
  Buildroot configuration points to a kernel _defconfig_

+ `make menuconfig`

  - Change to a custom configuration file. There's no need for the file
    to exist, it will be created by Buildroot.

+ `make linux-update-defconfig`

  - Will create your custom configuration file, as a minimal
    _defconfig_
