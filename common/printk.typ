#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

=== Debugging/tracing using logs 1/4

- Good old #kfunc("printk")!

  - Works in all contexts

  - Can specify a log level ranging from `0` (emergency) to `7` (debug)

  - Be careful of the delays introduced when logs are spitted out on a
    serial console at 115200 bauds

    - A `*_ratelimited()` version exists to limit the amount of print
      if called too often

  - Not recommended for upstream contributions

Example:

`
printk("in probe\n");
`

Here's what you get in the kernel log:

`
[    1.878382] in probe
`

All other logging facilities are based on it.

=== Debugging/tracing using logs 2/4

- The `pr_*()` family of functions

  - They include the log level in the name:
    #kfunc("pr_emerg"), #kfunc("pr_alert"),
    #kfunc("pr_crit"), #kfunc("pr_err"), #kfunc("pr_warn"),
    #kfunc("pr_notice"), #kfunc("pr_info"),
    #kfunc("pr_cont") and the special #kfunc("pr_debug") (see
    next pages)

  - They allow setting a manual prefix (eg. eases grepping):
    `#define pr_fmt(fmt) "foo: " fmt`

- Also defined in #kfile("include/linux/printk.h")

Example:

`
pr_info("in probe\n");
`

Here's what you get in the kernel log:

`
[    1.878382] in probe
`

or similarly with a manual format:

`
[    1.878382] foo: in probe
`

=== Debugging/tracing using logs 3/4

- The `dev_*()` family of functions

  - They include a formatted standard prefix with the device name:
    #kfunc("dev_emerg"), #kfunc("dev_alert"),
    #kfunc("dev_crit"), #kfunc("dev_err"),
    #kfunc("dev_warn"), #kfunc("dev_notice"),
    #kfunc("dev_info") and the special #kfunc("dev_dbg") (see
    next pages)

  - They additionally take a pointer to #kstruct("device") as first
    argument

  - Defined in #kfile("include/linux/dev_printk.h")

  - To be used in device drivers

Example:

`
dev_info(&pdev->dev, "in probe\n");
`

Here's what you get in the kernel log:

`
[    1.878382] serial 48024000.serial: in probe
[    1.884873] serial 481a8000.serial: in probe
`

=== Debugging/tracing using logs 4/4

- The kernel defines many more format specifiers than the standard
  `printf()` existing ones.

  - `%p`: Display the hashed value of pointer by default
  - `%px`: Always display the adress of a pointer (use carefully on non-sensitive)
  - `%pK`: Display hashed pointer value, zeros or the pointer address depending on `kptr_restrict` sysctl value
  - `%pOF`: Device-tree node format specifier
  - `%pr`: Resource structure format specifier
  - `%pa`: Physical adress display (work on all architectures 32/64 bits)
  - `%pe`: Error pointer (displays the string corresponding to the error number)

- See #kdochtml("core-api/printk-formats") for an exhaustive list of
  format specifiers

- Also features a helper to dump entire buffers with a `hexdump` like
  display: #kfunc("print_hex_dump")

=== pr_debug() and dev_dbg()

- When the driver is compiled with `DEBUG` defined, all these messages
  are compiled and printed at the debug level. `DEBUG` can be defined by
  at the beginning of the driver, or using `ccflags-$(CONFIG_DRIVER) += -DDEBUG` in the `Makefile`

- When the kernel is compiled with
  #kconfig("CONFIG_DYNAMIC_DEBUG"), then these messages can
  dynamically be enabled on a per-file, per-module or per-message basis,
  by writing commands to `/proc/dynamic_debug/control`. Note that
  messages are not enabled by default.

  - Details in #kdochtml("admin-guide/dynamic-debug-howto")

  - Very powerful feature to only get the debug messages you're
    interested in.

- When neither `DEBUG` nor #kconfig("CONFIG_DYNAMIC_DEBUG") are
  used, these messages are not compiled in.

#if sys.inputs.training == "debugging" {
  [

    === pr_debug() and dev_dbg() usage

    - Debug prints can be enabled using the `/proc/dynamic_debug/control`
      file.

      - `cat /proc/dynamic_debug/control` will display all lines that can
        be enabled in the kernel

      - Example: `init/main.c:1427 [main]run_init_process =p " %s"`

    - A syntax allows to enable individual print using lines, files or
      modules

      - `echo "file drivers/pinctrl/core.c +p" > /proc/dynamic_debug/control` will enable all debug prints in
        `drivers/pinctrl/core.c`

      - `echo "module pciehp +p" > /proc/dynamic_debug/control` will
        enable the debug print located in the `pciehp` module

      - `echo "file init/main.c line 1427 +p" > /proc/dynamic_debug/control` will enable the debug print located at
        line 1247 of file `init/main.c`

      - Replace `+p` with `-p` to disable the debug print
  ]
}

#if sys.inputs.training == "linux-kernel" {
  [

    === Configuring the priority

    - Each message is associated to a priority, as specified in
      #kfile("include/linux/kern_levels.h").

    - All the messages, regardless of their priority, are stored in the
      kernel log ring buffer

      - Typically accessed using the `dmesg` command

    - Messages with a priority lower than the `loglevel` also appear on the
      console

    - The `loglevel` can be changed:

      - in the kernel configuration using
        #kconfig("CONFIG_CONSOLE_LOGLEVEL_DEFAULT"))

      - on the cmdline with `loglevel=` (see
        #kdochtml("admin-guide/kernel-parameters"))

      - at runtime through `/proc/sys/kernel/printk`
        (#kdochtml("admin-guide/sysctl/kernel"))

    - Examples:

      - `loglevel=0`: no message on the console (see also: `quiet`)

      - `loglevel=8`: all messages on the console (see also:
        `ignore_loglevel`)
  ]
}

#if sys.inputs.training == "debugging" {
  [

    === Debug logs troubleshooting

    - When using dynamic debug, make sure that your debug call is enabled:
      it must be visible in `control` file in debugfs *and* be
      activated (`=p`)

    - Is your log output only in the kernel log buffer?

      - You can see it thanks to `dmesg`

      - You can lower the `loglevel` to output it to the console directly

      - You can also set `ignore_loglevel` in the kernel command line to
        force all kernel logs to console

    - If you are working on an out-of-tree module, you may prefer to define
      `DEBUG` in your module source or Makefile instead of using dynamic
      debug

    - If configuration is done through the kernel command line, is it
      properly interpreted?

      - Starting from 5.14, kernel will let you know about faulty command
        line:
        `Unknown kernel command line parameters foo, will be passed to user space.`

      - You may need to take care of special characters escaping (e.g:
        quotes)

    - Be aware that a few subsystems bring their own logging infrastructure,
      with specific configuration/controls, eg: `drm.debug=0x1ff`
  ]
}
