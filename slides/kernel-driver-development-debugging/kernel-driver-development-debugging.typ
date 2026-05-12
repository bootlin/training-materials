#import "@local/bootlin:0.1.0": *


#import "/typst/local/common.typ": *

#show: bootlin-theme

= Kernel debugging

#include "/common/printk.typ"

=== DebugFS

A virtual filesystem to export debugging information to user space.

- Kernel configuration: #kconfig("CONFIG_DEBUG_FS")

  - `Kernel hacking -> Debug Filesystem`

- The debugging interface disappears when Debugfs is configured out.

- You can mount it as follows:

  - `sudo mount -t debugfs none /sys/kernel/debug`

- First described on #link("https://lwn.net/Articles/115405/")

- API documented in the Linux Kernel Filesystem API:
  #kdochtml("filesystems/debugfs") The debugfs filesystem

=== DebugFS API

- Create a sub-directory for your driver:

  #[
    #show raw.where(lang: "c", block: true): set text(size: 15pt)
    ```c
    struct dentry *debugfs_create_dir(const char *name,
                                      struct dentry *parent);
    ```

    - Expose an integer as a file in DebugFS. Example:

      ```c
      struct dentry *debugfs_create_u8(const char *name, mode_t mode,
                      struct dentry *parent, u8 *value);
      ```

      - `u8`, `u16`, `u32`, `u64` for decimal representation

      - `x8`, `x16`, `x32`, `x64` for hexadecimal representation

    - Expose a binary blob as a file in DebugFS:

      ```c
      struct dentry *debugfs_create_blob(const char *name,
                      mode_t mode, struct dentry *parent,
                      struct debugfs_blob_wrapper *blob);
      ```
  ]

- Also possible to support writable DebugFS files or customize the
  output using the more generic #kfunc("debugfs_create_file")
  function.

=== Using Magic SysRq

Functionnality provided by serial drivers
#[ #set text(size: 18pt)
  - Allows to run multiple debug / rescue commands even when the kernel
    seems to be in deep trouble

    - On PC: press `[Alt]` + `[Prnt Scrn]` + `<character>`
      simultaneously
      (`[SysRq]` = `[Alt]` + `[Prnt Scrn]`)

    - On embedded: in the console, send a break character \
      (Picocom: press `[Ctrl]` + `a` followed by `[Ctrl]` + `\`), then
      press `<character>`

  - Example commands:

    - `h`: show available commands

    - `s`: sync all mounted filesystems

    - `b`: reboot the system

    - `n`: makes RT processes nice-able.

    - `w`: shows the kernel stack of all sleeping processes

    - `t`: shows the kernel stack of all running processes

    - You can even register your own!

  - Detailed in #kdochtml("admin-guide/sysrq")
]
#include "/common/kgdb.typ"

=== Debugging with a JTAG interface

Two types of JTAG dongles

- The ones offering a `gdb` compatible interface, over a serial port or
  an Ethernet connection. `gdb` can directly connect to them.

- The ones not offering a gdb compatible interface are generally
  supported by OpenOCD (Open On Chip Debugger):
  #link("https://openocd.sourceforge.net/")

  - OpenOCD is the bridge between the gdb debugging language and the
    JTAG interface of the target CPU.

  - See the very complete documentation: \
    #link("https://openocd.org/pages/documentation.html")

  - For each board, you'll need an OpenOCD configuration file (ask your
    supplier)

#align(center, [#image("jtag.pdf", width: 90%)])

=== Early traces

- If something breaks before the `tty` layer, serial driver and serial
  console are properly registered, you might just have nothing else
  after "`Starting kernel...`"

- On ARM, if your platform implements it, you can activate
  (#kconfig("CONFIG_DEBUG_LL") and
  #kconfig("CONFIG_EARLY_PRINTK")), and add `earlyprintk` to the
  kernel command line

  - Assembly routines to just push a character and wait for it to be
    sent

  - Extremely basic, but is part of the uncompressed section, so
    available even if the kernel does not uncompress correctly!

- On other platforms, hoping that your serial driver implements
  #kfunc("OF_EARLYCON_DECLARE"), you can enable
  #kconfig("CONFIG_SERIAL_EARLYCON")

  - The kernel will try to hook an appropriate `earlycon` UART driver
    using the `stdout-path` of the device-tree.

=== More kernel debugging tips 1/2

- Make sure #kconfig("CONFIG_KALLSYMS_ALL") is enabled

  - To get oops messages with symbol names instead of raw addresses

  - Turned on by default

- Make sure #kconfig("CONFIG_DEBUG_INFO") is also enabled

  - This way, the kernel is compiled with `$(CROSSCOMPILE)gcc -g`,
    which keeps the source code inside the binaries.

- If your device is not probed, try enabling
  #kconfig("CONFIG_DEBUG_DRIVER")

  - Extremely verbose!

  - Will enable all the debug logs in the device-driver core section

=== More kernel debugging tips 2/2

Device Tree output can be better understood with the in-tree `dtx_diff` script

- Show the origin of each property/node: `scripts/dtc/dtx_diff -T <dts>`

#text(size: 13pt)[
  ```yaml
  main_i2c3: i2c@20030000 { /* arch/arm64/boot/dts/ti/k3-am62-main.dtsi:450:26-460:4,
                               arch/arm64/boot/dts/ti/k3-am625-beagleplay.dts:820:12-825:3,
                               arch/arm64/boot/dts/ti/k3-am625-beagleplay-custom.dts:20:12-25:3 */
       ...
       reg = <0x00 0x20030000 0x00 0x100>; /* arch/arm64/boot/dts/ti/k3-am62-main.dtsi:452:3-452:38 */
       status = "okay"; /* arch/arm64/boot/dts/ti/k3-am625-beagleplay.dts:824:2-824:18 */

       joystick@52 { /* arch/arm64/boot/dts/ti/k3-am625-beagleplay-custom.dts:21:14-24:4 */
           compatible = "nintendo,nunchuk"; /* arch/arm64/boot/dts/ti/k3-am625-beagleplay-custom.dts:23:3-23:35 */
           reg = <0x52>; /* arch/arm64/boot/dts/ti/k3-am625-beagleplay-custom.dts:22:3-22:16 */
       };
  };
  ```]

- Can also be used to diff DTS

=== Getting help and reporting bugs

- If you are using a custom kernel from a hardware vendor, contact that
  company. The community will have less interest supporting a custom
  kernel.

- Otherwise, or if this doesn't work, try to reproduce the issue on the
  latest version of the kernel.

- Make sure you investigate the issue as much as you can: see \
  #kdochtml("admin-guide/bug-bisect")

- Check for previous bugs reports. Use web search engines, accessing
  public mailing list archives.

- If you're the first to face the issue, it's very useful for others to
  report it, even if you cannot investigate it further.

- If the subsystem you report a bug on has a mailing list, use it.
  Otherwise, contact the official maintainer (see the
  #kfile("MAINTAINERS") file). Always give as many useful details as
  possible.

=== Debugging resources

#table(
  columns: (70%, 30%),
  stroke: none,
  gutter: 15pt,
  [

    Checkout Bootlin's debugging training!

    - Linux debugging, profiling, tracing and performance analysis training

    - #link("https://bootlin.com/doc/training/debugging/")

    - #link(
        "https://bootlin.com/doc/training/debugging/debugging-slides.pdf",
      )[Slides]
      and
      #link(
        "https://bootlin.com/doc/training/debugging/debugging-stm32mp1-labs.pdf",
      )[labs]
      are available for free

  ],
  [

    #align(center, [#image("debugging-screenshot.png", width: 100%)])

  ],
)


#setuplabframe([Kernel debugging], [

  - Use the dynamic debug feature.

  - Add debugfs entries

  - Load a broken driver and see it crash

  - Analyze the error information dumped by the kernel.

  - Disassemble the code and locate the exact C instruction which caused
    the failure.

])
