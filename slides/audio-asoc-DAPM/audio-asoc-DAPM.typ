#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== ASoC DAPM

===  Power management with ASoC

- Many components allow flexible routing

- Different routings require different components to be turned on

- Many combinations: code to enable only what is needed tends to be
  complex and not easy to maintain

#align(center, [#image("adau1372.png", height: 40%)])
#text(size: 13pt)[#align(center, [(#link("https://www.analog.com/media/en/technical-documentation/data-sheets/ADAU1372.pdf"))])]

===  DAPM: Dynamic Audio Power Management

- The power management component of ASoC

- Linux Runtime PM works at the device level, → not suitable

- DAPM is independent from kernel Runtime PM, and co-existing

- Transparent to user space applications, saves as much power as
  possible by shutting down audio routes that are not in use.

- Describes every power-related element as a node of a graph

- Every power control is called a DAPM *widget* (graph node)

- Every connection between widgets is called a DAPM *route*
  (directed graph edge)

- DAPM automatically enables widgets based on active routes

#v(0.3em)

#table(columns: (50%, 50%), stroke: none, gutter: 30pt, [

#align(center, [#image("dapm-widgets-ain0.pdf", height: 25%)])

],[

#align(center, [#image("dapm-widgets-dmic0.pdf", height: 25%)])

])

===  DAPM: Dynamic Audio Power Management

- DAPM widgets can be controlled by a regular kcontrol

#align(center, [#image("dapm-mux.pdf", height: 40%)])

===  DAPM: Dynamic Audio Power Management

- The DAPM tree spans the whole card

  - In-component widgets and routes are implemented by the component
    driver

  - Border widgets and cross-component routes are added by the card

#align(center, [#image("dapm-widgets-cross-components.pdf", width: 100%)])

===  [t]Endpoint widgets

#align(center, [#image("widgets-endpoint.pdf", width: 70%)])

#v(2em)

- Widgets where the sound stream originates from or terminates at

- ADC, DAC (PCM waveform to/from memory)

- Speaker, Line out, Microphone, …

===  [t]Pass-through widgets

#align(center, [#image("widgets-pass-through.pdf", width: 70%)])

#v(2em)

- Widgets on a route between other widgets

- Sound modifiers (PGA, Effect)

- Routing: Mixer, Mux, Demux, Switch

===  [t]Supply widgets

#align(center, [#image("widgets-supply.pdf", width: 70%)])

#v(1em)

- Suppliers to other widgets

- Clock, current, voltage

===  Defining DAPM widgets

- A widget is defined by #kstruct("snd_soc_dapm_widget")

#v(0.5em)
#text(size: 14pt)[#kfile("include/sound/soc-dapm.h")]
#v(-0.3em)
#[
        #show raw.where(lang: "c", block: true): set text(size: 13pt)
```c
struct snd_soc_dapm_widget {
    enum snd_soc_dapm_type id;
    const char *name;                             /* widget name */
    const char *sname;                            /* stream name */
    struct snd_soc_dapm_context *dapm;
    /* ... */
    struct pinctrl *pinctrl;                      /* attached pinctrl */
    /* ... */
    int reg;                                      /* negative reg = no direct dapm */
    unsigned char shift;                          /* bits to shift */
    unsigned int mask;                            /* non-shifted mask */
    unsigned int on_val;                          /* on state value */
    unsigned int off_val;                         /* off state value */
    /* ... */
    unsigned short event_flags;                   /* flags to specify event types */
    int (*event)(struct snd_soc_dapm_widget*, struct snd_kcontrol *, int);
};
```
]

===  `snd_soc_dapm_widget`

- An array of #kstruct("snd_soc_dapm_widget") is registered by the
  component.

- Many helpers exist to avoid filling the struct manually:

#v(0.5em)
#text(size: 14pt)[#kfile("include/sound/soc-dapm.h")]
#v(-0.3em)

#[
        #show raw.where(lang: "c", block: true): set text(size: 10pt)
  ```c
  #define SND_SOC_DAPM_INPUT(wname) 
  {       .id = snd_soc_dapm_input, .name = wname, .kcontrol_news = NULL, 
          .num_kcontrols = 0, .reg = SND_SOC_NOPM }
  #define SND_SOC_DAPM_OUTPUT(wname) 
  {       .id = snd_soc_dapm_output, .name = wname, .kcontrol_news = NULL, 
          .num_kcontrols = 0, .reg = SND_SOC_NOPM }
  #define SND_SOC_DAPM_MIC(wname, wevent) 
  {       .id = snd_soc_dapm_mic, .name = wname, .kcontrol_news = NULL, 
          .num_kcontrols = 0, .reg = SND_SOC_NOPM, .event = wevent, 
          .event_flags = SND_SOC_DAPM_PRE_PMU | SND_SOC_DAPM_POST_PMD}
  [...]
  #define SND_SOC_DAPM_PGA(wname, wreg, wshift, winvert,
           wcontrols, wncontrols) 
  {       .id = snd_soc_dapm_pga, .name = wname, 
          SND_SOC_DAPM_INIT_REG_VAL(wreg, wshift, winvert), 
          .kcontrol_news = wcontrols, .num_kcontrols = wncontrols}
  [...]
  #define SND_SOC_DAPM_MUX(wname, wreg, wshift, winvert, wcontrols) 
  {       .id = snd_soc_dapm_mux, .name = wname, 
          SND_SOC_DAPM_INIT_REG_VAL(wreg, wshift, winvert), 
          .kcontrol_news = wcontrols, .num_kcontrols = 1}
  #define SND_SOC_DAPM_DEMUX(wname, wreg, wshift, winvert, wcontrols) 
  {       .id = snd_soc_dapm_demux, .name = wname, 
          SND_SOC_DAPM_INIT_REG_VAL(wreg, wshift, winvert), 
          .kcontrol_news = wcontrols, .num_kcontrols = 1}
  ```
]

===  `snd_soc_dapm_widget`

#text(size: 14pt)[#kfile("include/sound/soc-dapm.h")]
#v(-0.3em)
#[
        #show raw.where(lang: "c", block: true): set text(size: 9pt)
```c
#define SND_SOC_DAPM_DAC(wname, stname, wreg, wshift, winvert) 
{       .id = snd_soc_dapm_dac, .name = wname, .sname = stname, 
        SND_SOC_DAPM_INIT_REG_VAL(wreg, wshift, winvert) }
#define SND_SOC_DAPM_DAC_E(wname, stname, wreg, wshift, winvert, 
                           wevent, wflags)                                
{       .id = snd_soc_dapm_dac, .name = wname, .sname = stname, 
        SND_SOC_DAPM_INIT_REG_VAL(wreg, wshift, winvert), 
        .event = wevent, .event_flags = wflags}

#define SND_SOC_DAPM_ADC(wname, stname, wreg, wshift, winvert) 
{       .id = snd_soc_dapm_adc, .name = wname, .sname = stname, 
        SND_SOC_DAPM_INIT_REG_VAL(wreg, wshift, winvert), }
#define SND_SOC_DAPM_ADC_E(wname, stname, wreg, wshift, winvert, 
                           wevent, wflags)                                
{       .id = snd_soc_dapm_adc, .name = wname, .sname = stname, 
        SND_SOC_DAPM_INIT_REG_VAL(wreg, wshift, winvert), 
        .event = wevent, .event_flags = wflags}


/* generic widgets */
#define SND_SOC_DAPM_REG(wid, wname, wreg, wshift, wmask, won_val, woff_val) 
{       .id = wid, .name = wname, .kcontrol_news = NULL, .num_kcontrols = 0, 
        .reg = wreg, .shift = wshift, .mask = wmask, 
        .on_val = won_val, .off_val = woff_val, }
#define SND_SOC_DAPM_SUPPLY(wname, wreg, wshift, winvert, wevent, wflags) 
{       .id = snd_soc_dapm_supply, .name = wname, 
        SND_SOC_DAPM_INIT_REG_VAL(wreg, wshift, winvert), 
        .event = wevent, .event_flags = wflags}
#define SND_SOC_DAPM_REGULATOR_SUPPLY(wname, wdelay, wflags)            
{       .id = snd_soc_dapm_regulator_supply, .name = wname, 
        .reg = SND_SOC_NOPM, .shift = wdelay, .event = dapm_regulator_event, 
        .event_flags = SND_SOC_DAPM_PRE_PMU | SND_SOC_DAPM_POST_PMD, 
        .on_val = wflags}
```
]

===  DAPM example

#text(size: 14pt)[#kfile("sound/soc/codecs/pcm3168a.c")]
#v(-0.3em)

```c
static const struct snd_soc_dapm_widget pcm3168a_dapm_widgets[] = {
        SND_SOC_DAPM_DAC("DAC1", "Playback", PCM3168A_DAC_OP_FLT,
                        PCM3168A_DAC_OPEDA_SHIFT, 1),
        SND_SOC_DAPM_DAC("DAC2", "Playback", PCM3168A_DAC_OP_FLT,
                        PCM3168A_DAC_OPEDA_SHIFT + 1, 1),
        SND_SOC_DAPM_DAC("DAC3", "Playback", PCM3168A_DAC_OP_FLT,
                        PCM3168A_DAC_OPEDA_SHIFT + 2, 1),
        SND_SOC_DAPM_DAC("DAC4", "Playback", PCM3168A_DAC_OP_FLT,
                        PCM3168A_DAC_OPEDA_SHIFT + 3, 1),

        SND_SOC_DAPM_OUTPUT("AOUT1L"),
        SND_SOC_DAPM_OUTPUT("AOUT1R"),
        SND_SOC_DAPM_OUTPUT("AOUT2L"),
        SND_SOC_DAPM_OUTPUT("AOUT2R"),
        SND_SOC_DAPM_OUTPUT("AOUT3L"),
        SND_SOC_DAPM_OUTPUT("AOUT3R"),
        SND_SOC_DAPM_OUTPUT("AOUT4L"),
        SND_SOC_DAPM_OUTPUT("AOUT4R"),
```

Note: on the #link("https://www.ti.com/lit/gpn/pcm3168a")[PCM3168A] DACs
and ADCs can only be powered down in pairs.

===  DAPM example

#text(size: 14pt)[#kfile("sound/soc/codecs/pcm3168a.c")]
#v(-0.3em)

```c
        SND_SOC_DAPM_ADC("ADC1", "Capture", PCM3168A_ADC_PWR_HPFB,
                        PCM3168A_ADC_PSVAD_SHIFT, 1),
        SND_SOC_DAPM_ADC("ADC2", "Capture", PCM3168A_ADC_PWR_HPFB,
                        PCM3168A_ADC_PSVAD_SHIFT + 1, 1),
        SND_SOC_DAPM_ADC("ADC3", "Capture", PCM3168A_ADC_PWR_HPFB,
                        PCM3168A_ADC_PSVAD_SHIFT + 2, 1),

        SND_SOC_DAPM_INPUT("AIN1L"),
        SND_SOC_DAPM_INPUT("AIN1R"),
        SND_SOC_DAPM_INPUT("AIN2L"),
        SND_SOC_DAPM_INPUT("AIN2R"),
        SND_SOC_DAPM_INPUT("AIN3L"),
        SND_SOC_DAPM_INPUT("AIN3R")
};
```

===  `snd_soc_dapm_route`

- An array of #kstruct("snd_soc_dapm_route") is registered by the
  component to define the routes.

#v(0.5em)
#text(size: 14pt)[#kfile("include/sound/soc-dapm.h")]
#v(-0.3em)

```c
struct snd_soc_dapm_route {
        const char *sink;
        const char *control;
        const char *source;

        /* Note: currently only supported for links where source is a supply */
        int (*connected)(struct snd_soc_dapm_widget *source,
                         struct snd_soc_dapm_widget *sink);

        struct snd_soc_dobj dobj;
};
```

===  DAPM routes example

#text(size: 14pt)[#kfile("sound/soc/codecs/pcm3168a.c")]
#v(-0.3em)

```c
static const char * const adau1372_decimator_mux_text[] = { "ADC", "DMIC", }; static SOC_ENUM_SINGLE_DECL(adau1372_decimator0_1_mux_enum, ADAU1372_REG_ADC_CTRL2,
                            2, adau1372_decimator_mux_text);

static const struct snd_soc_dapm_route adau1372_dapm_routes[] = {
    { "PGA0",           NULL,   "AIN0"        },
    { "ADC0",           NULL,   "PGA0"        },
    { "Decimator0 Mux", "ADC",  "ADC0"        },
    { "Decimator0 Mux", "DMIC", "DMIC0_1"     },
    { "HPOUTL",         NULL,   "OP_STAGE_LP" },
    { "HPOUTL",         NULL,   "OP_STAGE_LN" },
    /* ... */
};
```

- Control is a standard ALSA kcontrol for selection of mux input, demux
  output, mixer levels, PGA gain, …

- Matching based on strings

===  Adding DAPM widgets and routes

- Just point to the defined arrays in
  #kstruct("snd_soc_component_driver")

```c
static const struct snd_soc_component_driver adau1372_driver = {
    .set_bias_level = adau1372_set_bias_level,
    .controls = adau1372_controls,
    .num_controls = ARRAY_SIZE(adau1372_controls),
    .dapm_widgets = adau1372_dapm_widgets,
    .num_dapm_widgets = ARRAY_SIZE(adau1372_dapm_widgets),
    .dapm_routes = adau1372_dapm_routes,
    .num_dapm_routes = ARRAY_SIZE(adau1372_dapm_routes),
};
```

===  Adding DAPM widgets and routes dynamically

- DAPM routes can be added dynamically, e.g. based on codec model

```c
static const struct snd_soc_dapm_widget wm8994_dapm_widgets[] = { ... }; static const struct snd_soc_dapm_route wm8994_intercon[] = { ... };

static int wm8994_component_probe(struct snd_soc_component *component)
{
    /* ... */
    switch (control->type) {
    case WM8994:
        snd_soc_dapm_new_controls(dapm, wm8994_specific_dapm_widgets,
                                  ARRAY_SIZE(wm8994_specific_dapm_widgets));
        /* ... */
        snd_soc_dapm_add_routes(dapm, wm8994_intercon,
                                ARRAY_SIZE(wm8994_intercon));
        /* ... */
    }
}
```

===  Connecting widgets to the DAI stream

- The endpoints of the DAPM graph are

  - The external input/output pins

    - `SND_SOC_DAPM_INPUT()`, `SND_SOC_DAPM_OUTPUT()`

  - The DAI (digital audio interface)

    - Via the stream name defined by the DAI driver, using
      (sub)string-based matching

```c
static const struct snd_soc_dapm_widget wm9705_dapm_widgets[] = {
    SND_SOC_DAPM_DAC("Left DAC",  "Left HiFi Playback",  SND_SOC_NOPM, 0, 0),
    SND_SOC_DAPM_DAC("Right DAC", "Right HiFi Playback", SND_SOC_NOPM, 0, 0),

...

static struct snd_soc_dai_driver wm9705_dai[] = {
    {
        .name = "wm9705-hifi",
        .playback = {
            .stream_name = "HiFi Playback",
...
```

===  [t]Phase 1: determining power state

#align(center, [#image("powerstate1.pdf", width: 70%)])
#v(1.5em)

- Source widgets are powered if they are active (used by a stream) and
  have a route to an active sink widget

- Sink widgets are powered if they are active (used by a stream) and
  have a route to an active source widget

===  [t]Phase 1: determining power state

#align(center, [#image("powerstate2.pdf", width: 70%)])
#v(1.5em)

- Pass-through widgets are powered if they are on the route between two
  powered endpoint widgets

- Computed by DAPM automatically

===  [t]Phase 1: determining power state

#align(center, [#image("powerstate3.pdf", width: 70%)])

#v(1.5em)

- Supply widgets are powered if they have a path to a powered widget

- Computed by DAPM automatically

===  Phase 2: Powering sequence

+ Compute difference between previous and new configurations

+ Power down newly-disabled widgets

+ Apply routing changes

+ Power up newly-enabled widgets

===  debugfs

- Each widget is exposed as a file in debugfs

- `/sys/kernel/debug/asoc/${CARD}/${COMPONENT}/dapm/${WIDGET}`

- `/sys/kernel/debug/asoc/${CARD}/dapm/${WIDGET}` for card-level widgets

#[
        #set text(size: 17pt)
  ```sh
  # cat "/sys/kernel/debug/asoc/STM32MP15-DK/cs42l51.0-004a/dapm/Left ADC"
  Left ADC: Off  in 1 out 0 - R2(0x2) mask 0x2
   stream Left HiFi Capture inactive
   widget-type adc
   out  "static" "Capture" "cs42l51.0-004a"
   in  "static" "Left PGA" "cs42l51.0-004a"
  #
  ```
]
- Format was improved in v6.10

===  vizdapm

- Simple shell script developed by Dimitris Papastamos, Wolfson Micro

- Generates a graph of DAPM widgets and routes as a PNG picture

- Based on `dot` from graphviz

- Repository disappeared, still available in some git forks

#v(0.3em)

```sh
# vizdapm /sys/kernel/debug/asoc/STM32MP15-DK/cs42l51.0-004a/dapm out.png
```

===  vizdapm

#align(center, [#image("graphviz.png", height: 90%)])

===  dapm-graph

- Inspired by vizdapm and also based on `dot` from graphviz

- Yet another shell script but more powerful and simpler to use

- Shows all components and their connections

- Works with BuyBox shell

- Basic usage:

  - `dapm-graph -o dapm.svg -c STM32MP15-DK`

- Remote mode:

  - `dapm-graph -o dapm.svg -c STM32MP15-DK -r root@192.168.0.1`

  - Gets the status from target, processes on the host

- And more

- Distributed with the kernel sources since v6.10

===  dapm-graph

```text
Usage:
    dapm-graph [options] -c CARD                  - Local sound card
    dapm-graph [options] -c CARD -r REMOTE_TARGET - Card on remote system
    dapm-graph [options] -d STATE_DIR             - Local directory

Options:
    -c CARD             Sound card to get DAPM state of
    -r REMOTE_TARGET    Get DAPM state from REMOTE_TARGET via SSH and SCP
                        instead of using a local sound card
    -d STATE_DIR        Get DAPM state from a local copy of a debugfs tree
    -o OUT_FILE         Output file (default: dapm.dot)
    -D                  Show verbose debugging info
    -h                  Print this help and exit
```

===  dapm-graph

#align(center, [#image("dapm-graph.pdf", height: 90%)])
