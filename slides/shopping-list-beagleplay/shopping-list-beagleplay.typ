#let training = sys.inputs.at("training", default: "")

#let beagleplay-nunchuk = (
  training in ("yocto", "embedded-linux", "linux-kernel")
)

#let beagleplay-audio = (
  training == "embedded-linux"
)

#import "@local/bootlin:0.1.0": *

#show: bootlin-theme

#set list(spacing: 0.8em)

=== BeaglePlay shopping list

#table(
  columns: (80%, 20%),
  stroke: none,
  gutter: 20pt,
  [
    - BeaglePlay, from #link("https://beagleboard.org")[BeagleBoard.org]
      - Texas Instruments AM625x (4×ARM Cortex-A53 CPU)
      - 2 GB RAM
      - 16 GB of on-board eMMC storage
      - Peripherals: SPI, I2C, UART, USB...
    - USB-C cable for the power supply
    - A USB-FTDI cable
    - RJ45 cable for networking
    - A micro SD card with at least 2G of capacity

    #if beagleplay-nunchuk [
      - Nintendo Nunchuk with UEXT connector
        #footnote[#text(size: 10pt)[#link(
          "https://www.olimex.com/Products/Modules/Sensors/MOD-WII/MOD-Wii-UEXT-NUNCHUCK/",
        )]]
      - Breadboard jumper wires - Male ends (to connect the Nunchuk)
        #footnote[#text(size: 10pt)[#link(
          "https://www.olimex.com/Products/Breadboarding/JUMPER-WIRES/JW-110x10/",
        )]]
    ]
    #if beagleplay-audio [
      - A standard USB audio headset
    ]
  ],
  [
    #align(center)[
      #image("beagleplay.jpg", width: 55%) \

      #if beagleplay-nunchuk [
        #image("/common/nunchuk.jpg", width: 50%) \
        #image("/common/jumper-wires.jpg", width: 50%) \
      ]

      #if beagleplay-audio [
        #image("/common/usb-audio.jpg", width: 50%) \

      ]
    ]
  ],
)
