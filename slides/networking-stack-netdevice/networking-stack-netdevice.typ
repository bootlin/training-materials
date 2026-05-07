#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== Network Devices

===  Network devices in Linux

- In UNIX systems, the common saying is that "_everything is a
  file_"

- Most classes of devices follow that rule, and expose *block*
  and *char* devices in `/dev`

  - `/dev/mmcblk0` : eMMC device 0

  - `/dev/i2c-3` : I2C bus number 3

  - `/dev/input/*` : HID devices

- Network devices don't follow that rule, as they are rarely directly
  accessed

- The Linux Kernel provides access to Layers 2, 3 and 4 through the
  *socket* API

- Network devices appear as *interfaces* under `/sys/class/net`

- The `sysfs` API is only for limited control and device information

===  `struct net_device`

- The #kstruct("net_device") structure represents a conduit

- Used for *physical* interfaces and *virtual* interfaces

- Abstract interfaces can be used for *vlan*, *bridging*,
  *tap*, *veth*, etc.

- Every #kstruct("net_device") object can transmit and receive
  packets :

  - Physically, in which case it is managed by a device driver

  - or Logically, by passing them to another component in the stack
    after potentially altering them

- Instances of #kstruct("net_device") are often called `netdev` in
  the Documentation

- Variables of that type are usually named `dev`

  - Unfortunately, this is als the usual name of #kstruct("device")
    objects

===  `struct net_device` (2)

- Userspace sees a `netdev` as an *interface*

  - Listed with `ip link show` or `ifconfig`

  - Also appearing under `/sys/class/net/`

- Interfaces have a *name*, which may change

- Interfaces also have an index (*ifindex*) that uniquely
  identifies them

- They have attributes, changeable or not, depending on their type :

  - Addresses : IPv4, IPv6, MAC, etc.

  - Properties : MTU, Queue length, etc.

  - Statistics : RX/TX packets, link events, etc.

  - State : Link up or down, admin state, Promiscuous, etc.

===  Network driver

- Creating a new Network Interface driver is similar to any other driver
  :

- The driver registers a *device driver* on its underlying bus :

  ```c
  static const struct of_device_id mvneta_match[] = {
          { .compatible = "marvell,armada-3700-neta" },
          { }
  };

  static struct platform_driver mvneta_driver = {
          .probe = mvneta_probe,
          .remove = mvneta_remove,
          .driver = {
                  .name = MVNETA_DRIVER_NAME,
                  .of_match_table = mvneta_match,
          },
  }; module_platform_driver(mvneta_driver);
  ```

- In the `.probe()` function, allocate a #kstruct("net_device") :

  ```c
  dev = devm_alloc_etherdev_mqs(&pdev->dev, sizeof(struct mvneta_port),
                                txq_number, rxq_number);
  ```

- The `netdev` is *registered* to the networking subsystem :

  ```c
  register_netdev(dev);
  ```

===  Reminder - Device Model and Device Drivers

#table(columns: (65%, 38%), stroke: none, [

In Linux, a driver is always interfacing with:

- a *framework* that allows the driver to expose the hardware
  features in a generic way.

- a *bus infrastructure*, part of the device model, to
  detect/communicate with the hardware.

],[

#align(center, [#image("driver-architecture.pdf", height: 80%)])

])

===  Netdevice allocation

- #kfunc("alloc_netdev_mqs") : Main allocation function :

  ```c
  struct net_device *
  alloc_netdev_mqs(int sizeof_priv,                /* Size of driver-dedicated private data area */
                   const char *name,               /* Default name of the device */
                   unsigned char name_assign_type, /* Category of device name assignment */
                   void (*setup)(struct net_device *), /* Setup callback function */
                   unsigned int txqs,              /* Number of TX queues */
                   unsigned int rxqs);             /* Number of RX queues */
  ```

- The `setup` callback is called directly by
  #kfunc("alloc_netdev_mqs")

- #kfunc("free_netdev") is used to destroy the netdevice

- *device-managed* variants exist :
  #kfunc("devm_alloc_etherdev_mqs")

===  Netdevice naming

- Netdevice names can be changed dynamically, and the name source is
  tracked

- `dev->name_assign_type`, exposed in
  `/sys/class/net/xxx/name_assign_type`

- `NET_NAME_ENUM` : Name built sequentially by the kernel

  - e.g. `eth0, eth1`, etc.

- `NET_NAME_PREDICTABLE` : Name predictably assigned by the kernel

  - e.g. `label="lan1"` in devicetree for DSA switches

- `NET_NAME_USER` : Name assigned by the user during device creation

  - e.g. `ip link add link eth0.10 type vlan id 10`

- `NET_NAME_RENAMED` : Device was renamed by userspace

  - e.g. `ip link set dev eth0 name new-eth0`

  - Used by systemd's
    #link("https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/")[Predictable Network Interface Names]

===  Ethernet-specific device allocation

- #kfunc("alloc_etherdev_mqs") : Allocate a new
  #kstruct("net_device") for Ethernet :

- Sets the number of queues passed as parameters

- Creates a default name using the `"eth%d"` template

- Sets all the Ethernet-specific default parameters :

  - MTU, Header len, Address len, etc.

===  Netdev ops

- Before registering, the driver populates a
  #kstruct("net_device_ops")

  #text(size: 15pt)[mvneta.c - simplified]
  #v(-0.1em)
  ```c
  static const struct net_device_ops mvneta_netdev_ops = {
          .ndo_open            = mvneta_open,
          .ndo_stop            = mvneta_stop,
          .ndo_start_xmit      = mvneta_tx,
          .ndo_set_mac_address = mvneta_set_mac_addr,
          .ndo_change_mtu      = mvneta_change_mtu,
  ...
  };

  static int mvneta_probe(struct platform_device *pdev)
  {
          ...
          dev->netdev_ops = &mvneta_netdev_ops;

          register_netdev(dev);
  }
  ```

- These hooks are referred to as *\NDO*\s

- `.ndo_start_xmit` must be populated, all other are optional.

===  Common NDOs

- `.ndo_open` and

- `.ndo_stop` : Bring the interface UP or DOWN

  - Call when using `ip link set eth0 up/down`

- `.ndo_start_xmit` : Send a packet

- `.ndo_set_rx_mode` : Configure the *rx filtering*

- `.ndo_set_mac_address` : Notify the driver that the MAC address was
  changed

- `.ndo_get_stats64` : Ask for hardware or driver statistics

- `.ndo_eth_ioctl` : Device-level `ioctl` handler, phased-out.

===  Netdev registration

- #kfunc("register_netdevice") : Registers the
  #kstruct("net_device"), in the `netdev->net` namespace

  - Allocates the interface index

  - Makes the device visible from userspace

  - From this point on, NDOs may be called

  - Assumes `RTNL` is held.

  - `.ndo_init` is called at that stage, if provided

- #kfunc("register_netdev") : Calls #kfunc("register_netdevice")
  with RTNL held

  - Used mostly in drivers, as the device driver's `.probe()` doesn't
    hold RTNL

===  Stacking Network Devices

#[ #set list(spacing: 0.3em)

- Netdevices can be independent conduits, or stacked in a hierarchy

- e.g. a VLAN is represented as a dedicated `netdev`

  - A VLAN netdev's `lower_dev` is the physical device

  - The physical netdev's `upper_dev` is the VLAN device

- #kstruct("net_device") has a list of `lower_dev` and `upper_dev`

- Packets may be passed between netdevs, which may modify them, e.g.

  - Encapsulation and Decapsulation (VLANs, tunnels)

  - Redirection and Routing (bridges)

  - Duplication and Redundancy (hsr, bond)

  - Encryption (macsec, wireguard)

- Can also be virtual interfaces, such as `veth`, `tun` and `tap`

#v(0.5em)

#align(center, [#image("vlan_uplow.pdf", width: 30%)])

]

===  Stacking Network Devices - 2

- Stacked devices show in userspace as `dev@lower`

  - _e.g._ DSA ports show as `lan1@eth0`

  - DSA uses stacking for the *conduit* interface

- The relationship is declared by calling :
  #[ #show raw.where(lang: "c", block: true): set text(size: 15pt)
  ```c
  int netdev_upper_dev_link(struct net_device *dev,
                            struct net_device *upper_dev,
                            struct netlink_ext_ack *extack)
  ```]

- A `netdev` can also have a `master` device

  - Similar to *upper*, except a `netdev` can only have one
    master

  - Used for *bridges*

  - `ip link set dev eth0 master br0`

===  Network Namespaces

- Netdevs can only view and pass traffic to other netdevs in the same
  *namespace*

- Net Namespaces, or *netns*, are represented internally by
  #kstruct("net")

- A `netns` is created using `netlink`, e.g. through `iproute2` :

  - `ip netns add new_netns`

- Network namespace have their own set of resources :

  - Routing tables, ARP tables, caches, pools of memory, identifier
    pools...

- Netdevs are *moved* to a `netns` with `ip link set dev eth0
  netns new_netns`

- All `netns` contain a *loopback* interface named `lo`, created
  when netdev is added to the netns

- Dedicated mechanisms such as *veth pairs* must be used for
  inter-netns communication

- Used by Containers for isolation

===  Network Namespaces - 2

- User processes run within a given *netns* and cannot see other
  interfaces

  - `ip netns <ns> exec <cmd>` : Run `cmd` in the `ns` namespace

- By default, netdevs are created in the *init_ns*

#v(0.5em)

#align(center, [#image("netns.pdf", width: 60%)])

===  `veth` : Virtual Ethernet Pairs

- `ip link add type veth` : creates `veth0@veth1` and `veth1@veth0`

- Both `veth0` and `veth1` are linked together, traffic flows between
  the 2

- Main way to traverse namespaces, heavily used by containers

#v(0.5em)

#align(center, [#image("veth.pdf", width: 60%)])

===  Bridges

#align(center, [#image("bridge.pdf", width: 40%)])

- A *bridge* represents a logical switch.

- If there is a hardware switch, its ports should act as
  *standalone* interfaces

  - A logical switch corresponding to the hardware can be re-created

  - switching operations can be *offloaded* in hardware with
    *switchdev*

- Bridges are represented with their own #kstruct("net_device")

  - Created with `ip link add name br0 type bridge`

  - It acts as the *master* of all the switch ports

  - Ports are added with ip link set dev lan0 master br0

- The bridge interface maintains the `fdb` and handles forwarding

===  Vlan

- Multiple types of Vlans are supported in Linux through dedicated
  drivers

- 802.1Q : Layer 2 tag-based VLANs

  - `ip link add link eth0 name eth0-100 type vlan id 100`

- 802.1AD (Q in Q) : Allows using Vlans within Vlans, with multiple tags

  - `ip link add link eth0 name eth0-100 type vlan id 100 protocol 802.1ad`

- VxLAN : VLAN using UDP encapsulation

  - `sudo ip link add link eth0 name vxlan100 type vxlan id 100` \
    `local 192.168.42.1 remote 192.168.42.2`

- MACVlan : Virtual interface with a different MAC address than the
  physical one

  - `ip link add macvlan1 link eth0 type macvlan mode bridge`

  - Used a lot by containers

===  tun and tap interfaces

#table(columns: (45%, 55%), stroke: none, gutter: 15pt, [

#align(center, [#image("tuntap.pdf", width: 100%)])

],[

- Create virtual interfaces where a userspace program feeds and receives
  data from the `netdev`

  - Data is sent and received by accessing `/dev/net/tun`

- Used for userspace tunnel implementations, such as VPNs

- `ip tuntap add dev tun0 mode tun`

- `ip tuntap add dev tap0 mode tap`

])