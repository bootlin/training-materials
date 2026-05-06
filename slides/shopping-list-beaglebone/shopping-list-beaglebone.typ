#import "@local/bootlin:0.1.0": *

#show: bootlin-theme.with(
  aspect-ratio: "16-9"
)

#let beaglebone-nunchuk = false
#let beaglebone-audio = false

#let beaglebone-nunchuk = (
  sys.inputs.at("training", default: "") in ("yocto", "buildroot", "embedded-linux", "linux-kernel")
)
#let beaglebone-audio = (
  sys.inputs.at("training", default: "") == "embedded-linux"
)
#set list(spacing: 0.6em)

===  Beaglebone Black / Beaglebone black wireless shopping list

#table(columns: (80%, 20%), stroke: none, gutter: 20pt,
[
  #text(size: 17pt)[
  - BeagleBone Black or BeagleBone Black Wireless, from #link("https://beagleboard.org")[BeagleBoard.org] 
    - #text(size: 16pt)[Texas Instruments AM335x (ARM Cortex-A8 CPU)]
    - #text(size: 16pt)[512 MB of RAM]
    - #text(size: 16pt)[4 GB of on-board eMMC storage]
    - #text(size: 16pt)[Plenty of peripherals and features]
    - #text(size: 16pt)[2 x 46 pins headers, with access to many expansion buses (I2C, SPI, UART and more)]
  - MicroUSB cable
  - USB Serial Cable - 3.3 V - Female ends (for serial console)
    #footnote[#text(size: 16pt)[#link("https://www.olimex.com/Products/USB-Modules/Interfaces/USB-SERIAL-F")]]
  #if beaglebone-nunchuk [
  - Nintendo Nunchuk with UEXT connector
    #footnote[#text(size: 16pt)[#link("https://www.olimex.com/Products/Modules/Sensors/MOD-WII/MOD-Wii-UEXT-NUNCHUCK/")]]
  - Breadboard jumper wires - Male ends (to connect the Nunchuk)
    #footnote[#text(size: 16pt)[#link("https://www.olimex.com/Products/Breadboarding/JUMPER-WIRES/JW-110x10/")]]]
  - MicroSD card 
  #if beaglebone-audio [
  - A standard USB audio headset
  ]]
  
],
[#align(center)[
    #v(-1em)
    #image("beagleboneblack.png", width: 50%) \
    #v(-1em)
    #image("/common/usb-serial-cable-female.jpg", width: 50%) \
    #v(-1em)
    #if beaglebone-nunchuk [
      #image("/common/nunchuk.jpg", width: 50%) \ 
      #v(-1em)
      #image("/common/jumper-wires.jpg", width: 50%) \
    ]
    #v(-1em)
    #if beaglebone-audio [
      #image("/common/usb-audio.png", width: 50%) \
      #v(-1em)
    ]
  ]
]
)