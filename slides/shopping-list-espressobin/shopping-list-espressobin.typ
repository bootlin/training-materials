#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

=== Shopping list

#table(
  columns: (75%, 25%),
  stroke: none,
  [

    - EspressoBin board: one of
      #link("https://globalscaletechnologies.com/product/espressobin/")[ESPRESSObin 1GB DDR4 with micro SD Card Slot],
      #link(
        "https://globalscaletechnologies.com/product/espressobin-1gb-ddr4-with-4gb-emmc/",
      )[ESPRESSObin 1GB DDR4 with 4GB eMMC]
      or
      #link(
        "https://globalscaletechnologies.com/product/espressobin-2gb-msd-card-slot/",
      )[ESPRESSObin 2GB DDR4 with micro SD Card Slot]

      - Marvell Armada 3720 SoC (Dual ARM64 Cortex-A53 CPU)

      - SoC with powerful Network Controller (up to 2.5Gbps), SATA, PCIe

      - 1 or 2 GB of RAM

      - Versions with SD card or eMMC

      - Marvell 88e6341 Switch with 3 Gbps interfaces

    - A 12V power supply compatible with the EspressoBin, such as
      #link("https://www.amazon.fr/dp/B015MGWBYE")[this one] (5.5mm / 2.1mm)

    - A USB-A to micro B cable for the serial console.

    - Two RJ45 cables for networking

    - A microSD card of at least 8 GB capacity

  ],
  [

    #align(center, [#image("espressobin.jpg", height: 30%)])

  ],
)
