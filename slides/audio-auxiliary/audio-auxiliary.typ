#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== Auxiliary devices

=== Amplifier

What about the amplifier?

- Supported using _auxiliary devices_

- Register a #kstruct("snd_soc_aux_dev") array using the
  `.aux_dev` and `.num_aux_devs` fields of the registered
  #kstruct("snd_soc_card")

- This will expose the auxiliary devices control widgets as part of the
  sound card

- There is a driver for simple amplifiers driven by a single GPIO,
  `simple-amplifier`

  - #kfile(
      "Documentation/devicetree/bindings/sound/simple-audio-amplifier.yaml",
    )

  - #kfile("sound/soc/codecs/simple-amplifier.c")

=== Auxiliary devices

#text(size: 14pt)[#kfile("sound/soc/samsung/neo1973_wm8753.c")]
#v(-0.3em)

```c
static struct snd_soc_aux_dev neo1973_aux_devs[] = {
        {
                .name = "dfbmcs320",
                .codec_name = "dfbmcs320.0",
        },
};

static struct snd_soc_card neo1973 = {
        .name = "neo1973",
        .owner = THIS_MODULE,
        .dai_link = neo1973_dai,
        .num_links = ARRAY_SIZE(neo1973_dai),
        .aux_dev = neo1973_aux_devs,
        .num_aux_devs = ARRAY_SIZE(neo1973_aux_devs),
```

=== simple-amplifier - example 1

#text(size: 14pt)[#kfile(
  "arch/arm64/boot/dts/allwinner/sun50i-a64-pinebook.dts",
)]
#v(-0.3em)

```dts

        speaker_amp: audio-amplifier {
                compatible = "simple-audio-amplifier";
                VCC-supply = <&reg_ldo_io0>;
                enable-gpios = <&pio 7 7 GPIO_ACTIVE_HIGH>; /* PH7 */
                sound-name-prefix = "Speaker Amp";
        };

&sound {
        status = "okay";
        simple-audio-card,aux-devs = <&codec_analog>, <&speaker_amp>;
        simple-audio-card,widgets = "Microphone", "Internal Microphone Left",
                                    "Microphone", "Internal Microphone Right",
                                    "Headphone", "Headphone Jack",
                                    "Speaker", "Internal Speaker";
        simple-audio-card,routing =
                        "Left DAC", "AIF1 Slot 0 Left",
                        "Right DAC", "AIF1 Slot 0 Right",
                        "Speaker Amp INL", "LINEOUT",
                        "Speaker Amp INR", "LINEOUT",
                        "Internal Speaker", "Speaker Amp OUTL",
                        "Internal Speaker", "Speaker Amp OUTR",
                        "Headphone Jack", "HP",
```

=== simple-amplifier - example 2

```dts
        dio2133: analog-amplifier {
                compatible = "simple-audio-amplifier";
                sound-name-prefix = "AU2";
                VCC-supply = <&hdmi_5v>;
                enable-gpios = <&gpio GPIOH_5 GPIO_ACTIVE_HIGH>;
        };

        sound {
                compatible = "amlogic,gx-sound-card";
                model = "GXL-LIBRETECH-S905X-CC";
                audio-aux-devs = <&dio2133>;
                audio-widgets = "Line", "Lineout";
                audio-routing = "AU2 INL", "ACODEC LOLN",
                                "AU2 INR", "ACODEC LORN",
                                "Lineout", "AU2 OUTL",
                                "Lineout", "AU2 OUTR";
```

Audio is routed through `AU2`, the amplifier.

=== Input Muxing

- There may be a muxer on the analog input lines.

- If controlled using a gpio, the `simple-mux` driver is available.

- It exposes two inputs: "IN1" and "IN2" and one output, "OUT".

- The device tree binding allows to provide a prefix to make the routes
  specific.

  - #kfile("Documentation/devicetree/bindings/sound/simple-audio-mux.yaml")

  - #kfile("sound/soc/codecs/simple-mux.c")

=== `simple-mux` example

```dts
        mic_mux: mic-mux {
                compatible = "simple-audio-mux";
                pinctrl-names = "default";
                pinctrl-0 = <&pinctrl_micsel>;
                mux-gpios = <&gpio5 5 GPIO_ACTIVE_LOW>;
                sound-name-prefix = "Mic Mux";
        };
```

- This exposes routes between `Mic Mux IN1` and `Mic Mux IN2` to `Mic Mux OUT`.

- This route is controlled by `gpio5 5`.

- A control named `Mic Mux Muxer` will be exposed to userspace.

=== `simple-mux` example

#text(size: 14pt)[#kfile(
  "arch/arm64/boot/dts/freescale/imx8mq-librem5-devkit.dts",
)]
#v(-0.3em)

#[
  #show raw.where(lang: "c", block: true): set text(size: 9pt)
  ```dts
          sound {
                  compatible = "simple-audio-card";
                  pinctrl-names = "default";
                  pinctrl-0 = <&pinctrl_hpdet>;
                  simple-audio-card,aux-devs = <&speaker_amp>, <&mic_mux>;
                  simple-audio-card,name = "Librem 5 Devkit";
                  simple-audio-card,format = "i2s";
                  simple-audio-card,widgets =
                          "Microphone", "Builtin Microphone",
                          "Microphone", "Headset Microphone",
                          "Headphone", "Headphones",
                          "Speaker", "Builtin Speaker";
                  simple-audio-card,routing =
                          "MIC_IN", "Mic Mux OUT",
                          "Mic Mux IN1", "Headset Microphone",
                          "Mic Mux IN2", "Builtin Microphone",
                          "Mic Mux OUT", "Mic Bias",
                          "Headphones", "HP_OUT",
                          "Builtin Speaker", "Speaker Amp OUTR",
                          "Speaker Amp INR", "LINE_OUT";
                  simple-audio-card,hp-det-gpio = <&gpio3 20 GPIO_ACTIVE_HIGH>;

                  simple-audio-card,cpu {
                          sound-dai = <&sai2>;
                  };

                  simple-audio-card,codec {
                          sound-dai = <&sgtl5000>;
                          clocks = <&clk IMX8MQ_CLK_SAI2_ROOT>;
                          frame-master;
                          bitclock-master;
                  };
          };
  ```
]
