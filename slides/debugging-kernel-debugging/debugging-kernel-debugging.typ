#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme


= Kernel Debugging

== Preventing bugs
<preventing-bugs>

=== Static code analysis

- Static analysis can be run with the _sparse_ tool

- _sparse_ works with annotation and can detect various errors at
  compile time

  - Locking issues (unbalanced locking)

  - Address space issues, such as accessing user space pointer directly

- Analysis can be run using `make C=2` to run only on files that are
  recompiled

- Or with `make C=1` to run on all files

- Example of an unbalanced locking scheme:

#v(0.5em)
#[
  #show raw.where(lang: "console", block: true): set text(size: 13.5pt)
  ```console
  rzn1_a5psw.c:81:13: warning: context imbalance in 'a5psw_reg_rmw' - wrong count
    at exit
  ```]
#v(1em)

#align(center, [#image("sparse.pdf", height: 12%)])

=== Good practices in kernel development (1/2)

- When writing driver code, never expect the user to provide correct
  values. Always check these values.

- Use the #kfunc("WARN_ON") macro if you want to display a
  stacktrace when a specific condition did happen.

  - #kfunc("dump_stack") can also be used during debugging to show
    the current call stack.

#v(0.5em)

```C
static bool check_flags(u32 flags)
{
  if (WARN_ON(flags & STATE_INVALID))
    return -EINVAL;
  return 0;
}
```

=== Good practices in kernel development (2/2)

- If the values can be checked at compile time (configuration input,
  `sizeof`, structure fields), use the #kfunc("BUILD_BUG_ON") macro
  to ensure the condition is true.

#v(0.5em)
```C
BUILD_BUG_ON(sizeof(ctx->__reserved) != sizeof(reserved));
```
#v(0.5em)

- If during compilation you have some warnings about unused
  variables/parameters, they must be fixed.

- Apply `checkpatch.pl –strict` when possible which might find some
  potential problems in your code.

== Linux Kernel Debugging
<linux-kernel-debugging>

=== Linux Kernel Debugging

- The Linux Kernel features multiple tools to ease kernel debugging:

  - A dedicated logging framework

  - A standard way to dump low level crash messages

  - Multiple runtime checkers to check for different kind of issues:
    memory issues, locking mistakes, undefined behaviors, etc.

  - Interactive or post-mortem debugging

- Many of those features need to be explicitely enabled in the kernel
  menuconfig, those are grouped in the `Kernel hacking -> Kernel debugging` menuconfig entry.

  - #kconfig("CONFIG_DEBUG_KERNEL") should be set to "y" to
    enable other debug options.

== Debugging using messages
<debugging-using-messages>

#include "/common/printk.typ"

=== Kernel early debug

- When booting, the kernel sometimes crashes even before displaying the
  system messages

- On ARM, if your kernel doesn't boot or hangs without any message, you
  can activate early debugging options

  - #kconfigval("CONFIG_DEBUG_LL", "y") to enable ARM early
    serial output capabilities

  - #kconfigval("CONFIG_EARLY_PRINTK", "y") will allow printk to
    output the prints earlier

- `earlyprintk` command line parameter should be given to enable early
  printk output

== Kernel crashes and oops
<kernel-crashes-and-oops>

=== Kernel crashes

- The kernel is not immune to crash, many errors can be done and lead to
  crashes

  - Memory access error (NULL pointer, out of bounds access, etc)

  - Voluntarily panicking on error detection (using #kfunc("panic"))

  - Kernel incorrect execution mode (sleeping in atomic context)

  - Deadlocks detected by the kernel (Soft lockup/locking problem)

- On error, the kernel will display a message on the console that is
  called a "Kernel oops"

#v(0.5em)

#align(center, [#image("crash.png", height: 35%)])

#text(size: 11pt)[#align(
  center,
  [_Icon by Peter van Driel, TheNounProject.com_],
)]

=== Kernel oops (1/2)

- The content of this message depends on the architecture that is used.

- Almost all architectures display at least the following information:

  - CPU state when the oops happened

  - Registers content with potential interpretation

  - Backtrace of function calls that led to the crash

  - Stack content (last X bytes)

- Depending on the architecture, the crash location can be identified
  using the content of the PC registers (sometimes named IP, EIP, etc).

- To have a meaningful backtrace with symbol names use
  #kconfigval("CONFIG_KALLSYMS", "y") which will embed the symbol
  names in the kernel image.

=== Kernel oops (2/2)

- Symbols are displayed in the backtrace using the following format:

  - `<symbol_name>+<hex_offset>/<symbol_size>`

- If the oops is not critical (taken in process context), then the
  kernel will kill process and continue its execution

  - The kernel stability might be compromised!

- Tasks that are taking too much time to execute and that are hung can
  also generate an oops (#kconfig("CONFIG_DETECT_HUNG_TASK"))

- If KGDB support is present and configured, on oops, the kernel will
  switch to KGDB mode.

=== Oops example (1/2)

#align(center, [#image("oops1.svg", height: 90%)])

=== Oops example (2/2)

#align(center, [#image("oops2.svg", height: 90%)])

=== Kernel oops debugging: `addr2line`

- In order to convert addresses/symbol name from this display to source
  code lines, one can use addr2line

  - `addr2line -e vmlinux <address>`

- GNU binutils >= 2.39 takes the symbol+offset notation too:

  - `addr2line -e vmlinux <symbol_name>+<off>`

- The symbol+offset notation can be used with older binutils versions
  via the `faddr2line` script in the kernel sources:

  - `scripts/faddr2line vmlinux <symbol_name>+<off>`

- The kernel must have been compiled with
  #kconfigval("CONFIG_DEBUG_INFO", "y") to embed the debugging
  information into the vmlinux file.

=== Kernel oops debugging: `decode_stacktrace.sh`

- `addr2line` decoding of oopses can be automated using
  `decode_stacktrace.sh` script which is provided in the kernel
  sources.

- This script will translate all symbol names/addresses to the matching
  file/lines and will display the assembly code where the crash did
  trigger.

- `./scripts/decode_stacktrace.sh vmlinux [linux_source_path/] \` \
  `< oops_report.txt > decoded_oops.txt`

- NOTE: `CROSS_COMPILE` and `ARCH` env var should be set to obtain the
  correct disassembly dump.

=== Panic and oops behavior configuration

- Sometimes, crash might be so bad that the kernel will panic and halt
  its execution entirely by stopping scheduling application and staying
  in a busy loop.

- Automatic reboot on panic can be enabled via
  #kconfig("CONFIG_PANIC_TIMEOUT")

  - 0: never reboots

  - Negative value: reboot immediately

  - Positive value: seconds to wait before rebooting

- OOPS can be configured to always panic:

  - at boot time, adding `oops=panic` to the command line

  - at build time, setting #kconfigval("CONFIG_PANIC_ON_OOPS", "y")

== Built-in kernel self tests
<built-in-kernel-self-tests>

=== Kernel memory issue debugging

- The same kind of memory issues that can happen in user space can be
  triggered while writing kernel code

  - Out of bounds accesses

  - Use-after-free errors (dereferencing a pointer after `kfree()`)

  - Out of memory due to missing `kfree()`

- Various tools are present in the kernel to catch these issues

  - _KASAN_ to find use-after-free and out-of-bound memory accesses

  - _KFENCE_ to find use-after-free and out-of-bound in production
    systems

  - _Kmemleak_ to find memory leak due to missing free of memory

=== KASAN

- Kernel Address Space Sanitizer

- Allows to find use-after-free and out-of-bounds memory accesses

- Uses GCC to instrument the kernel at compile-time

- Supported by almost all architectures (ARM, ARM64, PowerPC, RISC-V,
  S390, Xtensa and X86)

- Needs to be enabled at kernel configuration with
  #kconfig("CONFIG_KASAN")

- Can then be enabled for files by modifying Makefile

  - `KASAN_SANITIZE_file.o := y` for a specific file

  - `KASAN_SANITIZE := y` for all files in the Makefile folder

=== Kmemleak

- Kmemleak allows to find memory leaks for dynamically allocated objects
  with `kmalloc()`

  - Works by scanning the memory to detect if allocated address are not
    referenced anymore anywhere (large overhead).

- Once enabled with #kconfig("CONFIG_DEBUG_KMEMLEAK"), kmemleak
  control files will be visible in _debugfs_

- Memory leaks is scanned every 10 minutes

  - can be disabled via
    #kconfig("CONFIG_DEBUG_KMEMLEAK_AUTO_SCAN")

- An immediate scan can be triggered using

  - `# echo scan > /sys/kernel/debug/kmemleak`

- Results are displayed in debugfs

  - `# cat /sys/kernel/debug`

- See #kdochtml("dev-tools/kmemleak") for more information

=== Kmemleak report
#[
  #show raw.where(lang: "console", block: true): set text(size: 17pt)
  ```console
  # cat /sys/kernel/debug/kmemleak
  unreferenced object 0x82d43100 (size 64):
    comm "insmod", pid 140, jiffies 4294943424 (age 270.420s)
    hex dump (first 32 bytes):
      b4 bb e1 8f c8 a4 e1 8f 8c ce e1 8f 88 c6 e1 8f  ................
      10 a5 e1 8f 18 e2 e1 8f ac c6 e1 8f 0c c1 e1 8f  ................
    backtrace:
      [<c31f5b59>] slab_post_alloc_hook+0xa8/0x1b8
      [<c8200adb>] kmem_cache_alloc_trace+0xb8/0x104
      [<1836406b>] 0x7f005038
      [<89fff56d>] do_one_initcall+0x80/0x1a8
      [<31d908e3>] do_init_module+0x50/0x210
      [<2658dd55>] load_module+0x208c/0x211c
      [<e1d48f15>] sys_finit_module+0xe4/0xf4
      [<1de12529>] ret_fast_syscall+0x0/0x54
      [<7ee81f34>] 0x7eca8c80
  ```
]

=== UBSAN

- UBSAN is a runtime checker for code with undefined behavior

  - Shifting with a value larger than the type

  - Overflow of integers (signed and unsigned)

  - Misaligned pointer access

  - Out of bound access to static arrays

  - #link("https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html")

- It uses compile-time instrumentation to insert checks that will be
  executed at runtime

- Must be enabled using #kconfigval("CONFIG_UBSAN", "y")

- Then, can be enabled for specific files by modifying Makefile

  - `UBSAN_SANITIZE_file.o := y` for a specific file

  - `UBSAN_SANITIZE := y` for all files in the Makefile folder

=== UBSAN: report example

- Report for an undefined behavior due to a shift with a value > 32.

#v(0.5em)

```console
UBSAN: Undefined behaviour in mm/page_alloc.c:3117:19
shift exponent 51 is too large for 32-bit type 'int'
CPU: 0 PID: 6520 Comm: syz-executor1 Not tainted 4.19.0-rc2 #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
__dump_stack lib/dump_stack.c:77 [inline]
dump_stack+0xd2/0x148 lib/dump_stack.c:113
ubsan_epilogue+0x12/0x94 lib/ubsan.c:159
__ubsan_handle_shift_out_of_bounds+0x2b6/0x30b lib/ubsan.c:425
...
RIP: 0033:0x4497b9
Code: e8 8c 9f 02 00 48 83 c4 18 c3 0f 1f 80 00 00 00 00 48 89 f8 48
89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d
01 f0 ff ff 0f 83 9b 6b fc ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007fb5ef0e2c68 EFLAGS: 00000246 ORIG_RAX: 0000000000000010
RAX: ffffffffffffffda RBX: 00007fb5ef0e36cc RCX: 00000000004497b9
RDX: 0000000020000040 RSI: 0000000000000258 RDI: 0000000000000014
RBP: 000000000071bea0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000ffffffff R13: 0000000000005490 R14: 00000000006ed530 R15: 00007fb5ef0e3700
```

#include "/common/prove-locking.typ"

#setuplabframe([Kernel debugging], [

  Debugging kernel programming mistakes with integrated frameworks

  - Debug locking issues using lockdep

  - Spot function calls in invalid context

  - Use kmemleak to detect memory leaks on the system

])

== The Magic SysRq
<the-magic-sysrq>

=== The Magic SysRq
#[
  #set text(size: 18pt)
  Functionality provided by serial drivers

  - Allows to run multiple debug/rescue commands even when the kernel
    seems to be in deep trouble

    - On embedded: in the console, send a break character
      (Picocom: press `[Ctrl]` + `a` followed by `[Ctrl]` + ` `), then
      press `<character>`

    - By echoing `<character>` in `/proc/sysrq-trigger`

  - Example commands:
    #[ #set list(spacing: 0.3em)
      - `h`: show available commands

      - `s`: sync all mounted filesystems

      - `b`: reboot the system

      - `w`: shows the kernel stack of all sleeping processes

      - `t`: shows the kernel stack of all running processes

      - `g`: enter kgdb mode

      - `z`: flush trace buffer

      - `c`: triggers a crash (kernel panic)

      - You can even register your own!
    ]
  - Detailed in #kdochtml("admin-guide/sysrq")
]

== KGDB
<kgdb>

#include "/common/kgdb.typ"

=== Kernel _GDB scripts_

- #kconfig("CONFIG_GDB_SCRIPTS") allows to build a set of python
  script which ease the kernel debugging by adding new commands and
  functions.

- When using `gdb vmlinux`, the scripts present in vmlinux-gdb.py file
  at the root of build dir will be loaded automatically.

  - `lx-symbols`: (Re)load symbols for vmlinux and modules

  - `lx-dmesg`: display kernel dmesg

  - `lx-lsmod`: display loaded modules

  - `lx-device-bus|class|tree`: display device bus, classes and tree

  - `lx-ps`: `ps` like view of tasks

  - `$lx_current()` contains the current `task_struct`
    item `$lx_per_cpu(var, cpu)` returns a per-cpu variable

  - `apropos lx` To display all available functions.

- #link(
    "https://www.kernel.org/doc/html/next/dev-tools/gdb-kernel-debugging.html",
  )[dev-tools/gdb-kernel-debugging]

=== KDB

- #kconfig("CONFIG_KGDB_KDB") includes a kgdb frontend name "KDB"

- This frontend exposes a debug prompt on the serial console which
  allows debugging the kernel without the need for an external gdb.

- KDB can be entered using the same mechanism used for entering kgdb
  mode.

- _KDB_ and _KGDB_ can coexist and be used at the same time.

  - Use the `kgdb` command in KDB to enter kgdb mode.

  - Send a maintenance packet from gdb using `maintenance packet 3` to
    switch from kgdb to KDB mode.

=== KDB commands

- KDB does not consume gdb commands but a set of dedicated KDB commands:

  - `go`: Continue execution

  - `bt`: Display backtrace

  - `env`: Show environment variables

  - `ps`: List all tasks

  - `pid`: Switch to another task

  - `md/mm`: Read/write memory

  - `lsmod`: List loaded modules

- To check all available commands, you can refer to the `help` command
  output, or check #ksym("maintab") in kernel source code

=== kdmx

- When the system has only a single serial port, it is not possible to
  use both KGDB and the serial line as an output terminal since only one
  program can access that port.

- Fortunately, the _kdmx_ tool allows to use both KGDB and serial
  output by splitting GDB messages and standard console from a single
  port to 2 slave pty (`/dev/pts/x`)

- https://git.kernel.org/pub/scm/utils/kernel/kgdb/agent-proxy.git

  - Located in the subdirectory `kdmx`

#v(0.5em)

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [

    ```console
    $ kdmx -n -d -p/dev/ttyACM0 -b115200
    serial port: /dev/ttyACM0
    Initalizing the serial port to 115200 8n1
    /dev/pts/6 is slave pty for terminal emulator
    /dev/pts/7 is slave pty for gdb

    Use <ctrl>C to terminate program
    ```

  ],
  [

    #align(center, [#image("kdmx.svg", width: 100%)])

  ],
)

=== Going further with KGDB

- Good presentation from Doug Anderson with a lot of demos and
  explanations

  - Video:
    #link(
      "https://www.youtube.com/watch?v=HBOwoSyRmys",
    )[https://www.youtube.com/watch?v=HBOwoSyRmys]

  - Slides:
    #link(
      "https://elinux.org/images/1/1b/ELC19_Serial_kdb_kgdb.pdf",
    )[https://elinux.org/images/1/1b/ELC19_Serial_kdb_kgdb.pdf]

#v(0.5em)

#align(center, [#image("kgdb_conf.png", height: 60%)])

== crash
<crash>

=== crash

- _crash_ is a CLI tool allowing to investigate kernel (dead or
  alive!)

  - Uses /dev/mem or /proc/kcore on live systems

  - Requires #kconfigval("CONFIG_STRICT_DEVMEM", "n")

- Can use a coredump generated using kdump, kvmdump, etc.

- Based on `gdb` and provides many specific commands to inspect the
  kernel state.

  - Stack traces, dmesg (`log`), memory maps of the processes, irqs,
    virtual memory areas, etc.

- Allows examining all the tasks that are running on the system.

- Hosted at #link("https://github.com/crash-utility/crash")

=== crash example

```console
$ crash vmlinux vmcore
[...]
    TASKS: 75
NODENAME: buildroot
  RELEASE: 5.13.0
  VERSION: #1 SMP PREEMPT Tue Nov 15 14:42:25 CET 2022
  MACHINE: armv7l  (unknown Mhz)
  MEMORY: 512 MB
    PANIC: "Unable to handle kernel NULL pointer dereference at virtual address 00000070"
      PID: 127
  COMMAND: "watchdog"
    TASK: c3f163c0  [THREAD_INFO: c3f00000]
      CPU: 1
    STATE: TASK_RUNNING (PANIC)

crash> mach
    MACHINE TYPE: armv7l
     MEMORY SIZE: 512 MB
            CPUS: 1
 PROCESSOR SPEED: (unknown)
              HZ: 100
       PAGE SIZE: 4096
KERNEL VIRTUAL BASE: c0000000
KERNEL MODULES BASE: bf000000
KERNEL VMALLOC BASE: e0000000
KERNEL STACK SIZE: 8192
```

#setuplabframe([Kernel debugging], [

  Debugging kernel crashes on a live kernel

  - Analyze an OOPS message

  - Debug a crash with KGDB

])

== Post-mortem analysis
<post-mortem-analysis>

=== Kernel crash post-mortem analysis

- Sometimes, accessing the crashed system is not possible or the system
  can't stay offline while waiting to be debugged

- Kernel can generate crash dumps (a _vmcore_ file) to a remote
  location, allowing to quickly restart the system while still be able
  to perform post-mortem analysis with GDB.

- This feature relies on _kexec_ and _kdump_ which will boot
  another kernel as soon as the crash occurs right after dumping the
  _vmcore_ file.

  - The _vmcore_ file can be saved on local storage, via SSH, FTP
    etc.

=== kexec & kdump (1/2)

- On panic, the kernel kexec support will execute a "dump-capture
  kernel" directly from the kernel that crashed

  - Most of the time, a specific dump-capture kernel is compiled for
    that task (minimal config with specific initramfs/initrd)

- _kexec_ system works by saving some RAM for the kdump kernel
  execution at startup

  - `crashkernel` parameter should be set to specify the crash kernel
    dedicated physical memory region

- _kexec-tools_ are then used to load dump-capture kernel into this
  memory zone using the `kexec` command

  - Internally uses the `kexec_load` system call
    #manpage("kexec_load", "2")

=== kexec & kdump (2/2)

- Finally, on panic, the kernel will reboot into the "dump-capture"
  kernel allowing the user to dump the kernel coredump (`/proc/vmcore`)
  onto whatever media

- Additional command line options depends on the architecture

- See #kdochtml("admin-guide/kdump/kdump") for more comprehensive
  explanations on how to setup the kdump kernel with `kexec`.

- Additional user-space services and tools allow to automatically
  collect and dump the vmcore file to a remote location.

  - See kdump systemd service and the `makedumpfile` tool which can also
    compress the vmcore file into a smaller file (Only for x86, PPC,
    IA64, S390).

  - #link("https://github.com/makedumpfile/makedumpfile")

=== kdump

#align(center, [#image("kdump.png", height: 90%)])

#text(size: 12pt)[#align(center, [Image credits: Wikipedia])]

=== kexec config and setup

- On the standard kernel:

  - #kconfigval("CONFIG_KEXEC", "y") to enable KEXEC support

  - `kexec-tools` to provide the `kexec` command

  - A kernel and a DTB accessible by `kexec`

- On the dump-capture kernel:

  - #kconfigval("CONFIG_CRASH_DUMP", "y") to enable dumping a
    crashed kernel

  - #kconfigval("CONFIG_PROC_VMCORE", "y") to enable
    `/proc/vmcore` support

  - #kconfigval("CONFIG_AUTO_ZRELADDR", "y") on ARM32 platforms

- Set the correct `crashkernel` command line option:

  - `crashkernel=size[KMG][@offset[KMG]]`

- Load a dump-capture kernel on the first kernel with `kexec`:

  - `kexec –type zImage -p my_zImage –dtb=my_dtb.dtb \` \
    `–initrd=my_initrd –command-line="kernel command line"`

- Then simply wait for a crash to happen!

=== Going further with kexec & kdump

- Presentation from Steven Rostedt about using kexec, kdump and ftrace
  with lot of tips and tricks about using kexec/kdump

  - Video:
    #link(
      "https://www.youtube.com/watch?v=aUGNDJPpUUg",
    )[https://www.youtube.com/watch?v=aUGNDJPpUUg]

  - Slides:
    #link(
      "https://static.sched.com/hosted_files/ossna2022/c0/Postmortem_%20Kexec%2C%20Kdump%20and%20Ftrace.pdf",
    )[https://static.sched.com/hosted_files/ossna2022/c0/Postmortem_%20Kexec%2C%20Kdump%20and%20Ftrace.pdf]

#v(1em)
#align(center, [#image("kexec_kdump_ftrace.png", height: 50%)])

=== pstore (1/3)

- Linux provides a filesystem interface for Persistent Storage
  (`pstore`) to save data across system resets: kernel logs, oopses,
  ftrace records, user messages...

- The platform needs to provide a persistent area to pstore (a block
  device, reserved RAM which is not reset on reboot, etc). Then you can
  enable a pstore frontend.

- #link(
    "https://www.kernel.org/doc/html/latest/admin-guide/ramoops.html",
  )[ramoops]
  is a common frontend for pstore: it will log any panic/oops to a
  pstore-managed ram buffer, which will be accessible on next boot

- Saved logs can be retrieved on next boot thanks to the pstore
  filesystem

- Some earlier software components in the boot chain (eg:
  #link("https://docs.u-boot.org/en/v2021.01/usage/pstore.html")[U-Boot]),
  if properly configured, may be able to access pstore data as well

=== pstore (2/3)

- Kernel configuration:

  - #kconfigval("CONFIG_PSTORE", "y")

  - #kconfigval("CONFIG_PSTORE_RAM", "y")

- Platform configuration: reserve some memory for pstore and configure
  it

  - Either through kernel command line: \
  `mem=<usable_memory_size> ramoops.mem_address=0x8000000 ramoops.ecc=1`

  - Or through device tree:

#v(0.5em)
```c
reserved-memory {
        [...]
        ramoops@8f000000 {
                compatible = "ramoops";
                reg = <0 0x8f000000 0 0x100000>;
                record-size = <0x4000>;
                console-size = <0x4000>;
        };
};
```

=== pstore (3/3)

- After a crash, the collected logs/traces will be available in the
  pstore filesystem:
#v(0.5em)
#[
  #show raw.where(lang: "console", block: true): set text(size: 17pt)
  ```console
  mount -t pstore pstore /sys/fs/pstore
  ```
]
#v(0.5em)
- If your data is not present in pstore filesystem, some services
  spawned early may have already collected/moved it

  - For example: systemd-pstore

#setuplabframe([Kernel debugging], [

  Post-mortem debugging of a kernel crash

  - Setup kexec, kdump and extract a kernel coredump

])
