#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== Clocking and power management

=== Enabling hardware

In order to become functional, hardware blocks require:

- Power to be applied

- Clocks to be ticking

  - Hardware blocks are connected through hardware buses (AHB, APB,
    AXI...), their interface logic require an input clock to respond

    - One will experience bus hangs otherwise

  - When a device exposes a bus (eg. a SPI controller), there is
    typically a second clock whose frequency can be tuned

- Resets to be released

=== Power handling

- Internal and external devices can be fed by a regulator

  - Shared refcounted resources

  - See #kfunc("devm_regulator_get_enable")

- Internal devices can typically be part of a power management domain
  (named `pmdomain`, formerly `genpd`)

  - Shared refcounted resources

  - For example: all display related controllers may be in one power
    domain (CRTC, LCD controller, HDMI phy, etc). The whole domain is
    either powered on or off.

=== Clocks handling

- A clock tree typically starts from the main crystal, feeds PLLs,
  gates, divisors and reaches every device in the system

  - Shared refcounted resources

  - Managed by the Common Clock Framework (CCF)

  - Simple API described in #kfile("include/linux/clk.h").

    - #kfunc("devm_clk_get") to lookup and obtain a reference to a
      clock producer

    - #kfunc("clk_prepare_enable") to inform the system when the
      clock source should be running

    - #kfunc("clk_disable_unprepare") to inform the system when the
      clock source is no longer required.

    - #kfunc("clk_get_rate") to obtain the current clock rate (in
      Hz) for a clock source

    - #kfunc("clk_set_rate") to set the current clock rate (in Hz)
      of a clock source

- Allows to declare the available clocks and their association to
  devices in the Device Tree

- Provides a #emph[debugfs] representation of the clock tree

- Is implemented in #kdir("drivers/clk")

=== Diagram overview of the common clock framework

#align(center, [#image("clock-framework.svg", width: 100%)])

=== Reset handling

- Goal is to put a device in a known harder default state

- Typically done while probing

- Resets can be simple GPIOs

- More complex resets can be registered in the reset control framework

  - Pointed by the `resets` DT property

  - API is straightforward:

    - #kfunc("devm_reset_control_get")

    - #kfunc("reset_control_assert")

    - #kfunc("reset_control_deassert")

=== Runtime Power Management

- The state of a device can change at runtime, a sort of per-device idle
  state

- According to the kernel configuration interface: #emph[Enable
    functionality allowing I/O devices to be put into energy-saving (low
    power) states at run time (or autosuspended) after a specified period
    of inactivity and woken up in response to a hardware-generated wake-up
    event or a driver's request.]

- New hooks may be added to the drivers: `runtime_suspend()`,
  `runtime_resume()`, `runtime_idle()` in the
  #kstruct("dev_pm_ops") structure of
  #kstruct("device_driver").

- API and details on #kdochtml("power/runtime_pm"):

  - #kfunc("pm_runtime_enable")

  - #kfunc("pm_runtime_get_sync")

  - #kfunc("pm_runtime_put")

  - #kfunc("pm_runtime_disable")

- Runtime PM may use resets, clocks, power...

  - It sometimes replaces direct clock lookups and handling on some old
    ARM platforms, like the AM335x.

=== Useful resources

- #kdochtmldir("power") in kernel documentation.

- Introduction to kernel power management \
  Kevin Hilman (Kernel Recipes 2015)

  - #link(
      "https://www.youtube.com/watch?v=juJJZORgVwI",
    )[https://www.youtube.com/watch?v=juJJZORgVwI]

- Overview of Generic PM Domains \
  Kevin Hilman (Kernel Recipes 2017)

  - #link(
      "https://www.youtube.com/watch?v=SctfvoskABM",
    )[https://www.youtube.com/watch?v=SctfvoskABM]

- Linux Power Management Features, Their Relationships and Interactions

  Théo Lebrun (Embedded Linux Conference Europe 2024)

  - #link(
      "https://www.youtube.com/watch?v=_jb6U40ZCZk",
    )[https://www.youtube.com/watch?v=_jb6U40ZCZk]
