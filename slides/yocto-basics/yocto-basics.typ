#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

#set list(spacing: 0.8em)

= Using Yocto Project - basics

== Environment setup
<environment-setup>

=== Environment setup

- All Poky files are left unchanged when building a custom image.

- Specific configuration files and build repositories are stored in a
  separate build directory.

- A script, `oe-init-build-env` , is provided to set up the build directory and the
  environment variables (needed to be able to use the `bitbake` command
  for example).

=== oe-init-build-env

- Modifies the environment: has to be sourced!

- Adds environment variables, used by the build engine.

- Allows you to use commands provided in Poky.

- `source ./oe-init-build-env [builddir]`

- Sets up a basic build directory, named `builddir` if it is not found.
  If not provided, the default name is `build`.

=== The initial `build/` directory

- The `oe-init-build-env` script creates the `build` directory with only
  one subdirectory in it: \
  - / /conf: Configuration files. Image specific and layer configuration

=== Exported environment variables

#align(center, [
  / BUILDDIR: Absolute path of the build directory.

  #v(0.5em)

  / PATH: Contains the directories where executable programs are located. \ Absolute paths to `scripts/` and `bitbake/bin/` are prepended.
])

=== Available commands

#align(center, [
  / bitbake: The main build engine command. Used to perform tasks on available recipes (download, configure, compile…).

  #v(0.5em)

  / bitbake-\*: Various specific commands related to the BitBake build engine.
])

== Configuring the build system
<configuring-the-build-system>

=== The `build/conf/` directory

- The `conf/` directory in the `build` one holds two mandatory build-specific configuration files:

  / bblayers.conf: #block[
      Explicitly list the layers to use.
    ]

  / local.conf: #block[
      Set up the configuration variables relative to the current user for
      the build. Configuration variables can be overridden there.
    ]

- Additional optional configuration files can be used:

  / site.conf: #block[
      Similar to `local.conf` but intended to be used for site-specific
      settings, such as network mirrors and CPU/memory resource usage
      limits.
    ]

=== Configuring the build

The `conf/local.conf` configuration file holds local user configuration variables:

- #yoctovar("BB_NUMBER_THREADS"): How many tasks BitBake should
  perform in parallel. Defaults to the number of CPU threads on the
  system.

- #yoctovar("PARALLEL_MAKE"): How many processes should be used when
  compiling. Defaults to the number of CPU threads on the system.

- #yoctovar("MACHINE"): The machine the target is built for, e.g.
  `beaglebone`.

== Building an image
<building-an-image>

=== Compilation

- The compilation is handled by the BitBake _build engine_.

- Usage: `bitbake [options] [recipename/target ...]`

- To build a target: `bitbake [target]`

- Building a minimal image: `bitbake core-image-minimal`

  - This will run a full build for the selected target.

- The `oe-init-build-env` script lists some more example targets

=== The `build/ directory after the build 1/2`

/ conf/: Configuration files, as before, not touched by the build.#v(0.5em)

/ downloads/: Downloaded upstream tarballs of the recipes used in the builds.#v(0.5em)

/ state-cache/: Shared state cache. Used by all builds.#v(0.5em)

/ tmp/: Holds all the build system outputs.#v(0.5em)

=== The `build/ directory after the build 2/2`

/ tmp/work/: #block[
    Set of specific work directories, split by architecture. They are used
    to unpack, configure and build the packages. Contains the patched
    sources, generated objects and logs.
  ]#v(0.5em)

/ tmp/sysroots/: #block[
    Shared libraries and headers used to compile applications for the target
    but also for the host.
  ]#v(0.5em)

/ tmp/deploy/: #block[
    Final output of the build.
  ]#v(0.5em)

/ tmp/deploy/images/: #block[
    Contains the complete images built by the OpenEmbedded build system.
    These images are used to flash the target.
  ]#v(0.5em)

/ tmp/buildstats/: #block[
    Build statistics for all packages built (CPU usage, elapsed time, host,
    timestamps…).
  ]
