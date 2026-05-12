#let stm32mp157-nunchuk = (
  sys.inputs.at("training", default: "") in ("yocto", "buildroot", "embedded-linux", "linux-kernel")
)

#let stm32mp157-audio = (
  sys.inputs.at("training", default: "") == "embedded-linux"
)

#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

#set list(spacing: 0.8em)

=== STM32MP157 shopping list

#table(columns: (80%, 20%), stroke: none, gutter: 20pt,
[
  #text(size: 18.5pt)[
  - Discovery Kits from STMicroelectronics:
    STM32MP157A-DK1, STM32MP157D-DK1,
    STM32MP157C-DK2 or STM32MP157F-DK2
    #footnote[#text(size: 11pt)[Boards documentation:
      #link("https://www.st.com/en/evaluation-tools/stm32mp157a-dk1.html")[A-DK1],
      #link("https://www.st.com/en/evaluation-tools/stm32mp157d-dk1.html")[D-DK1],
      #link("https://www.st.com/en/evaluation-tools/stm32mp157c-dk2.html")[C-DK2],
      #link("https://www.st.com/en/evaluation-tools/stm32mp157f-dk2.html")[F-DK2]
    ]] 

    - #text(size: 18pt)[STM32MP157 (Dual Cortex-A7 + Cortex-M4) CPU]
    - #text(size: 18pt)[512 MB DDR3L RAM]
    - #text(size: 18pt)[Plenty of peripherals: GPIOs, SPI, Serial, USB, Ethernet...]

  - MicroUSB cable (to access serial console)
  - USB-C to USB-A cable (to power the board)

  #if stm32mp157-nunchuk [
  - Nintendo Nunchuk with UEXT connector
    #footnote[#text(size: 11pt)[#link("https://www.olimex.com/Products/Modules/Sensors/MOD-WII/MOD-Wii-UEXT-NUNCHUCK/")]]
  - Breadboard jumper wires - Male ends (to connect the Nunchuk)
    #footnote[#text(size: 11pt)[#link("https://www.olimex.com/Products/Breadboarding/JUMPER-WIRES/JW-110x10/")]]
  ]

  - MicroSD card
  - RJ45 cable

  #if stm32mp157-audio [
  - A standard USB audio headset
  ]]
],
[
  #align(center)[
    #image("discovery-board-dk1.png", width: 55%) \
    #v(-0.5em)
    #if stm32mp157-nunchuk [
      #image("/common/nunchuk.jpg", width: 50%) \
      #v(-0.5em)
      #image("/common/jumper-wires.jpg", width: 50%) \
    ]

    #if stm32mp157-audio [
      #v(-0.5em)
      #image("/common/usb-audio.png", width: 50%) \
    ]
  ]
])