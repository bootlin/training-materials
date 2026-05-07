#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme 

= Introduction to pin muxing

===  What is pin muxing?

- Modern SoCs (System on Chip) include more and more hardware blocks,
  many of which need to interface with the outside world using
  _pins_.

- However, the physical size of the chips remains small, and therefore
  the number of available pins is limited.

- For this reason, not all of the internal hardware block features can
  be exposed on the pins simultaneously.

- The pins are *multiplexed*: they expose either the
  functionality of hardware block A *or* the functionality of
  hardware block B.

- This _multiplexing_ is usually software configurable.

===  Pin muxing diagram

#align(center, [#image("pin-muxing-principle.pdf", height: 90%)])

===  Pin muxing in the Linux kernel

- Since Linux 3.2, a `pinctrl` subsystem has been added.

- This subsystem, located in #kdir("drivers/pinctrl") provides a
  generic subsystem to handle pin muxing. It offers:

  - A pin muxing driver interface, to implement the system-on-chip
    specific drivers that configure the muxing.

  - A pin muxing consumer interface, for device drivers.

- Most _pinctrl_ drivers provide a Device Tree binding, and the pin
  muxing must be described in the Device Tree.

  - The exact Device Tree binding depends on each driver. Each binding
    is defined in #kdoctext("devicetree/bindings/pinctrl").

===  `pinctrl` subsystem diagram

#align(center, [#image("pinctrl-subsystem.pdf", height: 90%)])

===  Device Tree properties for consumer devices 

The devices that require certains pins to be muxed will use the
`pinctrl-<x>` and `pinctrl-names` Device Tree properties.

- The `pinctrl-0`, `pinctrl-1`, `pinctrl-<x>` properties link to a pin
  configuration for a given state of the device.

- The `pinctrl-names` property associates a name to each state. The name
  `default` is special, and is automatically selected by a device
  driver, without having to make an explicit _pinctrl_ function
  call.

- See #kdoctext("devicetree/bindings/pinctrl/pinctrl-bindings.txt")
  for details.

===  Device Tree properties for consumer devices - Examples

#table(columns: (50%, 50%), stroke: none, gutter: 15pt, [

```perl
i2c0: i2c@11000 {
        ...
        pinctrl-0 = <&pmx_twsi0>;
        pinctrl-names = "default";
        ...
};
```

Most common case (#kfile("arch/arm/boot/dts/marvell/kirkwood.dtsi"))
],[

#text(size: 17pt)[
```perl
i2c0: i2c@f8014000 {
       ...
       pinctrl-names = "default", "gpio";
       pinctrl-0 = <&pinctrl_i2c0>;
       pinctrl-1 = <&pinctrl_i2c0_gpio>;
       ...
};
```]

Case with multiple pin states
(#kfile("arch/arm/boot/dts/microchip/sama5d4.dtsi"))

])


===  Defining pinctrl configurations

- The different _pinctrl configurations_ must be defined as child
  nodes of the main _pinctrl device_ (which controls the muxing of
  pins).

- The configurations may be defined at:

  - the SoC level (`.dtsi` file), for pin configurations that are often
    shared between multiple boards

  - at the board level (`.dts` file) for configurations that are board
    specific.

- The `pinctrl-<x>` property of the consumer device points to the pin
  configuration it needs through a DT _phandle_.

- The description of the configurations is specific to each
  _pinctrl driver_. See #kdoctext("devicetree/bindings/pinctrl")
  for the pinctrl bindings.

===  Example on OMAP/AM33xx

#table(columns: (55%, 45%), stroke: none, gutter: 15pt, [

- On OMAP/AM33xx, the `pinctrl-single` driver is used. It is common
  between multiple SoCs and simply allows to configure pins by writing a
  value to a register.

  - In each pin configuration, a `pinctrl-single,pins` value gives a
    list of _(register, value)_ pairs needed to configure the pins.

- To know the correct values, one must use the SoC and board datasheets.

],[

#text(size: 12pt)[
```perl
/* Excerpt from am335x-bone-common.dts */

&am33xx_pinmux {
   ...
   i2c2_pins: pinmux_i2c2_pins {
      pinctrl-single,pins = <
         AM33XX_PADCONF(AM335X_PIN_UART1_CTSN, PIN_INPUT_PULLUP, MUX_MODE3)
         /* uart1_ctsn.i2c2_sda */
         AM33XX_PADCONF(AM335X_PIN_UART1_RTSN, PIN_INPUT_PULLUP, MUX_MODE3)
         /* uart1_rtsn.i2c2_scl */
      >;
   };
};

&i2c2 {
   pinctrl-names = "default";
   pinctrl-0 = <&i2c2_pins>;

   status = "okay";
   clock-frequency = <400000>;
   ...

   pressure@76 {
      compatible = "bosch,bmp280";
      reg = <0x76>;
   };
};
```]

])

===  Example on the Allwinner A20 SoC

#align(center, [#image("allwinner-example.pdf", height: 90%)])

#setuplabframe([Setup pinmuxing to enable I2C communication],[

- Configure the pinmuxing for the I2C bus used to communicate with the
  Nunchuk

- Validate that the I2C communication works with user space tools.

])
