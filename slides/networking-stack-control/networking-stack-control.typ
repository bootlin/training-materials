#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== Control interfaces for the Network Stack

=== Networking stack control path

- The Networking stack is very highly configurable, at all levels :

- Controller and driver behaviour, through `ethtool`, _e.g._ set
  the link speed

- Interface configuration, with `iproute2`, _e.g._ configure the IP
  address

- System-wide configuration, _e.g._ enable IP forwarding

- Per-connection configuration, _e.g._ select the TCP
  congestion-control algorithm

  - The `setsockopts()` syscall is covered later in this training.

=== ioctl interface

- The `ioctl` syscall is used to perform device-specific configuration

- `ioctl()` acts on a *file descriptor*.

  - For hardware configuration, we usually use `ioctl` on `/dev/xxx`
    descriptors

- We don't have any `fd` that corresponds to a specific
  #kstruct("net_device")

- Network admin `ioctl` uses a `fd` corresponding to a *socket*
  with unspecified family : `AF_UNSPEC`

- Any socket *fd* can be used for network ioctls.

#v(0.5em)
#text(size: 15pt)[Example ioctl - Get interface name]
#v(-0.1em)
#[ #show raw.where(lang: "c", block: true): set text(size: 15pt)
  ```c
  struct ifreq ifr;
  ifr.ifr_ifindex = ifindex;
  ioctl (fd, SIOCGIFNAME, &ifr);
  ```]

=== ioctl API

- Network-related `ioctl` have the `SIOC` prefix :

  - _e.g._ #ksym("SIOCGIFNAME") : Returns the name of an
    interface from its index

  - _e.g._ #ksym("SIOCADDMULTI") : Add to the multicast address
    list

  - _e.g._ #ksym("SIOCSHWTSTAMP") : Contigure hardware
    timestamping

- Most of the `ioctl` API is now frozen, and maintained for
  compatibility

- Replaced with `Netlink`, which offers more flexibility

=== sysctl interface

- The *sysctl* parameters are global, kernel-level parameters
  tunable at runtime

- *sysctl* is equivalent to writing into the corresponding files
  under `/proc/sys/`

- e.g. `systcl net.ipv4.ip_forward=1` is equivalent to \
  `echo 1 > /proc/sys/net/ipv4/ip_forward`

- Values can be stored in `/etc/sysctl.d/*.conf`, and loaded with
  `sysctl -p`

- *sysctl* values are per-namespace, inheriting values from the
  `init_net`

- `net.core` : Core and net_device level configuration

  - `sysctl net.core.netdev_budget` : Displays the default NAPI budget

- `net.ipv4` IPv4 and Layer 4 configuration

  - `sysctl net.ipv4.ip_forward` : Allow IP forwarding (Router mode)

  - `sysctl net.ipv4.tcp_fin_timeout` : Set the TCP connection timeout
    (even for IPv6)

- `net.ipv6` IPv6 configuration

=== Netlink interface

- More flexible kernel to userspace communication mechanism, based on
  sockets
  #[ #show raw.where(lang: "c", block: true): set text(size: 16pt)
    ```c
    fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_GENERIC);
    ```]

- Allows easy extension of the userspace API without breaking
  compatibility

- User applications must open a *netlink socket* and send
  specially-formatted messages

- The socket can also be listened to for Kernel to userspace
  notifications

- Netlink messages are grouped into *families*, grouping message
  types per class.

  - routing, ethtool, 802.11, team, macsec, etc.

- Netlink messages have a well-defined and stable format, but
  extensible.

=== Netlink commands

- There are multiple types of Netlink requests based on the
  `nlmsg_flags`

- Commands may be used to Get or Set some kernel attributes

- Netlink `Get` commands can target one or several objects

  - A single object request is a `.doit()` request

    - `ip link show eth0`

  - An object listing request is a `.dumpit()` request

    - `ip link show`

- Netlink also exposes *multicast notifications*

- The message content is made of a set of pre-defined Attributes, based
  on the Command and Family

  - _e.g._ Command `ETHTOOL_MSG_LINKMODES_GET` for family
    "ethtool"

  - Contains `ETHTOOL_A_LINKMODES_SPEED`

=== Netlink monitor

- *Netlink Monitoring* can refer to 2 distinct operations :

- One can listen to *netlink notifications*

  - Emitted by the kernel upon configuration change

  - Applications can listen for specific notifications (Address change,
    link up, etc.)

  - e.g. `ip monitor`, `ethtool –monitor`, etc.

- It is also possible to listen to *All Netlink Traffic*

  - It includes All netlink messages, requests, replies and
    notifications

  - Done through a dedicated virtual interface : `nlmon`

  - e.g. `ip link add name nlmon0 type nlmon`

  - Tools such as `tcpdump` and `wireshark` can be used on the nlmon
    interface

- All these mechanisms still go through network namespaces

=== Configuration serialization in the kernel

- Actions triggered by `ioctl` or `netlink` messages often need
  serialization

  - Some actions impact multiple devices (e.g. netns removal)

  - Actions may be performed on multiple CPUs concurrently

- The main lock used to serialize the configuration is the *rtnl
  lock*

  - Global #kstruct("mutex"), taken with #kfunc("rtnl_lock") and
    released with #kfunc("rtnl_unlock")

  - *\R*\ou*\T*\ing *\N*\et*\L*\ink

- `net_device.lock` : Mutex to protect _some_ of the
  #kstruct("net_device") fields

  - Very recent feature, introduced in `v6.14`

- The list of #kstruct("net_device") is protected by RCU

- All #kstruct("net_device") instances are reference-counted and
  reference-tracked

=== The RTNL lock

- Sometimes the Network Stack's Big Kernel Lock

  - Its scope is slowly getting removed, replaced with more specific
    locks

- Serializes most NDOs that aren't on the datapath

  - e.g. it does not protect `.ndo_start_xmit()`.

- Also serializes most #kstruct("ethtool_ops")

- Protects some of the #kstruct("net_device") fields

- For now, RTNL is *not* per-namespace, it is global. This is
  being reworked.

- Functions that rely on the caller holding rtnl often use
  #kfunc("ASSERT_RTNL")

- It is a `mutex` :

  - It is possible to sleep while holding rtnl

  - rtnl cannot be used when sleeping is forbidden (e.g. interrupt and
    softirq context)

=== Using Netlink in the kernel

- A new family can be registered by registering a
  #kstruct("genl_family")

- This allows registering custom messages and associated handlers

  - e.g the
    #link(
      "https://elixir.bootlin.com/linux/v6.15.2/source/drivers/net/macsec.c#L3360",
    )[macsec family]

- Existing families already provide layers of abstractions :

  - The #kstruct("rtnl_link_ops") is used for virtual netdev types

  - The
    #link("https://elixir.bootlin.com/linux/v6.15.2/source/net/ethtool")[ethnl]
    abstraction is used for ethtool commands

=== #kstruct("netlink_ext_ack")

- #kstruct("netlink_ext_ack") allows reporting error messages to
  userspace

- It is included as part of the reply to netlink requests

- It can be found passed as a parameter to numerous internal kernel
  function

#v(0.5em)

#[ #show raw.where(lang: "c", block: true): set text(size: 13pt)
  ```c
  int dsa_port_mst_enable(struct dsa_port *dp, bool on, struct netlink_ext_ack *extack)
  {
          if (on && !dsa_port_supports_mst(dp)) {
                  NL_SET_ERR_MSG_MOD(extack, "Hardware does not support MST");
                  return -EINVAL;
          }

          return 0;
  }
  ```]

=== Userpace libraries

- #link("https://www.netfilter.org/projects/libmnl/index.html")[libmnl]:
  Simple and lightweight library to access netlink

  - Used by `nftables`, `iproute2` and `ethtool`

- #link("https://www.infradead.org/~tgr/libnl/")[libnl]: Higher level of
  abstraction but bigger binary

  - Useful for programs that "just work"

=== Userspace tooling

- *iproute2*

  - `ip` : Configure and query interfaces, routing and tunnels

  - `bridge` : Configures bridges (switching)

  - `tc` : Configures traffic control policing, shaping and filtering

  - `dcb` : Configures "Data Center Bridging" for traffic
    prioritization

  - These tools use the *Netlink* API

- *net-tools*

  - Obsolete ! replaced by *iproute2*

  - `ifconfig` : Configure interfaces (replaced by `ip`)

  - `brctl` : Configure bridges (replaced by `bridge`)

- *ethtool*

  - Used to configure Ethernet devices.

  - Can be compiled with `ioctl` or `netlink` support.

=== Userspace tooling - 2

- *NetworkManager*

  - Automatic configuration of interfaces based on config files

  - Handles IP assignment, low-level parameters

  - Very featureful, but bigger binary

  - Exposes a DBus API to interact with other software

  - See #manpage("NetworkManager", "8")

- *Connman*

  - Alternative to NetworkManager, more embedded-oriented and
    lightweight

  - Also uses DBus to communicate with other software

- *Systemd-networkd*

  - Network configuration tool provided by SystemD

  - `.network` files are used to describe interfaces

  - See #manpage("systemd-networkd", "8")

=== C library

- The "Standard" C library exposes a few helper functions to
  manipulate Network features

- `if_nametoindex`: Get the `ifindex` of a given interface

- `if_indextoname`: Get the name of an interface from its `index`

  - Can use either netlink or `ioctl`

- `inet_aton`, `inet_addr`: Convert IP address from string to binary

- `htons`, `ntohs`, `htonl`, `ntohl`: Endianness conversion

  - On most protocol headers, data is sent in *big endian* format

  - Also referred-to as Network Byte Order

  - *\h*\ost *to* *\n*\etwork *\s*\ort /
    *\l*\ong
