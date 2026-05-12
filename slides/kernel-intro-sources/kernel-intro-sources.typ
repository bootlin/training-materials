#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== Linux kernel sources

=== Location of the official kernel sources

- The mainline versions of the Linux kernel, as released by Torvalds

  - These versions follow the development model of the kernel (`master`
    branch)

  - They may not contain the latest developments from a specific area
    yet

  - A good pick for products development phase

  - #link("https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git")

=== Linux versioning scheme

- Until 2003, there was a new "stabilized" release branch of Linux every
  2 or 3 years (2.0, 2.2, 2.4). Development branches took 2-3 years to
  be merged (too slow!).

- Since 2003, there is a new official release of Linux about every 10
  weeks:

  - Versions `2.6` (Dec. 2003) to `2.6.39` (May 2011)

  - Versions `3.0` (Jul. 2011) to `3.19` (Feb. 2015)

  - Versions `4.0` (Apr. 2015) to `4.20` (Dec. 2018)

  - Versions `5.0` (Mar. 2019) to `5.19` (July 2022)

  - Versions `6.0` (Oct. 2022) to `6.19` (Feb. 2026)

  - Version `7.0` will be released in March/April 2026.

- Features are added to the kernel in a progressive way. Since 2003,
  kernel developers have managed to do so without having to introduce a
  massively incompatible development branch.

- Major updates
  #link("https://lore.kernel.org/lkml/CAHk-=wiiRA_XxoF96Q_1n4BadBGJLRkHarHG92u3aTc+1ZMeGQ@mail.gmail.com/")[have no specific meaning]!


=== Linux development model

- Each new release starts with a two-week merge window for new features

- Follow about 8 release candidates (one week each)

- Until adoption of a new official release.

#v(0.5em)

#align(center, [#image("development-process-simple.pdf", width: 100%)])

=== Need to further stabilize the official kernels

- Issue: bug and security fixes only merged into the master branch, need
  to update to the latest kernel to benefit from them.

- Solution: a stable maintainers team goes through all the patches
  merged into Torvald's tree and backports the relevant ones into their
  stable branches for at least a few months.

#v(0.5em)

#align(center, [#image("development-process.pdf", width: 65%)])

=== Location of the stable kernel sources

- The stable versions of the Linux kernel, as maintained by a
  maintainers group

  - These versions do not bring new features compared to Linus' tree

  - Only bug fixes and security fixes are pulled there

  - Each version is stabilized during the development period of the next
    mainline kernel

  - A good pick for products commercialization phase

  - #link("https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git")

  - Certain versions will be maintained much longer

=== Need for long term support

- Issue: bug and security fixes only released for most recent kernel
  versions.

- Solution: the last release of each year is made an LTS #emph[(Long
    Term Support)] release, and is supposed to be supported (and receive
  bug and security fixes) for at least 2 years. These projected EOL may
  be extended up to 6 years based on the industry interest at large.

#table(
  columns: (60%, 40%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image(
      "/common/long-term-support-kernels.png",
      width: 100%,
    )])

  ],
  [

    #text(
      size: 17pt,
    )[Captured on #link("https://kernel.org") in Feb. 2026, following the
      #link("https://www.kernel.org/category/releases.html")[#emph[Releases]]
      link.]
  ],
)
- Example at Google: starting from #emph[Android O (2017)], all new
  Android devices have to run such an LTS kernel.

=== Need for even longer term support

- You could also get long term support from a commercial embedded Linux
  provider.

  - Wind River Linux can be supported for up to 15 years.

  - Ubuntu Core can be supported for up to 10 years.

- #emph["If you are not using a supported distribution kernel, or a
    stable / longterm kernel, you have an insecure kernel"] - Greg KH,
  2019 \
  Some vulnerabilities are fixed in stable without ever getting a CVE.

- The #emph[Civil Infrastructure Platform] project is an industry /
  Linux Foundation effort to support much longer (at least 10 years)
  selected LTS versions (currently 4.4, 4.19, 5.10, 6.1 and 6.12) on
  selected architectures. See \
  #link("https://wiki.linuxfoundation.org/civilinfrastructureplatform/start").

=== Location of non-official kernel sources

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

  - Other communities (filesystems, memory-management, scheduling, etc)

  - Not suitable to be used in products

=== Linux kernel size and structure

- Linux v6.19 sources: close to 92k files, 42M lines, 1.4GiB

- But a compressed Linux kernel just sizes a few megabytes.

- So, why are these sources so big?
  Because they include numerous device drivers, network protocols,
  architectures, filesystems... The core is pretty small!

- As of kernel version v6.19 (in percentage of total number of lines):

#v(1em)

#table(
  columns: (35%, 28%, 50%),
  stroke: none,
  gutter: -23pt,
  [

    - #kdir("drivers"): 61%

    - #kdir("arch"): 12%

    - #kdir("tools"): 5.4%

    - #kdir("sound"): 3.9%

    - #kdir("fs"): 3.8%

    - #kdir("Documentation"): 3.8%

  ],
  [

    - #kdir("include"): 3.4%

    - #kdir("net"): 3.1%

    - #kdir("kernel"): 1.3%

    - #kdir("lib"): 0.8%

    - #kdir("mm"): 0.5%

    - #kdir("scripts"): 0.3%

  ],
  [

    - #kdir("security"), #kdir("rust"), #kdir("crypto"),
      #kdir("block"), #kdir("samples"), #kdir("io_uring"),
      #kdir("virt"), #kdir("usr"), #kdir("LICENSES"),
      #kdir("ipc"), #kdir("init"), #kdir("certs"): ≤ 0.3%

    - Build system files: #kfile("Kbuild"), #kfile("Kconfig"),
      #kfile("Makefile")

    - Other files: #kfile("COPYING"), #kfile("CREDITS"),
      #kfile("MAINTAINERS"), #kfile("README")


  ],
)
