#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Distro Layers

== Distro Layers
<distro-layers>

=== Distro layers

#align(center, [#image("yocto-layer-distro.pdf", height: 90%)])

=== Distro layers

- You can create a new distribution by using a Distro layer.

- This corresponds to the settings that have an impact on your packages.
  You can also decide to use Musl or Glibc, Wayland or X11, systemd or
  sysvinit…

- A distribution layer allows to change the defaults that are provided
  by  \ `openembedded-core` or `poky`.

- It is useful to distribute changes that have been made in `local.conf`

- Note: Poky is a rather bloated distribution, mainly meant to be used
  for testing. It's not necessarily a good starting point to optimize
  the root filesystem for your own platform.

=== Best practice

- A distro layer is used to provide policy configurations for a custom
  distribution.

- It is a best practice to separate the distro layer from the custom
  layers you may create and use.

- It often contains:

  - Distro configuration files.

  - Specific classes (for example to sign images)

  - Distribution specific recipes: initialization scripts, splash
    screen…

=== Creating a Distro configuration file

- The configuration file for the distro layer is
  `conf/distro/<distro>.conf`

- This file must define the #yoctovar("DISTRO_NAME") variable.

- You can also use all the `DISTRO_*` variables.

- Use `DISTRO = "<distro>"` in `local.conf` to use your distro
  configuration.

#v(0.5em)

#text(size: 18.5pt)[
  ```sh
  DISTRO_NAME = "My Custom Distro"
  DISTRO_VERSION = "1.0"
  MAINTAINER = "..."

  DISTRO_FEATURES = "sysvinit ipv4 ipv6 wifi zeroconf usbgadget usbhost pni-names"
  ```]

=== `DISTRO_FEATURES`

- Lists the features the distribution will enable (SSL, WiFi,
  Bluetooth…).

- As for #yoctovar("MACHINE_FEATURES"), this is used by package
  recipes to enable or disable functionalities.

- For example, the `bluetooth` feature:

  - Asks the `bluez` daemon to be built and added to the image.

  - Enables bluetooth support in `ConnMan`.

- #yoctovar("COMBINED_FEATURES") provides the list of features that
  are enabled in both #yoctovar("MACHINE_FEATURES") and
  #yoctovar("DISTRO_FEATURES").

=== Toolchain selection

- The toolchain selection is controlled by the #yoctovar("TCMODE")
  variable.

- It defaults to `"default"`.

- The `conf/distro/include/tcmode-${TCMODE}.inc` file is included.

  - This configures the toolchain to use by defining preferred providers
    and versions for recipes such as `gcc`, `binutils`, `*libc`…

- The providers' recipes define how to compile or/and install the
  toolchain.

- Toolchains can be built by the build system or external (rarely used
  because toolchains are fast to rebuild thanks to the shared state
  cache).

=== Sample files

- A distro layer often contains `sample files`, used as templates to
  build key configurations files.

- Example of `sample files`:

  - `bblayers.conf.sample`

  - `local.conf.sample`

- In `Poky`, they are in `meta-poky/conf/templates/default/`.

- The #yoctovar("TEMPLATECONF") environment variable controls where
  to find the samples and can be exported before sourcing
  `oe-init-build-env`.

- `##OEROOT##` can be used in `bblayers.conf.sample` and will be replaced by the path
  to the directory containing the `oe-init-build-env` script, after
  `oe-init-build-env` is sourced.

- `bitbake-layers save-build-conf` can be used to save the current
  configuration.
