#import "@local/bootlin:0.1.0": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#import "/typst/local/common.typ": *

#show: bootlin-theme

== CPU DAI driver

=== CPU DAI driver

- The CPU DAI driver is now a component driver, like the codec ones.

- However, it is usually more complex as it need to handle IRQs and take
  care of pinmuxing, clocks and DMA.

- Also, the list of supported format and rates is usually very large.

=== DMA handling

- When a DMA controller is available, handling DMA in ALSA is done
  almost completely in the core, through `dmaengine_pcm`.

- The DMA is simply registered using
  #kfunc("devm_snd_dmaengine_pcm_register"). This handles parsing
  the device tree if necessary.

- In the DAI driver probe callback, the DMA engine is simply configured
  using #kfunc("snd_soc_dai_init_dma_data") which takes the DMA
  configuration for playback and capture.

=== DMA handling example

#text(size: 14pt)[#kfile("sound/soc/atmel/atmel-i2s.c")]
#v(-0.3em)

```c
struct atmel_i2s_dev {
        struct device                           *dev;
        struct regmap                           *regmap;
        struct clk                              *pclk;
        struct clk                              *gclk;
        struct snd_dmaengine_dai_dma_data       playback;
        struct snd_dmaengine_dai_dma_data       capture;
        unsigned int                            fmt;
        const struct atmel_i2s_gck_param        *gck_param;
        const struct atmel_i2s_caps             *caps;
        int                                     clk_use_no;
};
[...]
static int atmel_i2s_dai_probe(struct snd_soc_dai *dai)
{
        struct atmel_i2s_dev *dev = snd_soc_dai_get_drvdata(dai);

        snd_soc_dai_init_dma_data(dai, &dev->playback, &dev->capture);
        return 0;
}
```

=== DMA handling example

#text(size: 14pt)[#kfile("sound/soc/atmel/atmel-i2s.c")]
#v(-0.3em)
```c
static int atmel_i2s_probe(struct platform_device *pdev)
{
[...]
        /* Prepare DMA config. */
        dev->playback.addr        = (dma_addr_t)mem->start + ATMEL_I2SC_THR;
        dev->playback.maxburst        = 1;
        dev->capture.addr        = (dma_addr_t)mem->start + ATMEL_I2SC_RHR;
        dev->capture.maxburst        = 1;

        if (of_property_match_string(np, "dma-names", "rx-tx") == 0)
                pcm_flags |= SND_DMAENGINE_PCM_FLAG_HALF_DUPLEX;
        err = devm_snd_dmaengine_pcm_register(&pdev->dev, NULL, pcm_flags);
        if (err) {
                dev_err(&pdev->dev, "failed to register PCM: %d\n", err);
                clk_disable_unprepare(dev->pclk);
                return err;
        }
[...]
}
```

=== DMA handling

- When a peripheral DMA controller is used, this is more complex.

- The driver will have to handle all the aspects of the PCM stream life
  cycle.

- Understandable example in #kfile("sound/soc/atmel/atmel-pcm-pdc.c")

=== ALSA snd_pcm_ops callbacks

#align(center + horizon)[
  #{
    set text(size: 14pt)
    diagram(
      spacing: (12mm, 12mm),
      node-stroke: 1pt,
      node-corner-radius: none,
      edge-stroke: 1pt + luma(100),

      node(
        (0, 0),
        [`.open`\ Allocates runtime memory],
        fill: rgb("#add8e6"),
        stroke: rgb("#5cacff"),
      ),
      edge("-}>"),
      node(
        (0, 1),
        [`.hw_params`\ Sets stream parameters, allocates DMA buffers],
        fill: rgb("#add8e6"),
        stroke: rgb("#5cacff"),
      ),
      edge("-}>"),
      node(
        (0, 2),
        [`.prepare`\ Resets hardware & pointers],
        fill: rgb("#add8e6"),
        stroke: rgb("#5cacff"),
        name: <prepare>,
      ),
      edge((0, 2), (0.5, 2), (0.5, 0), (1, 0), "-}>"),
      node(
        (1, 0),
        [`.trigger`\ (SNDRV_PCM_TRIGGER_START)\ Starts DMA engine],
        fill: rgb("#c5e387"),
        stroke: rgb("#6a8954"),
      ),
      edge("-}>", stroke: rgb("#6a8954")),
      node(
        (1, 1),
        [
          #align(center)[
            *Active Streaming State*\
            #v(-2pt)
            #line(length: 100%, stroke: 0.4pt + rgb("#6a8954"))
            #v(-2pt)
          ]
          #align(left)[
            `.pointer`: current hw buffer position\
            `.copy_user`: data transfer (optional)
          ]
        ],
        fill: rgb("#c5e387"),
        stroke: rgb("#6a8954"),
        name: <streaming>,
      ),
      edge("-}>", stroke: rgb("#cc1f1a")),
      node(
        (1, 3),
        [`.trigger`\ (SNDRV_PCM_TRIGGER_STOP)\ Stops DMA engine],
        fill: rgb("#ffacac"),
        stroke: rgb("#cc1f1a"),
        name: <stop>,
      ),
      edge(<stop>, (1.5, 3), (1.5, 0), (2, 0), "-}>"),
      node(
        (2, 0),
        [`.hw_free`\ Releases buffers],
        fill: rgb("#add8e6"),
        stroke: rgb("#5cacff"),
      ),
      edge("-}>"),
      node(
        (2, 1),
        [`.close`\ Frees runtime structures],
        fill: rgb("#add8e6"),
        stroke: rgb("#5cacff"),
      ),

      node(
        (2, 2),
        [
          #align(center)[
            *Async Callbacks*\
            #v(-2pt)
            #line(length: 100%, stroke: 0.4pt + rgb("#5cacff"))
            #v(-2pt)
            #align(left)[
              `.ioctl`: custom control/queries\
              `.page / .mmap`: memory mapping
            ]
          ]
        ],
        fill: rgb("#add8e6"),
        stroke: rgb("#5cacff"),
      ),

      edge(
        <streaming>,
        <streaming>,
        "-}>",
        stroke: rgb("#6a8954"),
        bend: -120deg,
        label: text(size: 6.5pt, fill: rgb("#6a8954"))[Continuous Poll / IRQ],
      ),

      edge(
        <stop>,
        <prepare>,
        "-}>",
        stroke: rgb("#cc1f1a") + 0.8pt,
        dash: "dashed",
        bend: 65deg,
        label: text(size: 6.5pt, fill: rgb("#cc1f1a"))[XRUN / Restart],
      ),
    )
  }
]

