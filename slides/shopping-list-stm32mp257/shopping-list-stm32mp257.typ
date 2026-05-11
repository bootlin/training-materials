#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#let training = if "training" in sys.inputs {
  sys.inputs.training
} else { "" }

#let stm32mp257-nunchuk = (
  training in ("yocto", "buildroot", "embedded-linux", "linux-kernel")
)

#let stm32mp257-audio = (
  training == "embedded-linux"
)

#show: bootlin-theme

#set list(spacing: 0.8em)

=== STM32MP257 shopping list

#table(
  columns: (80%, 20%),
  stroke: none,
  gutter: 20pt,
  [
    - Discovery Kit STM32MP257F from STMicroelectronics
      #footnote[#text(size: 11pt)[Boards documentation:
        #link("https://www.st.com/en/evaluation-tools/stm32mp257f-dk.html")
      ]]

      - STM32MP257 (Dual Cortex-A35 + Cortex-M33) CPU
      - 4 GB LPDDR4 RAM
      - Plenty of peripherals: GPIOs, SPI, Serial, USB, Ethernet

    - USB-C to USB-A cable (power + console)

    #if stm32mp257-nunchuk [
      - Nintendo Nunchuk with UEXT connector
        #footnote[#text(size: 11pt)[#link(
          "https://www.olimex.com/Products/Modules/Sensors/MOD-WII/MOD-Wii-UEXT-NUNCHUCK/",
        )]]
      - Breadboard jumper wires - Male ends
        #footnote[#text(size: 11pt)[#link(
          "https://www.olimex.com/Products/Breadboarding/JUMPER-WIRES/JW-110x10/",
        )]]
    ]

    - MicroSD card

    #if stm32mp257-audio [
      - A standard USB audio headset
    ]
  ],
  [
    #v(-0.6em)
    #align(center)[
      #image("STM32MP257F-DK.png", width: 60%) \

      #if stm32mp257-nunchuk [
        #v(-0.5em)
        #image("/common/nunchuk.jpg", width: 50%) \
        #v(-0.5em)
        #image("/common/jumper-wires.jpg", width: 50%) \
      ]

      #if stm32mp257-audio [
        #v(-0.5em)
        #image("/common/usb-audio.jpg", width: 50%) \
      ]
    ]
  ],
)
