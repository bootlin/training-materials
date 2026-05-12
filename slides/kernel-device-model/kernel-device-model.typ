#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Linux device and driver model

== Introduction
<introduction>

=== The need for a device model?

- The Linux kernel runs on a wide range of architectures and hardware
  platforms, and therefore needs to *maximize the reusability* of
  code between platforms.

- For example, we want the same _USB device driver_ to be usable on
  a x86 PC, or an ARM platform, even though the USB controllers used on
  these platforms are different.

- This requires a clean organization of the code, with the _device
  drivers_ separated from the _controller drivers_, the hardware
  description separated from the drivers themselves, etc.

- This is what the Linux kernel *Device Model* allows, in
  addition to other advantages covered in this section.

=== Kernel and device drivers

#table(
  columns: (70%, 30%),
  stroke: none,
  gutter: 15pt,
  [

    In Linux, a driver is always interfacing with:

    - a *framework* that allows the driver to expose the hardware
      features in a generic way.

    - a *bus infrastructure*, part of the device model, to
      detect/communicate with the hardware.

    This section focuses on the _bus infrastructure_, while
    _kernel frameworks_ are covered later in this training.

  ],
  [

    #align(center, [#image("driver-architecture.pdf", height: 95%)])

  ],
)

=== Device model data structures

- The _device model_ is organized around three main data
  structures:

  - The #kstruct("bus_type") structure, which represents one type of
    bus (USB, PCI, I2C, etc.)

  - The #kstruct("device_driver") structure, which represents one
    driver capable of handling certain devices on a certain bus.

  - The #kstruct("device") structure, which represents one device
    connected to a bus

- The kernel uses inheritance to create more specialized versions of
  #kstruct("device_driver") and #kstruct("device") for each bus
  subsystem.

=== Bus drivers

- The first component of the device model is the bus driver

  - One bus driver for each type of bus: USB, PCI, SPI, MMC, I2C, etc.

- It is responsible for

  - Registering the bus type (#kstruct("bus_type"))

  - Allowing the registration of adapter drivers (USB controllers, I2C
    adapters, etc.), able to detect the connected devices (if possible),
    and providing a communication mechanism with the devices

  - Allowing the registration of device drivers (USB devices, I2C
    devices, PCI devices, etc.), managing the devices

  - Matching the device drivers against the devices detected by the
    adapter drivers.

  - Provides an API to implement both adapter drivers and device drivers

  - Defining driver and device specific structures, eg.
    #kstruct("usb_driver") and #kstruct("usb_interface")

=== sysfs

- The bus, device, drivers, etc. structures are internal to the kernel

- The `sysfs` virtual filesystem offers a mechanism to export such
  information to user space

- Used for example by `udev` to provide automatic module loading,
  firmware loading, mounting of external media, etc.

- `sysfs` is usually mounted in `/sys`

  - `/sys/bus/` contains the list of buses

  - `/sys/devices/` contains the list of devices

  - `/sys/class` enumerates devices by the framework they are registered
    to (`net`, `input`, `block`...), whatever bus they are connected to.
    Very useful!

== Example of the USB bus
<example-of-the-usb-bus>

=== Example: USB bus 1/3

#align(center, [#image("usb-bus-hardware.pdf", height: 90%)])

=== Example: USB bus 2/3

#align(center, [#image("usb-bus.pdf", height: 90%)])

=== Example: USB bus 3/3

- Core infrastructure (bus driver)

  - #kdir("drivers/usb/core")

  - #kstruct("bus_type") is defined in
    #kfile("drivers/usb/core/driver.c") and registered in \
    #kfile("drivers/usb/core/usb.c")

- Adapter drivers

  - #kdir("drivers/usb/host")

  - For EHCI, UHCI, OHCI, XHCI, and their implementations on various
    systems (Microchip, IXP, Xilinx, OMAP, Samsung, PXA, etc.)

- Device drivers

  - Everywhere in the kernel tree, classified by their type (Example:
    #kdir("drivers/net/usb"))

=== Example of device driver

#table(
  columns: (75%, 25%),
  stroke: none,
  gutter: 15pt,
  [

    - To illustrate how drivers are implemented to work with the device
      model, we will study the source code of a driver for a USB network
      card

      - It is USB device, so it has to be a USB device driver

      - It exposes a network device, so it has to be a network driver

      - Most drivers rely on a bus infrastructure (here, USB) and register
        themselves in a framework (here, network)

    - We will only look at the device driver side, and not the adapter
      driver side

    - The driver we will look at is #kfile("drivers/net/usb/rtl8150.c")

  ],
  [

    #align(center, [#image("usb-network.pdf", width: 100%)])

  ],
)

=== Device identifiers

- Defines the set of devices that this driver can manage, so that the USB core knows for which devices this driver should be used
- The #kfunc("MODULE_DEVICE_TABLE") macro allows `depmod` (run by `make modules_install`) to extract the relationship betwee, device identifiers and drivers,
  so that drivers can be loaded automatically by `udev`. See \
  `/lib/modules/$(uname -r)/modules.{alias, usbmap}`

#v(0.5em)
#[ #show raw.where(lang: "c", block: true): set text(size: 17pt)
  ```c
  static struct usb_device_id rtl8150_table[] = {
      { USB_DEVICE(VENDOR_ID_REALTEK, PRODUCT_ID_RTL8150) },
      { USB_DEVICE(VENDOR_ID_MELCO, PRODUCT_ID_LUAKTX) },
      { USB_DEVICE(VENDOR_ID_MICRONET, PRODUCT_ID_SP128AR) },
      { USB_DEVICE(VENDOR_ID_LONGSHINE, PRODUCT_ID_LCS8138TX) },
      [...]
      {}
  }; MODULE_DEVICE_TABLE(usb, rtl8150_table);
  ```
]

=== Instantiation of usb_driver

- #kstruct("usb_driver") is a structure defined by the USB core.
  Each USB device driver must instantiate it, and register itself to the
  USB core using this structure

- This structure inherits from #kstruct("device_driver"), which is
  defined by the device model.
#v(0.5em)
#[ #show raw.where(lang: "c", block: true): set text(size: 17pt)
  ```c
  static struct usb_driver rtl8150_driver = {
      .name = "rtl8150",
      .probe = rtl8150_probe,
      .disconnect = rtl8150_disconnect,
      .id_table = rtl8150_table,
      .suspend = rtl8150_suspend,
      .resume = rtl8150_resume
  };
  ```]

=== Driver registration and unregistration

- When the driver is loaded / unloaded, it must register / unregister
  itself to / from the USB core

- Done using #kfunc("usb_register") and
  #kfunc("usb_deregister"), provided by the USB core.
#v(0.5em)
#[ #show raw.where(lang: "c", block: true): set text(size: 14pt)
  ```c
  static int __init usb_rtl8150_init(void)
  {
      return usb_register(&rtl8150_driver);
  }

  static void __exit usb_rtl8150_exit(void)
  {
      usb_deregister(&rtl8150_driver);
  }

  module_init(usb_rtl8150_init);
  module_exit(usb_rtl8150_exit);
  ```]
#v(0.5em)
- All this code is actually replaced by a call to the
  #kfunc("module_usb_driver") macro:
#v(0.5em)
#[ #show raw.where(lang: "c", block: true): set text(size: 14pt)
  ```c
  module_usb_driver(rtl8150_driver);
  ```]

=== At Initialization

- The USB adapter driver that corresponds to the USB controller of the
  system registers itself to the USB core

- The #ksym("rtl8150") USB device driver registers itself to the USB
  core

#v(0.5em)

#align(center, [#image("usb-registering.pdf", height: 50%)])

#v(0.5em)

- The USB core now knows the association between the vendor/product IDs
  of #ksym("rtl8150") and the #kstruct("usb_driver") structure of
  this driver

=== When a device is detected

#align(center, [#image("usb-detection.pdf", width: 100%)])

=== Probe method

- Invoked *for each device* bound to a driver

- The `probe()` method receives as argument a structure describing the
  device, usually specialized by the bus infrastructure
  (#kstruct("pci_dev"), #kstruct("usb_interface"), etc.)

- This function is responsible for

  - Initializing the device, mapping I/O memory, registering the
    interrupt handlers. The bus infrastructure provides methods to get
    the addresses, interrupt numbers and other device-specific
    information.

  - Registering the device to the proper kernel framework, for example
    the network infrastructure.

=== Example: probe() and disconnect() methods

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [

    ```c
    static int rtl8150_probe(struct usb_interface *intf,
        const struct usb_device_id *id)
    {
        rtl8150_t *dev;
        struct net_device *netdev;

        netdev = alloc_etherdev(sizeof(rtl8150_t));
        [...]
        dev = netdev_priv(netdev);
        tasklet_init(&dev->tl, rx_fixup, (unsigned long)dev);
        spin_lock_init(&dev->rx_pool_lock);
        [...]
        netdev->netdev_ops = &rtl8150_netdev_ops;
        alloc_all_urbs(dev);
        [...]
        usb_set_intfdata(intf, dev);
        SET_NETDEV_DEV(netdev, &intf->dev);
        register_netdev(netdev);

        return 0;
    }
    ```

    Source: #kfile("drivers/net/usb/rtl8150.c")

  ],
  [

    ```c
    static void rtl8150_disconnect(struct usb_interface *intf)
    {
            rtl8150_t *dev = usb_get_intfdata(intf);

            usb_set_intfdata(intf, NULL);
            if (dev) {
                    set_bit(RTL8150_UNPLUG, &dev->flags);
                    tasklet_kill(&dev->tl);
                    unregister_netdev(dev->netdev);
                    unlink_all_urbs(dev);
                    free_all_urbs(dev);
                    free_skb_pool(dev);
                    if (dev->rx_skb)
                            dev_kfree_skb(dev->rx_skb);
                    kfree(dev->intr_buff);
                    free_netdev(dev->netdev);
            }
    }
    ```
  ],
)

=== The model is recursive

#align(center, [#image("recursive-model.pdf", height: 90%)])

== Platform drivers
<platform-drivers>

=== Platform devices

- Amongst the non-discoverable devices, a huge family are the devices
  that are directly part of a system-on-chip: UART controllers, Ethernet
  controllers, SPI or I2C controllers, graphic or audio devices, etc.

- In the Linux kernel, a special bus, called the *platform bus*
  has been created to handle such devices. Those get controlled through
  *memory-mapped registers*.

- It supports *platform drivers* that handle *platform
  devices*.

- It works like any other bus (USB, PCI), except that devices are
  enumerated statically instead of being discovered dynamically.

=== Implementation of a platform driver (1)

The driver implements a #kstruct("platform_driver") structure (example taken from
#kfile("drivers/tty/serial/imx.c"), simplified)

#v(0.5em)

#[ #show raw.where(lang: "c", block: true): set text(size: 14pt)
  ```c
  static struct platform_driver serial_imx_driver = {
          .probe          = serial_imx_probe,
          .remove         = serial_imx_remove,
          .id_table       = imx_uart_devtype,
          .driver         = {
                  .name   = "imx-uart",
                  .of_match_table = imx_uart_dt_ids,
                  .pm     = &imx_serial_port_pm_ops,
          },
  };
  ```]

=== Implementation of a platform driver (2)

... and registers its driver to the platform driver infrastructure

#v(0.5em)

#[ #show raw.where(lang: "c", block: true): set text(size: 14pt)
  ```c
  static int __init imx_serial_init(void) {
      return platform_driver_register(&serial_imx_driver);
  }

  static void __exit imx_serial_cleanup(void) {
      platform_driver_unregister(&serial_imx_driver);
  }

  module_init(imx_serial_init);
  module_exit(imx_serial_cleanup);
  ```]

#v(0.5em)

Most drivers actually use the #kfunc("module_platform_driver")
macro when they do nothing special in `init()` and `exit()` functions:

#v(0.5em)

#[ #show raw.where(lang: "c", block: true): set text(size: 14pt)
  ```c
  module_platform_driver(serial_imx_driver);
  ```]

=== Platform device instantiation

- As platform devices cannot be detected dynamically, they are defined
  statically

  - Legacy way: by direct instantiation of
    #kstruct("platform_device") structures, as done on a few old ARM
    platforms. The device was part of a list, and the list of devices
    was added to the system during board initialization.

  - Current way: by parsing an "external" description, like a
    _device tree_ on most embedded platforms today, from which
    #kstruct("platform_device") instances are created.

=== Using additional hardware resources

- Regular DT descriptions contain many information. It includes phandles
  (pointers) towards additional hardware blocks which cannot be
  discovered.

  - I/O register addresses and IRQ lines are available through a
    #kstruct("resource") array associated to each
    #kstruct("platform_device").

  - Information relevant to a given subsystem is parsed by that specific
    subsystem. Examples are clocks, GPIOs or DMA. A subsystem is
    responsible for:

    - instantiating its components,

    - offering an API to use those objects from device drivers.

  - Specific properties are directly retrieved by device drivers,
    through (expensive) DT lookups.

- All these methods allow the same driver to be used with multiple
  devices functioning similarly, but with different addresses, IRQs,
  etc.

=== Using resources

- The platform driver has access to the resources provided by the
  platform bus:

#v(0.5em)

#[ #show raw.where(lang: "c", block: true): set text(size: 16pt)
  ```c
  res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
  base = ioremap(res->start, PAGE_SIZE);
  sport->rxirq = platform_get_irq(pdev, 0);
  ```]

#v(0.5em)

- As well as the various subsystem-provided dependencies through
  individual APIs:

  - #kfunc("clk_get")

  - #kfunc("gpio_request")

  - #kfunc("dma_request_channel")

=== Driver data

- In addition to the per-device resources and information, drivers may
  require driver-specific information to behave slightly differently
  when different flavors of an IP block are driven by the same driver.

- A `const void *data` pointer can be used to store per-compatible
  specificities:
#[ #show raw.where(lang: "c", block: true): set text(size: 14pt)
  ```c
  static const struct of_device_id marvell_nfc_of_ids[] = {
          {
                  .compatible = "marvell,armada-8k-nand-controller",
                  .data = &marvell_armada_8k_nfc_caps,
          },
  };
  ```]

#v(0.5em)

- Which can be retrieved in the probe with:

#v(0.5em)

#[ #show raw.where(lang: "c", block: true): set text(size: 14pt)
  ```c
          /* Get NAND controller capabilities */
          if (pdev->id_entry) /* legacy way */
                  nfc->caps = (void *)pdev->id_entry->driver_data;
          else /* current way */
                  nfc->caps = of_device_get_match_data(&pdev->dev);
  ```
]
