#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Introduction - Networking Technologies

===  OSI Model

#table(columns: (20%, 80%), stroke: none, gutter: 15pt, [

#align(center, [#image("osi.pdf", width: 90%)])

],[

- *\O*\pen *\S*\ystems *\I*\nterconnection

- Reference model to design network protocols, created in the late 1970s

- Defines 7 *layers*, with specific functions and semantics

- Each layer relies on the layer below, and provides features to the
  layer above

  - In practice, this is done through *encapsulation*

  - Each layer adds its required data to the front of the data array

    - This is the layer's *header*

  - A Layer N's header is part of Layer N-1's payload

])
===  OSI layer communication

#table(columns: (20%, 80%), stroke: none, gutter: 15pt, [

#align(center, [#image("osi_encap.pdf", width: 120%)])

],[

- The payload sent by a layer targets the same layer on the receiving
  end

- Each layer only cares about its specific header and treats the payload
  as a *black box*

- When the *peer* receives it, it *decapsulates* the
  received data

- Every layer has its own semantics about the data it manipulates

- Every layer's unit is called *\P*\rotocol *\D*\ata
  *\U*\nit

- Every layer has a *\M*\aximum *\T*\ransmit *\U*\nit per
  PDU

])

===  Layer 1 - PHY Layer

- Defines how data is sent to a peer trough a *physical medium*

- PDU is *symbols* and *bits*

- IEEE 802.3 "Ethernet" defines a lot of Layer 1 technologies

  - 1000BaseT4 : Transmit data at 1000Mbps over 4 twisted copper pairs

  - 1000BaseFX : Transmit data at 1.25Gsps / 1Gbps over an optics fiber

  - 10BaseT1S : Transmit data at 10Mbps over a single twisted copper
    pair

  - Ethernet protocols may use the same medium

    - Protocol selection can be done through *autonegotiation*

    - Link detection is done by sending *Idle* words

- IEEE 802.11 "Wifi" also defines Layer 1 technologies using
  2.4/5/60GHz radio modulation

- Many more exists : IEEE 802.15.4, "Bluetooth", NFC, etc.

- Usually handled by a dedicated hardware component : a *PHY*

===  Layer 2 - Data Link Layer

- Sometimes called *MAC* layer

- PDU is a *Frame*

- In charge of Point-to-point communication

- IEEE 802.3 "Ethernet" defines a Layer 2 standard as well

  - Source address, Destination address, Layer 3 type

- IEEE 802.11 "Wifi" also defines a Layer 2

  - 2, 3 or 4 addresses

  - Receiver, Transmitter, Source and Destination

===  Ethernet - Layer 2

#[ #set list(spacing: 0.4em)

#align(center, [#image("ethernet_frame.pdf", width: 70%)])

- Point-to-point *frames* are sent on the medium, separated by a
  *gap*

- Regardless of the speed and medium, frames have the same structure :

  - 7 bytes *Preamble*: Used to synchronize both equipment

  - 1 byte *SFD* (Start Frame Delimiter): Ends the preamble

  - 6 bytes *Destination address*, identifying the destination
    equipment

  - 6 bytes *Source address*, identifying the source equipment

  - 2 bytes *ethertype*, identifying the encapsulated protocol

  - A *payload*

  - 4 trailing bytes *FCS* (Frame Check Sequence): Checksum of
    the frame

- Each frame must be separated by at least 12 bytes, named the
  *\I*\nter *\P*\acket *\G*\ap

- _header_ + _payload_ + _fcs_ ≤ 1522 bytes, the
  payload's size is at most *1504 bytes*

- _header_ + _payload_ + _fcs_ ≥ 64 bytes, the
  payload must be _zero-padded_ otherwise

]

===  Network Bridging

- A *Network bridge* is a Layer 2 device interconnecting multiple
  network segments

- We usually use a dedicated *Network Switch* for this purpose

  - Using a *ASIC* chip

  - Using a software implementation

- Ethernet switches are usually *transparent switches*

  - They monitor Layer 2 header to *learn* the Port to Address
    association

  - This is stored in the FDB : *\F*\orwarding
    *\D*\ata*\B*\ase

- Some switches can be highly configurable, and support s

===  Transparent bridge

#table(columns: (30%, 70%), stroke: none, gutter: 15pt, [

#align(center, [#image("transparent_bridge.pdf", width: 110%)])

],[

- Ports are monitored, the *source address* saved

- The *destination address* is looked-up

- If no match is found, the frame is *flooded* on all ports

- Advanced switches can do *port mirroring*

  - Duplicate traffic going forwarded a port to another port

  - Used for administration and troubleshooting

])

===  VLANs

#table(columns: (30%, 70%), stroke: none, gutter: 15pt, [

#align(center, [#image("vlan_topo.pdf", width: 110%)])

],[

- *\V*\irtual *\L*\ocal *\A*\rea *\N*\etwork

- Multiple VLAN technologies exist:

  - 802.1Q (_dot1q_): Layer 2

  - 802.1AD (_QinQ_): Layer 2

  - VxLan : Layer 4 (UDP)

  - MACVlan : Based only on MAC addresses

- Logical segmentation of the network

- Used for isolation, prioritization and bandwidth optimization

- The same conduit can be used to convey multiple VLANs

  - We talk about a *trunk* interface

  - Frames are *tagged* to indicate the VLAN it belongs to

])

===  VLAN - 802.1Q
#align(center, [#image("ethernet_frame_vlan.pdf", width: 80%)])

- A 802.1Q frame has included an extra *4 bytes* tag in the
  Ethernet header

- The *ethertype* is set to `0x8100`, the real ethertype is
  stored after the tag

- A 16-bit value identifies the Tag : *\T*\ag *\C*\ontrol
  *\I*\nformation

  - 3 bits indicate a *priority*, between 0 and 7

    - Also called *\C*\lass *\O*\f *\S*\ervice

  - 1 bit for the *\D*\rop *\E*\ligible *\I*\ndicator

  - 12 bits represent the ID of the vlan, between 1 and 4094

    - ID 0 means *no tag*, only the priority is considered

    - ID *4095* is reserved.

===  Layer 3 - Network Layer

- PDU is *packet* or *Segment*

- Handles routing between multiple machines

- Defined by *subnets*, linked tothegher by *routers*

- Main technologies are *IPv4* and *IPv6*

  - IPv4 : 32-bit addresses, IPv6 : 128-bit addresses

- Layer 2 to Layer 3 addresses can be associated

  - e.g. the *\A*\ddress *\R*\esolution *\P*\rotocol

  - MAC to IP tables are named *ARP* or *neighbouring*
    tables

- Layer 3 can perform *fragmentation*

  - e.g. if an IPv4 packet is too big to fit within the Ethernet MTU, it
    is split into multiple IPv4 packets

  - each packet is individually routable

  - Re-assembly is done by the peer

===  Transport Layer

- Communication between endpoints over a routed network

  - _e.g._ Multiple applications on the same machine

  - Each end-point is further identified within the host

  - on TCP and UDP, *ports* are used

- TCP : Connection-oriented, reliable, guarantees ordering.

  - Stream of data, boundaries may be preserved

- UDP : Connection-less, not reliable, no ordering guarantee

  - Sends datagrams with clear boundaries

- QUIC : Based on UDP, introduced by Google. Connection-oriented,
  reliable, guarantees ordering

  - Can batch Acknowledgments, supports encryption

===  Tunneling

#table(columns: (30%, 70%), stroke: none, gutter: 15pt, [

#align(center, [#image("wireguard.pdf", width: 80%)])

],[

- Encapsulate a Lower-level layer into a higher one

- Used to virtualize networks (e.g. VXLAN is Ethernet over UDP)

- Also used for encryption (IPSec, Wireguard, OpenVPN)

  - _e.g._ Wireguard Encrypts and encapsulates IP packets into UDP
    packets

- There may therefore be more headers to decapsulate than there are OSI
  layers

])

===  Layers 5, 6 and 7

- Session : Handles the connection, authentication and lifetime of data
  exchanges

  - _e.g._ RPC, SOCKS

- Presentation : Handles data conversion and serialization for
  interoperability

  - _e.g._ character transcoding depending on the locale

  - _e.g._ serializing user data in `JSON` or `XML`

- Application : Communication between user applications

  - _e.g._ HTTP for Web applications

- _less relevant for this training, as they aren't handled by the
  linux kernel_


= The Linux Kernel Networking Stack
<the-linux-kernel-networking-stack>

===  The Linux Kernel Networking Stack

#table(columns: (65%, 35%), stroke: none, gutter: 15pt, [

#align(center, [#image("stackmap.pdf", width: 100%)])

],[ 

As of v6.16-rc1 :

- over 209000 commits

- over 7750 files

- over 993000 LoC

- around 100 maintainers

- Around 880 drivers (Layer 2)

])

===  Some history

- First support was introduced in v0.96 (may 1992) !

- Already exposing a socked-based API

- IPv4 : v0.98 - September 1992

- TCP/UDP : v0.98 - September 1992

- IPv6 : v2.2 - January 1999 (IPv6 was created in 1998)

- BPF : v2.5 - 2003, was then known as *\L*\inux *\S*\ocket
  *\F*\iltering

  - eBPF : v3.15 - June 2014

- PHYlib : v2.6.13 - August 2005, before that PHYs were handled in MAC
  drivers

- XDP : v4.8 - September 2016

- phylink : v4.13 - September 2017

===  Networking in the Linux Kernel

#table(columns: (45%, 55%), stroke: none, gutter: 15pt, [

#align(center, [#image("osi-kernel.pdf", width: 100%)])

],[

- Abstracts the Network Devices

- Implements some OSI Layers :

  - Layer 1 (PHY) : Ethernet, WiFi, CAN, etc.

  - Layer 2 (MAC) : Bridging, VLANs, etc.

  - Layer 3 (Network) : IPv4, IPv6, etc.

  - Layer 4 (Transport) : TCP, UDP, etc.

- Provides a set of APIs to userspace :

  - Socket API and `io_uring`

  - Control through ioctl and Netlink

])

===  Physical and MAC support

- The Networking stack provides a framework for Layer 2 drivers :
  #kstruct("net_device")

- Used by Ethernet, Wifi, Bluetooth, CAN, 802.15.4, Radio, etc.

- PHY drivers have their dedicated frameworks

  - phylib for Ethernet PHYs

  - mac80211 and wiphy for 802.11 PHYs

- A lot of communication technologies are handled through the network
  stack

  - Ethernet

  - Wifi

  - Bluetooth and Bluetooth Low Energy

  - Infiniband

  - 802.15.4, radio, X.25

  - CAN Bus

===  Ethernet

- Ethernet MAC controllers are supported through regular
  #kstruct("net_device") as well as `ethtool`

- Switch drivers are supported, with offload operation going through
  #link("https://docs.kernel.org/networking/switchdev.html")[Switchdev]

- Standalone Ethernet Switches are handled through
  #link("https://docs.kernel.org/networking/dsa/dsa.html")[DSA]

- Ethernet PHYs are supported via
  #link("https://docs.kernel.org/networking/phy.html")[phylib], and the
  MAC to PHY link via
  #link("https://docs.kernel.org/networking/sfp-phylink.html")[phylink]

- SFF and SFP cages and modules are also supported

- Supports 802.3 frames and Ethernet II

- Multiple 802.1 and 802.3 low-level aspects are supported :

  - Vlan with 802.1Q and 802.1AD

  - Bridging and Switching

  - MACSec (802.1ae) for Ethernet-level encryption

  - Teaming, Bonding, HSR and PRP for link redundancy

- Raw Ethernet frames can be sent and received in userspace API with
  `AF_PACKET`

===  Wireless subsystem

- Wifi (802.11) Stack :

  - Supports Wifi chips with internal MAC stack (*hardmac*)

  - Also provides a 802.11 MAC stack for *softmac* drivers in
    `mac80211`

  - The main implementation is in `cfg80211`, configured via `nl80211`

- Bluetooth stack :

  - Low-level support for Bluetooth and BLE

  - Exposes a socket-based API for management and data

  - Profiles are implemented either in the kernel or userspace

  - BlueZ is the main userspace companion stack

- 802.15.4 stack :

  - Also provides *hardmac* and *softmac* support

  - Has its own PHY layer

  - Complemented by the *6lowpan* stack for upper levels

    - 6lowpan can also be used with Bluetooth Low Energy

===  Other Technologies

- X25 / AX25 : Amateur radio protocols. Long-standing support in Linux.

- Infiniband : Used for very high speed link, usually in datacenters

  - Layer 1 and Layer 2 technology (like Ethernet)

  - Allows using RDMA : Remote Direct Memory Access

  - provides a VERBS-based API (IB Verbs) , not sockets

- RoCE : RDMA over Converged Ethernet

  - RDMA over Ethernet-based networks (instead of Infiniband)

  - Works on top of Layer 4 (RoCE v2)

- CAN bus : Controller Area Network Bus

  - Widely used in automotive and industrial equipment

  - Support implemented using the Network Stack, socket-based

===  Userspace Networking

- Userspace applications can also access traffic at various points in
  the stack through sockets :

- `AF_PACKET` sockets allow raw Layer 2 access

  - Can be used for custom protocol support in userspace

  - Used by `libpcap` and traffic monitoring tools like *tcpdump*
    and *wireshark*

- `socket(AF_PACKET, SOCK_DGRAM, 0)` sockets expose raw IPv4 and IPv6
  packets

- Some protocols only have userspace implementations by design :

  - QUIC : Not in the kernel when the protocol was first introduced

    - Rationale was to prevent ossification

    - Recent kernel-side implementation submitted for inclusion in the
      kernel

===  Kernel Bypass

#table(columns: (30%, 70%), stroke: none, gutter: 15pt, [

#align(center, [#image("kernel_bypass.pdf", width: 100%)])

],[

- Contrary to `AF_PACKET`, Kernel Bypass techniques circumvent the
  networking stack

- Allows using an alternative implementation of the network stack,
  entirely running in userspace

  - For use-case optimized scenarios

- DPDK : Data Plane Development Kit

  - Re-implement the drivers in userspace as well as a custom stack

- Not supported by the linux kernel community

- Implies re-writing a full driver in userspace

- With `XDP` + `AF_XDP`, we now have a fully upstream solution

])

===  Netdev community

- The networking stack is made up of around 1M lines, 7000 distinct
  files

- 4 Maintainers share the top-level load :

  - Jakub Kicinski, David S. Miller, Eric Dumazet and Paolo Abeni

- Lots of maintainers for specific aspects of the networking stack

  - Wireless, Bluetooth, TC, Ethernet framework, PHY framework,
    individual drivers...

- Very active subsystem with lots of contributions and reviews.

===  Contributing

- Development occurs on the `netdev@vger.kernel.org` mailing list,
  #link("https://lore.kernel.org/netdev/")[see archives]

- Follows the kernel development cycle, with a 2 weeks break during the
  merge window

- 2 git repositories are used as a development basis:

  - #link("https://git.kernel.org/pub/scm/linux/kernel/git/netdev/net-next.git/")[net-next]
    : For *new features*, development stops during the Merge
    Window

    - Check the
      #link("https://patchwork.hopto.org/net-next.html")[status page]
      before sending patches !

  - #link("https://git.kernel.org/pub/scm/linux/kernel/git/netdev/net.git/")[net]
    : For *fixes*, always open to patches.

- Very fast-paced development, replies arrive quickly, for quick
  iterations

- Patch status can be tracked on
  #link("https://patchwork.kernel.org/project/netdevbpf/list/")[patchwork]

- Automated build-test and runtime tests are run with NIPA, results are
  published #link("https://netdev.bots.linux.dev/status.html")[here]

===  Conferences

- The #link("https://lpc.events/")[*Linux Plumbers Conference*]
  hosts a Networking Track

  - Main maintainers attend and host the track

  - For *ongoing development*, to discuss current issues and
    future work

  - Very technical topics

  - Usually single-day track on a multi-day event

- The #link("https://netdevconf.info/")[*Netdev Conference*] is
  dedicated to kernel networking development

  - Main maintainers also attend

  - Hosted by a dedicated group of individuals (the Netdev Society)

  - 4 or 5 days, mixing remote and on-site sessions

  - Very technical topics as well, not many are embedded-oriented
