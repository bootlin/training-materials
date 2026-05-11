#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Embedded audio Hardware
<embedded-audio-hardware>

=== Anatomy

#align(center, [#image("anatomy.svg", width: 100%)])
#align(center, [#emph[Example of an embedded system sound card]])

== CODECs
<codecs>

=== CODECs

- A CODEC is a device that COdes and DECodes audio samples.

- It integrates an analog-to-digital converter (ADC) and a
  digital-to-analog converter (DAC) into a single chip.

- It converts a voltage signal from an analog input (e.g. microphone) to
  a sequence of samples or converts a stream of samples to a voltage for
  an analog output (e.g. speaker driver).

- It also has one or multiple digital audio interfaces (DAI) to transfer
  samples to or from a microcontroller or microprocessor.

- Usually an extra digital bus is used for configuration

=== Digital audio interface - signals

The CODEC DAI is a synchronous serial bus. A common PCM interface is represented here:

#align(center, [#image("i2s.svg", height: 50%)])

=== Digital audio interface - signals

- The PCM DAI uses two clocks: the bit clock and the frame clock.

  - The bit clock is usually referred to as BCK or BCLK

  - The frame clock is often called FCLK/FSCK/FSCLK, LRCK/LRCLK (Left
    Right clock) or WCLK (word clock). Its rate is the sample rate also
    called Fs.

  - The relationship between BCK and FSCK is: bck = fsck ∗ Nchannels ∗
    BitDepth

- It also has one or multiple data lines.

=== Digital audio interface - Data

- Codecs may have multiple data in or data out lines, one line per
  channel pair.

- Codecs may also have multiple DAI, one full interface for data in and
  one for data out.

#table(
  columns: (49.5%, 50.5%),
  stroke: none,
  gutter: 15pt,
  [
    e.g. #link("https://www.analog.com/media/en/technical-documentation/data-sheets/AD1937.pdf")[AD1937]
    has:

    - 8 DACs in 4 pairs, 4 ADCs in 2 pairs

    - clocks for data-in: DBCLK, DLRCLK

    - 4 data-in lines (DSDATA[1-4])

    - clocks for data-out: ABCLK, ALRCLK

    - 2 data-out lines (ASDATA[1-2])

  ],
  [

    #align(center, [#image("ad1937.pdf", width: 90%)])

  ],
)

=== MCLK

- MCLK is the codec clock. It is sometimes referred as the system clock.
  The IC needs it to be working.

- Some codecs will also require it to be able to use the control
  interface.

- Can be provided by the SoC when it has suitable clocks or a crystal.

- Some codecs are able to use BCLK or LRCLK as their clock, making MCLK
  optional.

- Usually the codecs will expect MCLK to be a multiple of BCLK. Usually
  specified as a multiple of Fs.

== SoC Digital Audio Interface
<soc-digital-audio-interface>

=== SoC

- The SoC also has a dedicated synchronous serial interface.

- Some are generic serial interfaces others are dedicated to audio
  formats.

- It has a DMA controller or a peripheral DMA controller (PDC) able to
  copy samples from memory to the serial interface registers or FIFO.

- It quite often also has dedicated multimedia (audio/video) clocks.

- Examples: Atmel SSC, NXP SSI, NXP SAI, TI McASP

- Some SoCs have a separate SPDIF controller

- Some SoCs (Allwinner A33, Atmel SAMA5D2) have the codec and the
  amplifier on the SoC itself so the sound card is completely on the
  SoC.

== Digital formats
<digital-formats>

=== Digital formats - Left Justified

#align(center, [#image("LJ.png", width: 100%)])

=== Digital formats - Right Justified

#align(center, [#image("RJ.png", width: 100%)])

=== Digital formats - I2S

#align(center, [#image("I2S.png", width: 100%)])

=== Digital formats - DSP A

#align(center, [#image("DSP_A.png", width: 100%)])

=== Digital formats - DSP B

#align(center, [#image("DSP_B.png", width: 100%)])

=== Digital formats - TDM

#align(center, [#image("TDM.png", width: 100%)])

=== Digital formats - AC-link

AC97 uses TDM slots. Slot 0 is 16bit wide and is the tag. Then twelve 20bit wide slots are used to transmit
data.

#v(0.5em)

#align(center, [#image("ac97.svg", height: 35%)])

#align(center, [#image("ac97_phases.svg", height: 35%)])

=== Digital formats - PDM

There is another, less common interface,
using Pulse Density Modulation. It has two signals per channels, clock
and data. Data has only one bit.

#align(center, [#image("PDM.svg", height: 85%)])

=== Digital formats - S/PDIF or IEC 60958

S/PDIF uses only one wire. Data is encoded using BMC (Biphase Mark Code), also known as
differential Manchester encoding. Its clock is then twice the bitrate.

#align(center, [#image("BMC.svg", height: 25%)])

Blocks of 192 frames are transmitted, each frame consisting of two
subframes (32bit words). There are three different preambles, one for
start of block and channel 0, one for channel 0 and one for channel 1.

#align(center, [#image("SPDIF.svg", height: 30%)])

== Auxiliary devices
<auxiliary-devices>

=== Auxiliary devices

- Some devices may be on the analog path of the audio signal.

- They can be amplifiers, potentiometers or multiplexers.

- Some can be controlled and should be exposed as controls of the sound
  card.

== Clocks
<clocks>

=== Clocks: producer/consumer

- One of the DAI is responsible to generate the bit clock, it is the bit
  clock producer (previously: master).

- One of the DAI is responsible to generate the frame clock, it is the
  frame producer.

- Some CODECs have a great set of PLLs and dividers, allowing to get a
  precise BCLK from many different MCLK rates.

- Quite often, it is better to use the CODEC as producer. However, some
  SoCs have specialized audio PLLs.
