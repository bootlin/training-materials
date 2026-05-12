#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Introduction to Buildroot

=== Buildroot at a glance

- Can build a toolchain, a rootfs, a kernel, a bootloader

- *Easy to configure*: menuconfig, xconfig, etc.

- *Fast*: builds a simple root filesystem in a few minutes

- Easy to understand: written in make, extensive documentation

- *Small* root filesystem, starting at 2 MB

- *3200+ packages* for user space libraries/apps available

- *Many architectures* supported

- *Well-known technologies*: _make_ and _kconfig_

- Vendor neutral

- Active community, regular releases

  - The present slides cover _Buildroot 2025.02_. There may be some
    differences if you use older or newer Buildroot versions.

- #link("https://buildroot.org")

=== Buildroot design goals

- Buildroot is designed with a few key goals:

  - Simple to use

  - Simple to customize

  - Reproducible builds

  - Small root filesystem

  - Relatively fast boot

  - Easy to understand

- Some of these goals require to not necessarily support all possible
  features

- There are some more complicated and featureful build systems available
  (Yocto Project, OpenEmbedded)

=== Getting Buildroot

- Stable Buildroot releases are published every three months

  - `YYYY.02`, `YYYY.05`, `YYYY.08`, `YYYY.11`

- Tarballs are available for each stable release

  - #link("https://buildroot.org/downloads/")

- However, it is generally more convenient to clone the Git repository

  - Allows to clearly identify the changes you make to the Buildroot
    source code

  - Simplifies the upstreaming of the Buildroot changes

  - `git clone https://gitlab.com/buildroot.org/buildroot.git`

  - Git tags available for every stable release.

- *Long term support* releases

  - Previously: YYYY.02 releases maintained one year

  - New policy starting with _2025.02_

  - Goal is to maintain it during 3 years

  - Security fixes, bug fixes, build fixes

  - LTS initiative to fund the maintenance work, sponsoring needed to
    cover the effort

=== Using Buildroot

- Implemented in `make`

  - With a few helper shell scripts

- All interaction happens by calling `make` in the main Buildroot
  sources directory.

  ```
  $ cd buildroot/
  $ make help
  ```

- No need to run as `root`, Buildroot is designed to be executed with
  normal user privileges.

  - Running as root is even strongly discouraged!

=== Configuring Buildroot

- Like the Linux kernel, uses _Kconfig_

- A choice of configuration interfaces:

  - `make menuconfig`

  - `make nconfig`

  - `make xconfig`

  - `make gconfig`

- Make sure to install the relevant libraries in your system
  (_ncurses_ for menuconfig/nconfig, _Qt_ for xconfig,
  _Gtk_ for gconfig)

=== Main `menuconfig` menu

#align(center, [#image("menuconfig.png", height: 80%)])

=== Running the build

- As simple as:

  ```
  $ make
  ```

- Often useful to keep a log of the build output, for analysis or
  investigation:

  ```
  $ make 2>&1 | tee build.log
  ```

- Or the helper shell script provided by Buildroot:

  ```
  $ ./utils/brmake
  ```

=== Build results

- The build results are located in `output/images`

- Depending on the configuration, this directory will contain:

  - One or several root filesystem images, in various formats

  - One kernel image, possibly one or several Device Tree blobs

  - One or several bootloader images

- There is no standard way to install the images on any given device

  - Those steps are very device specific

  - Buildroot provides some tools to generate SD card / USB key images
    (_genimage_) or directly to flash or boot specific platforms:
    SAM-BA for Microchip, _uuu_ for NXP i.MX, OpenOCD, etc.

#setuplabframe([Basic Buildroot usage], [

  - Get Buildroot

  - Configure a minimal system with Buildroot for the target hardware

  - Do the build

  - Prepare the target hardware for usage

  - Flash and test the generated system

])
