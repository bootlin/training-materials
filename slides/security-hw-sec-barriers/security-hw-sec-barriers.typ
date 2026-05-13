#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Hardware-enforced security barriers

== Privilege levels
<privilege-levels>

=== Kernel/Userland isolation

- We expect some security guarantees from modern systems:

  - Process isolation (resources, address space)

  - User isolation

  - Access control on files

- We need an entity in charge of enforcing those guarantees

- That entity is the operating system's kernel, this is one of its main
  roles

=== Kernel/Userland isolation

- The kernel has *privileged* access to the hardware

- On older CPUs, or some architectures, it even has *unfiltered*
  access

- Needs to be isolated from useland even though both run on the same
  hardware

- The key is the *privilege level*

  - x86 defines 4 "protection rings", tracked in 2 bits of the Code
    Segment Selector register Only 2 are actually used: ring 0 for the
    kernel, ring 3 for userland

  - ARM has 4 "Exception Levels" (EL), with the kernel in EL1 and
    userland in EL0. The current EL is tracked in the
    #link("https://developer.arm.com/documentation/ddi0595/2021-06/AArch64-Registers/CurrentEL--Current-Exception-Level")[CurrentEL]
    register

- The privilege level is checked e.g. when accessing memory

- Some instructions can only be executed from eleveated privilege levels

=== Protection rings

#align(center, [#image("rings.pdf", width: 50%)])

=== System Calls (1/2)
<system-calls-12>

-A system call allows the user space to request services from the
  kernel by executing a special instruction that will switch to the
  kernel mode (#manpage("syscall", "2"))

  - When executing functions provided by the libc (`read()`, `write()`,
    etc), they often end up executing a system call.

- System calls are identified by a numeric identifier that is passed via
  the registers.

  - The kernel exports some defines (in `unistd.h`) that are named
    `__NR_<sycall>` and defines the syscall identifiers.

#v(0.5em)

```C
#define __NR_read 63
#define __NR_write 64 
```

=== System Calls (2/2)
<system-calls-22>

-The kernel holds a table of function pointers which matches these
  identifiers and will invoke the correct handler after checking the
  validity of the syscall.

- System call parameters are passed via registers (up to 6).

- When executing this instruction the CPU will change its execution
  state and switch to the kernel mode.

- Each architecture uses a specific hardware mechanism
  (#manpage("syscall", "2"))

#v(0.5em)

```asm
    mov w8, #__NR_getpid
    svc #0
    tstne x0, x1
```

=== Virtual address translation

- When a core is running a user program it is not running the kernel

- The hardware itself must be able to enforce memory protection

  - this is where the MMU comes in

- The CPU accesses *virtual*, not *physical* addresses

- Each process has a different virtual address space

- Virtual memory is organized into a hierarchy of tables, the lowest
  level being pages. See #kdochtml("mm/page_tables")

- Table elements are descriptors, and contain several attributes

- Documentation:

  - ARMv8-A:
    #link("https://developer.arm.com/documentation/100940/0101/")[Armv8-A Address Translation]

  - x86:
    #link("https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html")[Intel Software Developer's Manual, Volume 3a, Chapter 5]

=== Memory attributes

- Page descriptors use a hardware-specific format:

- #kfunc("PTE_USER") (ARM64) / #kfunc("_PAGE_BIT_USER") (x86)
  indicates userland

- An entry can be marked non-executable:

  - on x86, using the NX bit (#kfunc("_PAGE_BIT_NX"))

  - on 64-bit ARM, split between EL0 (#kfunc("PTE_UXN")) and EL1+
    (#kfunc("PTE_PXN"))

- Userland (ring 3/EL0) execution from kernel (ring 0 /EL1) is
  conditional:

  - x86: depends on SMEP, see
    #link("https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html")[Intel SDM, Vol 3a, 5.6.1]

  - 64-bit ARM: this is why *XN* is split into
    #kfunc("PTE_UXN") and #kfunc("PTE_PXN")

- On x86, userland (ring 3) access from kernel (ring 0) can be disabled
  using SMAP

=== Memory attributes (ARMv8)

#image("armv8_descriptor.pdf", width: 60%)

- NS set to 1 means we are in normal world

- bit 7 (AP.1) encodes read-only

- bit 6 (AP.0) encodes unprivileged (EL0) access

  #table(
    columns: 6,
    align: (col, row) => (left,center,center,center,center,center,).at(col),
    inset: 6pt,
    [AP], [], [bit 7], [bit 6], [EL0], [EL1+],
    [00],
    [],
    [0],
    [0],
    [No access],
    [RW],
    [01],
    [],
    [0],
    [1],
    [RW],
    [RW],
    [10],
    [],
    [1],
    [0],
    [No access],
    [RO],
    [11],
    [],
    [1],
    [1],
    [RO],
    [RO],
  )

=== Experimenting with memory attributes
<experimenting-with-memory-attributes>

#[ #show raw.where(lang: "c", block: true): set text(size: 13pt)
```c
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>

int main(int argc, char *argv[])
{
        unsigned char *ptr = mmap(
            NULL, 4096 * 2, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0
        );

        printf("ptr: %pn", ptr);                               // 0x7XXXXXXXX000
        ptr[0] = 0xFF;
        printf("ptr[1025]: 0x%02xn", ptr[1025]);               // 0x00
        printf("ptr[4097]: 0x%02xn", ptr[4097]);               // 0x00

        unsigned int ret = mprotect(ptr, 1024,  PROT_NONE);

        printf("ptr[4097]: 0x%02xn", ptr[4097]);               // 0x00
        printf("ptr[1025]: 0x%02xn", ptr[1025]);               // SIGSEGV
}
```]

=== Limits to this model

- Although this model is widespread, it has limitations

- Sometimes, the kernel is untrusted:

  - Host virtual machine kernel

  - "Custom ROMs"

- Or it is not trusted *enough*:

  - Large attack surface

  - Not Invented Here

  - Money (not just the user's) is at stake

- This gave rise to multiple hardware isolation technologies

== ARM TrustZone
<arm-trustzone>

#include "trustzone.typ"