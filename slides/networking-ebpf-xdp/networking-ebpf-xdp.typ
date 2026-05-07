#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== XDP

===  eXpress Data Path

- Run an eBPF program as close to frame reception as possible

- Support is Hardware-specific and driver-specific

- Introduced for high-performance networking, but available on embedded
  devices

- Take very fast decisions in the driver, with user-configurable eBPF
  code

- Used for fast routing, DDoS protection, firewalling, etc.

- With `AF_XDP`, offers an upstream alternative to kernel bypass

===  XDP program

#table(columns: (30%, 70%), stroke: none, gutter: 15pt, [

#align(center, [#image("xdp.pdf", width: 140%)]) 

],[

- XDP programs are run by the MAC driver in the NAPI loop

- XDP programs may edit the received frame, and take a decision :

  - `XDP_PASS` : Packet continues to the Networking stack

  - `XDP_DROP` : Packet is immediately dropped

  - `XDP_ABORTED` : Similar `XDP_DROP` but triggers a
    #link("https://elixir.bootlin.com/linux/v6.12.32/A/ident/xdp_exception")[tracepoint]

  - `XDP_TX` : Packet is sent back from the same interface

  - `XDP_REDIRECT` : Packet is sent either :

    - back from another interface

    - to another CPU for processing

    - to an `AF_XDP` socket

])

===  XDP hook - driver side

#[ #show raw.where(lang: "c", block: true): set text(size: 16pt)

```c
u32 bpf_prog_run_xdp(const struct bpf_prog *prog, struct xdp_buff *xdp);
```
]

#table(columns: (30%, 70%), stroke: none, gutter: 15pt, [

#align(center, [#image("xdp_buff.pdf", width: 130%)])

],[

- #kstruct("bpf_prog") : The XDP program attached to the interface

- #kstruct("xdp_buff") : A representation of the buffer

- XDP runs _before_ the `skb` is even created

- a #kstruct("xdp_buff") is a very simple and lightweight
  representation of a frame

])

===  XDP hook - eBPF side

#text(size: 15pt)[#link("https://elixir.bootlin.com/linux/v6.12.32/source/tools/testing/selftests/bpf/progs/xdp_dummy.c")[example program]]
#v(-0.1em)
```c
SEC("xdp")
int xdp_dummy_prog(struct xdp_md *ctx)
{
        return XDP_PASS;
}
```
#v(0.5em)
#text(size: 15pt)[#kstruct("xdp_md") definition]
#v(-0.1em)
```c
struct xdp_md {
        __u32 data;
        __u32 data_end;
        __u32 data_meta;
        __u32 ingress_ifindex; /* rxq->dev->ifindex */
        __u32 rx_queue_index;  /* rxq->queue_index  */
        __u32 egress_ifindex;  /* txq->dev->ifindex */
};
```

===  XDP_DROP

- Used for firewalling and DDoS protection

- A XDP Program returning `XDP_DROP` causes the frame to be dropped
  immediately

- `XDP_ABORTED` is similar, but triggers a tracepoint.

- Happens before the #kstruct("sk_buff") is even created

- If the driver uses `page_pool`, the buffer is recycled

- Extremely efficient way of filtering

===  XDP_PASS

- A XDP Program returning `XDP_PASS` causes the frame to continue
  through the network stack

- The XDP program may modify the frame

- After `XDP_PASS`, a #kstruct("sk_buff") will be created by the
  MAC driver

- The usual processing of the packet through the stack will occur

===  XDP_TX

#table(columns: (30%, 70%), stroke: none, gutter: 15pt, [

#align(center, [#image("xdp_lb.pdf", width: 100%)])

],[

- A XDP Program returning `XDP_TX` re-emits the frame on the same
  interface

- The frame may be modified by the program

- Main advertised use-case is to perform load-balancing

])

===  XDP_REDIRECT

- Redirects the frame towards a target identified by a *map*

- Programs don't directly return `XDP_REDIRECT`

- The special bpf helper `bpf_redirect_map()` must be used

  - See #manpage("bpf-helpers", "7")
#v(0.5em)
#text(size: 15pt)[#link("https://elixir.bootlin.com/linux/v6.15.1/source/tools/testing/selftests/bpf/progs/xdp_redirect_map.c")[Example XDP redirect]]
#v(-0.2em)
#[ #show raw.where(lang: "c", block: true): set text(size: 14pt)
```c
struct {
        __uint(type, BPF_MAP_TYPE_DEVMAP);
        __uint(max_entries, 8);
        __uint(key_size, sizeof(int));
        __uint(value_size, sizeof(int));
} tx_port SEC(".maps");

SEC("xdp")
int xdp_redirect_map_0(struct xdp_md *xdp)
{
        return bpf_redirect_map(&tx_port, 0, 0);
}
```]

===  `bpf_redirect_map`

#[ #show raw.where(lang: "c", block: true): set text(size: 16pt)
```c long bpf_redirect_map(void *map, __u64 key, __u64 flags) ```]
#v(0.5em)
- See #manpage("bpf-helpers", "7")

- eBPF helper for `XDP_REDIRECT` actions

- The redirection target is `map[key]`, where `map` can be :

  - A #ksym("BPF_MAP_TYPE_DEVMAP"), value is an `ifindex`

  - A #ksym("BPF_MAP_TYPE_CPUMAP"), value is a `cpu number`

  - A #ksym("BPF_MAP_TYPE_XSKMAP"), value is a `queue index`

===  XDP_REDIRECT - To device

#table(columns: (35%, 65%), stroke: none, gutter: 15pt, [

#align(center, [#image("xdp_redirect_devmap.pdf", width: 100%)])

],[

- Uses #ksym("BPF_MAP_TYPE_DEVMAP"), Documented
  #link("https://docs.kernel.org/bpf/map_devmap.html")[here]

- Forwards the frame to another XDP-enabled \ #kstruct("net_device")

- The target device must implement `.ndo_xdp_xmit()`

- No #kstruct("sk_buff") is created, the #kstruct("xdp_buff") is
  sent directly

- `bpf_redirect()` can be used directly

])

===  XDP_REDIRECT - To CPU

#table(columns: (40%, 60%), stroke: none, gutter: 15pt, [

#align(center, [#image("xdp_redirect_cpumap.pdf", width: 100%)])

],[

- Uses #ksym("BPF_MAP_TYPE_CPUMAP"), Documented
  #link("https://docs.kernel.org/bpf/map_cpumap.html")[here]

- Make the packet processing occur on another CPU core

- Useful for CPU load balancing

- Also used to circumvent hardware issues

  - Flawed hash computation in hardware for RSS

  - Wrong internal
    #link("https://elixir.bootlin.com/linux/v6.15.1/source/drivers/net/ethernet/marvell/mvneta.c#L4424")[interrupt routing]

])

===  XDP_REDIRECT - To Socket

#table(columns: (40%, 60%), stroke: none, gutter: 15pt, [

#align(center, [#image("xdp_redirect_xskmap.pdf", width: 100%)])

],[

- Uses #ksym("BPF_MAP_TYPE_XSKMAP"), Documented
  #link("https://docs.kernel.org/bpf/map_xskmap.html")[here]

- Frames are forwarded directly to user memory attached to an
  #ksym("AF_XDP") socket (*XSK*)

- Upstream Linux's response to out-of-tree kernel bypass (e.g. DPDK)

- The driver is still in kernel, and the XDP program choses if bypass is
  needed for each frame

- No copy occurs, a *dedicated hardware queue* is needed

- Memory is shared with the *UMEM*, bound to a `queue_id` with
  `bind()`

- UMEM regions are shared ring-buffers, where user buffers are directly
  mapped to hw queues

])

===  XDP support in a driver

+ Implement the execution and return-code handling of the BPF XDP
  programs

  - Fairly straightforward, done in the main NAPI loop

+ Make sure the data handling meets the following constraints :

  - Frame must be *readable* and *writeable*

  - There must be *a headroom* big enough to fit `struct xdp_frame`

  - There must be *a tailroom* big enough to fit all
    `skb_shared_info`

+ #link("https://lore.kernel.org/netdev/cover.1642758637.git.lorenzo@kernel.org/")[XDP frags]
  is supported since v5.16

  - Allows using XDP with non-linear frames, which used to be impossible

+ The #kstruct("xdp_buff") layout uses #kstruct("skb_frag") as
  well

===  Loading an XDP program

- XDP programs are built like any other eBPF program :

  ```console clang -O2 -g -target bpf -c xdp_prog.c -o xdp_prog.o ```

- They can be loaded with `iproute2` :

  ```console ip link set dev eth0 xdp obj xdp-prog.o ```

- `iproute2` xdp support is recent, `xdp-loader` from `xdp-tools` can be
  used :

  ```console xdp-loader load eth0 xdp_drop.o ```

- `bpftool` can also be used to attach XDP programs

- `ethtool -S <iface>` shows the XDP statistics

- `xdp-monitor` shows detailed statistics using BPF tracing
