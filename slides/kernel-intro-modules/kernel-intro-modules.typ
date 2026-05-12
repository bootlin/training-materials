#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== Using kernel modules

=== Advantages of modules

#table(
  columns: (65%, 35%),
  stroke: none,
  gutter: 15pt,
  [

    - Modules make it easy to develop drivers without rebooting: load, test,
      unload, rebuild, load...

    - Useful to keep the kernel image size to the minimum (essential in
      GNU/Linux distributions for PCs).

    - Also useful to reduce boot time: you don't spend time initializing
      devices and kernel features that you only need later.

    - Caution: once loaded, have full control and privileges in the system.
      No particular protection. That's why only the `root` user can load and
      unload modules.

    - To increase security, possibility to allow only signed modules, or to
      disable module support entirely.

  ],
  [

    #align(center, [#image("modules-to-access-rootfs.pdf", width: 100%)])

  ],
)

=== Module utilities: extracting information

`<module_name>`: name of the module file without the trailing `.ko`

- `modinfo <module_name>` (for modules in `/lib/modules`) \
  `modinfo <module_path>.ko` \
  Gets information about a module without loading it: parameters,
  license, description and dependencies.

=== Module utilities: loading

- `sudo insmod <module_path>.ko` \
  Tries to load the given module. The full path to the module object
  file must be given.

- `sudo modprobe <top_module_name>` \
  Most common usage of `modprobe`: tries to load all the dependencies of
  the given top module, and then this module. Lots of other options are
  available. `modprobe` automatically looks in
  `/lib/modules/<version>/` for the object file corresponding to the
  given module name.

- `lsmod` \
  Displays the list of loaded modules \
  Compare its output with the contents of `/proc/modules`!

=== Understanding module loading issues

- When loading a module fails, `insmod` often doesn't give you enough
  details!

- Details are often available in the kernel log.

- Example:

  ```
  $ sudo insmod ./intr_monitor.ko
  insmod: error inserting './intr_monitor.ko': -1 Device or resource busy
  $ dmesg
  [17549774.552000] Failed to register handler for irq channel 2
  ```

=== Module utilities: removals

- `sudo rmmod <module_name>` \
  Tries to remove the given module. \
  Will only be allowed if the module is no longer in use (for example,
  no more processes opening a device file)

- `sudo modprobe -r <top_module_name>` \
  Tries to remove the given top module and all its no longer needed
  dependencies

=== Passing parameters to modules

- Find available parameters: \
  `modinfo usb-storage`

- Through `insmod`: \
  `sudo insmod ./usb-storage.ko delay_use=0`

- Through `modprobe`: \
  Set parameters in `/etc/modprobe.conf` or in any file in
  `/etc/modprobe.d/`: \
  `options usb-storage delay_use=0`

- Through the kernel command line, when the module is built statically
  into the kernel: \
  `usb-storage.delay_use=0`

  - `usb-storage` is the #emph[module name]

  - `delay_use` is the #emph[module parameter name]. It specifies a
    delay before accessing a USB storage device (useful for rotating
    devices).

  - `0` is the #emph[module parameter value]

=== Check module parameter values

How to find/edit the current values for the parameters of a loaded module?

- Check `/sys/module/<name>/parameters`.

- There is one file per parameter, containing the parameter value.

- Also possible to change parameter values if these files have write
  permissions (depends on the module code).

- Example:
  `echo 0 > /sys/module/usb_storage/parameters/delay_use`
