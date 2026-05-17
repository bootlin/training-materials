#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Layers

== Introduction to layers
<introduction-to-layers>

=== Layers principles

- The OpenEmbedded _build system_ manipulates _metadata_.

- Layers allow to isolate and organize the metadata.

  - A layer is a collection of recipes.

- It is a good practice to begin a layer name with the prefix `meta-`.

=== Layers in Poky

#align(center, [#image(
  "/slides/yocto-overview/yocto-overview-poky.svg",
  height: 90%,
)])

=== Layers in Poky

- The Poky _reference system_ is a set of basic common layers:

  - meta

  - meta-skeleton

  - meta-poky

  - meta-yocto-bsp

- Poky is not a final set of layers. It is the common base.

- Layers are added when needed.

- When making modifications to the existing recipes or when adding new
  ones, it is a good practice to avoid modifying Poky. Instead you can
  create your own layers!

=== Third party layers

#align(center, [#image("yocto-layer-intro.svg", height: 90%)])

=== Integrate and use a layer 1/3

- A list of existing and maintained layers can be found at \
  #link("https://layers.openembedded.org")

- Instead of redeveloping layers, always check the work hasn't been done
  by others.

- It takes less time to download a layer providing a package you need
  and to add an append file if some modifications are needed than to do
  it from scratch.

=== Integrate and use a layer 2/3

- The location where a layer is saved on the disk doesn't matter.

  - But a good practice is to save it where all others layers are
    stored.

- The only requirement is to let BitBake know about the new layer:

  - The list of layers BitBake uses is defined in
    `$BUILDDIR/conf/bblayers.conf`

  - To include a new layer, add its absolute path to the
    #yoctovar("BBLAYERS") variable.

  - BitBake parses each layer specified in #yoctovar("BBLAYERS") and
    adds the recipes, configurations files and classes it contains.

=== Integrate and use a layer 3/3

- The `bitbake-layers` tool is provided alongside `bitbake`.

- It can be used to inspect the layers and to manage \
  `$BUILDDIR/conf/bblayers.conf`:

  - `bitbake-layers show-layers`

  - `bitbake-layers add-layer meta-custom`

  - `bitbake-layers remove-layer meta-qt5`

=== Some useful layers

- Many SoC specific layers are available, providing support for the
  boards using these SoCs. Some examples: `meta-ti-bsp`,
  `meta-freescale` and `meta-st-stm32mp`.

- Other layers offer to support applications not available in
  OpenEmbedded-Core:

  - `meta-firefox`: Firefox web browser support.

  - `meta-filesystems`: support for additional filesystems.

  - `meta-java`: Java support.

  - `meta-arm-toolchain`: Arm GCC toolchain recipes.

  - `meta-qt6`: QT6 modules.

  - `meta-realtime`: real time tools and test programs.

  - `meta-virtualization` and many more…

  Notice that some of these layers do not come with all the Yocto
  branches. `meta-realtime` layer does not have a `honister` (3.4)
  branch, for example.

== Layer recommendations
<layer-recommendations>

=== Layer recommendations

- Keep your build system simple: use very few layers initially

- Then add layers when needed based on benefit/cost ratio

  - The quality of several board/SoM layers is questionable

  - The quality of SoC vendor layers is varying

- A working example:

  - #link("https://github.com/bootlin/simplest-yocto-setup")

  - Minimal dependencies: BitBake, OE-core, meta-arm

  - One company-specific layer: meta-kiss

  - Custom distro and machine configurations, image recipes

  - Can be used as a starting point for your project

  - Introduced at Yocto Project Summit 2023
    (#link("https://bootlin.com/pub/conferences/2023/yp-summit/ceresoli-simple-layer/ceresoli-simple-layer.pdf")[slides],
    #link("https://youtu.be/zCMHy2PjsaM")[video])

== Creating a layer
<creating-a-layer>

=== Custom layer

#align(center, [#image("yocto-layer-create.svg", height: 90%)])

=== Create a custom layer 1/2

- A layer is a set of files and directories and can be created by hand.

- However, the `bitbake-layers create-layer` command helps us create new
  layers and ensures this is done right.

- `bitbake-layers create-layer -p <PRIORITY> <layer>`

- The *priority* is used to select which recipe to use when
  multiple layers contains the same recipe

- The layer priority takes precedence over the recipe version number
  ordering. This allows to downgrade a recipe in a layer.

=== Create a custom layer 2/2

- The layer created will be pre-filled with the following files:

  / conf/layer.conf: #block[
      The layer's configuration. Holds its priority and generic information.
      No need to modify it in many cases.

      - Mandatory, this is the entry point for the layer.
    ]

  / COPYING.MIT: #block[
      The license under which a layer is released. By default MIT.
    ]

  / README: #block[
      A basic description of the layer. Contains a contact e-mail to update.
    ] #v(0.5em)

- By default, all metadata matching `./recipes-*/*/*.bb` will be
  parsed by the BitBake _build engine_.

=== Creating a layer: best practices

- Do not copy and modify existing recipes from other layers. Instead use
  append files.

- Avoid duplicating files. Use append files or explicitly use a path
  relative to other layers.

- Save the layer alongside other layers.

- Use #yoctovar("LAYERDEPENDS") to explicitly define layer
  dependencies.

- Use #yoctovar("LAYERSERIES_COMPAT") to define the Yocto version(s)
  with which the layer is compatible.
