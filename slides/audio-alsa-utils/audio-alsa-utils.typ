#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== alsa-utils

===  alsa-utils

- `alsa-utils` is a repository of tools to interact with ALSA
  devices

- #link("https://github.com/alsa-project/alsa-utils")

===  Controls

- `alsamixer ` provides a `ncurse` based graphical interface to
  modify sound cards controls.

- ` amixer ` is a command line tool to set controls.

  - The `scontrols` and `controls` commands list the available
    controls.

  - The `contents` commands list the available controls and shows
    their content.

  - The `cset` and `sset` commands allows modifying the
    controls.

  - The `cget` and `sget` commands show the content of a
    specific control.

- `alsactl` is a tool that can save the control values to a file and
  restore them from a file.

===  Playback and capture

- `speaker-test` can generate tones or noises to play on specific
  channels with a specified rate.

- `aplay` plays an audio file. It is able to set many stream
  parameters.

- `arecord` can record an audio stream to a file.

#setupdemoframe([Userspace tools],[ Using userspace tools to:

- configure sound card controls

- load and store default values for controls

- play sound

- record

])
