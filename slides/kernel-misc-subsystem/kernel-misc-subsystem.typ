#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= The misc subsystem

===  Why a _misc_ subsystem?

- The kernel offers a large number of *frameworks* covering a
  wide range of device types: input, network, video, audio, etc.

  - These frameworks allow to factorize common functionality between
    drivers and offer a consistent API to user space applications.

- However, there are some devices that *really do not fit in any
  of the existing frameworks*.

  - Highly customized devices implemented in a FPGA, or other weird
    devices for which implementing a complete framework is not useful.

- The drivers for such devices could be implemented directly as raw
  _character drivers_ (with #kfunc("cdev_init") and
  #kfunc("cdev_add")).

- But there is a subsystem that makes this work a little bit easier: the
  *misc subsystem*.

  - It is really only a *thin layer* above the _character
    driver_ API.

  - Another advantage is that devices are integrated in the Device Model
    (device files appearing in _devtmpfs_, which you don't have
    with raw character devices).

===  Misc subsystem diagram

#align(center, [#image("misc-subsystem-diagram.pdf", width: 100%)])

===  Misc subsystem API (1/2)

- The misc subsystem API mainly provides two functions, to register and
  unregister *a single* _misc device_:


  - ```c int misc_register(struct miscdevice * misc); ```

  - ```c void misc_deregister(struct miscdevice *misc); ```

- A _misc device_ is described by a #kstruct("miscdevice")
  structure:

#[ #show raw.where(lang: "c", block: true): set text(size: 15pt)
  ```c
  struct miscdevice  {
          int minor;
          const char *name;
          const struct file_operations *fops;
          struct list_head list;
          struct device *parent;
          struct device *this_device;
          const char *nodename;
          umode_t mode;
  };
  ```]

===  Misc subsystem API (2/2) 

The main fields to be filled in #kstruct("miscdevice") are:

- `minor`, the minor number for the device, or
  #ksym("MISC_DYNAMIC_MINOR") to get a minor number automatically
  assigned.

- `name`, name of the device, which will be used to create the device
  node if _devtmpfs_ is used.

- `fops`, pointer to the same #kstruct("file_operations") structure
  that is used for raw character drivers, describing which functions
  implement the _read_, _write_, _ioctl_, etc.
  operations.

- `parent`, pointer to the `struct device` of the underlying "physical"
  device (platform device, I2C device, etc.)

===  User space API for misc devices

- _misc devices_ are regular character devices

- The operations they support in user space depends on the operations
  the kernel driver implements:

  - The `open()` and `close()` system calls to open/close the device.

  - The `read()` and `write()` system calls to read/write to/from the
    device.

  - The `ioctl()` system call to call some driver-specific operations.

#setuplabframe([Output-only serial port driver],[

- Extend the driver started in the previous lab by registering it into
  the _misc_ subsystem.

- Implement serial output functionality through the _misc_
  subsystem.

- Test serial output using user space applications.

])
