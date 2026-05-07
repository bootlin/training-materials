#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== Switch drivers

=== Ethernet switches in Linux

- The *switchdev* framework allows configuring the
  *switching fabric*

- Switch ports are represented as regular `net_device`
#v(0.5em)
#align(center, [#image("switches.pdf", width: 60%)])

=== Ethernet switches in Linux

- By default, without any further configuration, each port is
  *independent*

- As each port has their `net_device`, they have their own
  `net_device_ops`

- Non-DSA switches are just regular Ethernet drivers, with extra logic
  for switchdev

- DSA switches have their ports handled by the
  #link(
    "https://elixir.bootlin.com/linux/v6.15.2/source/net/dsa/port.c",
  )[DSA port]
  infrastructure

  - Implements the `.ndo_start_xmit`

=== Switchdev

#table(
  columns: (40%, 60%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("switchdev.pdf", width: 100%)])

  ],
  [

    - *switchdev* is a framework allowing drivers to implement
      switching configuration ops

    - Bridging, VLANs, filtering, queueing, redirection, snooping, etc.

    - The hardware *must* be able to report internal reconfiguration
      events

  ],
)

=== Notifiers

- Drivers don't implement any kind of `switchdev_ops`

  - Switch-related events don't specifically target a single `netdev`

- Drivers instead subscribe to *kernel notifications* through
  `notifiers`

- Userspace bridging configuration triggers reconfiguration events

  - #ksym("NETDEV_CHANGEUPPER") : A `netdev` has a new `upper_dev`

  - #ksym("BR_STATE_FORWARDING") : A `bridge port` is set in
    forwarding state

- The switch reports internal events, that the driver notifies to the
  kernel

  - #kfunc("call_switchdev_notifiers")

=== Switchdev notifiers - example

#text(size: 15pt)[switchdev example]
#v(-0.2em)
```c
static int adin1110_switchdev_event(struct notifier_block *unused,
                                    unsigned long event, void *ptr)
{
    if (!adin1110_port_dev_check(netdev))
        return NOTIFY_DONE;

    switch (event) {
    case SWITCHDEV_FDB_ADD_TO_DEVICE:
    case SWITCHDEV_FDB_DEL_TO_DEVICE:
        /* Add item to FDB */
    }

    return NOTIFY_DONE;
}

static struct notifier_block adin1110_switchdev_notifier = {
    .notifier_call = adin1110_switchdev_event,
};

static int adin1110_setup_notifiers(void)
{
    register_switchdev_notifier(&adin1110_switchdev_notifier);
}
```

=== Switchdev notifications

- `NETDEV_CHANGEUPPER` : A `netdev` was added to or removed from a
  bridge

- `SWITCHED_FDB_ADD_TO_DEVICE` : A FDB entry was added by user

- `SWITCHED_PORT_OBJ_ADD` : Generic notifier to add an entry to a
  port

  - `SWITCHDEV_OBJ_ID_PORT_VLAN` : A port belongs to a VLAN

  - `SWITCHDEV_OBJ_ID_PORT_MDB` : Add a Multicast address to a port

- Drivers notify the kernel when the operation could be offloaded

  - _e.g._ `call_switchdev_notifiers(SWITCHDEV_FDB_OFFLOADED, ndev, &info.info, NULL);`

=== DSA

#align(center, [*\D*\istributed *\S*\witch *\A*\rchitecture])
#table(
  columns: (20%, 80%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("DSA.pdf", width: 100%)])

  ],
  [

    - Mainly used by dedicated switch chips

    - One or more ports are connected to SoC interfaces

    - DSA switches may be chained together

    - The CPU to Switch link is called the *cpu conduit* or
      *cpu port*

    - Switch to Switch links are called *dsa conduits*

    - Other interfaces are called *user* ports

    - Frames on *conduits* are often *tagged* to identify the
      destination port

    - DSA *uses* switchdev, and does not replace it

  ],
)

=== DSA tagging

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("dsa_tagging.pdf", width: 100%)])

  ],
  [

    - A vendor-specific TAG is added to the frame

    - It contains the identifier of the egress port

    - The frame is sent from the CPU to the switch

    - The switch strips the tag and sends it to the port

    - The opposite happens on receive

  ],
)

=== DSA in devicetree

#table(
  columns: (60%, 40%),
  stroke: none,
  gutter: 15pt,
  [

    ```dts
    &mdio {
      switch0: ethernet-switch@1 {
        compatible = "marvell,mv88e6085";
        reg = <1>;

        dsa,member = <0 0>;

        ethernet-ports {
          #address-cells = <1>;
          #size-cells = <0>;
          [...]
        };
      };
    };
    ```

  ],
  [

    - *reg* : Address on the MDIO bus

    - *dsa,member* : Position in the *cluster*, if applicable

    - *ethernet-ports* : Contains the list of ports

  ],
)

=== DSA Ports in devicetree

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [

    #text(size: 13pt)[
      ```dts
          ...
          ethernet-ports {
            switch0port0: ethernet-port@0 {
              reg = <0>;
              label = "cpu";
              ethernet = <&eth0>;
              phy-mode = "rgmii-id";
              fixed-link {
                speed = <1000>;
                full-duplex;
              };
            };

            switch0port1: ethernet-port@1 {
              reg = <1>;
              label = "wan";
              phy-handle = <&switch0phy0>;
            };

            switch0port2: ethernet-port@2 {
              reg = <2>;
      ^^Ilink = <&switch1port0>;
            };

            ...
          };
          ...
      ```]

  ],
  [

    - *reg* : Port number

    - *label* : Port name, will become the interface name

    - *ethernet* : phandle to the CPU-side MAC interface

    - *link* : phandle to another DSA switch's port, for cascading

    - PHY mode and phandle

  ],
)

=== Tagging

- Tagging happens outside of the switch driver, in a dedicated tagger : \
  `net/dsa/tag_*.c`

- Some switches support multiple tagging formats

  - It can be specified in *devicetree*

#v(0.5em)

#text(size: 15pt)[DSA tagger]
#v(-0.2em)
#[ #show raw.where(lang: "c", block: true): set text(size: 16pt)
  ```c
  static const struct dsa_device_ops foo_ops = {
      .name = "foo",
      .proto = DSA_TAG_PROTO_FOO,
      .xmit = foo_tag_xmit,
      .rcv = foo_tag_rcv,
      .needed_headroom = FOO_HDR_LEN,
      .promisc_on_conduit = true,
  };
  ```]

=== Chaining

- Some DSA switches can be daisy-chained

- The ports that link switches together have no associated `net_device`

#align(center, [#image("chained.pdf", width: 100%)])
