#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

===  Customize your board device tree!

- Kernel developers write _Device Tree Sources (DTS)_, which become
  _Device Tree Blobs (DTB)_ once compiled.

- There is one different Device Tree for each board/platform supported
  by the kernel, available in
  `arch/<arch>/boot/dts/<vendor>/<board>.dtb`
  (`arch/arm/boot/dts/<board>.dtb` on ARM 32 before Linux 6.5).

- As a board user, you may have legitimate needs to customize your board
  device tree:

  - To describe external devices attached to non-discoverable busses and
    configure them.

  - To configure pin muxing: choosing what SoC signals are made
    available on the board external connectors. See
    #link("http://linux.tanzilli.com/") for a web service doing this
    interactively.

  - To configure some system parameters: flash partitions, kernel
    command line (other ways exist)
