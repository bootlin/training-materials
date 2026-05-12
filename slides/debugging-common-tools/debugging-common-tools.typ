#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

#show raw.where(lang: "console", block: true): set text(size: 12pt)

= Linux Common Analysis & Observability Tools

== Pseudo Filesystems
<pseudo-filesystems>

=== Pseudo Filesystems

- Some virtual filesystems are exposed by the kernel and provide a lot
  of information on the system.

- _procfs_ contains information about processes and system
  information.

  - Mounted on `/proc`

  - Often parsed by tools to display raw data in a more user-friendly
    way.

- _sysfs_ provides information about hardware/logical devices,
  association between devices and drivers.

  - Mounted on `/sys`

- _debugfs_ exposes information related to debug.

  - Typically mounted on `/sys/kernel/debug/`

  - `mount -t debugfs none /sys/kernel/debug`

=== procfs

- _procfs_ exposes information about processes and system
  (#manpage("proc", "5")).

  - `/proc/cpuinfo` CPU information.

  - `/proc/meminfo` memory information (used, free, total, etc).

  - `/proc/sys/` contains system parameters that can be tuned. The list
    of parameters that can be modified is available at
    #kdochtml("admin-guide/sysctl/index")

  - `/proc/interrupts`: interrupt count per CPU for each interrupt in
    use

    - We also have one entry per interrupt in `/proc/irq` for specific
      configuration/status for each interrupt line

  - `/proc/<pid>/` process related information

    - `/proc/<pid>/status` process basic information

    - `/proc/<pid>/maps` process memory mappings

    - `/proc/<pid>/fd` file descriptors of the process

    - `/proc/<pid>/task` descriptors of threads belonging to the
      process

  - `/proc/self/` will refer to the process used to access the file

- A list of all available _procfs_ file and their content is
  described at #kdochtml("filesystems/proc") and #manpage("proc", "5")

=== sysfs

- _sysfs_ filesystem exposes information about various kernel
  subsystems, hardware devices and association with drivers
  (#manpage("sysfs", "5")).

- `/sys/bus` contains one directory per bus types

  - `/sys/bus/<bus>/drivers` shows all drivers attached to a bus

  - `/sys/bus/<bus>/devices` shows all devices sitting on a bus

  - Symlinks inside those directories allows inspecting the relationship
    between devices and drivers

- `/sys/class` contains a tree of class devices registered by drivers

- `/sys/kernel` contains interesting files for kernel debugging:

  - `irq` with information about interrupts (mapping, count, etc).

  - `tracing` for tracing control.

- #kdochtml("admin-guide/abi-stable")

=== debugfs

- _debugfs_ is a simple RAM-based filesystem which exposes
  debugging information.

- Used by some subsystems (_clk_, _block_, _dma_,
  _gpio_, etc) to expose debugging information related to the
  internals.

- Usually mounted on `/sys/kernel/debug`

  - Dynamic debug features exposed through
    `/sys/kernel/debug/dynamic_debug` (also exposed in `proc`)

  - Clock tree exposed through `/sys/kernel/debug/clk/clk_summary`.

== ELF file analysis
<elf-file-analysis>

=== ELF files
#table(
  columns: (70%, 30%),
  stroke: none,
  gutter: 15pt,
  [
    *E*\xecutable and *L*\inkable *F*\ormat

    - File starting with a header which holds binary structures defining the
      file

    - Collection of segments and sections that contain data

      - `.text` section: Code

      - `.data` section: Data

      - `.rodata` section: Read-only Data

      - `.debug_info` section: Contains debugging information

    - Sections are part of a segment which can be loadable in memory

    - Same format for all architectures supported by the kernel and also
      `vmlinux` format

      - Also used by a lot of other operating systems as the standard
        executable file format

  ],
  [

    #align(center, [#image("elf_layout.pdf", height: 60%)])

  ],
)

=== binutils for ELF analysis

- The binutils are used to deal with binary files, either object files
  or executables.

  - Includes `ld`, `as` and other useful tools.

- _readelf_ displays information about ELF files (header, section,
  segments, etc).

- _objdump_ allows to display information and disassemble ELF
  files.

- _objcopy_ can convert ELF files or extract/translate some parts
  of it.

- _nm_ displays the list of symbols embedded in ELF files.

- _addr2line_ finds the source code line/file pair from an address
  using an ELF file with debug information

=== binutils example (1/2)

- Finding the address of `ksys_read()` kernel function using _nm_:

  ```console
  $ nm vmlinux | grep ksys_read
  c02c7040 T ksys_read
  ```

- Using _addr2line_ to match a kernel OOPS address or a symbol name
  with source code:

  ```console
  $ addr2line -s -f -e vmlinux ffffffff8145a8b0
  queue_wc_show
  blk-sysfs.c:516
  ```

=== binutils example (2/2)

- Display an ELF header with _readelf_:
#v(0.5em)

```console
$ readelf -h binary
ELF Header:
Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
Class:                             ELF64
Data:                              2's complement, little endian
Version:                           1 (current)
OS/ABI:                            UNIX - System V
ABI Version:                       0
Type:                              DYN (Position-Independent Executable file)
Machine:                           Advanced Micro Devices X86-64
...
```

- Convert an ELF file to a flat binary file using _objcopy_:
#v(0.5em)

```console
$ objcopy -O binary file.elf file.bin
```

=== ldd

- In order to display the shared libraries used by an ELF binary, one
  can use _ldd_ (Generally packaged with C library. See
  #manpage("ldd", "1")).

- _ldd_ will list all the libraries that were used at link time.

  - Libraries that are loaded at runtime using `dlopen()` are not
    displayed.
#v(0.5em)
```console
$ ldd /usr/bin/bash
linux-vdso.so.1 (0x00007ffdf3fc6000)
libreadline.so.8 => /usr/lib/libreadline.so.8 (0x00007fa2d2aef000)
libc.so.6 => /usr/lib/libc.so.6 (0x00007fa2d2905000)
libncursesw.so.6 => /usr/lib/libncursesw.so.6 (0x00007fa2d288e000)
/lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2 (0x00007fa2d2c88000)
```

== Monitoring tools
<monitoring-tools>

=== Monitoring Tools

- Lots of monitoring tools on Linux to allow monitoring various part of
  the system.

- Most of the time, these are CLI interactive programs.

  - Processes with _ps_, _top_, _htop_, etc

  - Memory with _free_, _vmstat_

  - Networking

- Almost all these tools rely on the _sysfs_ or _procfs_
  filesystem to obtain the processes, memory and system information but
  will display them in a more human-readable way.

  - Networking tools use a netlink interface with the networking
    subsystem of the kernel.

== Process and CPU monitoring tools
<process-and-cpu-monitoring-tools>

=== Processes with _ps_

- The _ps_ command allows to display a snapshot of active processes
  and their associated information (#manpage("ps", "1"))

  - Lists both user processes and kernel threads.

  - Displays PID, CPU usage, memory usage, uptime, etc.

  - Uses _/proc/<pid>/_ directory to obtain process information.

  - Almost always present on embedded platforms (provided by
    _Busybox_).

- By default, displays only the current user/current tty processes, but
  output is highly customizable:

  - `aux`/`-e`: show all processes

  - `-L`: show threads

  - `-p`: target a specific process

  - `-o`: select output columns to display

- Useful for scripting and parsing since its output is static.

=== ps example

- Display all processes in a friendly way:
#v(0.5em)
```console
$ ps aux
USER    PID %CPU %MEM    VSZ   RSS TTY STAT START  TIME COMMAND
root      1  0.0  0.0 168864 12800 ?   Ss   09:08  0:00 /sbin/init
root      2  0.0  0.0      0     0 ?   S    09:08  0:00 [kthreadd]
root      3  0.0  0.0      0     0 ?   I<   09:08  0:00 [rcu_gp]
root      4  0.0  0.0      0     0 ?   I<   09:08  0:00 [rcu_par_gp]
root      5  0.0  0.0      0     0 ?   I<   09:08  0:00 [netns]
[...]
root    914  0.0  0.0 396216 16220 ?   Ssl  09:08  0:04 /usr/libexec/udisks2/udisksd
avahi   929  0.0  0.0   8728   412 ?   S    09:08  0:00 avahi-daemon: chroot helper
root    956  0.0  0.1 260304 19024 ?   Ssl  09:08  0:02 /usr/sbin/NetworkManager [...]
root    960  0.0  0.0  17040  5704 ?   Ss   09:08  0:00 /sbin/wpa_supplicant -u [...]
root    962  0.0  0.0 317644 11896 ?   Ssl  09:08  0:00 /usr/sbin/ModemManager
vnstat  987  0.0  0.0   5516  3696 ?   Ss   09:08  0:00 /usr/sbin/vnstatd -n
```

=== Processes with _top_

- _top_ command output information similar to _ps_ but dynamic
  and interactive ().

  - Also almost always present on embedded platforms (provided by
    _Busybox_)
#v(0.5em)
```console
$ top
top - 18:38:11 up  9:29,  1 user,  load average: 2.84, 2.74, 2.02
Tasks: 371 total,   1 running, 370 sleeping,   0 stopped,   0 zombie
%Cpu(s):  5.8 us,  2.1 sy,  0.0 ni, 77.4 id, 14.7 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :  15947.6 total,   1476.9 free,   7685.7 used,   6784.9 buff/cache
MiB Swap:  15259.0 total,  15238.7 free,     20.2 used.   7742.3 avail Mem

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
   2988 cleger    20   0 5184816   1.2g 430244 S  26.7   7.9  60:24.27 firefox-esr
   4326 cleger    20   0   16.4g 208104  81504 S  26.7   1.3   9:27.33 code
    909 root     -51   0       0      0      0 S  13.3   0.0  15:12.15 irq/104-nvidia
  41704 cleger    20   0   38.4g 373744 116984 S  13.3   2.3  13:25.76 code
  91926 cleger    20   0 2514784 145360  95144 S  13.3   0.9   1:29.85 Web Content
```

=== mpstat

- _mpstat_ displays Multiprocessor statistics
  (#manpage("mpstat", "1")).

- Useful to detect unbalanced CPU workloads, bad IRQ affinity, etc.
#v(0.5em)
```console
$ mpstat -P ALL
Linux 6.0.0-1-amd64 (fixe)      19/10/2022      _x86_64_        (4 CPU)

17:02:50     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
17:02:50     all    6,77    0,00    2,09   11,67    0,00    0,06    0,00    0,00    0,00   79,40
17:02:50       0    6,88    0,00    1,93    8,22    0,00    0,13    0,00    0,00    0,00   82,84
17:02:50       1    4,91    0,00    1,50    8,91    0,00    0,03    0,00    0,00    0,00   84,64
17:02:50       2    6,96    0,00    1,74    7,23    0,00    0,01    0,00    0,00    0,00   84,06
17:02:50       3    9,32    0,00    2,80   54,67    0,00    0,00    0,00    0,00    0,00   33,20
```

== Memory monitoring tools
<memory-monitoring-tools>

=== free

- _free_ is a simple program that displays the amount of free and
  used memory in the system (#manpage("free", "1")).

  - Useful to check if the system suffers from memory exhaustion

  - Uses `/proc/meminfo` to obtain memory information.

```console
$ free -h
               total        used        free      shared  buff/cache   available
Mem:            15Gi       7.5Gi       1.4Gi       192Mi       6.6Gi       7.5Gi
Swap:           14Gi        20Mi        14Gi
```

- _A small `free` value does not mean that your system suffers from
  memory depletion! Linux considers any unused memory as "wasted" so
  it uses it for buffers and caches to optimize performance. See also
  `drop_caches` from #manpage("proc", "5") to observe
  buffers/cache impact on free/available memory_

=== vmstat

- _vmstat_ displays information about system virtual memory usage

- Can also display stats from processes, memory, paging, block IO,
  traps, disks and cpu activity (#manpage("vmstat", "8")).

- Can be used to gather data at periodic interval using `vmstat
  <interval> <number>`

```console
$ vmstat 1 6
procs -----------memory----------   ---swap--  -----io---- -system-- ------cpu-----
r  b   swpd   free   buff  cache     si   so    bi    bo    in   cs  us sy id wa st
3  0 253440 1237236 194936 9286980    3    6   186   540    134  157  3  5 82 10  0
```

- _Note: vmstat consider a kernel block to be 1024 bytes_

=== pmap

- `pmap` displays process mappings more easily than accessing
  `/proc/<pid>/maps`  \ (#manpage("pmap", "1")).
#v(0.5em)
```console
# pmap 2002
2002:   /usr/bin/dbus-daemon --session --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
...
00007f3f958bb000     56K r---- libdbus-1.so.3.32.1
00007f3f958c9000    192K r-x-- libdbus-1.so.3.32.1
00007f3f958f9000     84K r---- libdbus-1.so.3.32.1
00007f3f9590e000      8K r---- libdbus-1.so.3.32.1
00007f3f95910000      4K rw--- libdbus-1.so.3.32.1
00007f3f95937000      8K rw---   [ anon ]
00007f3f95939000      8K r---- ld-linux-x86-64.so.2
00007f3f9593b000    152K r-x-- ld-linux-x86-64.so.2
00007f3f95961000     44K r---- ld-linux-x86-64.so.2
00007f3f9596c000      8K r---- ld-linux-x86-64.so.2
00007f3f9596e000      8K rw--- ld-linux-x86-64.so.2
00007ffe13857000    132K rw---   [ stack ]
00007ffe13934000     16K r----   [ anon ]
00007ffe13938000      8K r-x--   [ anon ]
 total            11088K
```

== I/O monitoring tools
<io-monitoring-tools>

=== iostat

- _iostat_ displays information about IOs per device on the system.

- Useful to see if a device is overloaded by IOs.

```console
$ iostat
Linux 5.19.0-2-amd64 (fixe)     11/10/2022      _x86_64_        (12 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           8,43    0,00    1,52    8,77    0,00   81,28

Device      tps  kB_read/s  kB_wrtn/s  kB_dscd/s  kB_read  kB_wrtn  kB_dscd
nvme0n1   55,89    1096,88     149,33       0,00  5117334   696668        0
sda        0,03       0,92       0,00       0,00     4308        0        0
sdb      104,42     274,55    2126,64       0,00  1280853  9921488        0
```

=== iotop

- _iotop_ displays information about IOs much like _top_ for
  each process.

- Useful to find applications generating too much I/O traffic.

  - Needs #kconfigval("CONFIG_TASKSTATS", "y"),
    #kconfigval("CONFIG_TASK_DELAY_ACCT", "y") and
    #kconfigval("CONFIG_TASK_IO_ACCOUNTING", "y") to be enabled
    in the kernel.

  - Also needs to be enabled at runtime: `sysctl -w kernel.task_delayacct=1`

```console
# iotop
Total DISK READ:        20.61 K/s | Total DISK WRITE:        51.52 K/s
Current DISK READ:      20.61 K/s | Current DISK WRITE:      24.04 K/s
    TID  PRIO  USER     DISK READ DISK WRITE>    COMMAND
    2629 be/4 cleger     20.61 K/s   44.65 K/s firefox-esr [Cache2 I/O]
    322 be/3 root        0.00 B/s    3.43 K/s [jbd2/nvme0n1p1-8]
  39055 be/4 cleger      0.00 B/s    3.43 K/s firefox-esr [DOMCacheThread]
      1 be/4 root        0.00 B/s    0.00 B/s init
      2 be/4 root        0.00 B/s    0.00 B/s [kthreadd]
      3 be/0 root        0.00 B/s    0.00 B/s [rcu_gp]
      4 be/0 root        0.00 B/s    0.00 B/s [rcu_par_gp]
      ...
```

== Networking observability tools
<networking-observability-tools>

=== ss

- _ss_ shows the status of network sockets

  - IPv4 and IPv6, UDP, TCP, ICMP and UNIX domain sockets

- Replaces _netstat_, now obsolete

- Gets info from `/proc/net`

- Usage:
  `ss` by default shows connected sockets \
  `ss -l` shows listening sockets \
  `ss -a` shows both listening and connected sockets \
  `ss -4/-6/-x` shows only IPv4, IPv6, or UNIX sockets \
  `ss -t/-u` shows only TCP or UDP sockets \
  `ss -p` shows process using each socket \
  `ss -n` shows numeric addresses \
  `ss -s` shows a summary of existing sockets

- See
  #link("https://www.man7.org/linux/man-pages/man8/ss.8.html")[the ss manpage]
  for all the options

=== ss example output

```console
# ss
Netid State  Recv-Q Send-Q                Local Address:Port            Peer Address:Port  Process
u_dgr ESTAB  0      0                                 * 304840                     * 26673
u_str ESTAB  0      0       /run/dbus/system_bus_socket 42871                      * 26100
icmp6 UNCONN 0      0                                 *:ipv6-icmp                  *:*
udp   ESTAB  0      0          192.168.10.115%wlp0s20f3:bootpc         192.168.10.88:bootps
tcp   ESTAB  0      136                      172.16.0.1:41376           172.16.11.42:ssh
tcp   ESTAB  0      273                    192.168.1.77:55494          87.98.181.233:https
tcp   ESTAB  0      0                   [2a02:...:dbdc]:38466     [2001:...:9]:imap2
...
#
```

=== iftop

- _iftop_ displays bandwidth usage on an interface by remote host

- Visualizes bandwidth using histograms

- `iftop -i eth0`

  #align(center, [#image("iftop.png", width: 90%)])

- The output can be customized interactively

- See #link("https://linux.die.net/man/8/iftop")[the iftop manpage] for
  details

=== tcpdump

- #link("https://www.tcpdump.org/")[_tcpdump_] allows to capture
  network traffic and decode many protocols

- `tcpdump -i eth0`

- based on the _libpcap_ library for packet capture

- It can also store captured packets to a file and read them back

  - In the _pcap_ format or the newer _pcapng_ format

  - `tcpdump -i eth0 -w capture.pcap`

  - `tcpdump -r capture.pcap`

- A BPF capture filter can be used to avoid capturing irrelevant packets

  - `tcpdump -i eth0 tcp and not port 22`

=== tcpdump example output

```console
# tcpdump -i eth0
18:41:22.913058 IP localhost.localnet.40764 > srv.localnet: 14324+ AAAA? bootlin.com. (29)
18:41:22.913797 IP srv.localnet > localhost.localnet.40764: 14324 0/1/0 (89)
18:41:22.914268 IP localhost.localnet > bootlin.com: ICMP echo request, id 3, seq 1, length 64
18:41:23.933063 IP localhost.localnet > bootlin.com: ICMP echo request, id 3, seq 2, length 64
18:41:24.957027 IP localhost.localnet > bootlin.com: ICMP echo request, id 3, seq 3, length 64
18:41:24.996415 IP bootlin.com > localhost.localnet: ICMP echo reply, id 3, seq 3, length 64
^C
# tcpdump -i eth0 tcp and not port 22
... IP B.https > A.38910: Flags [.], ack 469, win 501, options [...], length 0
... IP B.https > A.38910: Flags [P.], seq 2602:2857, ack 469, win 501, options [...], length 255
... IP A.38910 > B.https: Flags [.], ack 2857, win 501, options [...], length 0
... IP A.38910 > B.https: Flags [P.], seq 469:621, ack 2857, win 501, options [...], length 152
... IP B.https > A.38910: Flags [.], ack 621, win 501, options [...], length 0
... IP B.https > A.38910: Flags [P.], seq 2857:3825, ack 621, win 501, options [...], length 968
... IP A.38910 > B.https: Flags [P.], seq 621:779, ack 3825, win 501, options [...], length 158
^C
#
```

=== #link("https://www.wireshark.org/")[Wireshark]

- Similar to tcpdump, but with a GUI

- Also based on libpcap

  - Can capture and use the same BPF capture filters

  - Can load and save the same file formats

    - Useful for embedded: capture on the target with tcpdump, analyze
      on the host with Wireshark

- Has _dissectors_ to decode hundreds of protocols

  - Each individual value from each packet is dissected into a separate
    field

  - Fields are very fine-grained, at least for the most common protocols

- Has _display filters_ that allow filtering _already
  captured_ packets

  - Each dissected field is also a filter key

- Can also capture and decode Bluetooth, USB, D-Bus and more

=== #link("https://www.wireshark.org/")[Wireshark]

#align(center, [#image("wireshark.png", height: 100%)])

#setuplabframe([System Status ], [

  Check what is running on a system and its load

  - Observe processes and IOs

  - Display memory mappings

  - Monitor resources

])
