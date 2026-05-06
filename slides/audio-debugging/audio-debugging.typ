#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

#show raw.where(lang: "console", block: true): set text(size: 15pt)

= Troubleshooting

===  Troubleshooting: no sound 

Audio seems to play for the correct duration but there is no sound:

- Unmute `Master` and the relevant controls

- Turn up the volume

- Check the codec analog muxing and mixing (use alsamixer)

- Check the amplifier configuration

- Check the routing

===  Troubleshooting: no sound 

When trying to play sound but it seems stuck:

- Check pinmuxing

- Check the configured clock directions

- Check the producer/consumer configuration

- Check the clocks using an oscilloscope

- Check pinmuxing

- Some SoCs also have more muxing (NXP i.Mx AUDMUX, TI McASP)

===  Troubleshooting: write error

```console
# aplay test.wav 
Playing WAVE 'test.wav' : Signed 16 bit Little Endian, Rate 44100 Hz, Stereo aplay: pcm_write:1737: write error: Input/output error
```

- Usually caused by an issue in the routing

- Check that the codec driver exposes a stream named "Playback"

- Use `vizdapm`: #link("https://github.com/mihais/asoc-tools")

===  Troubleshooting: over/underruns

```console
# aplay test.wav 
Playing WAVE 'test.wav' : Signed 16 bit Little Endian, Rate 44100 Hz, Stereo underrun!!! (at least 1.899 ms long)
underrun!!! (at least 0.818 ms long)
underrun!!! (at least 2.912 ms long)
underrun!!! (at least 8.558 ms long)
```

- Usually caused by an imprecise BCLK

- Try to find a better PLL and dividers combination

===  Troubleshooting: going further

- Use `speaker-test` to generate audio and play tones.

- Be careful with the 440Hz tone, it may not expose all the errors.
  Rather play something that is not commonly divisible (e.g. 441Hz)

- Generate tone with fade in and fade out as this allows to catch DMA
  transfer issues more easily.

===  Troubleshooting: going further

- Have a look at the CPU DAI driver and its callback. In particular:
  `.set_clkdiv` and `.set_sysclk` to understand how the various clock
  dividers are setup. `.hw_params` or `.set_dai_fmt` may do some
  muxing

- Have a look at the codec driver callbacks, `.set_sysclk` as the
  `clk_id` parameter is codec specific.

- Remember using a codec as a clock consumer is an uncommon
  configuration and is probably untested.

- When in doubt, use `devmem` or `i2cget`

#setupdemoframe([Troubleshooting],[

- Using debugfs to find issues

- Using vizdapm

- Using ftrace to trace register writes and DAPM states

])
