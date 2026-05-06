#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme
#set list(spacing: 0.8em)

= Introduction to Embedded Linux

===  Simplified Linux system architecture

#align(center, [#image("linux-system-architecture.pdf", height: 80%)])

===  Overall Linux boot sequence

#align(center, [#image("overall-boot-sequence.pdf", height: 80%)])

===  Embedded Linux work

- *BSP work*: porting the bootloader and Linux kernel, developing
  Linux device drivers.

- *system integration work*: assembling all the user space
  components needed for the system, configure them, develop the upgrade
  and recovery mechanisms, etc.

- *application development*: write the company-specific
  applications and libraries.

===  Complexity of user space integration

#align(center,[
#image(
  "graph-depends.pdf",
  width: 110%,
  height: 100%,
  fit: "stretch"
)])

===  System integration: several possibilities

#text(size: 13pt)[
#align(center)[
#table(
  columns: 3,
  align: (col, row) => (left,left,left,).at(col),
  inset: 6pt,
  [], [*Pros*], [*Cons*],
  [*Building everything manually*],
  [Full flexibility \ Learning experience],
  [Dependency hell \ Need to understand a lot of details \ Version
  compatibility \ Lack of reproducibility],
  [*Binary distribution* \ Debian, Ubuntu, Fedora, etc.],
  [Easy to create and extend],
  [Hard to customize \ Hard to optimize (boot time, size) \ Hard to rebuild
  the full system from source \ Large system \ Uses native compilation
  (slow) \ No well-defined mechanism to generate an image \ Lots of
  mandatory dependencies \ Not available for all architectures],
  [*Build systems* \ Buildroot, Yocto, PTXdist, etc.],
  [Nearly full flexibility \ Built from source: customization and
  optimization are easy \ Fully reproducible \ Uses cross-compilation Have
  embedded specific packages not necessarily in desktop distros \ Make
  more features optional],
  [Not as easy as a binary distribution Build time],
)
]]

===  Embedded Linux build system: principle

#align(center, [#image("buildsystem-principle.pdf", width: 90%)])

#v(0.5em)

- Building from source → lot of flexibility

- Cross-compilation → leveraging fast build machines

- Recipes for building components → easy

===  Embedded Linux build system: tools

- A wide range of solutions: Yocto/OpenEmbedded, PTXdist, Buildroot,
  OpenWRT, and more.

- Today, two solutions are emerging as the most popular ones

  - *Yocto/OpenEmbedded* 
    Builds a complete Linux distribution with binary packages. Powerful,
    but somewhat complex, and quite steep learning curve.

  - *Buildroot* 
    Builds a root filesystem image, no binary packages. Much simpler to
    use, understand and modify.
