#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= eBPF

=== The ancestor: Berkeley Packet filter

- BPF stands for Berkeley Packet Filter and was initially used for
  network packet filtering

- BPF is implemented and used in Linux to perform Linux Socket Filtering
  (see #kdochtml("networking/filter"))

- tcpdump and Wireshark heavily rely on BPF (through libpcap) for packet
  capture

=== BPF in libpcap: setup

#table(
  columns: (70%, 30%),
  stroke: none,
  gutter: 15pt,
  [

    - tcpdump passes the capture filter string from the user to libpcap

    - libpcap translates the capture filter into a binary program

      - This program uses the instruction set of an abstract machine (the
        "BPF instruction set")

    - libpcap sends the binary program to the kernel via the `setsockopt()`
      syscall

  ],
  [

    #align(center, [#image("bpf-setup.svg", height: 90%)])

  ],
)

=== BPF in libpcap: capture

#table(
  columns: (60%, 40%),
  stroke: none,
  gutter: 15pt,
  [

    - The kernel implements the BPF "virtual machine"

    - The BPF virtual machine executes the program for every packet

    - The program inspects the packet data and returns a non-zero value if
      the packet must be captured

    - If the return value is non-zero, the packet is captured in addition to
      regular packet processing

  ],
  [

    #align(center, [#image("bpf-capture.svg", height: 90%)])

  ],
)

=== eBPF (1/2)

- #link("https://ebpf.io/")[eBPF] is a new framework allowing to run
  small user programs directly in the kernel, in a safe and efficient
  way. It has been added in kernel 3.18 but it is still evolving and
  receiving updates frequently.

- eBPF programs can capture and expose kernel data to userspace, and
  also alter kernel behavior based on some user-defined rules.

- eBPF is event-driven: an eBPF program is triggered and executed on a
  specific kernel event

- A major benefit from eBPF is the possibility to reprogram the kernel
  behavior, without performing kernel development:

  - no risk of crashing the kernel because of bugs

  - faster development cycles to get a new feature ready

#align(center, [#image("logo_ebpf.png", height: 20%)])
#text(size: 13pt)[#align(center, [Image credits: #link("https://ebpf.io/")])]

=== eBPF (2/2)

- The most notable eBPF features are:

  - A new instruction set, interpreter and verifier

  - A wide variety of "attach" locations, allowing to hook programs
    almost anywhere in the kernel

  - dedicated data structures called "maps", to exchange data between
    multiple eBPF programs or between programs and userspace

  - A dedicated `bpf()` syscall to manipulate eBPF programs and data

  - plenty of (kernel) helper functions accessible from eBPF programs.

=== eBPF program lifecycle

#align(center, [#image("bpf_lifecycle.svg", height: 90%)])

=== Kernel configuration for eBPF

- #kconfig("CONFIG_NET") to enable eBPF subsystem

- #kconfig("CONFIG_BPF_SYSCALL") to enable the `bpf()` syscall

- #kconfig("CONFIG_BPF_JIT") to enable JIT on programs and so
  increase performance

- #kconfig("CONFIG_BPF_JIT_ALWAYS_ON") to force JIT

- #kconfigval("CONFIG_BPF_UNPRIV_DEFAULT_OFF", "n") in
  *development* to allow eBPF usage without root

- You may then want to enable more general features to "unlock"
  specific hooking locations:

  - #kconfig("CONFIG_KPROBES") to allow hooking programs on kprobes

  - #kconfig("CONFIG_TRACING") to allow hooking programs on kernel
    tracepoints

  - #kconfig("CONFIG_NET_CLS_BPF") to write packets classifiers

  - #kconfig("CONFIG_CGROUP_BPF") to attach programs on cgroups
    hooks

=== eBPF ISA

- eBPF is a "virtual" ISA, defining its own set of instructions: load
  and store instruction, arithmetic instructions, jump instructions,etc

- It also defines a set of 10 64-bits wide registers as well as a
  calling convention:

  - `R0`: return value from functions and BPF program

  - `R1, R2, R3, R4, R5`: function arguments

  - `R6, R7, R8, R9`: callee-saved registers

  - `R10`: stack pointer

#v(0.5em)

#[ #show raw.where(lang: "console", block: true): set text(size: 14pt)
  ```console
  ; bpf_printk("Hello %sn", "World");
        0:  r1 = 0x0 ll
        2:  r2 = 0xa
        3:  r3 = 0x0 ll
        5:  call 0x6
  ; return 0;
        6:  r0 = 0x0
        7:  exit
  ```]

=== The eBPF verifier

- When loaded into the kernel, a program must first be validated by the
  eBPF verifier.

- The verifier is a complex piece of software which checks eBPF programs
  against a set of rules to ensure that running those may not compromise
  the whole kernel. For example:

  - a program must always return and so not contain paths which could
    make them "infinite" (e.g: no infinite loop)

  - a program must make sure that a pointer is valid before
    dereferencing it

  - a program can not access arbitrary memory addresses, it must use
    passed context and available helpers

- If a program violates one of the verifier rules, it will be rejected.

- Despite the presence of the verifier, you still need to be careful
  when writing programs! eBPF programs run with preemption enabled (but
  CPU migration disabled), so they can still suffer from concurrency
  issues

  - There are mechanisms and helpers to avoid those issues, like per-CPU
    maps types.

=== Program types and attach points

- There are different categories of hooks to which a program can be
  attached:

  - an arbitrary kprobe

  - a kernel-defined static tracepoint

  - a specific perf event

  - throughout the network stack

  - and a lot more, see #ksym("bpf_attach_type")

- A specific attach-point type can only be hooked with a set of specific
  program types, see #ksym("bpf_prog_type") and
  #kdochtml("bpf/libbpf/program_types").

- The program type then defines the data passed to an eBPF program as
  input when it is invoked. For example:

  - A `BPF_PROG_TYPE_TRACEPOINT` program will receive a structure
    containing all data returned to userspace by the targeted
    tracepoint.

  - A `BPF_PROG_TYPE_SCHED_CLS` program (used to implement packets
    classifiers) will receive a #kstruct("__sk_buff"), the kernel
    representation of a socket buffer.

  - You can learn about the context passed to any program type by
    checking \ #kfile("include/linux/bpf_types.h")

=== eBPF maps

- eBPF programs exchange data with userspace or other programs through
  maps of different nature:

  - `BPF_MAP_TYPE_ARRAY`: generic array storage. Can be
    differentiated per CPU

  - `BPF_MAP_TYPE_HASH`: a storage composed of key-value pairs. Keys
    can be of different types: `__u32`, a device type, an IP
    address...

  - `BPF_MAP_TYPE_QUEUE`: a FIFO-type queue

  - `BPF_MAP_TYPE_CGROUP_STORAGE`: a specific hash map keyed by a
    cgroup id. There are other types of maps specific to other object
    types (inodes, tasks, sockets, etc)

  - etc...

- For basic data, it is easier and more efficient to directly use eBPF
  global variables (no syscalls involved, contrary to maps)

=== The `bpf() syscall`

- The kernel exposes a `bpf()` syscall to allow interacting with the
  eBPF subsystem

- The syscall takes a set of subcommands, and depending on the
  subcommand, some specific data:

  - #ksym("BPF_PROG_LOAD") to load a bpf program

  - #ksym("BPF_MAP_CREATE") to allocate maps to be used by a
    program

  - #ksym("BPF_MAP_LOOKUP_ELEM") to search for an entry in a map

  - #ksym("BPF_MAP_UPDATE_ELEM") to update an entry in a map

  - etc

- The syscall works with file descriptors pointing to eBPF resources.
  Those resources (program, maps, links, etc) remain valid while there
  is at least one program holding a valid file descriptor to it. Those
  are automatically cleaned once there are no user left.

- For more details, see #manpage("bpf", "2")

=== Writing eBPF programs

- eBPF programs can either be written directly in raw eBPF assembly or
  in higher level languages (e.g: C or rust), and are compiled using the
  clang compiler.

- The kernel provides some helpers that can be called from an eBPF
  program:

  - `bpf_trace_printk` Emits a log to the trace buffer

  - `bpf_map_{lookup,update,delete}_elem` Manipulates maps

  - `bpf_probe_{read,write}[_user]` Safely read/write data from/to
    kernel or userspace

  - `bpf_get_current_pid_tgid` Returns current Process ID and Thread
    group ID

  - `bpf_get_current_uid_gid` Returns current User ID and Group ID

  - `bpf_get_current_comm` Returns the name of the executable running
    in the current task

  - `bpf_get_current_task` Returns the current
    #kstruct("task_struct")

  - Many other helpers are available, see #manpage("bpf-helpers", "7")

- Kernel also exposes kfuncs (see #kdochtml("bpf/kfuncs")), but
  contrary to bpf-helpers, those do not belong to the kernel stable
  interface.

=== Manipulating eBPF program

- There are different ways to build, load and manipulate eBPF programs:

  - One way is to write an eBPF program, build it with clang, and then
    load it, attach it and read data from it with bare `bpf()` calls in
    a custom userspace program

  - One can also use `bpftool` on the built ebpf program to manipulate
    it (load, attach, read maps, etc), without writing any userspace
    tool

  - Or we can write our own eBPF tool thanks to some intermediate
    libraries which handle most of the hard work, like libbpf

  - We can also use specialized frameworks like BCC or bpftrace to
    really get all operations (bpf program build included) handled

=== BCC

#table(
  columns: (70%, 30%),
  stroke: none,
  gutter: 15pt,
  [

    - BPF Compiler Collection (BCC) is (as its name suggests) a collection
      of BPF based tools.

    - BCC provides a large number of ready-to-use tools written in BPF.

    - Also provides an interface to write, load and hook BPF programs more
      easily than using "raw" BPF language.

    - Available on a large number of architecture (Unfortunately, not
      ARM32).

      - On debian, when installed, all tools are named \ `<tool>-bpfcc`.

    - BCC requires a kernel version >= 4.1.

    - BCC evolves quickly, many distributions have old versions: you may
      need to compile from the latest sources

  ],
  [

    #image("logo_bcc.png", height: 25%)
    #v(0.5em)
    #text(size: 12pt)[Image credits: \ #link("https://github.com/iovisor/bcc")]

  ],
)

=== BCC tools

#align(center, [#image("bcc_tracing_tools_2019.png", height: 90%)])

#text(size: 12pt)[#align(
  center,
  [Image credits: #link("https://www.brendangregg.com/ebpf.html")],
)]

=== BCC Tools example

#[
  #show raw.where(lang: "console", block: true): set text(size: 14pt)

  - `profile.py` is a CPU profiler allowing to capture stack traces of
    current execution. Its output can be used for flamegraph generation:

  #v(0.5em)

  ```console
  $ git clone https://github.com/brendangregg/FlameGraph.git
  $ profile.py -df -F 99 10 | ./FlameGraph/flamegraph.pl > flamegraph.svg
  ```

  #v(0.5em)

  - `tcpconnect.py` script displays all new TCP connection live

  #v(0.5em)

  ```console
  $ tcpconnect
  PID    COMM         IP SADDR            DADDR            DPORT
  220321 ssh          6  ::1              ::1              22
  220321 ssh          4  127.0.0.1        127.0.0.1        22
  17676  Chrome_Child 6  2a01:cb15:81e4:8100:37cf:d45b:d87d:d97d 2606:50c0:8003::154 443
  [...]
  ```

  #v(0.5em)

  - And much more to discover at #link("https://github.com/iovisor/bcc")

]

=== Using BCC with python

- BCC exposes a `bcc` module, and especially a `BPF` class

- eBPF programs are written in C and stored either in external files or
  directly in a python string.

- When an instance of the `BPF` class is created and fed with the
  program (either as string or file), it automatically builds, loads,
  and possibly attaches the program

- There are multiple ways to attach a program:

  - By using a proper program name prefix, depending on the targeted
    attach point (and so the attach step is performed automatically)

  - By explicitly calling the relevant attach method on the `BPF`
    instance created earlier

=== Using BCC with python

- Hook with a _kprobe_ on the `clone()` system call and display
  `"Hello, World!"` each time it is called

#v(0.5em)

```python
#!/usr/bin/env python3

from bcc import BPF

# define BPF program
prog = """
int hello(void *ctx) {
    bpf_trace_printk("Hello, World!n");
    return 0;
}
"""
# load BPF program
b = BPF(text=prog)
b.attach_kprobe(event=b.get_syscall_fnname("clone"), fn_name="hello")
```

=== libbpf

- Instead of using a high level framework like BCC, one can use libbpf
  to build custom tools with a finer control on every aspect of the
  program.

- libbpf is a C-based library that aims to ease eBPF programming thanks
  to the following features:

  - userspace APIs to handle open/load/attach/teardown of bpf programs

  - userspace APIs to interact with attached programs

  - eBPF APIs to ease eBPF program writing

- Packaged in many distributions and build systems (e.g.: Buildroot)

- Learn more at #link("https://libbpf.readthedocs.io/en/latest/")

=== eBPF programming with libbpf (1/2)

#text(size: 15pt)[`my_prog.bpf.c`]
#v(-0.1em)
#[ #show raw.where(lang: "c", block: true): set text(size: 10pt)

  ```c
        #include <linux/bpf.h>
        #include <bpf/bpf_helpers.h>
        #include <bpf/bpf_tracing.h>

        #define TASK_COMM_LEN 16
        struct {
          __uint(type, BPF_MAP_TYPE_ARRAY);
          __type(key, __u32);
          __type(value, __u64);
          __uint(max_entries, 1);
        } counter_map SEC(".maps");

        struct sched_switch_args {
          unsigned long long pad;
          char prev_comm[TASK_COMM_LEN];
          int prev_pid;
          int prev_prio;
          long long prev_state;
          char next_comm[TASK_COMM_LEN];
          int next_pid;
          int next_prio;
        };
  ```
]

- The fields to define in the `*_args` structure are obtained from the
  event description in `/sys/kernel/tracing/events` (see
  #link("https://elixir.bootlin.com/linux/v6.12/source/tools/testing/selftests/bpf/progs/test_stacktrace_map.c#L41")[this example])

=== eBPF programming with libbpf (2/2)

#text(size: 15pt)[`my_prog.bpf.c`]
#v(-0.1em)
#[ #show raw.where(lang: "c", block: true): set text(size: 10pt)
  ```c
        SEC("tracepoint/sched/sched_switch")
        int sched_tracer(struct sched_switch_args *ctx)
        {
          __u32 key = 0;
          __u64 *counter;
          char *file;

          char fmt[] = "Old task was %s, new task is %sn";
          bpf_trace_printk(fmt, sizeof(fmt), ctx->prev_comm, ctx->next_comm);

          counter = bpf_map_lookup_elem(&counter_map, &key);
          if(counter) {
                  *counter += 1;
                  bpf_map_update_elem(&counter_map, &key, counter, 0);
          }

          return 0;
        }

        char LICENSE[] SEC("license") = "Dual BSD/GPL";
  ```
]

=== Building eBPF programs

#[
  #show raw.where(lang: "console", block: true): set text(size: 16pt)

  - An eBPF program written in C can be built into a loadable object
    thanks to clang:

    ```console
      $ clang -target bpf -O2 -g -c my_prog.bpf.c -o my_prog.bpf.o
    ```

    - The `-g` option allows to add debug information as well as BTF
      information

  - GCC can be used too with recent versions

    - the toolchain can be installed with the `gcc-bpf` package in
      Debian/Ubuntu

    - it exposes the `bpf-unknown-none` target

  - To easily manipulate this program with a userspace program based on
    libbpf, we need "skeleton" APIs, which can be generated with to
    `bpftool`

]

=== bpftool

#[
  #show raw.where(lang: "console", block: true): set text(size: 16pt)

  - `bpftool` is a command line tool allowing to interact with bpf object
    files and the kernel to manipulate bpf programs:

    - Load programs into the kernel

    - List loaded programs

    - Dump program instructions, either as BPF code or JIT code

    - List loaded maps

    - Dump map content

    - Attach programs to hooks (so they can run)

    - etc

  - You may need to mount the bpf filesystem to be able to pin a program
    (needed to keep a program loaded after bpftool has finished running):

  #v(0.5em)

  ```console
          $ mount -t bpf none /sys/fs/bpf
  ```

]

=== bpftool

#[
  #show raw.where(lang: "console", block: true): set text(size: 15pt)

  - List loaded programs

  #v(0.5em)

  ```console
  $ bpftool prog
  348: tracepoint  name sched_tracer  tag 3051de4551f07909  gpl
  loaded_at 2024-08-06T15:43:11+0200  uid 0
  xlated 376B  jited 215B  memlock 4096B  map_ids 146,148
  btf_id 545
  ```

  #v(0.5em)

  - Load and attach a program

  #v(0.5em)

  ```console
  $ mkdir /sys/fs/bpf/myprog
  $ bpftool prog loadall trace_execve.bpf.o /sys/fs/bpf/myprog autoattach
  ```

  #v(0.5em)

  - Unload a program

  #v(0.5em)

  ```console
  $ rm -rf /sys/fs/bpf/myprog
  ```

]

=== bpftool

#[
  #show raw.where(lang: "console", block: true): set text(size: 12pt)

  - Dump a loaded program
  #v(0.5em)
  ```console
  $ bpftool prog dump xlated id 348
  int sched_tracer(struct sched_switch_args * ctx):
  ; int sched_tracer(struct sched_switch_args *ctx)
    0: (bf) r4 = r1
    1: (b7) r1 = 0
  ; __u32 key = 0;
    2: (63) *(u32 *)(r10 -4) = r1
  ; char fmt[] = "Old task was %s, new task is %s\n";
    3: (73) *(u8 *)(r10 -8) = r1
    4: (18) r1 = 0xa7325207369206b
    6: (7b) *(u64 *)(r10 -16) = r1
    7: (18) r1 = 0x7361742077656e20
  [...]
  ```]

- Dump eBPF program logs
#v(0.5em)
#[ #show raw.where(lang: "console", block: true): set text(size: 10pt)

  ```console
  $ bpftool prog tracelog
  kworker/u80:0-11  [013] d..41  1796.003605: bpf_trace_printk: Old task was kworker/u80:0, new task is swapper/13
  <idle>-0          [013] d..41  1796.003609: bpf_trace_printk: Old task was swapper/13, new task is kworker/u80:0
  sudo-18640        [010] d..41  1796.003613: bpf_trace_printk: Old task was sudo, new task is swapper/10
  <idle>-0          [010] d..41  1796.003617: bpf_trace_printk: Old task was swapper/10, new task is sudo
  [...]
  ```
]

=== bpftool

- List created maps
#[ #show raw.where(lang: "console", block: true): set text(size: 12pt)
  #v(0.5em)
  ```console
  $ bpftool map
  80: array  name counter_map  flags 0x0
      key 4B  value 8B  max_entries 1  memlock 256B
      btf_id 421
  82: array  name .rodata.str1.1  flags 0x80
      key 4B  value 33B  max_entries 1  memlock 288B
      frozen
  96: array  name libbpf_global  flags 0x0
      key 4B  value 32B  max_entries 1  memlock 280B
  [...]
  ```]
#v(0.5em)
- Show a map content
#v(0.5em)
#[ #show raw.where(lang: "console", block: true): set text(size: 12pt)

  ```console
  $ sudo bpftool map dump id 80
  [{
    "key": 0,
    "value": 4877514
    }
  ])
  ```
]

=== bpftool

- Generate libbpf APIs to manipulate a program

#v(0.5em)
#[ #show raw.where(lang: "console", block: true): set text(size: 14pt)

  ```console
  $ bpftool gen skeleton trace_execve.bpf.o name trace_execve > trace_execve.skel.h
  ```]
#v(0.5em)

- We can then write our userspace program and benefit from high level
  APIs to manipulate our eBPF program:

  - instantiation of a global context object which will have references
    to all of our programs, maps, links, etc

  - loading/attaching/unloading of our programs

  - eBPF program directly embedded in the generated header as a byte
    array

=== Userspace code with libbpf

#[ #show raw.where(lang: "c", block: true): set text(size: 10pt)

  ```c
        #include <stdlib.h>
        #include <stdio.h>
        #include <unistd.h>
        #include "trace_sched_switch.skel.h"

        int main(int argc, char *argv[])
        {
            struct trace_sched_switch *skel;
            int key = 0;
            long counter = 0;

            skel = trace_sched_switch__open_and_load();
            if(!skel)
                exit(EXIT_FAILURE);
            if (trace_sched_switch__attach(skel)) {
                trace_sched_switch__destroy(skel);
                exit(EXIT_FAILURE);
            }

            while(true) {
                bpf_map__lookup_elem(skel->maps.counter_map, &key, sizeof(key), &counter, sizeof(counter), 0);
                fprintf(stderr, "Scheduling switch count: %dn", counter);
                sleep(1);
            }

            return 0;
        }
  ```]

=== eBPF programs portability (1/2)

- Kernel internals, contrary to userspace APIs, do not expose stable
  APIs. This means that an eBPF program manipulating some kernel data
  may not work with another kernel version

- The CO-RE (Compile Once - Run Everywhere) approach aims to solve this
  issue and make programs portable between *kernel versions*. It
  relies on the following features:

  - your kernel must be built with
    #kconfigval("CONFIG_DEBUG_INFO_BTF", "y") to have BTF data
    embedded. BTF is a format similar to dwarf which encodes data layout
    and functions signatures in an efficient way.

  - your eBPF compiler must be able to emit BTF relocations (both clang
    and GCC are capable of this on recent versions, with the `-g`
    argument)

  - you need a BPF loader capable of processing BPF programs based on
    BTF data and adjust accordingly data accesses: `libbpf` is the
    de-facto standard bpf loader

  - you then need eBPF APIs to read/write to CO-RE relocatable
    variables. libbpf provides such helpers, like `bpf_core_read`

- To learn more, take a look at
  #link(
    "https://nakryiko.com/posts/bpf-core-reference-guide/",
  )[Andrii Nakryiko'sCO-RE guide]

=== eBPF programs portability (2/2)

- Despite CO-RE, you may still face different constraints on different
  kernel versions, because of major features introduction or change,
  since the eBPF subsystem keeps receiving frequent updates:

  - eBPF tail calls (which allow a program to call a function) have been
    added in version 4.2, and allow to call another program only since
    version 5.10

  - eBPF spin locks have been added in version 5.1 to prevent concurrent
    accesses to maps shared between CPUs.

  - Different attach types keep being added, but possibly on different
    kernel versions when it depends on the architecture: fentry/fexit
    attach points have been added in kernel 5.5 for x86 but in 6.0 for
    arm32.

  - Any kind of loop (even bounded) was forbidden until version 5.3

  - `CAP_BPF` capability, allowing a process to perform eBPF tasks, has
    been added in version 5.8

=== eBPF for tracing/profiling

- eBPF is a very powerful framework to spy on kernel internals: thanks
  to the wide variety of attach point, you can expose almost any kernel
  code path and data.

- In the mean time, eBPF programs remain isolated from kernel code,
  which makes it safe (compared to kernel development) and easy to use.

- Thanks to the in-kernel interpreter and optimizations like JIT
  compilation, eBPF is very well suited for tracing or profiling with
  low overhead, even in production environments, while being very
  flexible.

- This is why eBPF adoption level keeps growing for debugging, tracing
  and profiling in the Linux ecosystem. As a few examples, we find eBPF
  usage in:

  - tracing frameworks like #link("https://github.com/iovisor/bcc")[BCC]
    and #link("https://github.com/bpftrace/bpftrace")[bpftrace]

  - network infrastructure components, like
    #link("https://github.com/cilium/cilium")[Cilium] or
    #link("https://github.com/projectcalico/calico")[Calico]

  - network packet tracers, like
    #link("https://github.com/cilium/pwru")[pwru] or
    #link("https://github.com/feiskyer/dropwatch")[dropwatch]

  - And many more, check #link("https://ebpf.io/applications/")[ebpf.io]
    for more examples

=== eBPF: resources

- BCC tutorial:
  #link(
    "https://github.com/iovisor/bcc/blob/master/docs/tutorial_bcc_python_developer.md",
  )[https://github.com/iovisor/bcc/blob/master/docs/tutorial_bcc_python_developer.md]

- libbpf-bootstrap: #link("https://github.com/libbpf/libbpf-bootstrap")

- A Beginner'sGuide to eBPF Programming - Liz Rice, 2020

  - Video:
    #link(
      "https://www.youtube.com/watch?v=lrSExTfS-iQ",
    )[https://www.youtube.com/watch?v=lrSExTfS-iQ]

  - Resources: #link("https://github.com/lizrice/ebpf-beginners")

#v(0.5em)

#align(center, [#image("ebpf_liz_rice_2020.png", height: 45%)])
