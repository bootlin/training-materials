#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

=== kgdb - A kernel debugger

- #kconfig("CONFIG_KGDB") in #emph[Kernel hacking].

- The execution of the kernel is fully controlled by `gdb` from another
  machine, connected through a serial line.

- Can do almost everything, including inserting breakpoints in interrupt
  handlers.

- Feature supported for the most popular CPU architectures

- #kconfig("CONFIG_GDB_SCRIPTS") allows to build GDB python scripts
  that are provided by the kernel.

  - See #kdochtml("process/debugging/kgdb") for more information

#if sys.inputs.training == "debugging" {
  [=== kgdb kernel config

    - #kconfigval("CONFIG_DEBUG_KERNEL", "y") to make KGDB support
      visible

    - #kconfigval("CONFIG_KGDB", "y") to enable KGDB support

    - #kconfigval("CONFIG_DEBUG_INFO", "y") to compile the kernel
      with debug info (`-g`)

    - #kconfigval("CONFIG_FRAME_POINTER", "y") to have more reliable
      stacktraces

    - #kconfigval("CONFIG_KGDB_SERIAL_CONSOLE", "y") to enable KGDB
      support over serial

    - #kconfigval("CONFIG_GDB_SCRIPTS", "y") to enable kernel GDB
      python scripts

    - #kconfigval("CONFIG_RANDOMIZE_BASE", "n") to disable KASLR

    - #kconfigval("CONFIG_WATCHDOG", "n") to disable watchdog

    - #kconfigval("CONFIG_MAGIC_SYSRQ", "y") to enable Magic SysReq
      support

    - #kconfigval("CONFIG_STRICT_KERNEL_RWX", "n") to disable memory
      protection on code section, thus allowing to put breakpoints

    === kgdb pitfalls

    - KASLR should be disabled to avoid confusing gdb with randomized kernel
      addresses

      - Disable #emph[kaslr mode using `nokaslr` command line parameter if
          enabled in your kernel.]

    - Disable the platform watchdog to avoid rebooting while debugging.

      - When interrupted by KGDB, all interrupts are disabled thus, the
        watchdog is not serviced.

      - Sometimes, watchdog is enabled by upper boot levels. Make sure to
        disable the watchdog there too.

    - Can not interrupt kernel execution from gdb using `interrupt` command
      or `Ctrl + C`.

    - Not possible to break everywhere (see
      #kconfig("CONFIG_KGDB_HONOUR_BLOCKLIST")).

    - Need a console driver with polling support.

    - Some architecture lacks functionalities (No watchpoints on arm32 for
      instance) and some instabilities might happen!
  ]
}

=== Using kgdb (1/2)

- Details available in the kernel documentation:
  #kdochtml("process/debugging/kgdb")

- You must include a kgdb I/O driver. One of them is `kgdb` over serial
  console \ (`kgdboc`: `kgdb` over console, enabled by
  #kconfig("CONFIG_KGDB_SERIAL_CONSOLE"))

- Configure `kgdboc` at boot time by passing to the kernel:

  - `kgdboc=<tty-device>,<bauds>`.

  - For example: `kgdboc=ttyS0,115200`

- Or at runtime using sysfs:

  - `echo ttyS0 > /sys/module/kgdboc/parameters/kgdboc`

  - If the console does not have polling support, this command will
    yield an error.

=== Using kgdb (2/2)

- Then also pass `kgdbwait` to the kernel: it makes `kgdb` wait for a
  debugger connection.

- Boot your kernel, and when the console is initialized, interrupt the
  kernel with a break character and then `g` in the serial console (see
  our #emph[Magic SysRq] explanations).

- On your workstation, start `gdb` as follows:

  - `arm-linux-gdb ./vmlinux`

  - `(gdb) set serial baud 115200`

  - `(gdb) target remote /dev/ttyS0`

- Once connected, you can debug a kernel the way you would debug an
  application program.

- On GDB side, the first threads represent the CPU context
  (ShadowCPU\<x\>), then all the other threads represents a task.
