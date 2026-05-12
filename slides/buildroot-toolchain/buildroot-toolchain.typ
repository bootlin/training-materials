#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Toolchains in Buildroot

=== What is a cross-compilation toolchain?

- A set of tools to build and debug code for a target architecture, from
  a machine running a different architecture.

- Example: building code for ARM from a x86-64 PC.

#v(0.5em)

#align(center, [#image("components.pdf", height: 70%)])

=== Two possibilities for the toolchain

#table(
  columns: (60%, 40%),
  stroke: none,
  gutter: 15pt,
  [

    - Buildroot offers two choices for the toolchain, called
      *toolchain backends*:

      - The *internal toolchain* backend, where Buildroot builds the
        toolchain entirely from source

      - The *external toolchain* backend, where Buildroot uses a
        existing pre-built toolchain

    - Selected from `Toolchain` → `Toolchain type`.

  ],
  [
    #align(center, [#image("toolchain-types.png", width: 100%)])

  ],
)

=== Internal toolchain backend

- Makes Buildroot build the entire cross-compilation toolchain from
  source.

- Provides a lot of flexibility in the configuration of the toolchain.

  - Kernel headers version

  - C library: Buildroot supports uClibc, (e)glibc and musl

    - glibc, the standard C library. Good choice if you don't have tight
      space constraints (≥ 10 MB)

    - uClibc-ng and musl, smaller C libraries. uClibc-ng supports
      non-MMU architectures. Good for very small systems (< 10 MB).

  - Different versions of binutils and gcc. Keep the default versions
    unless you have specific needs.

  - Numerous toolchain options: C++, LTO, OpenMP, libmudflap, graphite,
    and more depending on the selected C library.

- Building a toolchain takes quite some time: 15-20 minutes on
  moderately recent machines.

=== Internal toolchain backend: result

- `host/bin/<tuple>-<tool>`, the cross-compilation tools: compiler,
  linker, assembler, and more. The compiler is hidden behind a wrapper
  program.

- `host/<tuple>/`

  - `sysroot/usr/include/`, the kernel headers and C library headers

  - `sysroot/lib/` and `sysroot/usr/lib/`, C library and gcc runtime

  - `include/c++/`, C++ library headers

  - `lib/`, host libraries needed by gcc/binutils

- `target/`

  - `lib/` and `usr/lib/`, C and C++ libraries

- The compiler is configured to:

  - generate code for the architecture, variant, FPU and ABI selected in
    the `Target options`

  - look for libraries and headers in the _sysroot_

  - no need to pass weird gcc flags!

=== External toolchain backend possibilities

- Allows to re-use existing pre-built toolchains

- Great to:

  - save the build time of the toolchain

  - use vendor provided toolchain that are supposed to be reliable

- Several options:

  - Use an existing toolchain profile known by Buildroot

  - Download and install a custom external toolchain

  - Directly use a pre-installed custom external toolchain

=== Existing external toolchain profile

#table(
  columns: (60%, 40%),
  stroke: none,
  gutter: 15pt,
  [

    - Buildroot already knows about a wide selection of publicly available
      toolchains.

    - Toolchains from

      - ARM (ARM and AArch64)

      - Mentor Graphics (AArch64, ARM, MIPS, NIOS-II)

      - Imagination Technologies (MIPS)

      - Synopsys (ARC)

      - Bootlin

    - In such cases, Buildroot is able to download and automatically use the
      toolchain.

    - It already knows the toolchain configuration: C library being used,
      kernel headers version, etc.

    - Additional profiles can easily be added.

  ],
  [
    #align(center, [#image("external-toolchain-profiles.png", width: 100%)])

  ],
)

=== Existing external toolchains: Bootlin toolchains

#table(
  columns: (55%, 45%),
  stroke: none,
  gutter: 15pt,
  [

    - #link("https://toolchains.bootlin.com")

    - A set of 218 pre-built toolchains, freely available

      - 43 different CPU architecture variants

      - All possible C libraries supported: glibc, uClibc-ng, musl

      - Toolchains built with Buildroot!

    - Two versions for each toolchain

      - _stable_, which uses the default version of gcc, binutils and
        gdb in Buildroot

      - _bleeding-edge_, which uses the latest version of gcc, binutils
        and gdb in Buildroot

    - Directly integrated in Buildroot

  ],
  [

    #align(center, [#image("bootlin-toolchains-com.png", height: 50%)])
    #align(center, [#image("bootlin-toolchains-menuconfig.png", width: 80%)])

  ],
)

=== Custom external toolchains

- If you have a custom external toolchain, for example from your vendor,
  select `Custom toolchain` in `Toolchain`.

- Buildroot can download and extract it for you

  - Convenient to share toolchains between several developers

  - Option `Toolchain to be downloaded and installed` in `Toolchain origin`

  - The URL of the toolchain tarball is needed

- Or Buildroot can use an already installed toolchain

  - Option `Pre-installed toolchain` in `Toolchain origin`

  - The local path to the toolchain is needed

- In both cases, you will have to tell Buildroot the configuration of
  the toolchain: C library, kernel headers version, etc.

  - Buildroot needs this information to know which packages can be built
    with this toolchain

  - Buildroot will check those values at the beginning of the build

=== Custom external toolchain example configuration

#align(center, [#image("external-toolchain-config.png", height: 90%)])

=== External toolchain: result

- `host/opt/ext-toolchain`, where the original toolchain tarball is
  extracted. Except when a local pre-installed toolchain is used.

- `host/bin/<tuple>-<tool>`, symbolic links to the cross-compilation
  tools in their original location. Except the compiler, which points to
  a wrapper program.

- `host/<tuple>/`

  - `sysroot/usr/include/`, the kernel headers and C library headers

  - `sysroot/lib/` and `sysroot/usr/lib/`, C library and gcc runtime

  - `include/c++/`, C++ library headers

- `target/`

  - `lib/` and `usr/lib/`, C and C++ libraries

- The wrapper takes care of passing the appropriate flags to the
  compiler.

  - Mimics the internal toolchain behavior

=== Kernel headers version

- One option in the toolchain menu is particularly important: the kernel
  headers version.

- When building user space programs, libraries or the C library, kernel
  headers are used to know how to interface with the kernel.

- This kernel/user space interface is *backward compatible*, but
  can introduce new features.

- It is therefore important to use kernel headers that have a version
  *equal or older* than the kernel version running on the target.

- With the internal toolchain backend, choose an appropriate kernel
  headers version.

- With the external toolchain backend, beware when choosing your
  toolchain.

=== Other toolchain menu options

- The toolchain menu offers a few other options:

  - _Target optimizations_

    - Allows to pass additional compiler flags when building target
      packages

    - Do not pass flags to select a CPU or FPU, these are already passed
      by Buildroot

    - Be careful with the flags you pass, they affect the entire build

  - _Target linker options_

    - Allows to pass additional linker flags when building target
      packages

  - gdb/debugging related options

    - Covered in our _Application development_ section later.
