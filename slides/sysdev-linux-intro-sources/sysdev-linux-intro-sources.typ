#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== Linux kernel sources

===  Location of official kernel sources

- The mainline versions of the Linux kernel, as released by Torvalds

  - These versions follow the development model of the kernel (`master`
    branch)

  - They may not contain the latest developments from a specific area
    yet

  - A good pick for products development phase

  - #link("https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git")

- The stable versions of the Linux kernel, as maintained by a
  maintainers group

  - These versions do not bring new features compared to Linus' tree

  - Only bug fixes and security fixes are pulled there

  - Each version is stabilized during the development period of the next
    mainline kernel

  - Certain versions can be maintained for much longer, 2+ years

  - A good pick for products commercialization phase

  - #link("https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git")

===  Location of non-official kernel sources

- Many chip vendors supply their own kernel sources

  - Focusing on hardware support first

  - Can have a very important delta with mainline Linux

  - Sometimes they break support for other platforms/devices without
    caring

  - Useful in early phases only when mainline hasn't caught up yet (many
    vendors invest in the mainline kernel at the same time)

  - Suitable for PoC, not suitable for products on the long term as
    usually no updates are provided to these kernels

  - Getting stuck with a deprecated system with broken software that
    cannot be updated has a real cost in the end

- Many kernel sub-communities maintain their own kernel, with usually
  newer but fewer stable features, only for cutting-edge development

  - Architecture communities (ARM, MIPS, PowerPC, etc)

  - Device drivers communities (I2C, SPI, USB, PCI, network, etc)

  - Other communities (real-time, etc)

  - Not suitable to be used in products

===  Getting Linux sources

- The kernel sources are available from
  #link("https://kernel.org/pub/linux/kernel") as *full tarballs*
  (complete kernel sources) and *patches* (differences between
  two kernel versions).

- But today the entire open source community has settled in favor of Git

  - Fast, efficient with huge code bases, reliable, open source

  - Incidentally written by Torvalds

===  Going through Linux sources

#table(columns:(40%, 60%), stroke:none, gutter: 15pt,[
- Development tools:

  - Any text editor will work

  - Vim and Emacs support ctags and cscope and therefore can help with
    symbol lookup and auto-completion.

  - It's also possible to use more elaborate IDEs to develop kernel
    code, like Visual Studio Code.
],[
- Powerful web browsing: Elixir

  - Generic source indexing tool and code browser for C and C++.

  - Very easy to find symbols declaration/implementation/usage

  - Try out #link("https://elixir.bootlin.com")!

#align(center, [#image("elixir.pdf", height: 50%)])

])

===  Linux kernel size and structure

- Linux v5.18 sources: close to 80k files, 35M lines, 1.3GiB

- But a compressed Linux kernel just sizes a few megabytes.

- So, why are these sources so big?  \
  Because they include numerous device drivers, network protocols,
  architectures, filesystems... The core is pretty small!

- As of kernel version v5.18 (in percentage of total number of lines):

#table(columns:(25%, 25%, 50%), stroke:none, gutter: 15pt,[

- #kdir("drivers"): 61.1%

- #kdir("arch"): 11.6%

- #kdir("fs"): 4.4%

- #kdir("sound"): 4.1%

- #kdir("tools"): 3.9%

- #kdir("net"): 3.7%
],[
- #kdir("include"): 3.5%

- #kdir("Documentation"): 3.4%

- #kdir("kernel"): 1.3%

- #kdir("lib"): 0.7%

- #kdir("usr"): 0.6%

- #kdir("mm"): 0.5%

], [

- #kdir("scripts"), #kdir("security"), #kdir("crypto"),  \
  #kdir("block"), #kdir("samples"), #kdir("ipc"),  \
  #kdir("virt"), #kdir("init"), #kdir("certs"): < 0.5%

- Build system files: #kfile("Kbuild"), #kfile("Kconfig"),  \
  #kfile("Makefile")

- Other files: #kfile("COPYING"), #kfile("CREDITS"),  \
  #kfile("MAINTAINERS"), #kfile("README")
  ])