#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Sound and its representation

=== What is sound?

- Sound is caused by vibrations

- Vibrations create waves, travelling through a medium

- Humans perceive acoustic waves with their ears, as eardrum are
  vibrating, converting the signal for the brain

- It is usually represented as a sine wave, however, it is a
  longitudinal wave (compression/rarefaction) in air and water and a
  transversal wave in solids.

#v(0.5em)

#align(center, [#image("CPT-sound-physical-manifestation.pdf", width: 60%)])

=== Sound characteristics

- Sound waves have a frequency, measured in Hertz (Hz), this is the
  pitch of the sound.

- They also have an amplitude, measured in decibels (dB), this is the
  loudness of the sound.

- Multiple waves of different frequencies and amplitude combine to
  create the actual sound with different qualities and timbre.

#v(0.5em)

#align(center, [#image("sound-compose.png", width: 80%)])

=== Sound digitization - samples

- Sound waves are continuous curves composed of a infinite number of
  points.

- For any point on the curve, it is possible to measure the audio level
  of this point.

- This is a sample. We can then take samples at regular interval to have
  a digital representation of the curve.

#v(0.5em)

#align(center, [#image("sound-samples.png", width: 80%)])

=== Sound digitization - sample rate

- The sample rate, or sampling frequency is the number of samples taken
  per seconds.

- If the sampling frequency is too slow, we may have aliasing issues
  were the sampled signal doesn't match the analog signal.

- The *Shannon-Nyquist theorem* states that the sampling
  frequency needs to be at least twice the maximum signal frequency to
  accurately digitize a signal.

- The Human ear can hear sound frequencies between approximately 20 Hz
  and 20 kHz.

#align(center, [#image("aliasing-1d.pdf", width: 60%)])
#align(center, [_Aliasing example, the sampled signal is in blue_])

=== Sound digitization - sample size

- The sample value varies from 0 to the maximum amplitude value.

- If the amplitude is 1.0, then it varies from -1.0 and 1.0

- The sample size, in bits, then defines the resolution.

- Common sample sizes are 16 and 24 bits.

- 8 bits is getting very rare due to the poor audio quality and 32 bits
  samples can be used when specific alignment is required.

=== Sound digitization - sample format

There are multiple ways to store samples in memory or on disk:

- as signed integers

- as unsigned integers

- as floating points

Also, they can be stored in little-endian or big-endian order. For 24bit
samples, packing can also differ: either they are packed on 3 bytes or
they can be packed in a 32bit integer with the most significant byte
being ignored.

=== Sound digitization - conclusions

- We can then store sound as a sequence of samples and the specific
  sample rate that was used.

- This method is called Linear Pulse-code modulation or LPCM.

- A sampling rate of about 40kHz is needed.

=== Sound digitization - example WAV

WAV is a format based on RIFF and has the following header:
#v(0.5em)
#text(size: 15pt)[
  #align(center)[
    #table(
      columns: 3,
      stroke: (x, y) => (
        top: if y > 0 { stroke(1pt) },
        left: if x > 0 { stroke(1pt) },
      ),
      align: (col, row) => (center, center, left).at(col),
      inset: 6pt,
      [Position], [Value], [Description],
      [1 - 4], ["RIFF"], [RIFF FOURCC code],
      [5 - 8], [], [File size in bytes, minus 8 (32-bit integer).],
      [9 -12], ["WAVE"], [WAVE FOURCC code],
      [13-16], [“fmt "], [Format chunk marker (includes trailing space)],
      [17-20], [16], [Length of format data, 16 for PCM],
      [21-22], [1], [Audio format, 1 for PCM],
      [23-24], [2], [Number of channels],
      [25-28], [48000], [Sample rate],
      [29-32],
      [176400],
      [Byte rate = (Sample rate*BitsPerSample*channels) / 8.],

      [33-34], [4], [BlockAlign = (BitsPerSample*Channels) / 8],
      [35-36], [16], [Bits per sample],
      [37-40], ["data"], [Data chunk header],
      [41-44], [], [Size of the data section in bytes],
    )
  ]]

=== Sound digitization - example WAV

#align(center, [#image("RIFF_WAVE.png", width: 100%)])
