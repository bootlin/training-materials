#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== Linux kernel source code

=== Programming language

- Implemented in C like all UNIX systems

- A little Assembly is used too:

  - CPU and machine initialization, exceptions

  - Critical library routines.

- No C++ used, see #link("https://lkml.org/lkml/2004/1/20/20")

- Rust support is currently being introduced:
  #kfile("drivers/net/phy/ax88796b_rust.rs") is a first driver
  written in Rust.

- All the code compiled with gcc

  - Many gcc specific extensions used in the kernel code, any ANSI C
    compiler will not compile the kernel

  - See
    #link("https://gcc.gnu.org/onlinedocs/gcc-10.2.0/gcc/C-Extensions.html")

- A subset of the supported architectures can be built with the LLVM C
  compiler (Clang) too: #link("https://clangbuiltlinux.github.io/")

=== No C library

- The kernel has to be standalone and can't use user space code.

- Architectural reason: user space is implemented on top of kernel
  services, not the opposite.

- Technical reason: the kernel is on its own during the boot up phase,
  before it has accessed a root filesystem.

- Hence, kernel code has to supply its own library implementations
  (string utilities, cryptography, uncompression...)

- So, you can't use standard C library functions in kernel code
  (`printf()`, `memset()`, `malloc()`,...).

- Fortunately, the kernel provides similar C functions for your
  convenience, like #kfunc("printk"), #kfunc("memset"),
  #kfunc("kmalloc"), ...

=== Portability

- The Linux kernel code is designed to be portable

- All code outside #kdir("arch") should be portable

- To this aim, the kernel provides macros and functions to abstract the
  architecture specific details

  - Endianness

  - I/O memory access

  - Memory barriers to provide ordering guarantees if needed

  - DMA API to flush and invalidate caches if needed

- Never use floating point numbers in kernel code. Your code may need to
  run on a low-end processor without a floating point unit.

=== Linux kernel to user API/ABI stability

#table(
  columns: (75%, 25%),
  stroke: none,
  gutter: 15pt,
  [
    Linux kernel to userspace API is stable

    - Source code for userspace applications will not have to be updated
      when compiling for a more recent kernel

      - System calls, `/proc` and `/sys` content cannot be removed or
        changed. Only new entries can be added.

    Linux kernel to userspace ABI is stable

    - Binaries are portable and can be executed on a more recent kernel

      - The way memory is accessed, the size of the variables in memory, how
        structures are organized, the calling convention, etc, are all
        stable over time.
  ],
  [
    #[ #set par(leading: 0.3em)
      #image("linux-user-api.pdf", height: 80%)
      #text(size: 10pt)[Modified Image from Wikipedia:] \
      #text(size: 10pt)[#link("https://bit.ly/2U2rdGB")]
    ]
  ],
)

=== Linux internal API/ABI instability

#table(
  columns: (75%, 25%),
  stroke: none,
  gutter: 15pt,
  [
    Linux internal API is not stable

    - The source code of a driver is not portable across versions

      - In-tree drivers are updated by the developer proposing the API
        change: works great for mainline code

      - An out-of-tree driver compiled for a given version may no longer
        compile or work on a more recent one

      - See #kdochtml("process/stable-api-nonsense") for reasons why

    Linux internal ABI is not stable

    - A binary module compiled for a given kernel version cannot be used
      with another version

      - The module loading utilities will perform this check prior to the
        insertion
  ],
  [
    #[ #set par(leading: 0.3em)
      #image("linux-internal-api.pdf", height: 80%)
      #text(size: 10pt)[Modified Image from Wikipedia:] \
      #text(size: 10pt)[#link("https://bit.ly/2U2rdGB")]
    ]
  ],
)

=== Kernel memory constraints

- No memory protection

- The kernel doesn't try to recover from attemps to access illegal
  memory locations. It just dumps #emph[oops] messages on the system
  console.

- Fixed size stack (8 or 4 KB). Unlike in user space, no mechanism was
  implemented to make it grow. Don't use recursion!

- Swapping is not implemented for kernel memory either  \
  (except #emph[tmpfs] which lives completely in the page cache and on
  swap)

=== Linux kernel licensing constraints

- The Linux kernel is licensed under the GNU General Public License
  version 2

  - This license gives you the right to use, study, modify and share the
    software freely

- However, when the software is redistributed, either modified or
  unmodified, the GPL requires that you redistribute the software under
  the same license, with the source code

  - If modifications are made to the Linux kernel (for example to adapt
    it to your hardware), it is a derivative work of the kernel, and
    therefore must be released under GPLv2.

- The GPL license has been successfully enforced in courts: \
  #link(
    "https://en.wikipedia.org/wiki/Gpl-violations.org#Notable_victories",
  )[https://en.wikipedia.org/wiki/Gpl-violations.org#Notable_victories]

- However, you're only required to do so

  - At the time the device starts to be distributed

  - To your customers, not to the entire world

=== Proprietary code and the kernel

- It is illegal to distribute a binary kernel that includes statically
  compiled proprietary drivers

- The kernel modules are a gray area: unclear if they are legal or not

  - The general opinion of the kernel community is that proprietary
    modules are bad: #kdochtml("process/kernel-driver-statement")

  - From a legal point of view, each driver is probably a different
    case:

    - Are they derived works of the kernel?

    - Are they designed to be used with another operating system?

- Is it really useful to keep drivers secret anyway?

=== Abusing the kernel licensing constraints

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [

    - There are some examples of proprietary drivers

      - Nvidia uses a wrapper between their drivers and the kernel

      - They claim the drivers could be used with a different OS with
        another wrapper

      - Unclear whether it makes it legal or not

    #v(0.5em)

    #align(center, [#image("binary-blobs.pdf", height: 40%)])

  ],
  [

    - The current trend is to hide the logic in the firmware or in
      userspace. The GPL kernel driver is almost empty and either:

      - Blindly writes an incoming flow of bytes in the hardware

      - Exposes a huge MMIO region to userspace through `mmap`

    #v(0.5em)

    #align(center, [#image("empty-modules.pdf", height: 40%)])

  ],
)

=== Advantages of GPL drivers

- You don't have to write your driver from scratch. You can reuse code
  from similar free software drivers.

- Your drivers can be freely and easily shipped by others (for example
  by Linux distributions or embedded Linux build systems).

- Legal certainty, you are sure that a GPL driver is fine from a legal
  point of view.

=== Advantages of mainlining your kernel drivers

- The community, reviewers and maintainers will review your code before
  accepting it, offering you the opportunity to enhance it and
  understand better the internal APIs.

- Once accepted, you will get cost-free bug and security fixes, support
  for new features, and general improvements.

- Your work will automatically follow the API changes.

- Accessing your code will be much easier for users.

- Your code will remain valid no matter the kernel version.

This will for sure reduce your maintenance and support work

=== User space device drivers 1/2

- The kernel provides some mechanisms to access hardware from userspace:

  - USB devices with #emph[libusb], #link("https://libusb.info/")

  - SPI devices with #emph[spidev], #kdochtml("spi/spidev")

  - I2C devices with #emph[i2cdev], #kdochtml("i2c/dev-interface")

  - GPIOs with #emph[libgpiod], #link("https://libgpiod.readthedocs.io")

  - Memory-mapped devices with #emph[UIO], including interrupt handling,
    #kdochtml("driver-api/uio-howto")

- These solutions can only be used if:

  - There is no need to leverage an existing kernel subsystem such as
    the networking stack or filesystems.

  - There is no need for the kernel to act as a "multiplexer" for the
    device: only one application accesses the device.

- Certain classes of devices like printers and scanners do not have any
  kernel support, they have always been handled in user space for
  historical reasons.

- Otherwise this is #strong[#emph[not]] how the system should be
  architectured. Kernel drivers should always be preferred!

=== User space device drivers 2/2

- Advantages

  - No need for kernel coding skills.

  - Drivers can be written in any language, even Perl!

  - Drivers can be kept proprietary.

  - Driver code can be killed and debugged. Cannot crash the kernel.

  - Can use floating-point computation.

  - Potentially higher performance, especially for memory-mapped
    devices, thanks to the avoidance of system calls.

- Drawbacks

  - The kernel has no longer access to the device.

  - None of the standard applications will be able to use it.

  - Cannot use any hardware abstraction or software helpers from the
    kernel

  - Need to adapt applications when changing the hardware.

  - Less straightforward to handle interrupts: increased latency.

#setuplabframe([Kernel Source Code - Exploring], [

  - Explore kernel sources manually

  - Use automated tools to explore the source code

])
