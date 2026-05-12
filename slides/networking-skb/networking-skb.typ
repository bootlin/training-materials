#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== Socket Buffers

=== #kstruct("sk_buff") (1)

- Object that represents a packet through the stack :
  *\s*\oc*\k*\et *\buff*\er

  - #kstruct("sk_buff") defined in
    #kfile("include/linux/skbuff.h")

- Created when user writes data into a socket

- Created by drivers upon receiving a packet

- Core object of the Networking Stack, often named `skb`

- It contains *meta-data* about the packet :

  - Origin/destination #kstruct("sock") (`skb->sk`)

  - Origin/destination #kstruct("net_device") (`skb->dev`)

  - Arrival timestamp, priority, etc.

- Also contains a lot of specific flags :

  - `wifi_acked` : Was the packet ack'd, wifi-specific

  - `decrypted` : Does the packet need decryption ?

  - `redirected` : Was the skb redirected ?

=== skb payload

#table(
  columns: (30%, 70%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("skb.pdf", width: 100%)])

  ],
  [

    - `skb` maintains positions to the data buffer

    - The *data* section is the current *payload*

    - The payload boundaries (`data` and `tail`) depend on the current Layer

    - `skb->len` identifies the current length of data

    - `skb->head` : Start of the allocated buffer

    - `skb->data` : Start of the *payload section* of the
      *current layer*

    - `skb->tail` : End of the payload section

    - `skb->end` : End of the buffer

    - These pointers are *moved* when the skb traverses the stack

  ],
)

=== skb geometry : Paged skb

#table(
  columns: (30%, 70%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("skb_nonlinear.pdf", width: 130%)])

  ],
  [

    - The data section of an `skb` may be non-contiguous

    - We talk about *non-linear* or *paged* skb.

    - Sections of the payload are stored in the `skb_shared_info`

    - Each part of the buffer is stored in an array of `skb_frag_t`

    - This happens when transmitting *scatter-gather* (SG) buffers

    - #kfunc("skb_linearize") will convert it to a single-buffer skb.

      - Useful for drivers that don't support SG.

  ],
)

=== skb geometry : Fragmented skb

#table(
  columns: (30%, 70%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("fragmented_skb.pdf", width: 100%)])

  ],
  [

    - Buffer bigger than the *MTU* needs to be fragmented

    - The original `skb` gets split into multiple parts

    - Each fragment is its *own skb*

    - Fragments are chained together through :

      - `skb_shared_info->frag_list` for the *first skb*

      - `skb->next` for the other fragments

  ],
)

=== skb cloning and duplication

#table(
  columns: (30%, 70%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("skb_clone.pdf", width: 100%)])

  ],
  [

    - #kfunc("skb_clone") allocates a new #kstruct("sk_buff")
      pointing to an existing buffer

    - Useful when the `skb` needs to be delivered multiple times

      - For Multicast, `AF_PACKET`, capturing, etc.

    - The fragments are also cloned

    - The buffer memory is *refcounted*

    - Destroy the clone with #kfunc("consume_skb") or
      #kfunc("kfree_skb")

    - #kfunc("skb_copy") duplicates the `skb` and all its associated
      memory

    - #kfunc("pskb_copy") duplicates the `skb` and the *header*
      but clones the payload

    - `skb` can also be shared, tracked with `skb->shared`

  ],
)

=== skb layer offsets

#table(
  columns: (30%, 70%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("skb_layers_offsets.pdf", width: 100%)])

  ],
  [

    - #kstruct("sk_buff") maintains *layer offsets* starting from
      `skb->head`

    - Set and modified by each encapsulation or decapsulation step

    - When processing a packet, each layer moves `skb->data`

    - `skb_reset_xxx_header()` sets the given header *where
      `skb->data` currently is*

      - #kfunc("skb_reset_mac_header") : Called by *drivers*

      - #kfunc("skb_reset_network_header") : Called after MAC
        processing

      - #kfunc("skb_reset_transport_header") : Called in L3 (IP)
        processing

  ],
)

=== #kfunc("skb_pull")

#table(
  columns: (40%, 60%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("skb_pull.pdf", width: 100%)])

  ],
  [

    - Pulls header data, used during *decapsulation*

    - Decreases `skb->len`

    - Usually followed by a layer offset readjustment

    - Returns the new `skb->data` pointer

    - May fail if `skb->len` is too short

    - May require a *checksum recompute*

      - #kfunc("skb_pull_rcsum") will update checksums

  ],
)

=== #kfunc("skb_push")

#table(
  columns: (40%, 60%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("skb_push.pdf", width: 100%)])

  ],
  [

    - Pushes the `skb->data` into the headroom

    - Increases `skb->len`

    - Used during *encapsulation*, when creating the headers

    - May fail if the headroom is too short

    - May require a *checksum recompute*

      - #kfunc("skb_push_rcsum") will update checksums

  ],
)

=== #kfunc("skb_put")

#table(
  columns: (40%, 60%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("skb_put.pdf", width: 100%)])

  ],
  [

    - Expands the payload section into the tailroom

    - Increases `skb->len`

    - Used in drivers to set the *full packet size*

    - Also used by some *DSA taggers*

  ],
)

=== #kfunc("skb_trim")

#table(
  columns: (40%, 60%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("skb_trim.pdf", width: 100%)])

  ],
  [

    - Shrinks down the payload from its end

    - Decreases `skb->len`

    - Only works on *linear skb*

    - Used to remove padding

    - Also useful to decapsulate protocols that insert a trailer

      - e.g.
        #link(
          "https://elixir.bootlin.com/linux/v6.15.1/source/net/hsr/hsr_forward.c#L196",
        )[PRP]

  ],
)

=== pskb helpers

- *\p*\otentially fragmented *skb* helpers manipulate
  non-linear `skb`

- Useful if you don't know and don't mind if the `skb` is paged

- Not all helpers have a matching `pskb` equivalent, not always relevant

- #kfunc("skb_put") => #kfunc("pskb_put")

- #kfunc("skb_pull") => #kfunc("pskb_pull")

- #kfunc("skb_trim") => #kfunc("pskb_trim")

- #kfunc("pskb_may_pull") indicates if a `pskb_pull` operation
  will succeed

  - #kfunc("pskb_may_pull_reason") returns a *drop reason*
    if it will fail

=== skb allocation

- #kfunc("build_skb") allocates a new `skb` around an existing
  buffer

- A new linear `skb` is allocated with #kfunc("alloc_skb"). It also
  allocates its data buffer.

- A paged `skb` can be allocated with
  #kfunc("alloc_skb_with_frags")

- A newly-allocated `skb` is empty : `skb->data` == `skb->head` ==
  `skb->tail`

- #kfunc("skb_reserve") grows the headroom, then
  #kfunc("skb_push") to prepare the data section

#v(0.5em)

#align(center, [#image("newskb.pdf", width: 100%)])

=== Dropping packets

- At any point, we may decide to *discard* an `skb`, it is
  *dropped*

- an `skb` is dropped with :

  #[ #show raw.where(lang: "c", block: true): set text(size: 15pt)
    ```c
    void kfree_skb_reason(struct sk_buff *skb, enum skb_drop_reason reason);
    ```]

- The `reason` allows reporting to users the cause of the drop

- Around 120 different reasons currently exist

  - see #kfile("include/net/dropreason-core.h")

- Drop reasons are not part of the *userspace API*, but can be
  retrieved with :

  - *ftrace*, via the `skb:kfree_skb` and
    `skb:consume_skb`tracepoints : \
    `trace-cmd record -e skb:kfree_skb <cmd>`

  - *dropwatch* : Uses the kernel's `dropmon` mechanism through
    `netlink`

  - *retis* : `eBPF`-based, uses the `BTF` information to display
    reasons

=== SKB decapsulation

#table(
  columns: (30%, 70%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("skb_decapsulation.pdf", width: 120%)])

  ],
  [

    - When *ingress* packets traverse the stack, they are
      decapsulated

    - Each header usually has a field indicating the nature of the upper
      layer

      - Ethernet header : `Ethertype` (2 bytes)

      - IPv4 header : `Protocol` (1 byte)

      - IPv6 header : `Next Header` (1 byte)

    - The `ptype` list maps `Ethertypes` to `packet handlers`

    - The `proto` list maps `Protocols` to `Transport handlers`

    - Each stage *parses* its header, and *moves `skb->data`*

    - In the last stage, `skb->data` points to the final payload

  ],
)

=== #kstruct("packet_type")

- L2 protocols such as `802.3` and `802.11` usually include an
  *Ethertype*

- 2-byte value indicating the higher-level protocol :

  - `0x0800` for IPv4, `0x0806` for ARP

  - `0x86dd` for IPv6, `0x8100` for 802.1Q (vlan)

  - See #kfile("include/uapi/linux/if_ether.h")

- We can associate #kstruct("packet_type") with Ethertypes :

  #[ #show raw.where(lang: "c", block: true): set text(size: 17pt)
    ```c
    struct packet_type {
        __be16 type;
        struct net_device *dev;
        int (*func) (struct sk_buff *skb,
                     struct net_device *dev,
                     struct packet_type *ptype,
                     struct net_device *orig_dev);
        /* ... truncated */
    };
    ```]

=== #kfunc("dev_add_pack")

- #kfunc("dev_add_pack") registers a #kstruct("packet_type")
  (`ptype`)

- if `ptype->dev` is `NULL`, the handler is registered system-wide

  - e.g. IPv4, IPv6, ARP

- otherwise, the `ptype` will only be handled on `ptype->dev`.

  - e.g. `AF_PACKET` sockets bound to an interface

- Upon match of the Ethertype, `ptype->func()` is called with the `skb`

- `ptype->list_func` can be implemented to handle multiple `skb`

=== IPv4 example

#[ #show raw.where(lang: "c", block: true): set text(size: 17pt)

  ```c
  static struct packet_type ip_packet_type __read_mostly = {
          .type = cpu_to_be16(ETH_P_IP),
          .func = ip_rcv,
          .list_func = ip_list_rcv,
  };

  static int __init inet_init(void) /* truncated */
  {
          /* For TX : Used by the socket's sendmsg */
          proto_register(&tcp_prot, 1);
          proto_register(&udp_prot, 1);
          proto_register(&ping_prot, 1);

          /* For RX : Handle the IP Ethertype */
          dev_add_pack(&ip_packet_type);
  }
  ```]

=== Exception : Vlan

- VLANs (802.1Q and 802.1AD) have a dedicated Ethertype, but no \
  #kstruct("packet_type")

- VLANS are handled
  #link(
    "https://elixir.bootlin.com/linux/v6.15.1/source/net/core/dev.c#L5756",
  )[directly in the receive path]

- Some hardware can strip the VLAN tag themselves

  - The tag is reported out-of-band, such as
    #link(
      "https://elixir.bootlin.com/linux/v6.15.1/source/drivers/net/ethernet/freescale/enetc/enetc.c#L1363",
    )[in the DMA descriptors]

  - The VLAN information is set in `skb->vlan_proto` and
    `skb->vlan_tci`

- This also allows optimizing speed by avoiding indirect branches

- Some hardware may also perform
  #link(
    "https://elixir.bootlin.com/linux/v6.15.1/source/drivers/net/ethernet/marvell/mvpp2/mvpp2_main.c#L5295",
  )[Vlan filtering]

=== RX handlers

- Protocol information alone may not always be sufficient for custom
  processing

- e.g. *MACVlan* has no dedicated Ethertype

- We can attach a callback function to a netdev, executed before
  protocol handling

  #[ #show raw.where(lang: "c", block: true): set text(size: 17pt)
    ```c
    rx_handler_result_t rx_handler_func_t(struct sk_buff **pskb);
    ```]

- Attached with #kfunc("netdev_rx_handler_register") (One handler
  per netdev)

- Handler may change the `skb`, including `skb->dev`, and return :

  - `RX_HANDLER_CONSUMED` : `skb`'s processing stops here

  - `RX_HANDLER_PASS` : continue as if the handler didn't exist

  - `RX_HANDLER_EXACT` : `PASS` to protocol only if `ptype->dev == skb->dev`

  - `RX_HANDLER_ANOTHER` : Re-process the `skb` as if it came from
    `skb->dev`

=== #kstruct("net_protocol")

- Layer 3 protocols include an 8-bit identifier describing the L4 layer

  - `6` for TCP, `17` for UDP

  - `1` for ICMP, `41` for IPv6-in-IPv4

  - see #kfile("include/uapi/linux/in.h")

- A *transport protocol handler* is represented by
  #kstruct("net_protocol")

  - For IPv6, it is represented by #kstruct("inet6_protocol")

#[ #show raw.where(lang: "c", block: true): set text(size: 17pt)
  ```c
  struct net_protocol {
          int (*handler)(struct sk_buff *skb);
          int (*err_handler)(struct sk_buff *skb, u32 info);
          ...
  };
  ```]

=== #kfunc("inet_add_protocol") and #kfunc("inet6_add_protocol")

#[
  #show raw.where(lang: "c", block: true): set text(size: 17pt)

  - Transport protocols are registered in each L3 stack

  - ```c
    int inet_add_protocol(struct net_protocol *prot, u8 num);
    ```

  - ```c
    int inet6_add_protocol(struct inet6_protocol *prot, u8 num);
    ```

  - Associate protocols with their respective identifiers

  - Upon matching the `num` identifier, `prot->handler()` is called

]

=== #kstruct("net_offload")

#[
  #show raw.where(lang: "c", block: true): set text(size: 13.5pt)

  - Some Layer 4 protocols may be associated with a
    #kstruct("net_offload")

  - Used to offload *segmentation* : Let the hardware or driver do
    it

    - Segmentation and re-assembly is protocol-specific

    - Each protocol can register a #kstruct("net_offload")

    - ```c
      int inet_add_offload(const struct net_offload *prot, unsigned char num);
      int inet6_add_offload(const struct net_offload *prot, unsigned char num);
      ```

  - `skb`s bigger than the *MTU* are passed to the driver

  - The driver or the hardware handles splitting the packet

    - L2 and L3 headers are added with fragment identifiers

  - On the receive side, the hardware or driver re-assembles the packets

    - Intermediate headers are stripped and the packet is re-assembled

]

=== Generic Receive Offload

- GRO may be used if the driver or the hardware doesn't handle
  re-assembly

  - May be toggled with `ethtool -K <iface> gro off|on`

- It is *generic*, works with any Layer 4 protocol

- This still requires driver support :

  - Upon receiving packets, fragmented or not, call
    #kfunc("napi_gro_receive")

  - Drivers that do not support it call #kfunc("netif_receive_skb")

- GRO accumulates `skbs` and asks L3 and L4 to act upon it

  - #kfunc("inet_gro_receive") : e.g. Checks if Don't Fragment flag
    is set

  - #kfunc("tcp_gro_receive") : e.g. Flush if we exceed the TCP MSS

- GRO-held `skb`s are merged and eventually flushed to the regular
  receive path

- Can be problematic for latency or throughput in *router* mode

=== Generic Segmentation Offload

- Perform the segmentation either in hardware, or just before passing to
  the driver

- Avoids having all the segments traverse the stack

  - Routing, filtering, scheduling decisions are the same for all
    segments

- Pure software implementation, but can be offloaded to hardware :

  - TCP Segmentation Offload (TSO)

  - Hardware will split the TCP data based on the MSS

  - Support for partial checksum offload is required

=== routing

#table(
  columns: (45%, 55%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("routing.pdf", width: 90%)])

  ],
  [

    - Routing happens on *ingress* and *egress*

    - Done by looking-up the *\F*\orwarding *\I*\nformation
      *\B*\ase

    - Decision taken in #kfunc("fib_lookup")

    - The table can be shown with *ip route*

  ],
)

=== Flow tables

- Allows a slow-path and fast-path for routing and bridging

- The first packet of a given flow goes through the whole stack

- The final routing or bridging decision is cached

- The next packet from the same flow will go through the fast-path

- These decisions may be offloaded to hardware
