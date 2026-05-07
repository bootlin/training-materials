#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Debugging and tracing the Network Stack

===  Challenges

- Latency issues : Can come from different locations

  - The network itself

  - Internal queueing and buffering

  - Hardware and OS-level latencies

- Throughput issues

  - May depend on the traffic type

  - May simply be a symptom : TCP retransmissions due to bad L1 link
    quality

- Link issues

  - May be hardware related

  - The kernel can't only tell you what it knows

===  Monitoring traffic and drops

- In case of large number of repeats or local drops

- dropwatch : monitor the in-kernel packet drops, see
  #manpage("dropwatch", "1")

  ```bash $ dropwatch -lkas ``` \
  ```bash $ dropwatch> start ``` \
  ```bash 2 drops at ip6_mc_input+1a8 (0xffffffff83347ba8) [software] ```

- retis : eBPF based monitoring. monitor drops as well as `skb` lifetime

- See the
  #link("https://retis.readthedocs.io/en/stable/")[official documentation]

  ```bash retis collect -c skb-drop --stack ```

===  Monitoring traffic with a capture

- Tools such as wireshark and tcpdump use `AF_PACKET` sockets for
  monitoring

- Some hardware devices may include extra information

  - _e.g._ the *radiotap* headers on 802.11 frames

- The monitoring happens between the *driver* and `tc`

- On the receive side, it happens before firewalling with netfilter

- Capture format is standardized with the `pcap` format

  - frames can be replayed, or analyzed on another host

===  Offloading

- Offloading issues are hard to troubleshoot, as the host doesn't see
  them

- `wireshark` may tell you *receive checksumming* issues

- `ethtool -k eth0` shows you the *features*

- Hardware counters should be used for debugging :

  - `ethtool -S eth0`

  - `ethtool –phy-statistics eth0`

  - `ethtool -S eth0 –groups eth-mac|eth-phy|eth-ctrl|rmon`

- Some information may be available in *debugfs*

- `ip -s link show eth0` shows software counters

- `cat /proc/interrupts` indicate the hardware interrupt counters

- `cat /proc/softirq` indicate the softirq counters

===  Traffic generation

- iperf3 : Throughput testing, fairly simple to use

- netperf : Made by kernel developers, similar to iperf3, more
  featureful

- scapy : Traffic generator written in python, craft arbitrary frames

- DPDK's #link("https://pktgen-dpdk.readthedocs.io/en/latest/")[pktgen]

  - PKTgen uses *kernel bypass*, not supported on every platform

  - Allows very fast packet crafting (10gbs)

  - Useful for testing multi-flow setups, or HW offloading

===  iperf3

- Widely used traffic generator

- `iperf3 -s -D` : Start in server mode

- `iperf3 -c 192.168.1.1` : Start in client mode, default is TCP

- `iperf3 -c 192.168.1.1 -u -b 0` : UDP mode, with unlimited bandwidth

- `iperf3 -c 192.168.1.1 -u -b 0 -l 100` : UDP mode, small packets

- `iperf3 -c 192.168.1.1 -P 16` : Multi-flow mode

===  scapy

- Traffic generator written in python. See the
  #link("https://scapy.net/")[official website]

- Allows generating arbitrary traffic very easily

- Each header can be crafted, for high flexibility

- Very easily scriptable

```python
# IPv4 with ToS field varying between 1 and 4
sendp(Ether()/IP(dst="1.2.3.4",tos=(1,4)), iface="eth0")

# Raw ethernet frame 
sendp(Ether(dst="00:51:82:11:22:02"), iface="eth0") 

# Send and wait for reply, simple ping implementation 
packet = IP(dst="192.168.42.1", ttl=20)/ICMP()
reply = sr1(packet)     
```

===  Counters

- Layer 4 counters : Maintained by the kernel.

  - `netstat -s` or `cat /proc/net/netstat`

  - More statistics in `/proc/net/stat`

- Layer 3 counters : Provided by `ip -s link show`

- Layer 2 counters : Hardware-provided

- XDP programs can be custom-written to gather specific statistics

- `xdp-monitor -s` tracks XDP statistics such as the number of drops and
  redirects

===  profiling

- Allows identifying the bottlenecks in software

- `perf` can be used : Rely on hardware and software counters

- `Flamegraphs` help identify software bottlenecks, in kernel and
  userspace

  - Covered in our
    #link("https://bootlin.com/training/debugging/")[debugging training]

- `ftrace` will generate timelines of events, to track
  *latencies*

- See
  #link("https://docs.kernel.org/trace/ftrace.html")[the ftrace documentation]
