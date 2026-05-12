#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Network device drivers

=== NIC and MAC

- Terms *NIC* and *MAC* are sometimes used interchangeably

- *\N*\etwork *\I*\nterface *\C*\ontroller, usually refers to "Network Cards"

  - MAC and PHY integrated in a single component. Usually, the PHY is
    transparent

- On embedded systems, we control each individual component

#align(center, [#image("nic.pdf", width: 75%)])

=== Low level networking components

- Multiple drivers are involved to configure a Network Interface

- Not all of them are required (depending on the design)

- Some MAC drivers also include DMA, Serdes, PCS and even PHY drivers

#align(center, [#image("net_drivers.pdf", width: 75%)])

=== Low level networking components - MAC

#table(
  columns: (30%, 70%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("net_components_mac.pdf", width: 100%)])

  ],
  [

    - The main component of a network interface

    - Represented by #kstruct("net_device")

    - Drivers are in #kdir("drivers/net/ethernet")

    - In charge of *Sending* and *Receiving* frames

    - Configures all the *Hardware offloaded* features

    - Reports status and statistics

    - Some devices include a PCS, Serdes, MDIO, PHY, DMA and even a Switch
      controller in the MAC

      - The single MAC driver handles it all

  ],
)

=== Low level networking components - DMA

#table(
  columns: (30%, 70%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("net_components_dma.pdf", width: 100%)])

  ],
  [

    - Some MAC controllers are connected to a shared *DMA Controller*

    - The controller handles DMA transfers for multiple devices

    - The MAC requests #kstruct("dma_chan") for TX and RX

      - This is done using the *dmaengine* API

    - Drivers are in #kdir("drivers/dma")

    - It is not unusual to have MAC with an integrated DMA controller

      - In that case, we don't use the dmaengine API

  ],
)

=== Low level networking components - PCS

#table(
  columns: (30%, 70%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("net_components_pcs.pdf", width: 100%)])

  ],
  [

    - *\P*\hysical *\C*\oding *\S*\ublayer

    - Represented by #kstruct("phylink_pcs")

    - Drivers in #kdir("drivers/net/pcs")

    - Component in charge of Data Encoding

      - For signal integrity, bits are encoded into symbols

      - At 100Mbps : 4 bits data, 5 bits symbols (4b/5b)

      - At 1000Mbps : 8b/10b

      - At 10Gbps : 64b/66b

    - Also in charge of in-band signaling

      - Link status, speed, duplex, flow-control

    - Can be transparently handled by the MAC (no driver)

    - The MAC driver may register its own PCS instance(s)

    - Some IPs are re-used across vendors, dedicated drivers are then used

  ],
)

=== Low level networking components - Generic PHY

#table(
  columns: (30%, 70%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("net_components_serdes.pdf", width: 100%)])

  ],
  [

    - Generic PHY, driving the physical link that comes out of the MAC

    - Represented by #kstruct("phy")

    - Drivers in #kdir("drivers/phy")

      - Not to be confused with #kdir("drivers/net/phy")

    - Usually drives *SerDes* lanes if the MAC interface is serialized

    - Also used by other subsystems : USB, PCI, Sata, etc.

    - Controls the physical link parameters

      - Drive strength

      - Timings

      - link training, etc.

    - Sometimes transparently handled by the MAC without a dedicated driver

  ],
)

=== Low level networking components - MDIO

#table(
  columns: (26%, 74%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("net_components_mdio.pdf", width: 110%)])

  ],
  [

    - *\M*\anagement *\D*\ata *\I*\nput *\O*\utput

      - a.k.a. *SMI* : *\S*\erial *\M*\anagement *\I*\nterface

      - a.k.a. *MIIM* : *\M*\edia *\I*\ndependent *\I*\nterface *\M*\anagement

    - Bus controller represented by #kstruct("mii_bus")

    - Peripherals represented by #kstruct("mdio_device")

    - Drivers in #kdir("drivers/net/mdio")

    - Management bus for most Ethernet PHYs and DSA Switches

      - Only bus for PHYs

      - Some DSA switches can be controlled by SPI or I²C

    - Provides ways to access registers, physically similar to I²C

    - Often controlled by the MAC driver, but can be standalone

  ],
)

=== Low level networking components - Switch

#table(
  columns: (30%, 70%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("net_components_switch.pdf", width: 100%)])

  ],
  [

    - DSA Switches are standalone chips, with one or more ports connected to
      the SoC's MAC

      - *\D*\istributed *\S*\witch *\A*\rchitecture

      - Relies on
        #link("https://docs.kernel.org/networking/switchdev.html")[switchdev]
        for the switching operations

    - Switches can also be integrated within the SoC

      - The MAC driver implements the switchdev operations

    - DSA switch represented by #kstruct("dsa_switch")

    - DSA switch port represented by #kstruct("dsa_port")

    - Switch port represented by #kstruct("net_device") (even for DSA)

    - Drivers in #kdir("drivers/net/dsa") and \
      #kdir("drivers/net/ethernet")

  ],
)

=== Low level networking components - Ethernet PHY

#table(
  columns: (30%, 70%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("net_components_phy.pdf", width: 100%)])

  ],
  [

    - In charge of 802.3 Layer 1 (PHY) operations

    - Represented by #kstruct("phy_device")

    - Drivers in #kdir("drivers/net/phy")

    - Specific to MDIO PHYs, as per the 802.3 specification

    - In charge of link management :

      - Auto-negotiation of Speed and Duplex

      - Link detection

    - A generic driver exists using only standard registers

    - The PHY management framework is called *phylib*

  ],
)
