#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme.with(
  aspect-ratio: "16-9",
)

#show raw.where(block: true): set text(size: 13.5pt)

== Obtaining a Toolchain

=== Building a toolchain manually

#text(size: 19pt)[
  - Building a cross-compiling toolchain manually is a fairly difficult
    process

  - Lots of details to learn: many components to build with complicated
    configuration

  - Typical process is:

    - Build dependencies of binutils/gcc (GMP, MPFR, ISL, etc.)

    - Build _binutils_

    - Build a baremetal, first stage _GCC_

    - Extract kernel headers from the Linux source code

    - Build the C library using the first stage GCC

    - Build the second stage and final _GCC_ supporting the Linux OS
      and the C library.

  - Many decisions to make about the components: C library, gcc and
    binutils versions, ABI, floating point mechanisms, etc. Not trivial to
    find correct combinations of these possibilities

  - See the
    #link(
      "https://crosstool-ng.github.io/docs/toolchain-construction/",
    )[Crosstool-NG documentation]
    for details on how toolchains are built.

  - Talk: _Anatomy of Cross-Compilation Toolchains_, by Thomas
    Petazzoni, ELCE 2017, #link("https://youtu.be/Pbt330zuNPc")[video] and
    #link(
      "https://elinux.org/images/1/15/Anatomy_of_Cross-Compilation_Toolchains.pdf",
    )[slides]
]

=== Get a pre-compiled toolchain

- Solution that many people choose

  - Advantage: it is the simplest and most convenient solution

  - Drawback: you can't fine tune the toolchain to your needs

- Make sure the toolchain you find meets your requirements: CPU,
  endianness, C library, component versions, version of the kernel
  headers, ABI, soft float or hard float, etc.

- Some possibilities:

  - Toolchains packaged by your distribution, for example Ubuntu package
    #link(
      "https://packages.ubuntu.com/gcc-arm-linux-gnueabihf",
    )[gcc-arm-linux-gnueabihf]
    or Fedora
    #link("https://packages.fedoraproject.org/pkgs/cross-gcc/gcc-arm-linux-gnu/")[gcc-arm-linux-gnu].
    Often limited to ARM/ARM64 with glibc.

  - Bootlin's GNU toolchains, most CPU architectures, with
    glibc/uClibc/musl, #link("https://toolchains.bootlin.com")

  - #link(
      "https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads",
    )[ARM and ARM64 toolchains released by ARM]

=== Example of toolchains from ARM: downloading

#table(
  columns: (50%, 50%),
  stroke: none,
  [

    #align(center, [#image("arm-toolchain.png", height: 90%)])

  ],
  [

    From
    #link(
      "https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads",
    )[Arm GNU Toolchains]

  ],
)

=== Example of toolchains from ARM: using

```
$ wget https://developer.arm.com/-/media/Files/downloads/gnu-a/10.3-2021.07/binrel/[...]
    [...]gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf.tar.xz

$ tar xf gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf.tar.xz

$ cd gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/

$ ./bin/arm-none-linux-gnueabihf-gcc -o test test.c

$ file test test: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-armhf.so.3, [...]
   for GNU/Linux 3.2.0, with debug_info, not stripped
```

=== Toolchain building utilities

Another solution is to use utilities that *automate the process of building the toolchain*

- Same advantage as the pre-compiled toolchains: you don't need to mess
  up with all the details of the build process

- But also offers more flexibility in terms of toolchain configuration,
  component version selection, etc.

- Allows to rebuild the toolchain if needed to fix a bug or security
  issue.

- They also usually contain several patches that fix known issues with
  the different components on some architectures

- Multiple tools with identical principle: shell scripts or Makefile
  that automatically fetch, extract, configure, compile and install the
  different components

=== Toolchain building utilities (2)

#table(
  columns: (50%, 50%),
  stroke: none,
  [

    *Crosstool-ng*

    - Rewrite of the older Crosstool, with a menuconfig-like configuration
      system

    - Feature-full: supports uClibc, glibc and musl, hard and soft float,
      many architectures

    - Actively maintained

    - #link("https://crosstool-ng.github.io/")

  ],
  [

    #align(center, [#image("crosstool-ng.png", width: 100%)])

  ],
)

=== Toolchain building utilities (3)

Many root filesystem build systems also allow the construction of a cross-compiling toolchain

- *Buildroot*

  - Makefile-based. Can build glibc, uClibc and musl based toolchains,
    for a wide range of architectures. Use `make sdk` to only generate a
    toolchain.

  - #link("https://buildroot.org")

- *PTXdist*

  - Makefile-based, maintained mainly by _Pengutronix_, supporting
    only glibc and uClibc (version 2023.01 status)

  - #link("https://www.ptxdist.org/")

- *OpenEmbedded / Yocto Project*

  - A featureful, but more complicated build system, supporting only
    glibc and musl.

  - #link("https://www.openembedded.org/")

  - #link("https://www.yoctoproject.org/")

=== Crosstool-NG: download

- Getting Crosstool-NG

  ```
  $ git clone https://github.com/crosstool-ng/crosstool-ng.git
  ```

- Using a well-known stable version

  ```
  $ cd crosstool-ng
  $ git checkout crosstool-ng-1.27.0
  ```

- As we're fetching from Git, the `configure` script needs to be
  generated:

  ```
  $ ./bootstrap
  ```

=== Crosstool-NG: installation

- Installation can be done:

  - system-wide, for example in `/usr/local`, the `ct-ng` command is
    then available globally

    ```
    $ ./configure
    $ make
    $ sudo make install
    ```

  - or just locally in the source directory, the `ct-ng` command will be
    invoked from this directory

    ```
    $ ./configure --enable-local
    $ make
    ```

- In our labs, we will use the second method

- Note: the `make` invocation doesn't build any toolchain, it builds the
  `ct-ng` executable.

=== Crosstool-NG: toolchain configuration

- Once installed, the `ct-ng` tool allows to configure and build an
  arbitrary number of toolchains

- Its configuration system is based on _kconfig_, like the Linux
  kernel configuration system

- Configuration of the toolchain to build stored in a `.config` file

- Example configurations provided with Crosstool-NG

  - List: `./ct-ng list-samples`

  - Load an example: `./ct-ng <sample-name>`, replaces `.config`

  - For example `./ct-ng aarch64-unknown-linux-gnu`

  - No sample loaded →  default Crosstool-NG configuration is a
    bare-metal toolchain for the _Alpha_ CPU architecture!

- The configuration can then be refined using either:

  - `./ct-ng menuconfig`

  - `./ct-ng nconfig`

=== Crosstool-NG: toolchain configuration

#align(center, [#image("ct-ng-menu.png", height: 70%)])

`./ct-ng menuconfig`

=== Crosstool-NG: toolchain building

- To build the toolchain

  ```
  ./ct-ng build
  ```

  This will automatically download all the needed dependencies, and
  build all toolchain components in the right order, with the specified
  configuration.

- By default the results go in , as defined by the option in _Paths
  and misc options_

=== Important toolchain contents

- `bin/`: cross compilation tool binaries

  - This directory can be added to your `PATH` to ease usage of the
    toolchain

  - Sometimes with symlinks for shorter names

    ```
    arm-linux-gcc -> arm-cortexa7-linux-uclibcgnueabihf-gcc
    ```
- `<arch-tuple>/sysroot`: _sysroot_ directory

  - `<arch-tuple>/sysroot/lib`: C library, GCC runtime, C++ standard
    library compiled for the target

  - `<arch-tuple>/sysroot/usr/include`: C library headers and kernel
    headers
