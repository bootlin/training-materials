#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Sockets and Data Path

===  Sockets

#table(columns: (20%, 80%), stroke: none, gutter: 15pt, [

#align(center, [#image("socket.pdf", width: 140%)]) 

],[

- The Socket programming model stems from *UNIX*

- It has been the main way for users to transmit data through the
  network since then

- Sockets are about more than networking, their behaviour depends on
  their attributes.

- A socket is represented from userspace as a *file descriptor* :
  
  #[ #show raw.where(lang: "c", block: true): set text(size: 15pt)
  ```c
  int socket(int domain, int type, int protocol);
  ```]

  - see #manpage("socket", "2")

- The `domain` or _family_ defines the *underlying protocol*
  : IPv4, IPv6, Bluetooth, Netlink...

- The `type` defines the *semantics* : Connection-oriented,
  re-transmission, message ordering...

- The `protocol` depends on the domain and type, for further
  configuration.

])

===  Socket Families

#align(center, [` int socket(`*int domain*`, int type, int protocol);`])
#v(1em)

- Families as defined by *UNIX*, *POSIX* or are
  *Linux*-specific

- In Linux, defined in `include/linux/socket.h`

  - `AF_UNIX`, `AF_LOCAL` : Unix Domain Sockets, for IPC. See
    #manpage("unix", "7")

  - `AF_INET`, `AF_INET6` : IPv4 and IPv6 sockets, see
    #manpage("ip", "7")

  - `AF_PACKET` (_raw_ sockets) : Layer 2 sockets, see
    #manpage("packet", "7")

  - `AF_NETLINK`, `AF_ROUTE` : Userspace to kernel sockets for
    configuration, see #manpage("netlink", "7")

  - More specialized families : `AF_BLUETOOTH`, `AF_IEE802154`,
    `AF_NFC`, etc.

- Socket families are named `AF_xxx`, but equivalent names `PF_xxx`
  also exist

  - `PF` standing for *\P*\rotocol *\F*\amily, `AF` for
    *\A*\ddress *\F*\amily

  - legacy from the early UNIX days, `AF` and `PF` enums are equivalent
    on linux.

===  Socket Types

#align(center, [` int socket(int domain, `*int type*`, int protocol);`])
#v(1em)

- Socket type indicates the transmission semantics, which usually means
  Layer 4

- Its meaning depends on the selected *domain* :

  - `socket(AF_INET, SOCK_DGRAM, 0)` : UDP over IPv4 socket

  - `socket(AF_UNIX, SOCK_DGRAM, 0)` : Message-oriented Unix Socket

- `SOCK_STREAM` : Sequenced, reliable, two-way, connection-oriented

  - `socket(AF_INET, SOCK_STREAM, 0)` : TCP over IPv4 socket

- `SOCK_DGRAM` : Transmit datagrams of fixed maximum size, unreliable,
  connection-less

  - `socket(AF_INET, SOCK_DGRAM, 0)` : UDP over IPv4 socket

- `SOCK_RAW` : Raw sockets, usually containing the full *frame*
  including L2

- `SOCK_SEQPACKET`, `SOCK_RDM` : Other types with different ordering
  and message-length attributes

- `SOCK_NONBLOCK`, `SOCK_CLOEXEC` : Extra bitwise flags for
  configuration

===  Socket protocol

#align(center, [` int socket(int domain, int type, `*int protocol*`);`])
#v(1em)

- Complements the tuple `<domain, type>` to allow protocol selection.

  - `socket(AF_INET, SOCK_STREAM, 0)` : TCP over IPv4 socket

  - `socket(AF_INET, SOCK_STREAM, IPPROTO_SCTP)` : SCTP over IPv4
    socket

- For *raw sockets*, allows filtering by Ethertype (in network
  byte order)

  - `socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL))` : All raw frames

  - `socket(AF_PACKET, SOCK_RAW, htons(ETH_P_IP))` : All IPv4 frames

  - `socket(AF_PACKET, SOCK_RAW, htons(ETH_P_8021Q))` : All Vlan
    frames

===  binding a socket

- The `bind()` call allows associating a *local address* to a
  socket, see #manpage("bind", "2")

- For connection-oriented, necessary before being able to
  *accept* connections

- The socket's address format is represented by the generic `struct
  sockaddr`.

#[ #show raw.where(lang: "c", block: true): set text(size: 15pt)
```c
struct sockaddr {
        sa_family_t sa_family;
        char        sa_data[14];
}
```

- The sockaddr must be subclassed by *family-specific* addresses
  :

```c
struct sockaddr_in {
        sa_family_t    sin_family; /* address family: AF_INET */
        in_port_t      sin_port;   /* TCP/UDP port in network byte order */
        struct in_addr sin_addr;   /* IPv4 address (uint32_t) */
};
```
]

===  listen(), connect() and accept()

`int listen(int sockfd, int backlog)`

- Set the socket as listening for up to `backlog` connections,
  #manpage("listen", "2")

#v(1em)

`int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen)`

- Accepts a remote connection request on a *listening* socket,
  #manpage("accept", "2")

- The peer's address is filled into the `addr` parameter

- Returns a *new socket file descriptor* for that connection

#v(1em)

`int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen)`

- Connect to a remote listening socket, #manpage("connect", "2")

- For connection-less protocols, it simply sets the destination address
  for datagrams

===  socket options

- The `socket()` syscall doesn't allow fine-tuned configuration

- Sockets are configured through `setsockopt`

  - `int setsockopt(int sockfd, int level, int optname, const void
    *optval, socklen_t optlen)`

  - #manpage("setsockopt", "2")

- The options can be used to configure the socket itself :

  - `setsockopt(fd, SOL_SOCKET, ...);`

  - `SO_ATTACH_BPF` : attach BPF programs to sockets

  - `SO_BINDTODEVICE` : bind the socket to an interface

  - see #manpage("socket", "7")

- We can also configure the underlying protocol's behaviour :

  - `setsockopt(fd, proto_num, ...);`

  - The protocol number can be retrieved from `/etc/protocols`

  - See #manpage("ip", "7"), #manpage("tcp", "7"),
    #manpage("udp", "7"), etc.

===  Socket queues

- All sockets are created with 2 queues : A *Receive* queue and a
  *Transmit* queue

- Queue size is the same for every socket at creation time, but can be
  adjusted

  - With the `SO_RCVBUF` socket option, see #manpage("socket",
    "7")

  - Using the `net.core.rmem_default` sysctl

- Packets that can't be queued because the queue is full are dropped

- `netstat` shows the current queue usage of every open socket

===  read() and write()

- Generic syscalls, acting on any kind of file descriptors

- Does not allow passing any extra flags

#v(1em)

`ssize_t read(int fd, void *buf, size_t count)`

- Reads up to `count` bytes from the socket.

- May block until data arrives, unless the socket is non-blocking

#v(1em)

`ssize_t write(int fd, const void *buf, size_t count)`

- Only works on *connected* sockets

- Recipient's address is part of the socket's connection information

- For *datagrams*, `count` can't exceed the datagram size

- Not possible to know if the recipient actually received the message

===  send() and recv()

- Socket-only, very similar to read() and write()

- Also only works with *connected* sockets

- Accepts `MSG_xxx` bitwise flags

#v(1em)

`ssize_t recv(int sockfd, void *buf, size_t len, int flags)`

- Similar to `read()`

- `MSG_PEEK` : Receives a message without consuming it from the socket
  queue

- `MSG_TRUNC` : Returns the real size, even if `count` is too small

- `MSG_DONTWAIT` : Per-message non-blocking operation

#v(1em)

`ssize_t send(int sockfd, const void *buf, size_t len, int flags)`

- Accepts a remote connection request on a *listening* socket

- `MSG_MORE` : More data is yet to be sent, as a single datagram or TCP
  message

===  sendto() and recvfrom()

- Socket-only, specifies the peer address per-message

- Allows using the same socket with multiple peers on UDP

#v(1em)

`ssize_t recvfrom(int sockfd, void *buf, size_t len, int flags,`
`struct sockaddr *src_addr, socklen_t *addrlen)`

- Get the address of the peer that sent the message along with the
  message

- `src_addr` and `addrlen` may be null, equivalent to `recv()`

#v(1em)

`ssize_t sendto(int sockfd, const void *buf, size_t len, int flags,`
` const struct sockaddr *dest_addr, socklen_t addrlen`

- Send data to the the peer at the specified address

- On connection-oriented sockets (e.g. TCP), `dest_addr` is ignored

- On Datagram sockets, the address overrides the `connect()` address.

===  sendmsg() and recvmsg()

- Allows passing ancillary data alongside the buffers

- Ancillary data is following the `cmsg` format

- Also allows scatter-gather buffers

#v(1em)

`ssize_t recvmsg(int sockfd, struct msghdr *msg, int flags)`

- Grabs the peer address, like in `recvfrom()`

- Allows reading from the socket _error queue_

  - The error queue contains the original packet content and associated
    errors

  - Also used for *timestamping*

#v(1em)

`ssize_t sendmsg(int sockfd, const struct msghdr *msg, int flags)`

- Sends single or scatter-gather buffers to a designed peer

- Also accepts ancillary data

===  Summary - Server

#[ #show raw.where(lang: "c", block: true): set text(size: 14pt)

+ Create the socket 

  ```c
      int sockfd = socket(AF_INET, SOCK_STREAM, 0);
  ```

+ Bind to the local IP address and port 

  ```c
      struct sockaddr_in addr;
      addr.sin_family = AF_INET;
      addr.sin_port = htons(80);
      inet_aton("87.98.181.233", &addr.in_saddr);
      bind(sockfd, &addr, sizeof(addr));
  ```

+ Listen for new inbound connections 

  ```c
      listen(sockfd, 10);
  ```

+ Wait and accept a new connection 

  ```c
      conn_fd = accept(sockfd, &peer_addr, &peer_addr_len);
  ```

+ Receive data from the client 

  ```c
      recv(conn_fd, buf, 128);
  ```
]

===  Summary - Client

#[ #show raw.where(lang: "c", block: true): set text(size: 14pt)

+ Create the socket 

  ```c
      int sockfd = socket(AF_INET, SOCK_STREAM, 0);
  ```

+ Connect to the server 

  ```c
      struct sockaddr_in addr;
      addr.sin_family = AF_INET;
      addr.sin_port = htons(80);
      inet_aton("87.98.181.233", &addr.sin_addr);
      connect(sockfd, (struct sockaddr *)&addr, sizeof(addr));
  ```

+ Send data to the server 

  ```c
      send(conn_fd, buf, 128);
  ```
]

===  Waiting for data

- The standard file descriptor polling methods also work on sockets

- `select()` and `poll()` can be used to wait for incoming packets

- The `epoll` API is becoming the preferred method nowadays

- `epoll_create()` allows creating *epoll instances* to listen
  on *interest lists*

- `epoll_ctl()` is used to add, modify or remove descriptors to an
  instance

- `epoll_wait()` is then used to wait and process *events*

- This mechanism interacts directly with *NAPI* instances for
  events

- New features such as _IRQ suspension_ rely on epoll

===  Timestamping

- Timestamping traffic is useful for *debugging* and *time
  synchronization* (PTP)

- The `SO_TIMESTAMP` *sockopt* causes timestamp creation for
  *ingress datagrams*

- The newer `SO_TIMESTAMPING` allows configuring the timestamp source :

  - Hardware timestamp generation (configurable through `ethtool`)

  - Software timestamp generation, in the driver

  - TX sched timestamping, can help measure the queueing delay

  - TX ACK for TCP, when the acknowledgment was received

  - TX completion timestamping, when the packet finished being sent

- Timestamping can also be configured *per-packet* with
  `sendmsg()` and `recvmsg()`

- Timestamps are received through `recvmsg` ancillary data in RX

- *TX timestamps* are accessible through the socket's
  *error queue*

  - Packets are looped-back through the error queue with an associated
    timestamp

===  io_uring

- `io_uring` is an alternative to *socket* programming

- It is an asynchronous API, originally developed for the Storage
  subsystem

- Aims at reducing the number of `syscalls` such as `read` and `write`

- Recently, `io_uring` gained network support

  - Applications have to create special ring-buffers shared with the
    kernel

  - Transfers are queued in a TX ring-buffer by userspace

  - A completion ring-buffer is used to know when data has been sent

  - A similar mechanism exists for RX

- Still new and gaining features, see
  #link("https://developers.redhat.com/articles/2023/04/12/why-you-should-use-iouring-network-io")[this introduction post]

===  Sockets in the kernel

#table(columns: (30%, 70%), stroke: none, gutter: 15pt, [

#align(center, [#image("socket_kernel.pdf", width: 100%)])

],[

- Sockets have a *file descriptor*

- It is handled internally with a *pseudo file*

- #kstruct("socket") is the generic representation

  - stores the SOCK_xxx types

  - holds the #kstruct("proto_ops") pointer

  - interfaces with the syscall API

- #kstruct("sock") is what the network stack manipulates

  - more internal representation

  - for use mostly by the network stack

  - maintains the queues, locks, and internal state

])

===  #kstruct("proto_ops")

#table(columns: (50%, 50%), stroke: none, gutter: 15pt, [

#align(center, [#image("socket_proto_ops.pdf", width: 100%)])

],[

- #kstruct("proto_ops") implement the protocol-specific operations

- Selected at socket creation based on the *family*

- Very close to the syscall interface

#[ #show raw.where(lang: "c", block: true): set text(size: 15pt)

```c
struct proto_ops{
...
int (*bind) (struct socket *sock,
             struct sockaddr *myaddr,
             int sockaddr_len); 
int (*sendmsg) (struct socket *sock,
                struct msghdr *m,
                size_t total_len);
...
};
```
]

])

===  sending through a socket

+ Userspace program calls `write()`, `send()`, `sendto()` or `sendmsg()`

+ The corresponding `syscall` is invoked

+ All above syscalls end-up calling #kfunc("__sock_sendmsg")

+ `sock->ops->sendmsg()` is called (#kfunc("inet6_sendmsg"),
  #kfunc("inet_sendmsg"), etc.)

+ `sock->sk_prot->sendmsg()` is called (#kfunc("tcp_sendmsg"),
  #kfunc("udpv6_sendmsg"), etc.)

+ `skb` chain gets created through #kfunc("ip_make_skb") or
  #kfunc("ip6_make_skb")

+ `skb` is then sent with e.g.#kfunc("udp_send_skb"), which calls
  #kfunc("ip_send_skb")

+ The target #kstruct("net_device") is retrieved with
  #kfunc("ip_route_output_key_hash")

  - This is cached in #kstruct("sock")

+ #kfunc("dst_output") is eventually called, handing over from L4 to
  L3

===  L3 processing

- In #kfunc("ip_finish_output") or #kfunc("ip6_finish_output")

- The Layer 2 *MTU* is looked-up (`skb->dev->mtu`)

- The `skb` is *fragmented* if needed

- Once the *routing* information is found, the *neighbour*
  is looked up

- This is usually done by looking up the gateway in the *ARP*
  table

  - ARP tables can be dumped with `ip neigh` (or `arp`)
