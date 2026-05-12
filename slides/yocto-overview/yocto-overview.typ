#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Yocto Project and Poky reference system overview

== The Yocto Project overview
<the-yocto-project-overview>

=== About

- The Yocto Project is an open source collaboration project that allows
  to build custom embedded Linux-based systems.

- Established by the Linux Foundation in 2010 and still managed by one
  of its fellows: Richard Purdie.

=== Yocto: principle

#align(center, [#image("yocto-principle.pdf", width: 100%)])

#v(1em)

- Yocto always builds binary packages (a "distribution")

- The final root filesystem is generated from the package feed

- The
  #link(
    "https://docs.yoctoproject.org/_images/yp-flow-diagram.svg",
  )[big picture]
  is way more complex

=== Lexicon: `bitbake`

In Yocto / OpenEmbedded, the _build engine_ is implemented by the `bitbake` program

- `bitbake` is a task scheduler, like `make`

- `bitbake` parses text files to know what it has to build and how

- It is written in Python (need Python 3 on the development host)

=== Lexicon: recipes

#table(
  columns: (60%, 40%),
  stroke: none,
  gutter: 15pt,
  [


    - The main kind of text file parsed by `bitbake` is _recipes_, each
      describing a specific software component

    - Each _Recipe_ describes how to fetch and build a software
      component: e.g. a program, a library or an image

    - They have a specific syntax

    - `bitbake` can be asked to build any recipe, building all its
      dependencies automatically beforehand

  ],
  [

    #align(center, [#image("recipe-dependencies.pdf", width: 90%)])

  ],
)

=== Lexicon: tasks

#table(
  columns: (60%, 40%),
  stroke: none,
  gutter: 15pt,
  [

    - The build process implemented by a recipe is split in several
      _tasks_

    - Each task performs a specific step in the build

    - Examples: fetch, configure, compile, package

    - Tasks can depend on other tasks (including on tasks of other recipes)

  ],
  [

    #align(center, [#image("recipe-dependencies-tasks.pdf", width: 100%)])

  ],
)

=== Lexicon: metadata and layers

- The input to `bitbake` is collectively called _metadata_

- Metadata includes _configuration files_, _recipes_,
  _classes_ and _include files_

- Metadata is organized in _layers_, which can be composed to get
  various components

  - A layer is a set of recipes, configurations files and classes
    matching a common purpose

    - For Texas Instruments board support, the _meta-ti-bsp_ layer
      is used

  - Multiple layers are used for a project, depending on the needs

- _openembedded-core_ is the core layer

  - All other layers are built on top of openembedded-core

  - It supports the ARM, MIPS (32 and 64 bits), PowerPC, RISC-V and x86
    (32 and 64 bits) architectures

  - It supports QEMU emulated machines for these architectures

=== Lexicon: Poky

- The word _Poky_ has several meanings

- Poky is a git repository that is assembled from other git
  repositories: bitbake, openembedded-core, yocto-docs and meta-yocto

- poky is the _reference distro_ provided by the Yocto Project

- meta-poky is the layer providing the poky reference distribution

=== The Yocto Project lexicon

#align(center, [#image("yocto-project-overview.pdf", height: 90%)])

=== The Yocto Project lexicon

- The Yocto Project is *not used as* a finite set of layers and
  tools.

- Instead, it provides a *common base* of tools and layers on top
  of which custom and specific layers are added, depending on your
  target.

=== Example of a Yocto Project based BSP

- To build images for a BeagleBone Black, we need:

  - The Poky reference system, containing all common recipes and tools.

  - The _meta-ti-bsp_ layer, a set of Texas Instruments specific
    recipes.

- All modifications are made in your own layer. Editing Poky or any
  other third-party layer is a *no-go*!

- We will set up this environment in the lab.

== The Poky reference system overview
<the-poky-reference-system-overview>

=== Getting the Poky reference system

- All official projects part of the Yocto Project are available at \
  #link("https://git.yoctoproject.org/")

- To download the Poky reference system: \
  `git clone -b scarthgap https://git.yoctoproject.org/git/poky`

- A new version is released every 6 months, and maintained for 7 months

- *LTS* versions are maintained for 4 years, and announced before
  their release.

- Each release has a codename such as `kirkstone` or `scarthgap`,
  corresponding to a release number.

  - A summary can be found at
    #link("https://wiki.yoctoproject.org/wiki/Releases")

=== Poky

#align(center, [#image("yocto-overview-poky.pdf", height: 90%)])

=== Poky source tree 1/2

/ /bitbake/: Holds all scripts used by the `bitbake` command. Usually matches the stable release of the BitBake project.

/ /documentation/: All documentation sources for the Yocto Project documentation. Can be used to generate nice PDFs.

/ /meta/: Contains the OpenEmbedded-Core metadata.

/ /meta-skeleton/: Contains template recipes for BSP and kernel development.

=== Poky source tree 2/2

/ /meta-poky/: Holds the configuration for the Poky reference distribution.

/ /meta-yocto-bsp/: Configuration for the Yocto Project reference hardware board support package.

/ /LICENSE: The license under which Poky is distributed (a mix of GPLv2 and MIT).

/ /oe-init-build-env: Script to set up the OpenEmbedded build environment. It will create the build directory.

/ /scripts/: Contains scripts used to set up the environment, development tools, and tools to flash the generated images on the target.

=== Documentation

- Documentation for the current sources, compiled as a "mega manual",
  is available at:
  #link("https://docs.yoctoproject.org/singleindex.html")

- Variables in particular are described in the variable glossary: \
  #link("https://docs.yoctoproject.org/genindex.html")
