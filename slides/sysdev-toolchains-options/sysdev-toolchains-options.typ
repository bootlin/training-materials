#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== Toolchain Options 

===  ABI

- When building a toolchain, the ABI used to generate binaries needs to
  be defined

- ABI, for _Application Binary Interface_, defines the calling
  conventions (how function arguments are passed, how the return value
  is passed, how system calls are made) and the organization of
  structures (alignment, etc.)

- All binaries in a system are typically compiled with the same ABI, and
  the kernel must understand this ABI.

- On ARM 32-bit, two main ABIs: _EABI_ and _EABIhf_

  - _EABIhf_ passes floating-point arguments in floating-point
    registers → needs an ARM processor with a FPU

- On RISC-V, several ABIs: _ilp32_, _ilp32f_, _ilp32d_,
  _lp64_, _lp64f_, and _lp64d_

- #link("https://en.wikipedia.org/wiki/Application_Binary_Interface")[https://en.wikipedia.org/wiki/Application_Binary_Interface]

===  Floating point support

- All ARMv7-A (32-bit) and ARMv8-A (64-bit) processors have a floating
  point unit

- RISC-V cores with the `F` extension have a floating point unit

- Some older ARM cores (ARMv4/ARMv5) or some RISC-V cores may not have a
  floating point unit

- For processors without a floating point unit, two solutions for
  floating point computation:

  - Generate _hard float code_ and rely on the kernel to emulate
    the floating point instructions. This is very slow.

  - Generate _soft float code_, so that instead of generating
    floating point instructions, calls to a user space library are
    generated

- Decision taken at toolchain configuration time

- For processors with a floating point unit, sometimes different FPU are
  possible. For example on ARM: VFPv3, VFPv3-D16, VFPv4, VFPv4-D16, etc.

===  CPU optimization flags

- GNU tools (gcc, binutils) can only be compiled for a specific target
  architecture at a time (ARM, x86, RISC-V...)

- gcc offers further options:

  - `-march` allows to select a specific target instruction set

  - `-mtune` allows to optimize code for a specific CPU

  - For example: `-march=armv7 -mtune=cortex-a8`

  - `-mcpu=cortex-a8` can be used instead to allow gcc to infer the
    target instruction set (`-march=armv7`) and cpu optimizations
    (`-mtune=cortex-a8`)

  - #link("https://gcc.gnu.org/onlinedocs/gcc/ARM-Options.html")

- At the GNU toolchain compilation time, values can be chosen. They are
  used:

  - As the default values for the cross-compiling tools, when no other
    `-march`, `-mtune`, `-mcpu` options are passed

  - To compile the C library

- Note: LLVM (Clang, LLD...) utilities support multiple target
  architectures at once.
