#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== PHY driver and link management

===  PHY devices

#table(columns: (30%, 70%), stroke: none, gutter: 15pt, [

#align(center, [#image("phy_easy.pdf", width: 100%)])

],[

- Ethernet PHYs handle Layer 1 of the OSI model

- Standardized by IEEE 802.3

- *\M*\edia *\I*\ndependent *\I*\nterface

  - Communication bus between MAC and PHY

- *\M*\edia *\D*\ependent *\I*\nterface

  - Communication medium with the *link partner*

  - Can be Cat6 cable, Fiber, Coax, backplane, etc.

- *\M*\anagement *\D*\ata *\I*\nput *\O*\utput

  - Control bus for PHY devices

  - Can be shared by multiple PHYs

  - Allows accessing PHY registers

- Optionally, PHYs can raise interrupts

  - _e.g._ to report link status changes

- Optionally, PHYs can have a reset line

])

===  MDIO Bus

#table(columns: (80%, 20%), stroke: none, gutter: 15pt, [

- Most common bus to access Ethernet PHYs

- Addressable, 32 addresses

- Physically very similar to i2c

  - An *adapter* initiates all transfers to *devices*

  - 2 physical signals : *MDC* for the clock, *MDIO* for
    data

], [

#align(center, [#image("mdio.pdf", width: 80%)])

])

#v(-1em)
- 802.3 defines 2 protocols for MDIO :

  - Clause 22 : 5 bits device address, 5 bits register address, 16 bits
    data

  - Clause 45 : 3-part addresses : 5 bits addresses, 5 bits
    *devtype*, 16 bits register address, 16 bits data

  - *devtype* allows addressing sub-components of the PHY : PCS,
    PMA/PMD, etc.

  - C45 is backwards compatible with C22

- Register layout is defined by *802.3*, with room for
  vendor-specific registers

- a
  #link("https://elixir.bootlin.com/linux/v6.15.1/source/drivers/net/mdio/mdio-bitbang.c")[gpio bitbang]
  MDIO driver exists

===  MDIO driver

- MDIO controller drivers are represented by #kstruct("mii_bus")

- Contains callback ops for `C22` and `C45` access :

#v(0.5em)

#[ #show raw.where(lang: "c", block: true): set text(size: 13pt)
```c
struct mii_bus {
        const char *name;
        void *priv;
        int (*read)(struct mii_bus *bus, int addr, int regnum);
        int (*write)(struct mii_bus *bus, int addr, int regnum, u16 val);
        int (*read_c45)(struct mii_bus *bus, int addr, int devnum, int regnum);
        int (*write_c45)(struct mii_bus *bus, int addr, int devnum, int regnum, u16 val);
        int (*reset)(struct mii_bus *bus);
/* ... truncated ... */
};
```
]

===  MDIO accessors

- Raw read/write operations :
  #[ #show raw.where(lang: "c", block:false): set text(size: 13.5pt)

  ```c int mdiobus_read(struct mii_bus *bus, int addr, u32 regnum);  ``` \
  ```c int mdiobus_write(struct mii_bus *bus, int addr, u32 regnum, u16 val);  ``` \
  ```c int mdiobus_c45_read(struct mii_bus *bus, int addr, int devad, u32 regnum);  ``` \
  ```c int mdiobus_c45_write(struct mii_bus *bus, int addr,  int devad, u32 regnum, u16 val); ```
]

- Wrapped by phylib for convenience : #kfunc("phy_read"),
  #kfunc("phy_read_mmd"), etc.

- Unlocked versions : #kfunc("__mdiobus_write"),
  #kfunc("__phy_write"), etc.

  - Caller implements their own locking

  - Useful for large transfers, _e.g._ loading a firmware

===  MDIO access from userspace

- `ioctl` based API, limited on purpose

- Useful for debugging, but interferes with phylib

  - Phylib and drivers have no way to track user-made configuration

- Main userspace tool is `phytool`

  - `phytool read eth0/1/2` : Read register 2 from mdio device at
    address 1

  - `phytool read eth0/1:2/3` : Read register 3 on MMD 2 from mdio
    device at address 1

- Can be tedious for indirect access

- *mdio-tools* uses an out-of-tree module to access MDIO over
  Netlink

===  MDIO controllers in devicetree

#table(columns: (50%, 50%), stroke: none, gutter: 15pt, [

#text(size: 15pt)[#kfile("arch/arm64/boot/dts/marvell/armada-37xx.dtsi")]

#text(size: 17pt)[
```perl
mdio: mdio@32004 {
    #address-cells = <1>;
    #size-cells = <0>;
    compatible = "marvell,orion-mdio";
    reg = <0x32004 0x4>;
};
```]

#v(0.5em)

#text(size: 14pt)[#kfile("arch/arm/boot/dts/st/stm32mp15xx-dkx.dtsi")]

#text(size: 17pt)[
```perl
&ethernet0 {
    mdio {
        compatible = "snps,dwmac-mdio";
        /* ... */
    };
};
```]

],[

- SoCs may have dedicated MDIO controllers

  - Dedicated drivers with their own `compatible`

- Some MACs and DSA switches have an integrated MDIO controller

  - `mdio` child node within the MAC controller's node

])

===  Ethernet PHYs identification

- 802.3 specifies that registers 0x2 and 0x3 are *identifiers*

  - `OUI` (24 bits) and `Model` information (10 bits)

- PHY drivers register which identifier they support

  - `phy_driver.phy_id`

- We don't need per-device `compatible` strings in devicetree

- PHY `compatible` is used to indicate :

  - The MDIO clause :

    - `ethernet-phy-ieee802.3-c22`

    - `ethernet-phy-ieee802.3-c45`

  - The PHY id, if PHY reports the wrong information

    - _e.g._ `ethernet-phy-id2000.a231`

===  Ethernet PHYs in devicetree

#table(columns: (50%, 50%), stroke: none, gutter: 15pt, [

#text(size: 15pt)[#kfile("arch/arm64/boot/dts/marvell/armada-8040-mcbin.dtsi")]

#text(size: 17pt)[
```perl
&cp0_mdio {
    status = "okay";
    
    ge_phy: ethernet-phy@0 {
        reg = <0>;
    };
};

&eth0 {
        phy-handle = <&ge_phy>;
}
```]

],[

- `reg` - mandatory

  - The PHY's address on the MDIO bus

  - Usually assigned via PCB straps

- `reset-gpios` : GPIO reset line

- `rx|tx-internal-delay-ps`

  - RGMII delays adjustments

- `leds` : LEDs driven by the PHY

- `interrupts` :

  - Status interrupt, level-triggered

- `sfp` : _phandle_ to an SFP cage description

])

===  PHY devices in the kernel

#table(columns: (80%, 20%), stroke: none, gutter: 15pt, [

- A PHY driver is represented by #kstruct("phy_driver")

- PHY instances are represented by #kstruct("phy_device")

  - By convention, objects are named `phydev` or `phy`

- *All* Ethernet PHY devices are `mdio` devices

  - Fixed-PHY uses an
    #link("https://elixir.bootlin.com/linux/v6.15.1/source/drivers/net/phy/swphy.c")[emulated bus]

  - Memory-mapped PHYs can use a
    #link("https://elixir.bootlin.com/linux/v6.15.1/source/drivers/net/mdio/mdio-regmap.c")[regmap conversion layer]

],[
  
  #align(center, [#image("phy.pdf", width: 80%)])

])
#v(-0.5em)
- Managed by the *phylib* PHY framework

- PHY drivers mostly handle the vendor-specific aspects

- Most of the standardized logic is generic, and implemented in phylib

- A
  #link("https://elixir.bootlin.com/linux/v6.15.1/source/drivers/net/phy/phy_device.c#L3510")[Generic driver]
  implements only the standard logic

  - Used as a fallback when a PHY is detected with no associated driver

===  PHY device role

- The PHY driver reports the *link status* :

  - Updated by `phy_driver.read_status()`

    - Called upon PHY interrupt, or polled

  - `phydev.link` : Link with the partner is `UP` or `DOWN`

  - `phydev.speed` : Established link speed, in Mbps

  - `phydev.duplex` : Established duplex (half or full)

- It is in charge of configuring and performing the *Link
  negotiation*

  - Based on what the MAC can do and user-specified parameters

  - _e.g._ `ethtool -s eth0 speed 100 duplex full autoneg on` on a
    1G interface

- It may implement some *offloaded operations*

  - Some PHYs can offload *MACSec*

  - PHY timestamping is implemented by some devices

===  PHY device role - 2

- *Wake on Lan* can be implemented at the PHY level

  - The PHY receives the
    #link("https://en.wikipedia.org/wiki/Wake-on-LAN#Magic_packet")[magic packet]

  - It triggers an interrupt to wake the system up

  - `phy_driver.set_wol()` and `phy_driver.get_wol()`

- Some PHYs can perform *cable testing*

  - Detects cable and connector faults

  - `ethtool –cable-test eth0`

- They may report stats, useful for debugging link bringup

  - `ethtool –phy-statistics eth0`

- *`BaseT1S`* PHYs can configure the
  #link("https://docs.kernel.org/networking/ethtool-netlink.html#plca-get-cfg")[plca]
  parameters

===  Fixed-link

- The PHY is responsible for reporting the link state, but doesn't
  always exist

- _e.g._ MAC to MAC links, between a SoC and a DSA switch

- Fixed-link allows describing a link that is always `UP`

- In creates a virtual PHY internally that reports fixed parameters

#v(0.5em)
#text(size: 15pt)[fixed link example]

```perl
&eth0 {
        /* ... */
        fixed-link {
                speed = <1000>;
                full-duplex;
        };
};
```

===  MII 

#table(columns: (80%, 20%), stroke: none, gutter: 15pt, [

- *\M*\edia *\I*\ndependent *\I*\nterface

- Conveys the data stream between MAC and PHY

- Specified in devicetree via `phy-mode` or `phy-connection-type`

],[

#align(center, [#image("mii.pdf", width: 75%)])

])

#v(-2em)
- In some scenarios, the mode may change dynamically

  - For *serialized* modes that are physically compatible

  - Depending on the negotiated link speed, the PHY may change its mode

  - example: the
    #link("https://elixir.bootlin.com/linux/v6.15.1/source/drivers/net/phy/marvell10g.c")[Marvell 88x3310 PHY]

  - When link speed is negotiated at 1Gbps, uses *SGMII*

  - When link speed is negotiated at 2.5Gbps, uses *2500BaseX*

  - When link speed is negotiated at 10Gbps, uses *10GBaseR*

- On the MAC side, may require specific *PCS* and *Serdes*
  configuration

===  MII flavours - Parallel interfaces

- `MII` : Also describes a 8-bit, 10/100Mbps interface

- `RMII` : *\R*\educed *MII* : 4 bits, 10/100Mbps

  - Popular mode for 100Mbps interfaces

- `GMII` : *\G*\igabit *MII* : 8 bits, 10/100/1000Mbps

  - Rarely found on PCBs, mostly used within the SoC

- `RGMII` : *\R*\educed *\G*\igabit *MII* : 4 bits,
  10/100/1000Mbps

  - Popular mode for 1Gbps interfaces

- `XGMII` : *X* (Roman Numeral 10) *\G*\igabit *MII*
  : 32 bits, 10Gbps

- `XLGMII` : *XL* (Roman Numeral 40) *\G*\igabit
  *MII* : 32 bits, 40Gbps

  - *XGMII* and *XLGMII* are on-silicon modes, not used on
    PCBs

===  MII flavours - Serial interfaces

- `Cisco SGMII` : *\S*\erialized *\G*\igabit *MII*, 1
  lane, 10/100/1000Mbs

  - _de facto_ standard. Lane always clocked at 1.25GHz

  - Frames are repeated for 10 and 100Mbps

  - Inband signaling : Special word sent on the link to negotiate speed,
    duplex and flow control

- `QSGMII` (Quad SGMII) : Mux 4 different MAC to PHY links on a single
  5Gbps lane

- `USXGMII` : Standard for 10Gbps link. Supports 10/100/1000Mbps,
  2.5/5/10Gbps

  - Implements *rate matching* : The clock speed adjusts to
    follow the link speed

  - Supports multiplexing up to 8 links on the same lane

- `XAUI` and `RXAUI` : Standard, 10Gbps on 4 or 2 lanes, 10b/8b
  encoding.

===  RGMII delay

- RGMII is a popular interface on embedded systems

- Per the specification, *clock* must have a 2ns delay from
  *data*

- This is to ensure data signals have settled when sampled

#v(0.5em)

#align(center, [#image("rgmii_delays.pdf", width: 80%)])

===  RGMII modes

#table(columns: (40%, 60%), stroke: none, gutter: 15pt, [

#align(center, [#image("rgmii_modes.pdf", width: 120%)])

],[

- The delays can be added using different methods :

- Longer PCB lines for the clock

  - Very rarely done

- Most PHYs and some MACs can insert delays internally

  - RGMII-*ID* modes : *\I*\nternal *\D*\elay

  - Preferred solution, delays are adjustable

- Delays may only need to be added in one direction

  - RGMII-TXID : TX delays are internal

  - RGMII-RXID : RX delays are internal

- Some MAC and PHYs have *hardwired* delays

])

===  RGMII modes in devicetree

- `phy-mode` in devicetree : Hardware representation

  - *`phy-mode = "rgmii";`* : No delays need to be added

  - *`phy-mode = "rgmii-id";`* : delays need to be added
    internally

  - *`phy-mode = "rgmii-txid";`* : delays need to be added in
    TX

  - *`phy-mode = "rgmii-rxid";`* : delays need to be added in
    RX

- Internally, these mode are represented as \
  `PHY_INTERFACE_MODE_RGMII[_ID|_TXID|_RXID]`

- The MAC driver reads the mode, and passes it to the PHY driver

- If the MAC inserts delays, it modifies the mode passed to the PHY

  + e.g. `phy-mode = "rgmii-id";`

  + MAC inserts delays in TX, but not in RX

  + MAC passes `PHY_INTERFACE_MODE_RXID` to the PHY

===  MDI - Media Dependent Interface

- A huge number of physical protocols are defined by the 802.3 standard

- As of v6.15,
  #link("https://elixir.bootlin.com/linux/v6.15.1/source/include/uapi/linux/ethtool.h#L1950")[120]
  linkmodes are supported

- They follow a specific naming convention from IEEE 802.3

- #text(fill: blue)[speed]`Band-`#text(fill: purple)[Medium]#text(fill: red)[Encoding]#text(fill:  rgb("#dbab0dc7"))[Lanes]#text(fill: blue)[: 1000]Base-#text(fill: purple)[T], #text(fill: blue)[10G]Base-#text(fill: purple)[K]#text(fill: red)[R], #text(fill: blue)[10]Base-#text(fill: purple)[T]#text(fill: rgb("#dbab0dc7"))[1]…

- Band: `BASE`band, `BROAD`band or `PASS`band.

#table(columns: (80%, 20%), stroke: none, gutter: 15pt, [

- #text(fill: purple)[Medium]

  - Base-*T*: Link over twisted-pair copper cables (Classic
    RJ45).

  - Base-*K*: Backplanes (PCB traces) links.

  - Base-*C*: Copper links.

  - Base-*L*, Base-*S*, Base-*F*: Fiber links.

  - Base-*H*: Plastic Fiber.

],[

  #align(center, [#image("mdi.pdf", width: 80%)])

])
#v(-0.5em)
- #text(fill: red)[Encoding]: Describe the block encoding used by the `PCS`

  - Base-*X*: 10b/8b encoding.

  - Base-*R*: 66b/64b encoding.

- #text(fill:  rgb("#dbab0dc7"))[Lanes]: Number of lanes per link (for Base-*T*, number of
  twisted pairs used).

===  linkmodes

- In 802.3 Clauses 22 and 45, standard registers report the capabilities

- Allows dynamically building the list of MDI modes supported by the PHY

- Done in #kfunc("genphy_read_abilities") and
  #kfunc("genphy_c45_pma_read_abilities")

- PHY drivers can implement their own `phy_driver.get_features()`

- Get the supported linkmodes *on the interface* : `ethtool eth0`

  - Intersection between :

  - what the PHY can do : `phydev->supported`

  - what the MAC can do based on the *mac capabilities*

  - what the in-use *MII* interface can convey

- The *advertised* linkmodes take into account the user settings

===  Interactions between MAC and PHY drivers

- *phylib* provides a simple API for PHY consumers

  - #kfunc("phy_start"), #kfunc("phy_stop"),
    #kfunc("phy_connect")

  - #kfunc("phy_suspend"), #kfunc("phy_resume") for power
    management

- MAC drivers may use that API, however it has some limitations :

  - It can't handle MII reconfiguration

  - It introduces some layering violations : MAC driver access
    `phydev->*` fields

  - It makes it difficult to support other Layer 1 technologies such as
    *SFP*

- #link("https://elixir.bootlin.com/linux/v6.15.1/source/drivers/net/phy/phylink.c")[phylink]
  is a framework that sits between MAC drivers and PHY drivers

- It abstracts away the PHY from the MAC, and provides a feature-full
  set of callbacks for MAC configuration

- It also handles PCS configuration

===  phylib usage in MAC drivers

- MAC drivers that use *phylib* directly call
  #kfunc("phy_connect") to link with the PHY

  - Their `.ndo_open()` calls #kfunc("phy_start") to establish the
    link

  - Their `.ndo_close()` calls #kfunc("phy_stop") to quiesce it

- They register an `.adjust_link` callback to the `phydev` for link
  change notification

#align(center, [#image("phylib_seq.pdf", width: 100%)])

===  phylink

- The phylink framework abstracts the Layer 1 configuration away

- MAC driver can transparently connect to a PHY or an SFP module

- Handles MII reconfiguration, PCS configuration, ethtool
  reconfiguration

- Doesn't superseeds phylib, but complements it for the MAC API

#align(center, [#image("phylink.pdf", width: 100%)])

===  phylink - MAC ops

- MAC driver populate a set of callbacks in
  #kstruct("phylink_mac_ops") registered to phylink

- `.mac_config` : Reconfigure the *MII* mode and parameters,
  *major reconfig*

- `.mac_link_up` : Notify that the link with the partner is
  established

  - Negociated speed, duplex and flow control are passed

  - The MAC should re-adjust its settings, if possible without bringing
    the link down

- `.mac_link_down` : Notify that the link partner is gone

- `.mac_select_pcs` : The MAC returns which
  #kstruct("phylink_pcs") must be used

  - MACs may have
    #link("https://elixir.bootlin.com/linux/v6.15.1/source/drivers/net/ethernet/marvell/mvpp2/mvpp2_main.c#L6468")[multiple PCS],
    chosen based on the MII

- `.mac_enable/disable_tx_lpi` : Configures the *Low Power
  Idle* modes, for *\E*\nergy *\E*\fficient *\E*\thernet

===  phylink - MAC capabilities

- When creating the #kstruct("phylink") instance, the MAC indicates
  its capabilities

- This is done by populating a #kstruct("phylink_config") object

- `mac_capabilities` : indicates all Speeds and Duplex settings
  supported

- `supported_interfaces` : indicates all MII interfaces this MAC can
  output

#v(0.5em)

#text(size: 15pt)[phylink config example]
#v(-0.2em)
#[ #show raw.where(lang: "c", block: true): set text(size: 14pt)
```c
phylink_config.mac_capabilities = MAC_ASYM_PAUSE | MAC_SYM_PAUSE | MAC_10 |
                                  MAC_100 | MAC_1000FD | MAC_2500FD; phy_interface_set_rgmii(phylink_config.supported_interfaces);
__set_bit(PHY_INTERFACE_MODE_MII, phylink_config.supported_interfaces);
__set_bit(PHY_INTERFACE_MODE_GMII, phylink_config.supported_interfaces);
__set_bit(PHY_INTERFACE_MODE_SGMII, phylink_config.supported_interfaces);
__set_bit(PHY_INTERFACE_MODE_1000BASEX, phylink_config.supported_interfaces);
__set_bit(PHY_INTERFACE_MODE_2500BASEX, phylink_config.supported_interfaces);
```]

===  SFP

- *\S*\mall *\F*\ormfactor *\P*\luggable is defined by
  the SFF standards

- It allows having a hot-pluggable *module* that deals with the
  Media side

- Useful for *Fiber* links, but also exists in Copper flavours
  (BaseT or DAC)

- Each module has a standardized behaviour and interface :

  - An *i2c* bus and some GPIOs are used to control the module

  - An *eeprom* is accessible on the *i2c* bus, at address
    `0x50`

  - Its content is standardized, indicating the capabilities, vendor,
    model, etc.

  - Some modules also provide Diagnostics and Montoring over i2c :
    Temperature, Power output, etc.

===  SFP

- The internals of an SFP module are a black box, but some modules may
  have a PHY within

- The PHY may be accessed over the i2c bus, but not always

- If accessible, the embedded PHY can be managed by the kernel

- If the SoC can't output a *serialized* interface, a
  *media converter* can be used

#align(center, [#image("phy_sfp.pdf", width: 60%)])

===  Ethtool reporting

- Userspace can retrieve information reported by the PHY drivers through
  `ethtool`

- Contrary to #kstruct("net_device"), #kstruct("phy_driver")s
  don't implement \ `ethtool ops`

- `phylib` implements the #kstruct("ethtool_phy_ops"), and calls
  into #kstruct("phy_driver")

- The netdev `ethtool_ksettings_get` and `ethtool_ksettings_set`
  have PHY-centric implementation :

  - They report the current link settings : Speed, duplex, linkmodes

  - Also report Link-partner information : The *advertised*
    linkmodes

  - See #kfunc("phylink_ethtool_ksettings_set") and
    #kfunc("phy_ethtool_ksettings_set")

===  PHY reporting with Netlink

#table(columns: (20%, 80%), stroke: none, gutter: 15pt, [

#align(center, [#image("one-media-converter-one-phy-one-mac.pdf", width: 90%)])

],[

- Some hardware topologies may have *more than one PHY* attached
  to a MAC

  - When an SFP module is driven by a PHY, and contains a PHY itself

  - When a PHY is used as a *media converter*

- Netlink requests targeting PHY devices can now be passed a *phy
  index*

  - Implemented by #kfile("drivers/net/phy/phy_link_topology.c")

])