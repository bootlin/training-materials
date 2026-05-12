#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== Traffic Control

=== Packet Scheduling

- On complex systems, thousands of applications may use the same
  interface

- The scheduling of egress traffic needs to be configurable and
  predictable

- Queueing strategies can be tuned for *throughput* and
  *latency*

- *tc* is the main component that deals with traffic scheduling

=== Packet Scheduling in the stack

#table(
  columns: (45%, 55%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("routing_tc.pdf", width: 90%)])

  ],
  [

    - The scheduling decision occurs between *routing* and the
      *driver*

    - On *egress*, decides which packet to enqueue

    - On *ingress*, may decide to drop or redirect

  ],
)

=== TC : Traffic Control

- `tc` is a subsystem in charge of traffic control operations, namely :

  - *Traffic Shaping* : Control the transmission rate for traffic
    classes

  - *Traffic Scheduling* : Control the ordering and burst
    behaviour of outgoing traffic

  - *Traffic Policing* : Control the reception rate for traffic
    classes

  - *Drop control* : Control discard conditions for egress and
    ingress traffic

  - *Classification* : Identify packets of interest for further
    actions

=== TC use-cases

- `tc mqprio` - Assign priorities to the Network Controller's queues

- `tc taprio` - Time-aware queue prioritization, for TSN

- `tc flower` - Flow-based actions, can be offloaded to hardware

- `tc ingress` - Attach TC actions to ingress traffic

=== TC QDisc : Queueing Disciplines

- Controls how traffic is enqueued, in the *tx* direction

- Allows shaping the traffic very precisely on a per flow basis

- *Flows* can be assigned to different *Qdisc* to define
  how to schedule transmission

=== Queues

- Queue management is crucial for Latency and Throughput

- Long queues allow absorbing network instabilities...

- ... but may cause latencies, leading to *bufferbloat*

- The Network Interface's queues are exposed to TC

- *qdisc* algorithms select which queue is used for a given
  *flow*

=== Traffic flows

- Packets with same *addressing parameters* are part of the same
  *flow*

- A Layer 4 flow is defined by 4 parameters : It's a *4-tuple*

  - Source and Destination *ports*

  - Source and Destination *IP address*

- A Layer 3 flow is defined by 2 parameters : It's a *2-tuple*

  - Source and Destination *IP address*

- The *vlan id*, if applicable, may be included in the flow
  definition

  - Flows may therefore be *3-tuple* or *5-tuple*

- When acting on a packet, we need to identify the *flow* it
  belongs to :

- This is called *n-tuple classification*. The `n-tuple` is
  extracted, and its *hash* is computed

- Extracting the `n-tuple` value from a packet is called
  *bisection*

- The hash is used for the subsequent lookup operations, and may be
  computed in hardware.

=== TC example : QDisc

#table(
  columns: (40%, 60%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("tc-qdisc.pdf", width: 100%)])

  ],
  [

    - Queueing Disciplines, or *qdisc*, allow configuring the queue
      policy

    - Multiple qdisc can co-exist, separated into different *classes*

    - *classes* are used to split traffic, and enforce policing

    - Traffic is assigned to classes through *classification*

  ],
)

=== TC example : Classification

- Match traffic with priority 0 or 4, and assign it to class "1:20"

  ```bash
  tc filter add dev eth0 parent 1: basic match 'meta(priority eq 0)' \
  or 'meta(priority eq 4)' classid 1:20
  ```

- In *ingress*, classification is usually done to assign traffic
  to queues

- It can also be used for early filtering :

  ```bash
  tc qdisc add dev eth0 ingress
  tc filter add dev eth0 protocol ip parent ffff: flower \
  ip_proto tcp dst_port 80 \
  action drop
  ```

- `tc-flower` can also be offloaded to hardware, see
  #manpage("tc-flower", "8")

=== TC example : shaping

- Traffic Shaping, consists in limiting the egress rate of a flow

- Multiple strategies exist :

  - Add Jitter on purpose : \ `tc qdisc add dev eth0 root netem delay 10ms 5ms`

  - Use a Token Bucket filter : \ `tc qdisc add dev eth0 parent 1:1 handle 10: tbf rate 256kbit`

- This can be combined with classification :

  ```bash
  tc qdisc add dev eth0 root handle 1: prio
  tc qdisc add dev eth0 parent 1:3 handle 30: tbf rate 250kbit
  tc filter add dev eth0 protocol ip parent 1:0 prio 3 u32 match ip \
  dst 192.168.42.2/32 flowid 1:3
  ```

=== TC example : editing

- TC also allows editing traffic or metadata on-the-fly

- This is done with the `skbedit` action

- This can be used to change the `skb->priority` field

- Can also control which Hardware *tx queue* will be used

```bash
tc filter add dev eth0 parent 1: protocol ip prio 1 u32 \
match ip dst 192.168.0.3 \
action skbedit priority 6
```

=== TC mqprio

#table(
  columns: (30%, 70%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("txq_mq.pdf", width: 80%)])

  ],
  [

    - Most Network Controllers today have multiple queues in `tx` and `rx`

    - They implement in hardware a *policing* algorithm to select the
      next `tx` queue to use

      - It can be a simple *weighted round robin* algorithm

      - Alternatively a *strict priority* selection

      - Some controllers also implement Time-aware scheduling for queue
        selection

  ],
)

=== TC mqprio

#align(center, [#image("TX_path_tc_mqprio.pdf", width: 70%)])

=== TC offloads

- Some TC operations can be offloaded to the Ethernet Controler, if
  supported

- `tc mqprio` - The Hardware will implement the queue-selection
  algorithm

- `tc taprio` - For TSN-enabled hardware

- `tc flower` - Classification in *ingress* is done by hardware
