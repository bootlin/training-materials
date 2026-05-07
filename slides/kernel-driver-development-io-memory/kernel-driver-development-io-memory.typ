#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= I/O Memory

===  Memory-Mapped I/O

#table(columns: (75%, 25%), stroke: none, gutter: 15pt, [

- Same address bus to address memory and I/O device registers

- Access to the I/O device registers using regular instructions

- Most widely used I/O method across the different architectures
  supported by Linux

],[

#align(center, [#image("mmio-vs-pio.pdf", width: 100%)])

])

===  Requesting I/O memory

- Tells the kernel which driver is using which I/O registers

#[ #show raw.where(lang: "c", block: true): set text(size: 16pt)
- ```c
  struct resource *request_mem_region(unsigned long start,
                                      unsigned long len, char *name);
  ```

- ```c
  void release_mem_region(unsigned long start, unsigned long len);
  ```]

- Allows to prevent other drivers from requesting the same I/O
  registers, but is purely voluntary.

===  /proc/iomem example - ARM 32 bit (BeagleBone Black, Linux 5.11)

#table(columns: (50%, 50%), stroke: none, gutter: 30pt, [

#text(size: 13pt)[
```
40300000-4030ffff : 40300000.sram sram@0
44e00c00-44e00cff : 44e00c00.prm prm@c00
44e00d00-44e00dff : 44e00d00.prm prm@d00
44e00e00-44e00eff : 44e00e00.prm prm@e00
44e00f00-44e00fff : 44e00f00.prm prm@f00
44e01000-44e010ff : 44e01000.prm prm@1000
44e01100-44e011ff : 44e01100.prm prm@1100
44e01200-44e012ff : 44e01200.prm prm@1200
44e07000-44e07fff : 44e07000.gpio gpio@0
44e09000-44e0901f : serial
44e0b000-44e0bfff : 44e0b000.i2c i2c@0
44e10800-44e10a37 : pinctrl-single
44e10f90-44e10fcf : 44e10f90.dma-router dma-router@f90
48024000-48024fff : 48024000.serial serial@0
48042000-480423ff : 48042000.timer timer@0
48044000-480443ff : 48044000.timer timer@0
```]

],[

#text(size: 13pt)[
```
48046000-480463ff : 48046000.timer timer@0
48048000-480483ff : 48048000.timer timer@0
4804a000-4804a3ff : 4804a000.timer timer@0
4804c000-4804cfff : 4804c000.gpio gpio@0
48060000-48060fff : 48060000.mmc mmc@0
4819c000-4819cfff : 4819c000.i2c i2c@0
481a8000-481a8fff : 481a8000.serial serial@0
481ac000-481acfff : 481ac000.gpio gpio@0
481ae000-481aefff : 481ae000.gpio gpio@0
481d8000-481d8fff : 481d8000.mmc mmc@0
49000000-4900ffff : 49000000.dma edma3_cc
4a100000-4a1007ff : 4a100000.ethernet ethernet@0
4a101200-4a1012ff : 4a100000.ethernet ethernet@0
80000000-9fdfffff : System RAM
80008000-80cfffff : Kernel code
80e00000-80f3d807 : Kernel data
```]

])

===  Mapping I/O memory in virtual memory

- Load/store instructions work with virtual addresses

- To access I/O memory, drivers need to have a virtual address that the
  processor can handle, because I/O memory is not mapped by default in
  virtual memory.

- The `ioremap` function satisfies this need:

#v(0.5em)
#[ #show raw.where(lang: "c", block: true): set text(size: 16pt)
  ```c
  #include <linux/io.h>

  void __iomem *ioremap(phys_addr_t phys_addr, unsigned long size);
  void iounmap(void __iomem *addr);
  ```]

#v(0.5em)

- Caution: check that #kfunc("ioremap") doesn't return a `NULL`
  address!

===  ioremap()

#align(center, [#image("ioremap.pdf", height: 90%)])

#align(center, [`ioremap(0xAFFEBC00, 4096) = 0xCDEFA000`])

===  Managed API 

Using #kfunc("request_mem_region") and #kfunc("ioremap") in device drivers is now deprecated. You should use
the below "managed" functions instead, which simplify driver coding
and error handling:

- #kfunc("devm_ioremap"), #kfunc("devm_iounmap")

- #kfunc("devm_ioremap_resource")

  - Takes care of both the request and remapping operations!

- #kfunc("devm_platform_ioremap_resource")

  - Takes care of #kfunc("platform_get_resource"),
    #kfunc("request_mem_region") and #kfunc("ioremap")

  - Caution: unlike the other `devm_` functions, its first argument is
    of type #kstruct("platform_device"), not a pointer to
    #kstruct("device"):

#v(0.5em)

#[ #show raw.where(lang: "c", block: true): set text(size: 16pt)
    ```c
    base = devm_platform_ioremap_resource(pdev, 0);
    if (IS_ERR(base))
            return PTR_ERR(base);
    ```]

===  Accessing MMIO devices: using accessor functions

- Care must be taken when accessing MMIO registers

  - Memory mapped I/O can be weakly ordered

    - Developer's responsibility to enforcing proper ordering

  - Endianness of the device may be different than the CPU endianness

    - Endianness conversions might be required

  - Directly reading from or writing to addresses returned by
    #kfunc("ioremap") (#emph[pointer dereferencing]) may not work on
    some architectures.

- A family of architecture-independent accessor functions are available
  covering most needs.

  - A few architecture-specific accessor functions also exists.

===  Ordering

- Reads/writes to MMIO-mapped registers of given device are done in
  program order

- However reads/writes to RAM can be re-ordered between themselves, and
  between MMIO-mapped read/writes

- Some of the accessor functions include memory barriers to help with
  this:

  - Write operation starts with a write memory barrier which prior
    writes cannot cross

  - Read operation ends with a read memory barrier which guarantees the
    ordering with regard to the subsequent reads

- Sometimes compiler/CPU reordering is not an issue, in this case the
  code may be optimized by dropping the memory barriers, using the raw
  or relaxed helpers

- See #kfile("Documentation/memory-barriers.txt")

===  MMIO access functions

- `read[b/w/l/q]` and `write[b/w/l/q]` for access to little-endian
  devices, includes memory barriers

- `ioread[8/16/32/64]` and `iowrite[8/16/32/64]` are very similar to
  read/write but also work with port I/O (not covered in the course),
  includes memory barriers

- `ioread[8/16/32/64]be` and `iowrite[8/16/32/64]be` for access to
  big-endian devices, includes memory barriers

- `__raw_read[b/w/l/q]` and `__raw_write[b/w/l/q]` for raw
  access: no endianness conversion, no memory barriers

- `read[b/w/l/q]_relaxed` and `write[b/q/l/w]_relaxed` for access
  to little-endian devices, without memory barriers

- All functions work on a `void __iomem *`

===  MMIO access functions summary

#align(center)[
#table(
  columns: 3,
  align: (col, row) => (left,center,center,).at(col),
  inset: 6pt,
  [Name], [Device endianness], [Memory barriers],
  [`read/write`],
  [little],
  [yes],
  [`ioread/iowrite`],
  [little],
  [yes],
  [`ioreadbe/iowritebe`],
  [big],
  [yes],
  [`__raw_read/__raw_write`],
  [native],
  [no],
  [`read_relaxed/write_relaxed`],
  [little],
  [no],
)
]
#v(0.3em)
More details at
#link("https://docs.kernel.org/driver-api/device-io.html")

===  /dev/mem

- Used to provide user space applications with direct access to physical
  addresses.

- Usage: open `/dev/mem` and read or write at given offset. What you
  read or write is the value at the corresponding physical address.

- Used by applications such as the X server to write directly to device
  memory.

- Easy to use from a shell with the devmem2 program

- For security reasons, on `x86`, `arm`, `arm64`, `riscv`, `powerpc`,
  `parisc`, `s390`:

  - #kconfig("CONFIG_STRICT_DEVMEM") restricts `/dev/mem` to
    non-RAM addresses (from v5.12)

  - #kconfig("CONFIG_IO_STRICT_DEVMEM") goes beyond and only
    allows to access #emph[idle] I/O ranges (not appearing in
    `/proc/iomem`).
