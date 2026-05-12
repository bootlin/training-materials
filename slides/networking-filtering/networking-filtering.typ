#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== Traffic Filtering

=== current solutions

- The Networking stack can filter *egress* and *ingress*
  traffic

  - Necessary for *firewalling*

- Filters can also identify *packets of interest* for on-the-fly
  modification

  - e.g. NAT : The destination *IPv4* address is re-written

- Historically, multiple solutions have been implemented in the Linux
  Kernel :

  - `iptables` and `ip6tables` for Layer 3

  - `arptables` and `ebtables` for Layers 2 and 3

  - These solutions have been replaced by *netfilter* and its
    *nftables*

- Alternative solutions exist :*eBPF*, *P4* and
  *TC*

=== Legacy filtering solutions

- There used to be multiple traffic filtering, each for a different
  layer

- `iptables` and `ip6tables` : IP-level filtering and mangling

  - #kfile("net/ipv4/netfilter/ip_tables.c") and
    #kfile("net/ipv6/netfilter/ip6_tables.c")

- `ebtables` : Filtering based on Layer 2 information

  - Filter and forward VLANs and bridging operations

  - ARP filtering

=== nftables

- Originates from the
  #link("https://www.netfilter.org/")[Netfilter project]

- More modern approach, with a centralized filtering table and multiple
  *hooks*

- Rules expressed in a low-level language

- Users attach *chains* to *hooks* to express rules

- Chains are stored within *tables* created by users

- See the
  #link(
    "https://wiki.nftables.org/wiki-nftables/index.php/Simple_ruleset_for_a_server",
  )[project provided examples]

=== Netfilter hooks

#table(
  columns: (45%, 55%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("routing_nf.pdf", width: 90%)])

  ],
  [

    - *ingress* : Filter as soon as the packet is received

    - *pre-routing* : Filter before taking a routing decision

    - *input* : Filter packets going to sockets

    - *forward* : Filter packets forwarded to the outside

    - *output* : Filter local outgoing packets

    - *post-routing* : Filter all outgoing packets

  ],
)

=== netfilter in userspace

- Netfilter was integrated as another backed for existing tools like
  *iptables*

- Dedicated tool is called *nft*, see #manpage("nft", "8")
