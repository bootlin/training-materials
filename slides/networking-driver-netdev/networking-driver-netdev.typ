#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== Ethernet controller driver

===  Ethernet driver endpoints

- Ethernet controllers are represented by #kstruct("net_device")

- Entry points are the #kstruct("net_device_ops")

- Extra ethernet-specific callbacks implemented with
  #kstruct("ethtool_ops")

`
dev->netdev_ops = &mvneta_netdev_ops;
dev->ethtool_ops = &mvneta_eth_tool_ops;
`

===  Queues

#table(columns: (30%, 70%), stroke: none, gutter: 15pt, [

#align(center, [#image("queues.pdf", width: 100%)])
],[

- Most Ethernet controllers today have multiple *transmit* and
  *receive* queues

- *tx* queues hold *descriptors* for packets that are
  yet-to-be-sent

- The NIC will dequeue one packet at a time during transmission, from
  one of the tx queues

- The TX de-queueing behaviour can sometimes be controlled : Weighted
  Round-Robin, Per-queue priorities, etc.

- *rx* queues hold descriptors for packets received that weren't
  yet handled by the CPU

- the RX buffer size depends on the configured *MTU*

])

===  RX filtering

- The *receive filtering* is adjusted with : \
  #[ #show raw.where(lang: "c", block:false): set text(size: 16pt)
  ```c void (*ndo_set_rx_mode)(struct net_device *dev); ```]

- `dev->flags` contains the new filtering parameters :

  - `IFF_PROMISC` : If set, the interface must go in
    *promiscuous mode*

    - No hardware filtering of incoming frames must occur

    - Used by tools like `tcpdump`, or `ip link set dev eth0 promisc on`

  - `IFF_ALLMULTI` : If set, all *multicast frames* must be
    accepted

- The *unicast* and *multicast* address list must be
  updated :

  - `dev->uc` contains all the Unicast addresses the interface must
    accept

  - `dev->mc` contains all the Multicast addresses the interface must
    accept

- The address list is maintained by the Networking stack, updated
  through #kfunc("dev_uc_add"), #kfunc("dev_uc_del"),
  #kfunc("dev_mc_add"), etc.

===  Changing the MTU

- *\M*\aximum *\T*\ransmit *\U*\nit, used by the upper
  layers for fragmentation

  - Stored in `netdev->mtu`

- User-modifiable with `ip link set dev eth0 mtu 1500`

  - Triggers a call to the `.ndo_change_mtu` netdev ops

- Changing the MTU may require the *re-allocation* of RX buffers
  in the queues

#v(0.5em)

#text(size: 15pt)[`.ndo_change_mtu()` - option 1]
#v(-0.2em)
#[ #show raw.where(lang: "c", block: true): set text(size: 13pt)
```c
if (netif_running(ndev
        return -EBUSY; /* Can't change the MTU while the interface is UP */

WRITE_ONCE(ndev->mtu, new_mtu);
```

#v(0.5em)

#text(size: 15pt)[`.ndo_change_mtu()` - option 2]
#v(-0.2em)
```c
WRITE_ONCE(ndev->mtu, new_mtu);

foo_stop_dev(dev); /* Stop sending and receiving, empty the queues*/
foo_realloc_queues(dev); /* Re-allocate buffers for the new MTU */
foo_start_dev(dev); /* Resume */
```
]

===  Channels

#table(columns: (30%, 70%), stroke: none, gutter: 15pt, [

#align(center, [#image("channels.pdf", width: 100%)])

],[

- `tx` and `rx` queues will notify queueing and dequeueing through
  `interrupts`

- Multiple queues may share the same interrupt line

- A *channel* represents an interrupt line and its associated
  queues

- Channels can be added or removed, depending on hardware support
#v(0.5em)
#[ #show raw.where(lang: "c", block:false): set text(size: 12pt)
```c void (*get_channels)(struct net_device *, struct ethtool_channels *); ``` \
```c int (*set_channels)(struct net_device *, struct ethtool_channels *); ```
]
])

===  Receiving data

- The receive path for a Ethernet Controller Driver must use the
  *NAPI* API

- The entry-point is an *interrupt handler* that will be called
  upon frame reception

- There may be multiple interrupts for RX (per-queue, per-cpu...)

- NAPI mandates a short *top half* that acknowledges the
  interrupt and *masks it*

- The handler then calls #kfunc("napi_schedule").

- Most of the processing occurs in *softirq* context, on the
  *same CPU* that handled the interrupt

===  NAPI principle

- NAPI does *not* stand for *\N*\ew *API*

  - it was new in Linux v2.4, today NAPI means NAPI

- Designed to avoid interrupt interference, as traffic often occurs in
  bursts

- The *first packet* of a burst is handled through interrupt

- The interrupt stays disabled, each subsequent packet is pulled using
  *polling*

- The polling stops when the *budget* is exhausted (by default,
  50 packets)

- The driver must then re-enable the interrupts for further processing

- NAPI is not a batch processing mechanism, which is achievable through
  *interrupt coalescing*

===  NAPI Loop

- Register the NAPI polling function (per-queue) : `netif_napi_add`

- Polling function runs in *softirq* context : *Cannot
  sleep*

+ Hardware IRQ fires upon receiving a first packet

+ IRQ handler disables interrupts for that queue, and calls
  `napi_schedule`

+ The NAPI system calls the polling function \
`int (*poll)(struct napi_struct *napi, int budget`

+ Each received frame counts as *1* budget item

  - If the budget is exhausted but there are still packets to process,
    return `budget`

  - The polling function may be called with a budget of `0`, for TX
    processing only

+ If the budget isn't exhausted but all packets are processed, call
  `napi_complete_done()` and unmask interrupts

===  NAPI instances

- NAPI poll handlers are registered with #kfunc("netif_napi_add")

- Multiple NAPI *instances* can be registered

  - Usually one per *channel* or per *CPU*

#v(0.5em)

#text(size: 15pt)[napi .poll()]
#v(-0.2em)
#[ #show raw.where(lang: "c", block: true): set text(size: 16pt)
```c
static int foo_poll(struct napi_struct *napi, int budget)
{
    while(rx_done < budget) {
        buff = foo_queue_get_next_desc();
        foo_do_xdp(buff);
        skb = foo_build_skb(buff);
        napi_gro_receive(skb);
        rx_done++;
    }
}
```
]

===  Interrupt Coalescing

- *Hardware feature* where the MAC waits for multiple packets to
  be received before triggering the interrupt

- Users configure a number of pending packets and a timeout for RX
  interrupt generation

- Must be fine-tuned depending on the use-case :

  - High threshold allows batching the interrupts, suitable for
    high-throughput workloads

  - Low threshold allows triggering interrupts as soon as data is
    received, for low-latency workloads

- `ethtool -C eth0 adaptive-rx on adaptive-tx on tx-usecs-irq 50`

- Software IRQ coalescing also exists, using NAPI and a polling-rearm
  timer

===  Transmit path

- Packets are sent from a network controller through the
  `.ndo_start_xmit` callback

  - `netdev_tx_t .ndo_start_xmit(struct sk_buff *skb, struct net_device *dev)`

  - it is the only mandatory `net_device_ops` member !

- The `.ndo_start_xmit()` callback enqueues and sends the `skb`

- If the skb is fragmented, all fragments must be sent

- In case of an error, the `skb` is dropped, but we still return
  `NETDEV_TX_OK`

- The `dev->stats` and driver-specific counters must be updated

===  NAPI TX

- TX *completions* are handled in the NAPI loop

- The driver acknowledges that packets were correctly sent

- During a NAPI poll, drivers are free to acknowledge as many TX packets
  as they want

- `budget` does not apply to TX packets

  - The NAPI poll function can acknowledge as many TX packets as it
    wants

===  Buffer management

- Hardware queues contain pre-populated *dma descriptors*

- On the receive side, when receiving packets the queues must be
  *refilled*

- Usually done at the end of the NAPI loop

- This is driver specific, but the buffers can be kept in *pools*

===  Page pool

- Page pools allows fast page allocation without locking

- One `struct page_pool` must be allocated per-queue

- Getting a page from `page_pool` happens without locking

- This is only used on the *receive* side

- Using `page_pool` is strongly recommended to support *XDP*

- See the
  #link("https://docs.kernel.org/networking/page_pool.html")[page pool documentation]

===  Timestamping

- Packet timestamping can be done in RX and TX

- Hardware timestamping is configured in the `.ndo_ioctl()`

  - Being replaced in favor of `.ndo_timestamping()`

- Timestamp is stored in the `skb_shared_info`

- On TX timestamping, the `skb` is cloned, timestamp is attached to the
  clone

  - The clone is sent back to the *socket error queue*

===  Netdev features

- `features` represents hardware offload capabilities

  - Checksumming, Scatter-gather, segmentation, filtering (mac / vlan)

  - see `ethtool -k <iface>`

  - attributes of `struct net_device`

- Drivers set `netdev.hw_features` at init, and can also set
  `netdev.features`

  - `features` : The current active features

  - `hw_features` : Features that can be changed (_hw !=
    hardware_)

- Users but also the core might want to change the enabled features

  - Child devices might require some features to be disabled

- `.ndo_fix_features()` filters incompatible feature sets for the
  driver

- `.ndo_set_features()` applies the new feature set

- `vlan_features` contains the feature set inherited by VLAN interfaces

- #link("https://docs.kernel.org/networking/netdev-features.html")

===  Offloading

- Most modern controllers can perform themselves some operations on
  packets

- *checksumming* offload makes so the CPU doesn't have to check
  or compute checksums

- *filtering* offloads makes so that the MAC drops unknown MAC
  addresses and VLANs

- *classification*-capable controllers may implement more
  powerful features :

  - *header hashing* computes a hash of a specific set of fields
    in the header. Useful for RSS.

  - *flow steering* allows specific actions (enqueueing, drop,
    redirection) to be done based on specific header values

- *crypto* offload for some tunneling technologies such as MACSec

- Offloading can however make debugging harder, as decisions are taken
  before packets reach the CPU

  - Most controllers will expose counters, accessible over `ethtool -S <iface>`

===  Checksumming

- Some protocols include a checksum of the header or payload in the
  frame

  - Ethernet has the *FCS* that checksums the whole frame

  - IPv4 header includes a Header Checksum for the IPv4 header itself

  - TCP and UDP checksums the header and the payload

- Checksum computation and verification need to be done for every frame

- Some devices can compute and verify checksums at the hardware level

- TX checksumming involves computing the checksum of a section of the
  packet, and editing the checksum inline

- *caution :* Outgoing traffic will be shown with wrong checksums
  in captures

===  RSS

#align(center, [*\R*\ecieve *\S*\ide *\S*\teering])
#v(0.3em)
- Hardware feature on the *receive* side to spread traffic
  handling across queues and cores

- Requires per-queue or per-cpu interrupt support in the Ethernet
  controller

- Incoming packets can't be arbitrarily steered to any CPU or queue

  - Risk of out-of-order delivery, and bad caching behaviour

- The hardware parses the packet header and computes a hash of some of
  its fields

  - Usually CRC32 or Toeplitz

- The Hash is then used as a lookup index in a RSS table to get the RX
  queue

- `.get_rxfh` and `.set_rxfh`

===  XPS

- Associate TX queues with CPU cores

- Frames enqueued from a given core always go in the same queue

- Avoids contention on enqueueing

  - Each CPU can enqueue without cross-CPU locking

- Optimizes the completion handling

- `netif_set_xps_queue(dev, cpumask_of(queue), queue);`

===  Flow steering

- Advanced controllers have the ability to *parse* packet headers

- This is complex, as the header fields are not at fixed offsets
  (presence of VLAN tags, encapsulation, etc.)

- This is usually achieved with internal *TCAM-based lookup
  engines*

- Traffic is classified based on specific fields : src/dst MAC, src/dst
  IP, src/dst Port, VLAN, etc.

- Classified traffic are assigned actions :

  - Drop (DoS mitigation)

  - Redirection

  - Enqueueing

  - Policing (rate limiting)

===  TC and ethtool steering

- Flow steering can be offloaded via `ethtool` :

  ```bash ethtool -K eth0 ntuple on ``` \
  ```bash ethtool -N eth0 flow-type tcp4 vlan 0xa000 m 0x1fff action 3 loc 1 ```

- Steers Vlan-tagged TCP over IPv4 with priority 6 (`0xa000 & 0x1fff`)
  in queue 3

- Implemented in the `.set_rxnfc` ethtool op, _e.g._
  #kfunc("mvpp2_ethtool_set_rxnfc")

- Can also be done with *tc flower*

  - Through `.ndo_setup_tc`

- Both APIs use the same representation : #kstruct("flow_rule")

===  Multi-queue and priorisation

- Some Ethernet Controllers have multiple `tx` and`rx` queues

- On the *transmit* side, allow shaping and priorizing traffic

- On the *receive* side, allow load-balancing and per-queue
  actions

- flows can be assigned to dedicated *rx queues*

- These queues can in turn be pinned to CPUs, apps, VMs, or be
  rate-limited.

- Most of this is controlled through *tc* in `.ndo_setup_tc`

- Example in #kfunc("mvneta_setup_mqprio")

===  Other #kstruct("ethtool_ops")

- `.get_ringparam` and `.set_ringparam`

  - Adjust the size of queues

- `.get_strings` and `get_ethtool_stats`

  - Returns hardware stats

- `.get_link_ksettings` and `set_link_ksettings`

  - Get the link speed and duplex

  - Usually the driver queries the PHY driver to get this information

- `.get_wol` and `.set_wol`

  - Configure Wake-on-Lan
