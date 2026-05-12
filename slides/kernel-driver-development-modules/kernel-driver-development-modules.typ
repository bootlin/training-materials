#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Developing kernel modules

=== Hello module 1/2

#[ #show raw.where(lang: "c", block: true): set text(size: 13.5pt)
  ```c
  // SPDX-License-Identifier: GPL-2.0
  /* hello.c */
  #include <linux/init.h>
  #include <linux/module.h>
  #include <linux/kernel.h>

  static int __init hello_init(void)
  {
    pr_alert("Good morrow to this fair assembly.n");
    return 0;
  }

  static void __exit hello_exit(void)
  {
    pr_alert("Alas, poor world, what treasure hast thou lost!n");
  }

  module_init(hello_init);
  module_exit(hello_exit);
  MODULE_LICENSE("GPL");
  MODULE_DESCRIPTION("Greeting module");
  MODULE_AUTHOR("William Shakespeare");
  ```]

=== Hello module 2/2

- Code marked as #ksym("__init"):

  - Removed after initialization (static kernel or module.)

  - See how init memory is reclaimed when the kernel finishes booting:

    `
    [    2.689854] VFS: Mounted root (nfs filesystem) on device 0:15.
    [    2.698796] devtmpfs: mounted
    [    2.704277] Freeing unused kernel memory: 1024K
    [    2.710136] Run /sbin/init as init process
    `

- Code marked as #ksym("__exit"):

  - Discarded when module compiled statically into the kernel, or when
    module unloading support is not enabled.

- Code of this example module available on \
  #link(
    "https://raw.githubusercontent.com/bootlin/training-materials/master/code/hello/hello.c",
  )

=== Hello module explanations

- Headers specific to the Linux kernel: `linux/xxx.h`

  - No access to the usual C library, we're doing kernel programming

- An initialization function

  - Called when the module is loaded, returns an error code (`0` on
    success, negative value on failure)

  - Declared by the #kfunc("module_init") macro: the name of the
    function doesn't matter, even though `<modulename>_init()` is a
    convention.

- A cleanup function

  - Called when the module is unloaded

  - Declared by the #kfunc("module_exit") macro.

- Metadata information declared using #kfunc("MODULE_LICENSE"),
  #kfunc("MODULE_DESCRIPTION") and #kfunc("MODULE_AUTHOR")

=== Symbols exported to modules 1/2

- From a kernel module, only a limited number of kernel functions can be
  called

- Functions and variables have to be explicitly exported by the kernel
  to be visible to a kernel module

- Two macros are used in the kernel to export functions and variables:

  - `EXPORT_SYMBOL(symbolname)`, which exports a function or variable
    to all modules

  - `EXPORT_SYMBOL_GPL(symbolname)`, which exports a function or
    variable only to GPL modules

  - Linux 5.3: contains the same number of symbols with
    #kfunc("EXPORT_SYMBOL") and symbols with
    #kfunc("EXPORT_SYMBOL_GPL")

- A normal driver should not need any non-exported function.

=== Symbols exported to modules 2/2

#align(center, [#image("exported-symbols.pdf", width: 100%)])

=== Module license

- Several usages

  - Used to restrict the kernel functions that the module can use if it
    isn't a GPL licensed module.

    - Difference between #kfunc("EXPORT_SYMBOL") and
      #kfunc("EXPORT_SYMBOL_GPL").

  - One reason a kernel can become "tainted" is proprietary modules,
    among others.

    - See #kdochtml("admin-guide/tainted-kernels") for other taint
      flags.

    - This attribute is visible in kernel crashes and oopses for bug
      reports.

  - Useful for users to check that their system is 100% free (for the
    kernel, check `/proc/sys/kernel/tainted`; run `vrms` to check
    installed packages).

- Values

  - GPL compatible (see #kfile("include/linux/license.h"): \
  `GPL`, `GPL v2`, `GPL and additional rights`, `Dual MIT/GPL`, `Dual BSD/GPL`, `Dual MPL/GPL`)

  - `Proprietary`

=== Compiling a module

Two solutions

- #emph[Out of tree], when the code is outside of the kernel source
  tree, in a different directory

  - Not integrated into the kernel configuration/compilation process

  - Needs to be built separately

  - The driver cannot be built statically, only as a module

- Inside the kernel tree

  - Well integrated into the kernel configuration/compilation process

  - The driver can be built statically or as a module

=== Compiling an out-of-tree module 1/2

- The below `Makefile` should be reusable for any single-file
  out-of-tree Linux module

- The source file is `hello.c`

- Just run `make` to build the `hello.ko` file

#v(0.5em)
```make
ifneq ($(KERNELRELEASE),)
obj-m := hello.o
else
KDIR := /path/to/kernel/sources

all:
<tab>$(MAKE) -C $(KDIR) M=$$PWD
endif
```
#v(0.5em)

- `KDIR`: kernel source or headers directory (see next slides)

=== Compiling an out-of-tree module 2/2

#align(center, [#image("out-of-tree.pdf", height: 50%)])
#v(0.5em)
- The module `Makefile` is interpreted with `KERNELRELEASE` undefined,
  so it calls the kernel `Makefile`, passing the module directory in the
  `M` variable

- The kernel `Makefile` knows how to compile a module, and thanks to the
  `M` variable, knows where the `Makefile` for our module is. This
  module `Makefile` is then interpreted with `KERNELRELEASE` defined, so
  the kernel sees the `obj-m` definition.

=== Modules and kernel version

- To be compiled, a kernel module needs access to #emph[kernel headers],
  containing the definitions of functions, types and constants.

- Two solutions

  - Full kernel sources (configured + `make modules_prepare`)

  - Only kernel headers (`linux-headers-*` packages in Debian/Ubuntu
    distributions, or directory created by `make headers_install`).

- The sources or headers must be configured (`.config` file)

  - Many macros or functions depend on the configuration

- You also need the kernel #kfile("Makefile"), the
  #kdir("scripts") directory, and a few others.

- A kernel module compiled against version X of kernel headers will not
  load in kernel version Y

  - `modprobe` / `insmod` will say `Invalid module format`

=== New driver in kernel sources 1/2

- To add a new driver to the kernel sources:

  - Add your new source file to the appropriate source directory.
    Example: \ #kfile("drivers/usb/serial/navman.c")

  - Single file drivers in the common case, even if the file is several
    thousand lines of code big. Only really big drivers are split in
    several files or have their own directory.

  - Describe the configuration interface for your new driver by adding
    the following lines to the `Kconfig` file in this directory:
#v(0.5em)
```
config USB_SERIAL_NAVMAN
        tristate "USB Navman GPS device"
        depends on USB_SERIAL
        help
          To compile this driver as a module, choose M
          here: the module will be called navman.
```

=== New driver in kernel sources 2/2

- Add a line in the `Makefile` file based on the `Kconfig` setting: \
  `obj-$(CONFIG_USB_SERIAL_NAVMAN) += navman.o`

- It tells the kernel build system to build `navman.c` when the
  `USB_SERIAL_NAVMAN` option is enabled. It works both if compiled
  statically or as a module.

  - Run `make xconfig` and see your new options!

  - Run `make` and your new files are compiled!

  - See #kdochtmldir("kbuild") for details and more elaborate
    examples like drivers with several source files, or drivers in their
    own subdirectory, etc.

=== Hello module with parameters 1/2

#[ #show raw.where(lang: "c", block: true): set text(size: 16pt)
  ```c
  // SPDX-License-Identifier: GPL-2.0
  /* hello_param.c */
  #include <linux/init.h>
  #include <linux/module.h>

  MODULE_LICENSE("GPL");

  static char *whom = "world";
  module_param(whom, charp, 0644);
  MODULE_PARM_DESC(whom, "Recipient of the hello message");

  static int howmany = 1;
  module_param(howmany, int, 0644);
  MODULE_PARM_DESC(howmany, "Number of greetings");
  ```]

=== Hello module with parameters 2/2

#[ #show raw.where(lang: "c", block: true): set text(size: 15pt)
  ```c
  static int __init hello_init(void)
  {
      int i;

      for (i = 0; i < howmany; i++)
          pr_alert("(%d) Hello, %sn", i, whom);
      return 0;
  }

  static void __exit hello_exit(void)
  {
      pr_alert("Goodbye, cruel %sn", whom);
  }

  module_init(hello_init);
  module_exit(hello_exit);
  ```]

#v(0.5em)

Thanks to Jonathan Corbet for the examples \
#text(size: 14pt)[Source code available on:
  #link(
    "https://github.com/bootlin/training-materials/blob/master/code/hello-param/hello_param.c",
  )[https://github.com/bootlin/training-materials/blob/master/code/hello-param/hello_param.c]]

=== Declaring a module parameter

#[ #show raw.where(lang: "c", block: true): set text(size: 17pt)
  ```c
  module_param(
      name, /* name of an already defined variable */
      type, /* standard types (different from C types) are:
             * byte, short, ushort, int, uint, long, ulong
             * charp: a character pointer
             * bool: a bool, values 0/1, y/n, Y/N.
             * invbool: the above, only sense-reversed (N = true). */
      perm  /* for /sys/module/<module_name>/parameters/<param>,
             *  0: no such module parameter value file */
  );

  /* Example: drivers/block/loop.c */
  static int max_loop;
  module_param(max_loop, int, 0444);
  MODULE_PARM_DESC(max_loop, "Maximum number of loop devices");
  ```]

Modules parameter arrays are also possible with
#kfunc("module_param_array").

#setuplabframe([Writing modules], [

  - Create, compile and load your first module

  - Add module parameters

  - Access kernel internals from your module

])
