#let training = sys.inputs.at("training", default: "")

#let imx93-frdm-nunchuk = (
  training in ("yocto", "embedded-linux", "linux-kernel")
)

#let imx93-frdm-audio = (
  training == "embedded-linux"
)

#let imx93-frdm-extra-serial = (
  training == "linux-kernel"
)

#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

#set list(spacing: 0.8em)

=== IMX93 FRDM shopping list

#table(columns: (80%, 20%), stroke: none, gutter: 20pt,
[
  
  - #text(size: 17pt)[NXP i.MX93 11x11 FRDM board Available from Mouser (76 EUR + VAT)]
    
    - NXP i.MX93 (Dual ARM Cortex-A55 + Cortex-M33)
    - 2 GB LPDDR4
    - 32 GB of on-board eMMC storage
    - Plenty of peripherals: I2C, SPI, UART, USB...

  - 2 USB-C cable for the power supply and the serial console
  - RJ45 cable for networking

  #if imx93-frdm-extra-serial [
  - USB Serial Cable - 3.3 V - Female ends
    #footnote[#text(size: 11pt)[#link("https://www.olimex.com/Products/USB-Modules/Interfaces/USB-SERIAL-F")]]
  ]

  #if imx93-frdm-nunchuk [
  - Nintendo Nunchuk with UEXT connector
    #footnote[#text(size: 11pt)[#link("https://www.olimex.com/Products/Modules/Sensors/MOD-WII/MOD-Wii-UEXT-NUNCHUCK/")]]
  - #text(size: 18pt)[Breadboard jumper wires - Male/Female ends (to connect to Nunchuk)]
    #footnote[#text(size: 11pt)[#link("https://www.olimex.com/Products/Breadboarding/JUMPER-WIRES/JW-200x10-FM/")]]
  ]
  - RJ45 cable for networking
  #if imx93-frdm-audio [
  - A standard USB audio headset
  ]
],
[
  #align(center)[
    #v(-1em)
    #image("imx93-frdm.png", width: 55%) \
    #v(-0.5em)
    #if imx93-frdm-extra-serial [
      #image("/common/usb-serial-cable-female.jpg", width: 50%) \
    ]
    #v(-0.5em)
    #if imx93-frdm-nunchuk [
      #image("/common/nunchuk.jpg", width: 50%) \
      #v(-0.5em)
      #image("/common/jumper-wires.jpg", width: 50%) \
      #v(-0.5em)
    ]

    #if imx93-frdm-audio [
      #image("/common/usb-audio.png", width: 50%) \
    ]
  ]
]
)