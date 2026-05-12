#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme


= Accessing hardware devices

== Kernel drivers
<kernel-drivers>

=== Typical software stack for hardware access

#table(
  columns: (60%, 40%),
  stroke: none,
  gutter: 15pt,
  [
    From the bottom to the top:
    - A _bus controller driver_ in the kernel drives an I2C, SPI, USB,
      PCI controller
    - A _bus subsystem_ provides an API for drivers to access a
      particular type of bus: I2C, SPI, PCI, USB, etc.
    - A _device driver_ in the kernel drives a particular device
      connected to a given bus
    - A _driver subsystem_ exposes features of certain class of
      devices, through a standard _kernel/user-space interface_
    - An application can access the device through this standard
      _kernel/user-space interface_ either directly or through a
      library.
  ],
  [
    #align(center, [#image("kernel-driver-stack.pdf", height: 80%)])
  ],
)

=== Stack illustrated with a GPIO expander

#align(center, [#image("kernel-driver-stack-gpio-i2c.pdf", height: 90%)])

=== Standardized user-space interface

- Strong advantage of kernel drivers: they expose a standard
  _kernel to user-space interface_

- All devices of the same class (e.g GPIO controllers) will expose the
  same _kernel to user-space interface_

- Applications don't have to know the details of the GPIO controller,
  they just need to know the standard user-space interface valid for all
  GPIO controllers

- Applications can use existing open-source libraries that leverage this
  standard user-space interface

- Such kernel drivers can also be used internally inside the kernel, for
  example if one driver needs to control a GPIO directly (reset signal,
  interrupt signal, etc.)

=== Numerous kernel subsystems for device classes

#table(
  columns: (50%, 50%),
  stroke: none,
  [

    - Networking stack for Ethernet, WiFi, CAN, 802.15.4, etc.

    - GPIO

    - Video4Linux for camera, video encoders/decoders

    - DRM for display controllers, GPU

    - ALSA for audio

    - IIO for ADC, DAC, gyroscopes, sensors, and more

    - MTD for flash memory

    - PWM
  ],
  [
    - Input for keyboard, mouse, touchscreen, joystick

    - Watchdog

    - RTC for real-time clocks

    - remoteproc for auxiliary processors

    - crypto for cryptographic accelerators

    - hwmon for hardware monitoring sensors

    - block layer for block storage

  ],
)

#align(center, "and many more")

=== Accessing devices directly from user-space

- Even though device drivers in the kernel are preferred, it is also
  possible to access devices directly from user-space

- Especially useful for very specific devices that do not fit in any
  existing kernel subsystems

- The kernel provides the following mechanisms, depending on the bus:

  - I2C:
    #link("https://docs.kernel.org/i2c/dev-interface.html")[i2c-dev]

  - SPI: #link("https://docs.kernel.org/spi/spidev.html")[spidev]

  - Memory-mapped:
    #link("https://docs.kernel.org/driver-api/uio-howto.html")[UIO]

  - USB: `/dev/bus/usb`, through #link("https://libusb.info/")[libusb]

  - PCI:
    #link("https://docs.kernel.org/PCI/sysfs-pci.html")[sysfs entries for PCI]

=== Accessing devices directly from user-space: GPIO example

#table(
  columns: (28%, 72%),
  stroke: none,
  [
    This diagram shows what's not recommended to do → for a GPIO controller, a kernel driver
    is preferred
  ],
  [
    #align(center, [#image(
      "kernel-driver-stack-gpio-i2c-direct-userspace.pdf",
      height: 90%,
    )])

  ],
)

=== What can go wrong with a user-space driver?

- You write your GPIO driver in user-space: other kernel drivers cannot
  use GPIOs from this GPIO controller

  - Other devices that use GPIO signals from this controller for reset,
    interrupt, etc. cannot control/configure those signals

  - Your application is less portable: it will take many changes to
    support another type of GPIO controller.

- You write your touchscreen driver in user-space: the standard Linux
  graphics stack components cannot use your touchscreen

- You write your network driver in user-space

  - You can probably send/receive packets

  - But you cannot leverage the Linux kernel networking stack for IP,
    TCP, UDP, etc.

  - And none of the Linux networking applications can use your network
    device

=== Upstream drivers vs. out-of-tree drivers

- The _upstream_ Linux kernel contains thousands of drivers

  - This is the best place to look for drivers

  - Drivers have been reviewed and approved by the community

  - They comply with standard interfaces

- Vendor kernels often include additional drivers, directly in the
  kernel tree

- Device vendors sometimes also provide _out of tree drivers_

  - Their source code is provided separately from the Linux kernel tree

  - Quality is often dubious

  - Compatibility issues when updating to newer kernel releases

  - Not always use standard user-space interfaces

  - Example: #link("https://github.com/lwfinger/rtl8723ds")

  - Avoid them when possible!

=== Finding Linux kernel drivers

- `grep` in the Linux kernel tree is your _best friend_

  - For I2C, SPI and memory-mapped devices, matching of the driver is
    done based on the device name → _grep_ for variants of
    the device name and vendor

  - For USB, PCI, matching is done either on the vendor ID/product ID,
    or the class → _grep_ for these

- Driver file names are sometimes named in a "generic" way, not
  necessarily reflecting all devices they support.

  - Example: #kfile("drivers/gpio/gpio-pca953x.c") supports much more
    than just PCA953x. See the
    #link(
      "https://elixir.bootlin.com/linux/v5.19/source/drivers/gpio/gpio-pca953x.c#L1221",
    )[full list of devices]
    supported by this driver

=== Finding Linux kernel drivers: an example

- You have a
  #link(
    "https://www.maximintegrated.com/en/products/interface/controllers-expanders/MAX7313.html",
  )[Maxim Integrated MAX7313]
  GPIO expander on I2C

- Search in the Linux kernel
#[ #set text(size: 13pt)
  git grep -i max7313
  ```
  drivers/gpio/gpio-pca953x.c:    { "max7313", 16 | PCA953X_TYPE | PCA_INT, }, drivers/gpio/gpio-pca953x.c:    { .compatible = "maxim,max7313", .data = OF_953X(16, PCA_INT), },
  ```
]
- #text(size: 20pt)[#kfile("drivers/gpio/gpio-pca953x.c")] seems to support it

- Read #kfile("drivers/gpio/Makefile") to learn which kernel
  configuration option enables this driver
#[ #set text(size: 13pt)
  #kfile("drivers/gpio/Makefile")
]
#[ #set text(size: 14pt)
  ```
  obj-$(CONFIG_GPIO_PCA953X)              += gpio-pca953x.o
  ```
]

- Conclusion: you need to enable #text(size: 20pt)[#kconfig("CONFIG_GPIO_PCA953X")] in
  your kernel configuration

== User-space interfaces to drivers
<user-space-interfaces-to-drivers>

=== User-space interfaces for hardware devices

For a high-level perspective: three main interfaces to access hardware
devices exposed by the Linux kernel

- Device nodes in `/dev`

- Entries in the _sysfs_ filesystem

- Network sockets and related APIs

=== Devices in _/dev/_

- One of the kernel important roles is to *allow applications to
  access hardware devices*

- In the Linux kernel, most devices are presented to user space
  applications through two different abstractions

  - *Character* device

  - *Block* device

- Internally, the kernel identifies each device by a triplet of
  information

  - *Type* (character or block)

  - *Major* (typically the category of device)

  - *Minor* (typically the identifier of the device)

- See #kfile("Documentation/admin-guide/devices.txt") for the
  official list of reserved type/major/minor numbers.

=== Block vs. character devices

- Block devices

  - A device composed of fixed-sized blocks, that can be read and
    written to store data

  - Used for hard disks, USB keys, SD cards, etc.

- Character devices

  - Originally, an infinite stream of bytes, with no beginning, no end,
    no size. The pure example: a serial port.

  - Used for serial ports, terminals, but also sound cards, video
    acquisition devices, frame buffers

  - Most of the devices that are not block devices are represented as
    character devices by the Linux kernel

=== Devices: everything is a file

- A very important UNIX design decision was to represent most
  _system objects_ as files

- It allows applications to manipulate all _system objects_ with
  the normal file API (`open`, `read`, `write`, `close`, etc.)

- So, devices had to be represented as files to the applications

- This is done through a special artifact called a *device file*

- It is a special type of file, that associates a file name visible to
  user space applications to the triplet _(type, major, minor)_
  that the kernel understands

- All _device files_ are by convention stored in the `/dev`
  directory

=== Device files examples

Example of device files in a Linux system
#[ #set text(size: 17pt)
  ```
  $ ls -l /dev/ttyS0 /dev/tty1 /dev/sda /dev/sda1 /dev/sda2 /dev/sdc1 /dev/zero
  brw-rw---- 1 root disk    8,  0 2011-05-27 08:56 /dev/sda
  brw-rw---- 1 root disk    8,  1 2011-05-27 08:56 /dev/sda1
  brw-rw---- 1 root disk    8,  2 2011-05-27 08:56 /dev/sda2
  brw-rw---- 1 root disk    8, 32 2011-05-27 08:56 /dev/sdc
  crw------- 1 root root    4,  1 2011-05-27 08:57 /dev/tty1
  crw-rw---- 1 root dialout 4, 64 2011-05-27 08:56 /dev/ttyS0
  crw-rw-rw- 1 root root    1,  5 2011-05-27 08:56 /dev/zero
  ```
]

#v(0.5em)

Example C code that uses the usual file API to write data to a serial port
#[ #set text(size: 17pt)
  ```c
  int fd;
  fd = open("/dev/ttyS0", O_RDWR);
  write(fd, "Hello", 5);
  close(fd);
  ```
]

=== Creating device files

- Before Linux 2.6.32, on basic Linux systems, the device files had to
  be created manually using the `mknod` command

  - `mknod /dev/<device> [c|b] major minor`

  - Needs root privileges

  - Coherency between device files and devices handled by the kernel was
    left to the system developer

- The `devtmpfs` virtual filesystem can be mounted on `/dev` → the kernel automatically creates/removes device files

  - #kconfig("CONFIG_DEVTMPFS_MOUNT") → asks the kernel to
    mount _devtmpfs_ automatically at boot time (except when
    booting on an initramfs).

=== Better handling of device files: _udev_ and _mdev_

- _devtmpfs_ is great, but its capabilities are limited, so
  complementary solutions exist

- *udev*

  - daemon that receives events from the kernel about devices
    appearing/disappearing

  - can create/remove device files (but that's done by _devtmpfs_
    now), adjust permission/ownership, load kernel modules
    automatically, create symbolic links to devices

  - according to rules files in `/lib/udev/rules.d` and
    `/etc/udev/rules.d`

  - used in almost all desktop Linux distributions

  - #link("https://en.wikipedia.org/wiki/Udev")

- *mdev*

  - lightweight implementation of _udev_, part of Busybox

  - #link("https://wiki.gentoo.org/wiki/Mdev")

=== Examples of user-space interfaces in `/dev`

- Serial-ports: `/dev/ttyS*`, `/dev/ttyUSB*`, `/dev/ttyACM*`, etc.

- GPIO controllers (modern interface): `/dev/gpiochipX`

- Block storage devices: `/dev/sd*`, `/dev/mmcblk*`, `/dev/nvme*`

- Flash storage devices: `/dev/mtd*`

- Display controllers and GPUs: `/dev/dri/*`

- Audio devices: `/dev/snd/*`

- Camera devices: `/dev/video*`

- Watchdog devices: `/dev/watchdog*`

- Input devices: `/dev/input/*`

- and many more...

=== _sysfs_ filesystem

- `block/`, symlinks to all block devices, in `/sys/devices`

- `bus/`, one sub-folder by type of bus

- `class/`, one sub-folder per class (category of devices): input, leds,
  pwm, etc.

- `dev/`

  - `block/`, one symlink per block device, named after major/minor

  - `char/`, one symlink per character device, named after major/minor

- `devices/`, all devices in the system, organized in a slightly chaotic
  way, see #link("https://lwn.net/Articles/646617/")[this article]

- `firmware/`, representation of firmware data

  - `devicetree/`, directory and file representation of Device Tree
    nodes and properties

- `fs/`, properties related to filesystem drivers

- `kernel/`, properties related to various kernel subsystems

- `module/`, properties about kernel modules

- `power/`, power-management related properties

=== _sysfs_ filesystem example

- `/sys/bus/i2c/drivers`: all device drivers for devices connected on
  I2C busses
#[ #set text(size: 13pt)
  ```
  [...]
  edt_ft5x06
  stpmic1
  [...]
  ```
]

- `/sys/bus/i2c/devices`: all devices in the system connected to I2C busses
#[ #set text(size: 13pt)
  ```
  0-002a -> ../../../devices/platform/soc/40012000.i2c/i2c-0/0-002a
  0-0039 -> ../../../devices/platform/soc/40012000.i2c/i2c-0/0-0039
  0-004a -> ../../../devices/platform/soc/40012000.i2c/i2c-0/0-004a
  1-0028 -> ../../../devices/platform/soc/5c002000.i2c/i2c-1/1-0028
  1-0033 -> ../../../devices/platform/soc/5c002000.i2c/i2c-1/1-0033
  i2c-0 -> ../../../devices/platform/soc/40012000.i2c/i2c-0
  i2c-1 -> ../../../devices/platform/soc/5c002000.i2c/i2c-1
  i2c-2 -> ../../../devices/platform/soc/40012000.i2c/i2c-0/i2c-2
  ```
]

=== _sysfs_ filesystem example

#[ #set text(size: 15pt)
  /sys/bus/i2c/devices/0-002a/]
#[ #set text(size: 13pt)
  ```
  lrwxrwxrwx    driver -> ../../../../../../bus/i2c/drivers/edt_ft5x06
  -rw-r--r--    gain
  drwxr-xr-x    input
  -r--r--r--    modalias
  -r--r--r--    name
  lrwxrwxrwx    of_node -> ../../../../../../firmware/devicetree/base/soc/i2c@40012000/touchscreen@2a
  -rw-r--r--    offset
  -rw-r--r--    offset_x
  -rw-r--r--    offset_y
  drwxr-xr-x    power
  -rw-r--r--    report_rate
  lrwxrwxrwx    subsystem -> ../../../../../../bus/i2c
  -rw-r--r--    threshold
  -rw-r--r--    uevent
  ```
]
- `driver`, symlink to the driver directory in `/sys/bus/i2c/drivers`
- `of_node`, symlink to the directory for the Device Tree node
  describing this device

=== Example of driver interfaces in _sysfs_

- All devices are visible in _sysfs_, whether they have an
  interface in `/dev` or not

  - Usually `/dev` is to access the device

  - `/sys` is more about properties of the devices

- However, some devices only have a _sysfs_ interface

  - LED: `/sys/class/leds`, see
    #link("https://docs.kernel.org/leds/leds-class.html")[documentation]

  - PWM: `/sys/class/pwm`, see
    #link(
      "https://docs.kernel.org/driver-api/pwm.html#using-pwms-with-the-sysfs-interface",
    )[documentation]

  - IIO: `/sys/bus/iio`, see
    #link("https://docs.kernel.org/driver-api/iio/index.html")[documentation]

  - etc.

=== Accessing GPIOs

A class of devices worth mentioning is GPIOs (_General Purpose Input Output_)

- The GPIOs can be accessed through a legacy interface in
  `/sys/class/gpios`

  - You will find many instructions on the Internet about how to drive
    GPIOs through this interface.

  - However, this interface is deprecated and has multiple shortcomings:

    - GPIOs remain exported if the process using them crashes

    - Need to compute the GPIO numbers, such numbers are not stable

- A new interface recommended:
  #link("https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/")[libgpiod]

  - Based on `/dev/gpiochipx` character devices

  - Implementing advanced features not possible with the legacy
    interface

  - Of course, this is a C library

  - But it also provides command line utilities: `gpiodetect`,
    `gpioset`, `gpioget`...

  - The only constraint is to cross-compile them for your target (the
    legacy interface could be used without any additional software).

=== Other virtual filesystems

- _debugfs_

  - Conventionally mounted in `/sys/kernel/debug`

  - Contains lots of debug information from the kernel, including device
    related

  - `/sys/kernel/debug/pinctrl` for pin-mux debugging,
    `/sys/kernel/debug/gpio` for GPIO debugging, `/sys/kernel/debug/pwm`
    for PWM debugging, etc.

  - #link("https://www.kernel.org/doc/html/latest/filesystems/debugfs.html")

- _configfs_

  - Conventionally mounted in `/sys/kernel/config`

  - Allows to manage configuration of advanced kernel mechanisms

  - Example: configuration of USB gadget functionalities

  - #kfile("Documentation/filesystems/configfs.rst")

== Using kernel modules
<using-kernel-modules>

=== Why kernel modules?

#table(
  columns: (70%, 30%),
  stroke: none,
  [

    - Primary reason: keep the kernel image minimal, and load drivers
      on-demand depending on the hardware detected

      - Needed to create a generic kernel configuration that works on many
        platforms

      - Used by all desktop/server Linux distributions

    - But also useful for

      - Driver development: allows to modify, build and test a driver
        without rebooting

      - Boot time reduction: allows to defer the initialization of a driver
        after user-space has started critical applications

  ],
  [

    #align(center, [#image("modules-to-access-rootfs.pdf", width: 100%)])

  ],
)

=== Module installation and metadata

- As discussed earlier, modules are installed in
  `/lib/modules/<kernel-version>/`

- Compiled kernel modules are stored in `.ko` (_Kernel Object_)
  files

- Metadata files:

  - `modules.dep`

  - `modules.alias`

  - `modules.symbols`

  - `modules.builtin`

- Each file has a corresponding `.bin` version, which is an optimized
  version of the corresponding text file

=== Module dependencies: _modules.dep_

- Some kernel modules can depend on other modules, based on the symbols
  (functions and data structures) that they use.

- Example: the `ubifs` module depends on the `ubi` and `mtd` modules.

  - `mtd` and `ubi` need to be loaded before `ubifs`

- These dependencies are described both in
  `/lib/modules/<kernel-version>/modules.dep` and in
  `/lib/modules/<kernel-version>/modules.dep.bin`

- Will be used by module loading tools.

=== Module alias: _modules.alias_

#align(center, [#image("module-alias-usage.pdf", width: 100%)])

=== Module utilities: _modinfo_

- `modinfo <module_name>`, for modules in `/lib/modules`

- `modinfo /path/to/module.ko`

#[ #set text(size: 15pt)
  ```
  # modinfo usb_storage filename:       /lib/modules/5.18.13-200.fc36.x86_64/kernel/drivers/usb/storage/usb-storage.ko.xz license:        GPL
  description:    USB Mass Storage driver for Linux author:         Matthew Dharm <mdharm-usb@one-eyed-alien.net>
  alias:          usb:v*p*d*dc*dsc*dp*ic08isc06ip50in*
  alias:          usb:v*p*d*dc*dsc*dp*ic08isc05ip50in*
  alias:          usb:v*p*d*dc*dsc*dp*ic08isc04ip50in*
  [...]
  intree:         Y
  name:           usb_storage
  [...]
  parm:           option_zero_cd:ZeroCD mode (1=Force Modem (default), 2=Allow CD-Rom (uint)
  parm:           swi_tru_install:TRU-Install mode (1=Full Logic (def), 2=Force CD-Rom, 3=Force Modem) (uint)
  parm:           delay_use:seconds to delay before using a new device (uint)
  parm:           quirks:supplemental list of device IDs and their quirks (string)
  ```
]

=== Module utilities: _lsmod_

- Lists currently loaded kernel modules

- Includes

  - The reference count: incremented when the module is used by another
    module or by a user-space process, prevents from unloading modules
    that are in-use

  - Dependant modules: modules that depend on us

- Information retrieved through `/proc/modules`
#[ #set text(size: 15pt)
  ```
  $ lsmod
  Module                  Size  Used by
  tun                    61440  2
  tls                   118784  0
  rfcomm                 90112  4
  snd_seq_dummy          16384  0
  snd_hrtimer            16384  1
  wireguard              94208  0
  curve25519_x86_64      36864  1 wireguard
  libcurve25519_generic  49152  2 curve25519_x86_64,wireguard
  ip6_udp_tunnel         16384  1 wireguard
  ```]

=== Module utilities: _insmod_ and _rmmod_

- Basic tools to:

  - _load_ a module: `insmod`

  - _unload_ a module: `rmmod`

- Basic because:

  - Need a full path to the module `.ko` file

  - Do not handle module dependencies

```
# insmod /lib/modules/`uname -r`/kernel/fs/fuse/cuse.ko.xz
# rmmod cuse
```

=== Module utilities: _modprobe_

- _modprobe_ is the more advanced tool for loading/unloading
  modules

- Takes just a module name as argument: `modprobe <module-name>`

- Takes care of dependencies automatically, using the `modules.dep` file

- Supports removing modules using `modprobe -r`, including its no longer
  used dependencies

#[ #set text(size: 15pt)
  ```
  # modinfo fat_test | grep depends
  depends:        kunit,fat
  # lsmod | grep -E "^(kunit|fat|fat_test)"
  fat                    86016  1 vfat
  # modprobe fat_test
  # lsmod | grep -E "^(kunit|fat|fat_test)"
  fat_test               24576  0
  kunit                  36864  1 fat_test
  fat                    86016  2 fat_test,vfat
  # sudo modprobe -r fat_test
  # lsmod | grep -E "^(kunit|fat|fat_test)"
  fat                    86016  1 vfat
  ```
]

=== Passing parameters to modules

- Some modules have parameters to adjust their behavior

- Mostly for debugging/tweaking, as parameters are global to the module,
  not per-device managed by the module

- Through `insmod` or `modprobe`:
  `insmod ./usb-storage.ko delay_use=0`
  `modprobe usb-storage delay_use=0`

- `modprobe` supports configuration files: `/etc/modprobe.conf` or in
  any file in `/etc/modprobe.d/`:
  `options usb-storage delay_use=0`

- Through the kernel command line, when the module is built statically
  into the kernel:
  `usb-storage.delay_use=0`

  - `usb-storage` is the _module name_

  - `delay_use` is the _module parameter name_. It specifies a
    delay before accessing a USB storage device (useful for rotating
    devices).

  - `0` is the _module parameter value_

=== Modules in _sysfs_

- All modules are visible in _sysfs_, under `/sys/module/<name>`

- Lots of information available about each module

- For example, the `/sys/module/<name>/parameters` directory contains
  one file per module parameter

- Can read the current value of module parameters

- Some of them can even be changed at runtime (determined by the module
  code)

- Example:
  `echo 0 > /sys/module/usb_storage/parameters/delay_use`

== Describing non-discoverable hardware: Device Tree
<describing-non-discoverable-hardware-device-tree>

=== Describing non-discoverable hardware

#let items = (
  (
    title: [Directly in the \ *OS/bootloader \ code*],
    details: (
      [Using compiled data structures, typically in C],
      [How it was done on most embedded platforms in Linux, U-Boot.],
      [Considered not maintainable/sustainable on ARM32, which motivated the move to another solution.],
    ),
  ),
  (
    title: [Using *ACPI* tables],
    details: (
      [On _x86_ systems, but also on a subset of ARM64 platforms],
      [Tables provided by the firmware],
    ),
  ),
  (
    title: [Using a *Device Tree*],
    details: (
      [Originates from *OpenFirmware*, defined by Sun, used on SPARC and PowerPC
        - that's why many Linux/U-Boot functions related to DT have a `of_` prefix
      ],
      [Now used by most embedded-oriented CPU architectures that run Linux: ARC, ARM64, RISC-V, ARM32, PowerPC, Xtensa, MIPS, etc.],
      [Writing/tweaking a DT is necessary when porting Linux to a new board, or when connecting additional peripherals],
    ),
  ),
)

#for (i, item) in items.enumerate() [
  // Pas de pagebreak avant le premier
  #if i != 0 [
    #pagebreak()
  ]

  #grid(
    columns: (2fr, 3fr),
    gutter: 2cm,

    [
      #text(fill: bootlin-orange, [#(i + 1).]) #item.title
    ],

    [
      #for detail in item.details [
        - #detail
      ]
    ],
  )
]

=== Device Tree: from source to blob

#table(
  columns: (70%, 30%),
  stroke: none,
  [

    - A tree data structure describing the hardware is written by a
      developer in a *Device Tree Source* file, `.dts`

    - Processed by the *Device Tree Compiler*, `dtc`

    - Produces a more efficient representation: *Device Tree Blob*,
      `.dtb`

    - Additional C preprocessor pass

    - `.dtb` → accurately describes the hardware platform in an
      *OS-agnostic* way.

    - `.dtb` ≈ few dozens of kilobytes

    - DTB also called *FDT*, _Flattened Device Tree_, once
      loaded into memory.

      - `fdt` command in U-Boot

      - `fdt_` APIs
  ],
  [
    #align(center, [#image("dts-to-dtb.pdf", height: 70%)])

  ],
)

=== dtc example

#table(
  columns: (50%, 50%),
  stroke: none,
  [
    #[ #set text(size: 18pt)
      ```
      $ cat foo.dts
      /dts-v1/;

      / {
              welcome = <0xBADCAFE>;
              bootlin {
                      webinar = "great";
                      demo = <1>, <2>, <3>;
              };
      };
      ```]
  ],
)

#pagebreak()

#table(
  columns: (50%, 50%),
  stroke: none,
  [
    #[ #set text(size: 18pt)
      ```
      $ cat foo.dts
      /dts-v1/;

      / {
              welcome = <0xBADCAFE>;
              bootlin {
                      webinar = "great";
                      demo = <1>, <2>, <3>;
              };
      };
      ```

      ```
      $ dtc -I dts -O dtb -o foo.dtb foo.dts
      $ ls -l foo.dt*
      -rw-r--r-- 1 thomas thomas 169 ... foo.dtb
      -rw-r--r-- 1 thomas thomas 102 ... foo.dts
      ```
    ]
  ],
)

#pagebreak()

#table(
  columns: (50%, 50%),
  stroke: none,
  [
    #[ #set text(size: 18pt)
      ```
      $ cat foo.dts
      /dts-v1/;

      / {
              welcome = <0xBADCAFE>;
              bootlin {
                      webinar = "great";
                      demo = <1>, <2>, <3>;
              };
      };
      ```

      ```
      $ dtc -I dts -O dtb -o foo.dtb foo.dts
      $ ls -l foo.dt*
      -rw-r--r-- 1 thomas thomas 169 ... foo.dtb
      -rw-r--r-- 1 thomas thomas 102 ... foo.dts
      ```
    ]
  ],
  [

    ```
    $ dtc -I dtb -O dts foo.dtb
    /dts-v1/;

    / {
            welcome = <0xbadcafe>;

            bootlin {
                    webinar = "great";
                    demo = <0x01 0x02 0x03>;
            };
    };
    ```

  ],
)

=== Device Tree: using the blob

#table(
  columns: (60%, 40%),
  stroke: none,
  [

    - Can be *linked directly* inside a bootloader binary

      - For example: U-Boot, Barebox

    - Can be *passed* to the operating system by the bootloader

      - Most common mechanism for the Linux kernel

      - U-Boot: `boot[z,i,m] <kernel-addr> - <dtb-addr>`

      - The bootloader can adjust the DTB before passing it to the kernel

    - The DTB parsing can be done using `libfdt`, or ad-hoc code

  ],
  [

    #align(center, [#image("ram.pdf", height: 80%)])

  ],
)

=== Where are Device Tree Sources located?

- Even though they are OS-agnostic, *no central and OS-neutral*
  place to host Device Tree sources and share them between projects

  - Often discussed, never done

- In practice, the Linux kernel sources can be considered as the
  *canonical location* for Device Tree Source files

  - `arch/<ARCH>/boot/dts/<vendor>/`

  - `arch/arm/boot/dts` (on ARM 32 architecture before Linux 6.5)

  - ≈ 4500 Device Tree Source files (`.dts` and `.dtsi`) in Linux
    as of 6.0.

- Duplicated/synced in various projects

  - U-Boot, Barebox, TF-A

=== Device Tree base syntax

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [

    - Tree of *nodes*

    - Nodes with *properties*

    - Node ≈ a device or IP block

    - Properties ≈ device characteristics

    - Notion of *cells* in property values

    - Notion of *phandle* to point to other nodes

    - `dtc` only does syntax checking, no semantic validation

  ],
  [

    #align(center, [#image("dt-basic-syntax.pdf", height: 60%)])

  ],
)

=== DT overall structure: simplified example

#table(
  columns: (60%, 40%),
  stroke: none,
  gutter: 15pt,
  [

    #[ #set text(size: 18pt)
      ```perl
      / {
        #address-cells = <1>;
        #size-cells = <1>;
        model = "STMicroelectronics STM32MP157C-DK2 Discovery Board";
        compatible = "st,stm32mp157c-dk2", "st,stm32mp157";

        cpus { ... };
        memory@0 { ... };
        chosen { ... };
        intc: interrupt-controller@a0021000 { ... };
        soc {
          i2c1: i2c@40012000 { ... };
          ethernet0: ethernet@5800a000 { ... };
        };
      };
      ```]

  ],
  [

    #align(center, [#image("simple-hardware.pdf", width: 100%)])

  ],
)

#pagebreak()

#table(
  columns: (60%, 40%),
  stroke: none,
  gutter: 15pt,
  [

    #[ #set text(size: 12pt)

      ```perl
      / {
        cpus {
          #address-cells = <1>;
          #size-cells = <0>;
          cpu0: cpu@0 {
            compatible = "arm,cortex-a7";
            clock-frequency = <650000000>;
            device_type = "cpu";
            reg = <0>;
          };

          cpu1: cpu@1 {
            compatible = "arm,cortex-a7";
            clock-frequency = <650000000>;
            device_type = "cpu";
            reg = <1>;
          };
        };

        memory@0 { ... };
        chosen { ... };
        intc: interrupt-controller@a0021000 { ... };
        soc {
          i2c1: i2c@40012000 { ... };
          ethernet0: ethernet@5800a000 { ... };
        };
      };
      ```]

  ],
  [

    #align(center, [#image("simple-hardware.pdf", width: 100%)])

  ],
)

#table(
  columns: (60%, 40%),
  stroke: none,
  gutter: 15pt,
  [

    #[ #set text(size: 18pt)
      ```perl
      / {
        cpus { ... };
        memory@0 {
          device_type = "memory";
          reg = <0x0 0x20000000>;
        };

        chosen {
          bootargs = "";
          stdout-path = "serial0:115200n8";
        };
        intc: interrupt-controller@a0021000 { ... };
        soc {
          i2c1: i2c@40012000 { ... };
          ethernet0: ethernet@5800a000 { ... };
        };
      };
      ```
    ]

  ],
  [

    #align(center, [#image("simple-hardware.pdf", width: 100%)])

  ],
)

#table(
  columns: (60%, 40%),
  stroke: none,
  gutter: 15pt,
  [

    #[ #set text(size: 13pt)
      ```perl
      / {
        cpus { ... };
        memory@0 { ... };
        chosen { ... };

        intc: interrupt-controller@a0021000 {
          compatible = "arm,cortex-a7-gic";
          #interrupt-cells = <3>;
          interrupt-controller;
          reg = <0xa0021000 0x1000>,
                <0xa0022000 0x2000>;
        };

        soc {
          compatible = "simple-bus";
          #address-cells = <1>;
          #size-cells = <1>;
          interrupt-parent = <&intc>;

          i2c1: i2c@40012000 { ... };
          ethernet0: ethernet@5800a000 { ... };
        };
      };
      ```
    ]

  ],
  [

    #align(center, [#image("simple-hardware.pdf", width: 100%)])

  ],
)

#table(
  columns: (60%, 40%),
  stroke: none,
  gutter: 15pt,
  [

    #[ #set text(size: 13pt)
      ```perl
      / {
        cpus { ... };
        memory@0 { ... };
        chosen { ... };
        intc: interrupt-controller@a0021000 { ... };
        soc {
          i2c1: i2c@40012000 {
            compatible = "st,stm32mp15-i2c";
            reg = <0x40012000 0x400>;
            interrupts = <GIC_SPI 31 IRQ_TYPE_LEVEL_HIGH>,
                         <GIC_SPI 32 IRQ_TYPE_LEVEL_HIGH>;
            #address-cells = <1>;
            #size-cells = <0>;
            status = "okay";

            cs42l51: cs42l51@4a {
              compatible = "cirrus,cs42l51";
              reg = <0x4a>;
              reset-gpios = <&gpiog 9 GPIO_ACTIVE_LOW>;
              status = "okay";
            };
          };
          ethernet0: ethernet@5800a000 { ... };
        };
      };
      ```
    ]

  ],
  [

    #align(center, [#image("simple-hardware.pdf", width: 100%)])

  ],
)

#table(
  columns: (60%, 40%),
  stroke: none,
  gutter: 15pt,
  [

    #[ #set text(size: 13pt)
      ```perl
      / {
        cpus { ... };
        memory@0 { ... };
        chosen { ... };
        intc: interrupt-controller@a0021000 { ... };
        soc {
          compatible = "simple-bus";
          ...
          interrupt-parent = <&intc>;
          i2c1: i2c@40012000 { ... };

          ethernet0: ethernet@5800a000 {
            compatible = "st,stm32mp1-dwmac", "snps,dwmac-4.20a";
            reg = <0x5800a000 0x2000>;
            interrupts-extended = <&intc GIC_SPI 61 IRQ_TYPE_LEVEL_HIGH>;
            status = "okay";

            mdio0 {
              #address-cells = <1>;
              #size-cells = <0>;
              compatible = "snps,dwmac-mdio";
              phy0: ethernet-phy@0 {
                reg = <0>;
              };
            }; }; }; };
      ```]

  ],
  [

    #align(center, [#image("simple-hardware.pdf", width: 100%)])

  ],
)

=== Device Tree inheritance

- Device Tree files are not monolithic, they can be split in several
  files, including each other.

- `.dtsi` files are included files, while `.dts` files are _final_
  Device Trees

  - Only `.dts` files are accepted as input to `dtc`

- Typically, `.dtsi` will contain

  - definitions of SoC-level information

  - definitions common to several boards

- The `.dts` file contains the board-level information

- The inclusion works by *overlaying* the tree of the including
  file over the tree of the included file, according to the order of the
  `#include` directives.

- Allows an including file to *override* values specified by an
  included file

- Uses the C pre-processor `#include` directive

=== Device Tree inheritance example

#align(center, [#image("dt-inheritance.pdf", width: 100%)])

=== Inheritance and labels

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [

    Doing:  \
    #[ #set text(size: 14pt)
      soc.dtsi
    ]

    #[ #set text(size: 12pt)
      ```perl
      / {
        soc {
          usart1: serial@5c000000 {
            compatible = "st,stm32h7-uart";
            reg = <0x5c000000 0x400>;
            status = "disabled";
          };
        };
      };
      ```
    ]
    #[ #set text(size: 14pt)
      board.dts
    ]
    #[ #set text(size: 12pt)
      ```perl
      #include "soc.dtsi"

      / {
        soc {
          serial@5c000000 {
            status = "okay";
          };
        };
      };
      ```
    ]
  ],
)

#pagebreak()

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [

    Doing:  \
    #[ #set text(size: 14pt)
      soc.dtsi
    ]

    #[ #set text(size: 12pt)
      ```perl
      / {
        soc {
          usart1: serial@5c000000 {
            compatible = "st,stm32h7-uart";
            reg = <0x5c000000 0x400>;
            status = "disabled";
          };
        };
      };
      ```
    ]
    #[ #set text(size: 14pt)
      board.dts
    ]
    #[ #set text(size: 12pt)
      ```perl
      #include "soc.dtsi"

      / {
        soc {
          serial@5c000000 {
            status = "okay";
          };
        };
      };
      ```
    ]

  ],
  [

    Is exactly equivalent to:  \
    #[ #set text(size: 14pt)
      soc.dtsi
    ]
    #[ #set text(size: 12pt)
      ```perl
      / {
        soc {
          usart1: serial@5c000000 {
            compatible = "st,stm32h7-uart";
            reg = <0x5c000000 0x400>;
            status = "disabled";
          };
        };
      };
      ```
    ]

    #[ #set text(size: 14pt)
      board.dts
    ]
    #[ #set text(size: 12pt)
      ```perl
      #include "soc.dtsi"

      &usart1 {
        status = "okay";
      };
      ```
    ]
    → this solution is now often preferred

  ],
)

=== DT inheritance in STM32MP1 support

#align(center, [#image("dt-inheritance-stm32.pdf", height: 90%)])

=== Device Tree design principles

- *Describe hardware* (how the hardware is), not configuration
  (how I choose to use the hardware)

- *OS-agnostic*

  - For a given piece of HW, Device Tree should be the same for U-Boot,
    FreeBSD or Linux

  - There should be no need to change the Device Tree when updating the
    OS

- Describe *integration of hardware components*, not the
  internals of hardware components

  - The details of how a specific device/IP block is working is handled
    by code in device drivers

  - The Device Tree describes how the device/IP block is
    connected/integrated with the rest of the system: IRQ lines, DMA
    channels, clocks, reset lines, etc.

- Like all beautiful design principles, these principles are sometimes
  violated.

=== Device Tree specifications

#table(
  columns: (65%, 35%),
  stroke: none,
  gutter: 15pt,
  [

    - How to write the correct nodes/properties to describe a given hardware
      platform ?

    - *Device Tree Specifications* → base Device Tree syntax + number of standard properties.

      - #link("https://www.devicetree.org/specifications/")

      - Not sufficient to describe the wide variety of hardware.

    - *Device Tree Bindings* → documents that each specify
      how a piece of HW should be described

      - #kdir("Documentation/devicetree/bindings") in Linux kernel
        sources

      - Reviewed by DT bindings maintainer team

      - Legacy: human readable documents

      - New norm: YAML-written specifications

  ],
  [

    #align(center, [#image("dt-spec.png", width: 90%)])

  ],
)

=== Device Tree binding: old style

#align(center, [#kfile("Documentation/devicetree/bindings/mtd/spear_smi.txt")
  \
  This IP is _not_ used on STM32MP1.])

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [

    #[ #set text(size: 11pt)
      ```
      * SPEAr SMI

      Required properties:
      - compatible : "st,spear600-smi"
      - reg : Address range of the mtd chip
      - #address-cells, #size-cells : Must be present if the device has sub-nodes
        representing partitions.
      - interrupts: Should contain the STMMAC interrupts
      - clock-rate : Functional clock rate of SMI in Hz

      Optional properties:
      - st,smi-fast-mode : Flash supports read in fast mode
      ```
    ]

  ],
  [

    #[ #set text(size: 11pt)
      ```
      Example:

              smi: flash@fc000000 {
                      compatible = "st,spear600-smi";
                      #address-cells = <1>;
                      #size-cells = <1>;
                      reg = <0xfc000000 0x1000>;
                      interrupt-parent = <&vic1>;
                      interrupts = <12>;
                      clock-rate = <50000000>;        /* 50MHz */

                      flash@f8000000 {
                              st,smi-fast-mode;
                              ...
                      };
              };
      ```
    ]

  ],
)

=== Device Tree binding: YAML style

#kfile("Documentation/devicetree/bindings/i2c/st,stm32-i2c.yaml")

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [
    #[ #set text(size: 10pt)
      ```yaml
      # SPDX-License-Identifier: (GPL-2.0-only OR BSD-2-Clause)
      %YAML 1.2
      ---
      $ id: http://devicetree.org/schemas/i2c/st,stm32-i2c.yaml#
      $ schema: http://devicetree.org/meta-schemas/core.yaml#

      title: I2C controller embedded in STMicroelectronics STM32 I2C platform

      maintainers:
        - Pierre-Yves MORDRET <pierre-yves.mordret@st.com>

      properties:
        compatible:
          enum:
            - st,stm32f4-i2c
            - st,stm32f7-i2c
            - st,stm32mp15-i2c

        reg:
          maxItems: 1

        interrupts:
          items:
            - description: interrupt ID for I2C event
            - description: interrupt ID for I2C error

        resets:
          maxItems: 1
      ```
    ]

  ],
  [
    #[ #set text(size: 10pt)
      ```yaml
        clocks:
          maxItems: 1

        dmas:
          items:
            - description: RX DMA Channel phandle
            - description: TX DMA Channel phandle

        ...

        clock-frequency:
          description: Desired I2C bus clock frequency in Hz. If not specified,
                       the default 100 kHz frequency will be used.
                       For STM32F7, STM32H7 and STM32MP1 SoCs, if timing
                       parameters match, the bus clock frequency can be from
                       1Hz to 1MHz.
          default: 100000
          minimum: 1
          maximum: 1000000

      required:
        - compatible
        - reg
        - interrupts
        - resets
        - clocks
      ```
    ]
  ],
)

=== Device Tree binding: YAML style example

#[ #set text(size: 14pt)
  ```yaml
  examples:
    - |
      //Example 3 (with st,stm32mp15-i2c compatible on stm32mp)
      #include <dt-bindings/interrupt-controller/arm-gic.h>
      #include <dt-bindings/clock/stm32mp1-clks.h>
      #include <dt-bindings/reset/stm32mp1-resets.h>
        i2c@40013000 {
            compatible = "st,stm32mp15-i2c";
            #address-cells = <1>;
            #size-cells = <0>;
            reg = <0x40013000 0x400>;
            interrupts = <GIC_SPI 33 IRQ_TYPE_LEVEL_HIGH>,
                         <GIC_SPI 34 IRQ_TYPE_LEVEL_HIGH>;
            clocks = <&rcc I2C2_K>;
            resets = <&rcc I2C2_R>;
            i2c-scl-rising-time-ns = <185>;
            i2c-scl-falling-time-ns = <20>;
            st,syscfg-fmp = <&syscfg 0x4 0x2>;
        };
  ```
]

=== Validating Device Tree in Linux

- `dtc` only does syntactic validation

- YAML bindings allow to do semantic validation

- Linux kernel `make` rules:

  - `make dt_binding_check`
    verify that YAML bindings are valid

  - `make dtbs_check`
    validate DTs currently enabled against YAML bindings

  - `make
    DT_SCHEMA_FILES=Documentation/devicetree/bindings/trivial-devices.yaml
    dtbs_check`
    validate DTs against a specific YAML binding

=== The `compatible` property

- Is a list of strings

  - From the most specific to the least specific

- Describes the specific *binding* to which the node complies.

- It uniquely identifies the *programming model* of the device.

- Practically speaking, it is used by the operating system to find the
  *appropriate driver* for this device.

- When describing real hardware, the typical form is `vendor,model`

- Examples:

  - `compatible = "arm,armv7-timer";`

  - `compatible = "st,stm32mp1-dwmac", "snps,dwmac-4.20a";`

  - `compatible = "regulator-fixed";`

  - `compatible = "gpio-keys";`

- Special value: `simple-bus` → bus where all sub-nodes are
  memory-mapped devices

=== `compatible` property and Linux kernel drivers

#table(
  columns: (60%, 40%),
  stroke: none,
  gutter: 15pt,
  [

    - Linux identifies as *platform devices*:

      - Top-level DT nodes with a `compatible` string

      - Sub-nodes of `simple-bus`

        - Instantiated automatically at boot time

    - Sub-nodes of I2C controllers → _I2C devices_

    - Sub-nodes of SPI controllers → _SPI devices_

    - Each Linux driver has a table of compatible strings it supports

      - #kstruct("of_device_id")`[]`

    - When a DT node compatible string matches a given driver, the device is
      _bound_ to that driver.

  ],
  [

    #align(center, [#image("dt-to-devices.pdf", width: 100%)])

  ],
)

=== Matching with drivers in Linux: platform driver

#[ #set text(size: 14pt)
  #kfile("drivers/tty/serial/stm32-usart.c")
]
```c
static const struct of_device_id stm32_match[] = {
        { .compatible = "st,stm32-uart", .data = &stm32f4_info},
        { .compatible = "st,stm32f7-uart", .data = &stm32f7_info},
        { .compatible = "st,stm32h7-uart", .data = &stm32h7_info},
        {},
}; MODULE_DEVICE_TABLE(of, stm32_match);

...

static struct platform_driver stm32_serial_driver = {
        .probe          = stm32_serial_probe,
        .remove         = stm32_serial_remove,
        .driver = {
                .name   = DRIVER_NAME,
                .pm     = &stm32_serial_pm_ops,
                .of_match_table = of_match_ptr(stm32_match),
        },
};
```

=== Matching with drivers in Linux: I2C driver

#[ #set text(size: 14pt)
  #kfile("sound/soc/codecs/cs42l51.c")
]
```c
const struct of_device_id cs42l51_of_match[] = {
        { .compatible = "cirrus,cs42l51", },
        { }
}; MODULE_DEVICE_TABLE(of, cs42l51_of_match);
```
#[ #set text(size: 14pt)
  #kfile("sound/soc/codecs/cs42l51-i2c.c")
]
```c
static struct i2c_driver cs42l51_i2c_driver = {
        .driver = {
                .name = "cs42l51",
                .of_match_table = cs42l51_of_match,
                .pm = &cs42l51_pm_ops,
        },
        .probe = cs42l51_i2c_probe,
        .remove = cs42l51_i2c_remove,
        .id_table = cs42l51_i2c_id,
};
```

=== `reg` property

- Most important property after `compatible`

- *Memory-mapped* devices: base physical address and size of the
  memory-mapped registers. Can have several entries for multiple
  register areas.

  ```
  sai4: sai@50027000 {
      reg = <0x50027000 0x4>, <0x500273f0 0x10>;
  };
  ```
#pagebreak()
- Most important property after `compatible`

- *Memory-mapped* devices: base physical address and size of the
  memory-mapped registers. Can have several entries for multiple
  register areas.

- *I2C* devices: address of the device on the I2C bus.

  ```
  &i2c1 {
     hdmi-transmitter@39 {
        reg = <0x39>;
     };
     cs42l51: cs42l51@4a {
        reg = <0x4a>;
     };
  };
  ```
#pagebreak()
- Most important property after `compatible`

- *Memory-mapped* devices: base physical address and size of the
  memory-mapped registers. Can have several entries for multiple
  register areas.

- *I2C* devices: address of the device on the I2C bus.

- *SPI* devices: chip select number

  ```
  &qspi {
          flash0: mx66l51235l@0 {
                  reg = <0>;
          };
          flash1: mx66l51235l@1 {
                  reg = <1>;
          };
  };
  ```
#pagebreak()
- Most important property after `compatible`

- *Memory-mapped* devices: base physical address and size of the
  memory-mapped registers. Can have several entries for multiple
  register areas.

- *I2C* devices: address of the device on the I2C bus.

- *SPI* devices: chip select number

- The unit address must be the address of the first `reg` entry.

  ```
  sai4: sai@50027000 {
      reg = <0x50027000 0x4>, <0x500273f0 0x10>;
  };
  ```

=== Status property

- The `status` property indicates if the device is really in use or not

  - `okay` or `ok` → the device is really in use

  - any other value, by convention `disabled` → the device is
    not in use

- In Linux, controls if a device is instantiated

- In `.dtsi` files describing SoCs: all devices that interface to the
  outside world have `status = "disabled";`

- Enabled on a per-device basis in the board `.dts`

=== Resources: interrupts, clocks, DMA, reset lines, ...

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [

    - Common pattern for resources shared by multiple hardware blocks

      - Interrupt lines

      - Clock controllers

      - DMA controllers

      - Reset controllers

      - ...

    - A Device Tree node describing the _controller_ as a device

    - References from other nodes that use resources provided by this
      _controller_

  ],
  [

    #[ #set text(size: 10pt)
      ```perl
      intc: interrupt-controller@a0021000 {
         compatible = "arm,cortex-a7-gic";
         #interrupt-cells = <3>;
         interrupt-controller;
         reg = <0xa0021000 0x1000>, <0xa0022000 0x2000>;
      };

      rcc: rcc@50000000 {
         compatible = "st,stm32mp1-rcc", "syscon";
         reg = <0x50000000 0x1000>;
         #clock-cells = <1>;
         #reset-cells = <1>;
      };

      dmamux1: dma-router@48002000 {
         compatible = "st,stm32h7-dmamux";
         reg = <0x48002000 0x1c>;
         #dma-cells = <3>;
         clocks = <&rcc DMAMUX>;
         resets = <&rcc DMAMUX_R>;
      };

      spi3: spi@4000c000 {
         interrupts = <GIC_SPI 51 IRQ_TYPE_LEVEL_HIGH>;
         clocks = <&rcc SPI3_K>;
         resets = <&rcc SPI3_R>;
         dmas = <&dmamux1 61 0x400 0x05>,  <&dmamux1 62 0x400 0x05>;
      };
      ```]

  ],
)

=== Pin-muxing description

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [

    - Most modern SoCs, including the STM32MP1, have more features than they
      have pins to expose those features to the outside world.

    - Pins are muxed: a given pin can be used for one function *or*
      another

    - A specific IP block in the SoC controls the muxing of pins: the
      *pinmux controller*

    - The Device Tree describes which pin configurations are possible, and
      which configurations are used by the different devices.

  ],
  [

    #align(center, [#image("pin-muxing-principle.pdf", width: 100%)])

  ],
)

=== Pin-muxing controllers on STM32MP1

#[ #set text(size: 14pt)
  #kfileversion("arch/arm/boot/dts/st/stm32mp151.dtsi", "6.1")
]
#[ #set text(size: 12pt)
  ```perl
  pinctrl: pin-controller@50002000 {
          #address-cells = <1>;
          #size-cells = <1>;
          compatible = "st,stm32mp157-pinctrl";
          ...
          gpioa: gpio@50002000 { ... };
          gpiob: gpio@50003000 { ... };
          gpioc: gpio@50004000 { ... };
          gpiod: gpio@50005000 { ... };
          gpioe: gpio@50006000 { ... };
          gpiof: gpio@50007000 { ... };
          ...
  };

  pinctrl_z: pin-controller-z@54004000 {
          #address-cells = <1>;
          #size-cells = <1>;
          compatible = "st,stm32mp157-z-pinctrl";
          ranges = <0 0x54004000 0x400>;
          ...
          gpioz: gpio@54004000 { .... };
          ...
  };
  ```
]

=== Pin-muxing configuration

#[ #set text(size: 14pt)
  #kfileversion("arch/arm/boot/dts/st/stm32mp15-pinctrl.dtsi", "6.1")
]
#[ #set text(size: 11.5pt)
  ```perl
  &pinctrl {
          ...
          i2c1_pins_a: i2c1-0 {
                  pins {
                          pinmux = <STM32_PINMUX('D', 12, AF5)>, /* I2C1_SCL */
                                   <STM32_PINMUX('F', 15, AF5)>; /* I2C1_SDA */
                          bias-disable;
                          drive-open-drain;
                          slew-rate = <0>;
                  };
          };
          ...
          m_can1_pins_a: m-can1-0 {
                  pins1 {
                          pinmux = <STM32_PINMUX('H', 13, AF9)>; /* CAN1_TX */
                          slew-rate = <1>;
                          drive-push-pull;
                          bias-disable;
                  };
                  pins2 {
                          pinmux = <STM32_PINMUX('I', 9, AF9)>; /* CAN1_RX */
                          bias-disable;
                  };
          };
          ...
  };
  ```
]

#pagebreak()

#align(center, [#image("stm32mp157-i2c-pin-mux.png", height: 90%)])
#[ #set text(size: 12pt)
  Source:
  #link("https://www.st.com/resource/en/datasheet/stm32mp157c.pdf")[STM32MP157C datasheet].
  Note that `I2C1_SDA` is also available on pin `PF15` (not shown here).
]

=== Pin-muxing consumer

#[ #set text(size: 15pt)
  ```perl
  &i2c1 {
          pinctrl-names = "default", "sleep";
          pinctrl-0 = <&i2c1_pins_a>;
          pinctrl-1 = <&i2c1_sleep_pins_a>;
          ...
  };
  ```
]
- Typically board-specific, in `.dts`

- `pinctrl-0`, `pinctrl-1`, `pinctrl-X` provides the pin mux
  configurations for the different *states*

- `pinctrl-names` gives a name to each state, mandatory even if only one
  state

- States are mutually exclusive

- The driver is responsible for switching between states

- `default` state is automatically set up when the device is
  _probed_

=== Example: LED and I2C device

#[
  #show raw.where(block: true): set text(size: 14pt)
  - Let's see how to describe an LED and an I2C device connected to the
    DK1 platform.

  - Create `arch/arm/boot/dts/st/stm32mp157a-dk1-custom.dts` which
    includes `stm32mp157a-dk1.dts`

    ```
    #include "stm32mp157a-dk1.dts"
    ```

  - Make sure `stm32mp157a-dk1-custom.dts` gets compiled to a DTB by
    changing #kfile("arch/arm/boot/dts/Makefile")

    ```
    dtb-$(CONFIG_ARCH_STM32) +=
            ...
            stm32mp157a-dk1.dtb
            stm32mp157a-dk1-custom.dtb
    ```

  - `make dtbs`
    ```
      DTC     arch/arm/boot/dts/st/stm32mp157a-dk1-custom.dtb
    ```
]

=== Example: describe an LED

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [
    #[ #set text(size: 16pt)
      stm32mp157a-dk1-custom.dts
    ]
    #[ #set text(size: 12pt)
      ```perl
      #include "stm32mp157a-dk1.dts"

      / {
              leds {
                      compatible = "gpio-leds";
                      webinar {
                              label = "webinar";
                              gpios = <&gpioe 1 GPIO_ACTIVE_HIGH>;
                      };
              };
      };
      ```
    ]
    #[ #set text(size: 16pt)
      shell
    ]
    #[ #set text(size: 12.5pt)
      ```
      # echo 255 > /sys/class/leds/webinar/brightness
      ```
    ]
  ],
  [
    #align(center, [#image("cn14-pinout.png", height: 40%)])
    #align(center, [#image("led-on.jpg", height: 40%)])

  ],
)

=== Example: connect I2C temperature, humidity and pressure sensor

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [
    #[ #set text(size: 15pt)
      stm32mp157a-dk1-custom.dts
    ]
    #[ #set text(size: 12pt)
      ```perl
      &i2c5 {
              status = "okay";
              clock-frequency = <100000>;
              pinctrl-names = "default", "sleep";
              pinctrl-0 = <&i2c5_pins_a>;
              pinctrl-1 = <&i2c5_pins_sleep_a>;

              pressure@76 {
                      compatible = "bosch,bme280";
                      reg = <0x76>;
              };
      };
      ```
    ]
    #[ #set text(size: 15pt)
      shell
    ]
    #[ #set text(size: 12pt)
      ```
      # cat /sys/bus/iio/devices/iio:device2/in_humidityrelative_input
      49147
      # cat /sys/bus/iio/devices/iio:device2/in_pressure_input
      101.567167968
      # cat /sys/bus/iio/devices/iio:device2/in_temp_input
      24380
      ```
    ]
  ],
  [
    #align(center, [#image("cn13-pinout.png", width: 100%)])
    #align(center, [#image("bme.jpg", width: 40%)])

  ],
)

#[ #set text(size: 17pt)
  #align(center, [
    Details at
    #link(
      "https://bootlin.com/blog/building-a-linux-system-for-the-stm32mp1-connecting-an-i2c-sensor/",
    )])
]

=== Further details about the Device Tree

Check out our _DeviceTree 101 webinar_, by Thomas Petazzoni (2021)

- Slides:
  #link("https://bootlin.com/blog/device-tree-101-webinar-slides-and-videos/")


- Video: #link("https://youtu.be/a9CZ1Uk3OYQ")

#align(center, [#image("/common/device-tree-video.jpg", height: 50%)])

== Discoverable hardware: USB and PCI

=== Discoverable hardware

- Some busses have built-in hardware discoverability mechanisms

- Most common busses: USB and PCI

- Hardware devices can be enumerated, and their characteristics
  retrieved with just a driver or the bus controller

- Useful Linux commands

  - `lsusb`, lists all USB devices detected

  - `lspci`, lists all PCI devices detected

  - A detected device does not mean it has a kernel driver associated to
    it!

- Association with kernel drivers done based on product ID/vendor ID, or
  some other characteristics of the device: device class, device
  sub-class, etc.

#setuplabframe([Accessing hardware devices], [
  Time to start the
  practical lab!

  - Exploring the contents of `/dev` and `/sys` and the devices available
    on the embedded hardware platform.

  - Using GPIOs and LEDs.

  - Modifying the Device Tree to control pin multiplexing and declare an
    I2C-connected joystick.

  - Adding support for a USB audio card using Linux kernel modules

  - Adding support for the I2C-connected joystick through an out-of-tree
    module.

])
