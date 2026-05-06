#let training = sys.inputs.at("training", default: "")

#let beagleplay-nunchuk = (
  training in ("yocto", "embedded-linux", "linux-kernel")
)

#let beagleplay-audio = (
  training == "embedded-linux"
)

#import "@local/bootlin:0.1.0": *

#show: bootlin-theme

=== BeaglePlay shopping list

#table(columns: (80%, 20%), stroke: none, gutter: 20pt,
[
  #text(size: 19.5pt)[
  - BeaglePlay, from #link("https://beagleboard.org")[BeagleBoard.org] 
    - #text(size: 18pt)[Texas Instruments AM625x (4× ARM Cortex-A53)]
    - #text(size: 18pt)[2 GB RAM]
    - #text(size: 18pt)[16 GB eMMC]
    - #text(size: 18pt)[Peripherals: SPI, I2C, UART, USB]
  - USB-C cable (power)
  - USB-FTDI cable
  - RJ45 cable
  - MicroSD card (≥ 2 GB)

  #if beagleplay-nunchuk [
  - Nintendo Nunchuk with UEXT connector
    #footnote[#text(size: 16pt)[#link("https://www.olimex.com/Products/Modules/Sensors/MOD-WII/MOD-Wii-UEXT-NUNCHUCK/")]]
  - Breadboard jumper wires - Male ends
    #footnote[#text(size: 16pt)[#link("https://www.olimex.com/Products/Breadboarding/JUMPER-WIRES/JW-110x10/")]]
  ]

  #if beagleplay-audio [
  - A standard USB audio headset
  ]]
],
[
  #align(center)[
    #image("beagleplay.png", width: 55%) \

    #if beagleplay-nunchuk [
      #image("/common/nunchuk.jpg", width: 50%) \ 
      #image("/common/jumper-wires.jpg", width: 50%) \
    ]

    #if beagleplay-audio [
      #image("/common/usb-audio.png", width: 50%) \ 
      
    ]
  ]
]
)