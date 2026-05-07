#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Hardware

===  Hardware latencies 

The hardware itself can be the source of latencies:

- Power-management features uses sleep states that introduce latencies

- Throughput features introduce lots of cache levels that are hard to
  predict

- Even CPU features like branch-prediction introduce latencies

- Hardware latencies are nowadays unavoidable, but some can be mitigated

- It's important to benchmark the hardware platform early during
  development

===  Non-Maskable Interrupts 

Non-Maskable Interrupts can't be disabled, and can be transparent to the OS

- Common NMIs are System Management Interrupts (SMIs)

- SMIs run in a dedicated context, the System Management Mode

- It often runs low-level firmware code, like BIOS and EFI

- Used for thermal management, remote configuration, and are very opaque

- Can't be prevented, predicted, monitored or controlled

- Modern CPUs can expose a NMI counter

- Kernel-processed NMIs can be instrumented with `ftrace`

- `hwlatdetect` can help measure the NMIs on a given system

===  Deep Firmwares 

On modern hardware, several firmware can run outside the control of the Kernel

- The ARM TrustZone can run firmware like OP-TEE, to handle sensitive
  tasks

- Low-level firmware calls can be made by drivers through SMC calls or
  similar

- Such firmware can disable interrupts while they run

- Depending on the SoC, we might or might not have control over these
  firmware

- `hwlatdetect` and careful driver analysis can help identify these
  issues

===  Memory access 

Accessing a virtual address can trigger a Page Fault if:

- The page isn't mapped yet

- The address is invalid

Programs should first access all pages to populate the page-table, then
pin them with `mlockall()`

On a smaller scale, caching can also impact memory access time, and be
affected by processes running on other CPUs

===  Hyperthreading 

Some CPU cores have 2 pipelines feeding the same ALU. This is known as *Hyperthreading*

- The ALU executes instructions for one pipeline while the other fetches
  instructions

- This maximizes CPU usage and throughput

- Hyperthreads are very sensitive to what the co-thread runs

- Usually we recommend that hyperthreading is disabled for RT

*Core Scheduling* can help with hyperthreading

- Recent kernel development introduced *core scheduling*, in
  v5.14

- The scheduler is aware of hyperthreads, mostly for security reasons

- RT tasks won't have sibling processes scheduled on the same core

- Non-RT process can still benefit from hyperthreading

===  IO Memory and DMA

- When writing drivers that are RT-critical, several considerations
  should be taken

- Some memory busses can buffer accesses and create latency spikes

- PCI accesses can buffer writes until the next read

- Some control busses such as `i2c` can be shared between devices

- DMA accesses can also introduce latencies due to bus mastering

===  NUMA

- *\N*\on *\U*\niform *\M*\emory *\A*\ccess

- For high-end machines and servers, there are several banks of memory
  called *nodes*

- Typically, nodes are closer to some CPUs than others

- The Kernel can migrate pages from one node to another if need be

- Access latency will be longer for distant nodes

- Critical applications must have their memory locked to avoid migration

- Use `numactl` to pin nodes to CPU cores, and pin your application on
  the CPU

===  CPU Idle

- Modern CPUs have several Idle States for better power management

- The deeper the CPU core is sleeping, the longer it takes to wake it up

- Idle states are often called *C-States*

- Other Idle states can also exists, such as *PC-States* on a
  per-package basis

- We can limit the CPU idle states to lightweight states

- This can have a big impact on power consumption and thermal management

#align(center, [#image("cpuidle_latency.pdf", width: 80%)])

===  Idle States

#table(columns: (70%, 30%), stroke: none, gutter: 15pt, [

C-States are defined by:

- `latency`: The time it takes to wake-up

- `residency`: Expected sleeping time for which the state can be used

- `power`: The power consumption in this C-State

The `POLL` state means that the CPU stays in a busy-loop instead of
sleeping

],[

Idle states, Intel i7-8550U

#align(center, [#image("cpu_idle_states_example.pdf", width: 90%)])

])

C-States can be controlled in `/sys/devices/system/cpu/cpuX/cpuidle/`

===  Limiting the Idle states

- Limiting the idle states can be done at runtime

  - `echo 1 > /sys/devices/system/cpu/cpu0/cpuidle/stateX/disable`

- C-States can be also limited at boot-time with boot options:

  - `processor.max_cstates=1`: Limits the deepest sleep state

  - `idle=poll`: Only use polling, never go to sleep

- C-States can also be temporarily limited by an application:

  - While `/dev/cpu_dma_latency` is opened, deep C-States won't be
    used

  - Writing `0` to this file and maintaining it opened emulates
    `idle=poll`

- *Be careful*, using the `POLL` idle state can overheat and
  destroy your CPU!

===  CPU Frequency scaling 

The CPU frequency can also be dynamically changed through DVFS

- Dynamic Voltage and Frequency Scaling

- The frequency can be controlled by the kernel by picking a governor

- The governor selects one of the available *Operating
  Performance Points*

- An *OPP* defines a frequency and voltage at which a core can
  run

- The `performance` governor always uses the highest frequency

- The `powersave` governor uses the lowest frequency

- Other governors can adjust the frequency dynamically

- Adjusting the frequency causes non-deterministic execution times

- `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`

- The governor can also be picked in the Kernel Configuration

===  powertop 

Powertop is a tool to monitor the CPU idle states and frequency usage

- It is designed to optimize the power usage of a system

- Useful to undertstand which C-States and OPP are being used

#v(0.5em)

#align(center, [#image("powertop.png", width: 80%)])
