#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Testing and Benchmarking

===  Benchmarking vs Testing

- *Benchmarking* will give you system-wide metrics for:

  - Your hardware platform

  - Your Kernel configuration

  - Your Non-critical userspace stack

- *Testing* will ensure that your business application behaves
  correctly

- Stressing tools used for benchmarking can also be used for testing

- It's important to always consider the *Worst Case Scenario*

===  ftrace - Kernel function tracer

Infrastructure that can be used for debugging or analyzing latencies and
performance issues in the kernel.

- Very well documented in #kdochtml("trace/ftrace")

- Negligible overhead when tracing is not enabled at run-time.

- Traces *events*, defined within the kernel code, in
  *per-cpu buffers*

- Events have associated context:

  - `sched:sched_switch` : Context switch, indicates `prev_pid`,
    `next_pid`

- Can also be used to trace any kernel function with the
  *function tracer*

===  Using ftrace

- Tracing information available through the `tracefs` virtual fs

- Mount this filesystem as follows: \
  `mount -t tracefs nodev /sys/kernel/tracing`

- On some systems, it can also be found in `/sys/kernel/debug/tracing`

- Check available tracers:

  - `cat /sys/kernel/tracing/available_tracers`

- Select the interesting events:

  - `echo 1 > /sys/kernel/tracing/events/[X/Y/]enable`

- Start/stop tracing:

  - `echo [0|1] > /sys/kernel/tracing/tracing_on`

- Retrieve the trace:

  - `/sys/kernel/tracing/trace`: The trace buffers merged

  - `/sys/kernel/tracing/trace_pipe`: Stream the trace buffers,
    consuming data

  - `/sys/kernel/tracing/per-cpu/cpuX/trace`: Per-cpu traces

===  Scheduling latency tracer 

#[ #show raw.where(block: true): set text(size: 12pt)

#kconfig("CONFIG_SCHED_TRACER")
(_Kernel Hacking_ section)

- Maximum recorded time between waking up a top priority task and its
  scheduling on a CPU, expressed in us.

- Check that `wakeup` is listed in
  `/sys/kernel/tracing/available_tracers`

- To select, reset and enable this tracer:

  ```
  echo wakeup > /sys/kernel/tracing/current_tracer 
  echo 0 > /sys/kernel/tracing/tracing_max_latency 
  echo 1 > /sys/kernel/tracing/tracing_enabled
  ```

- Let your system run, in particular real-time tasks. \
  Dummy example: `chrt -f 5 sleep 1`

- Disable tracing: 

  ```
  echo 0 > /sys/kernel/tracing/tracing_enabled
  ```

- Read the maximum recorded latency and the corresponding trace: 

  ```
  cat /sys/kernel/tracing/tracing_max_latency
  ```
]

===  trace-cmd

#[ #set list(spacing: 0.5em)

- Wrapper around the `ftrace` interface

- Trace only during a program execution:

  - `trace-cmd record <opts> <cmd>`

  - `trace-cmd report`

- Start, stop and show the trace buffer:

  - `trace-cmd start <opts>`

  - `trace-cmd stop`

  - `trace-cmd show`

- Save the content of the trace buffer for further analysis:

  - `trace-cmd extract`

- Options

  - Events: `-e sched`, `-e sched:sched_switch`

  - Plugins: `-p function`

  - Tracers: `-t osnoise`

  - Functions: `-f netif_tx_wake_queue`

]

===  rtla 

*\R*\eal*\T*\ime *\L*\inux *\A*\nalysis tool

- Developped by Daniel Bristot de Oliveira

- High-level interface to the `timerlat` and `osnoise` tracers

- `rtla osnoise|timerlat top|hist` gives high-level view of noise and
  latencies

- Can generate histograms, that can then be visualized

===  rtla - osnoise

- Gives an overview of "noise" sources from the Kernel and the
  Hardware

- Uses a similar measurement loop as `hwlatdetect`

- Uses `tracepoints` to detect the source of noise:

  - Thread Latency: Latencies due to the measuring thread being
    preempted

  - SoftIRQ Latency: Latencies due to softIRQ processing

  - IRQ Latency: Latencies introduced by IRQs

  - NMI Latency: Latencies introduced by NMIs

  - Hardware Latency: Latencies that aren't explained by any of the
    above

- `trace-cmd start -p osnoise`: Start recording os noise events

- `trace-cmd start -p osnoise -e osnoise`: Start recording noise events
  and trace their cause

===  rtla - timerlat

#align(center, [#image("rtla.pdf", width: 100%)])

- Periodic, per-cpu wakeup latency measurement in-kernel

- Can differentiate the IRQ wakeup time from the scheduling wakeup time

- Can use `osnoise` tracepoints to analyze the delay sources

- Can also trace *User return* latency, to benchmark custom
  applications

===  rtla autoanalysis

- Running `timerlat -a <us>` will trigger the auto-analysis mode

- A threshold is set with `-a`

- Measurement will stop if a latency higher than the threshold is
  detected

- Timerlat then prints a stack trace with the cause of the latency

- Can identify if the latency comes from a *blocking* or an
  *interference*

- Can identify the *task* of *interrupt* at the origin of
  the latency

- Can identify if the *hardware* itself is the culprit

===  rtla - hwnoise

- Focus on Hardware-induced latencies

- Similar to osnoise, but runs with *interrupts disabled*

- Only the hardware or non-maskable interrupts can interfere with
  measurements

- Tries to assign the noise to `NMI` when it can

- *NMI-based* watchdogs and *Hyperthreading* can cause
  such latencies

===  kernelshark

- Kernelshark is a graphical interface for processing ftrace reports

- It's better used with `trace-cmd`, an interface to ftrace

- Useful when a deep analysis is required for a specific bug

- `trace-cmd list`

- `trace-cmd record -e <event> [<command>]`

- `kernelshark`

===  hwlatdetect 

Tool provided by `rt-tests`, relying on a dedicated `ftrace` tracer.

- Predecessor to *rtla hwnoise*

- Runs a tight loop on all CPU cores with local interrupts disabled

- Only NMIs and Hardware Latencies can interrupt the loop

- Samples a high precision timer and looks for large gaps between
  samples

- Useful to benchmark and validate a hardware platform

- Must *not* be used in production environment, introduces huge
  latencies

===  cyclictest

- Tool that tests the System and Kernel Latencies

- Provided by the `rt-test` suite

- Schedules timer events and compares the expected and actual wakeup
  time

- Measures the kernel-induced latencies, but also hardware-induced
  latencies

- Can create graphs, and be used with tracing subsystems

- Best used in conjunction with various stressing workloads

- Should be run for long amounts of time

===  hackbench 

Stress and benchmark the Linux Kernel Scheduler

- Stresses the scheduler by creating lots of processes of threads

- They communicate with each-other through sockets or pipes

- This generates lots of context switches and scheduling events

- Useful to check how a RT program behaves when heavy workloads run in
  parallel

===  stress-ng 

Very feature-full stressing utility, with more than 260 stressors

- Can stress very specific aspects of the system:

  - Specific syscalls

  - CPU instructions and computations

  - Caches, Memory access, Page-faults

  - Network and Filesytem stacks

- Very useful to accurately simulate known workloads

===  rteval

- Allows orchestrating stressing tools and testing tools

- Loads are *hackbench*, *kcompile* and *stress-ng*

- Testing tools are *cyclictest* and *timerlat*

- Describe a full test through configuration files

- Generates a test report

- Ideal to integrate in a CI environment

#link("https://git.kernel.org/pub/scm/utils/rteval/rteval.git/")

== Benchmarking an application
<benchmarking-an-application>

===  strace 

strace is a userspace tool that trace system-calls and signals

- Help analyze how an application interacts with the kernel

- Some syscalls can be detrimental to RT behaviour

- strace can help understand what an application does

- Helpful for external libraries

===  perf 

perf is a performance analysis tool that gathers kernel and hardware statistics

- Uses Hardware Counters and monitoring units

- Uses Kernel Counters and the tracing infrastructure

- Can profile the whole system, an application, a CPU core, etc.

- Very versatile, but tied to the kernel version

- Perf relies on various *events* reported by the kernel

===  Using perf, examples

- Lots of events measurable: hardware events, software events, cache
  misses, power management

  - `perf list`

- Display statistics in real-time

  - `perf top`

  - `perf top -e cache-misses`

  - `perf top -e context-switches`

- Investigate scheduling latencies

  - `perf sched record`

  - `perf sched latency`

===  Other useful tools

- `vmstat`: Displays the system state, interrupts, context switches...

  - `vmstat -w 0`

- `powertop`: Display the CPU usage

- `cat /sys/kernel/realtime`: Indicates if the RT Patch is applied

- `htop`: Displays running tasks, including kernel tasks
