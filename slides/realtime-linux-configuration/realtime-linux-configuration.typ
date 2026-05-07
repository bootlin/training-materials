#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Configuring the system

===  Configuration

- The Linux Kernel has a lot of available configurations

- Some are dedicated to performance

  - Focus on improving the most-likely scenario

  - Have the best average performance

  - Optimize throughput and low-latency

  - Usually have a slow-path, which is non-deterministic

- Some are dedicated to security and hardening

- Some can be useful for Deterministic Behaviour

===  CPU Pinning

- The Linux Kernel Scheduler allows setting constraints about the CPU
  cores that are allowed to run each task

- This can be useful for lots of purposes:

  - Make sure that a process won't be migrated to another core

  - Dedicate cores for specific tasks

  - Optimize the data-path if a process deals with data handled by a
    specific CPU core

  - Ease the job of the scheduler's CPU load-balancer, whose complexity
    grows non-linearly with the number of CPUs

- This mechanism is called the `cpu affinity` of a process

- The `cpuset` subsystem and the `sched_setaffinity` syscall are used
  to select the CPUs

- Use `taskset -p <mask> <cmd>` to start a new process on the given
  CPUs

===  CPU Isolation

- Users can pin processes to CPU cores through the cpu affinity
  mechanism

- But the kernel might also schedule other processes on these CPUs

- `isolcpus` can be passed on the kernel commandline

- Isolated CPUs will not be used by the scheduler

- The only way to run processes on these CPUs is with cpu affinity

- Very useful when RT processes coexist with non-RT processes

`isolcpus=0,2,3`

===  CPU Isolation - cpusets

- `cpuset` is a mechanism allowing to subdivide the CPU scheduling pool

- They are created at runtime, through the `cpusetfs`

  - `mount -t cpuset none /dev/cpuset`

- cpusets are created at will in the cpuset main directory

  - `mkdir /dev/cpuset/rt-set`

  - `mkdir /dev/cpuset/non-rt-set`

- Each cpuset is assigned a pool of cpu cores

  - `/bin/echo 2,3 > /dev/cpuset/rt-set`

  - `/bin/echo 0,1 > /dev/cpuset/non-rt-set`

- We can then select which task gets to run in each cpuset
  
  - `while read i; do /bin/echo $i; done < /dev/cpuset/tasks > /dev/cpuset/ nontrt-set/tasks`
  
  - `/bin/echo $$ > /dev/cpuset/rt-set/tasks`

- You can run tasks in a given set with `cgexec -g cpuset:rt-set ...`

===  IRQ affinity

- Interrupts are handled by a specific CPU core

- The default CPU that handles interrupts is the CPU 0

- On Multi-CPU systems, it can be good to balance interrupt handling
  between CPUs

- Similarly, we might also want to prevent CPUs from handling external
  interrupts

- IRQs can be pinned to CPUs by tweaking `/proc/irq/XX/smp_affinity`

- The `irqbalance` tool monitors and distributes the irq affinty to
  spread the load across CPUs

- Use the `IRQBALANCE_BANNED_CPUS` environment variable to make
  `irqbalance` ignore some CPUs

- The `irqaffinity` cmdline parameter can also be used

===  RCU Callbacks and Workqueues

#align(center, [*RCU*])

#v(0.5em)

- *\R*\ead *\C*\opy *\U*\pdate

- Synchronisation mechanism that can deferred object reclamation

- Deffered reclamation can be executed on any CPU `RCU callbacks`

- We can prevent CPU cores from running RCU callbacks with \
  `rcu_nocbs=<cpus> rcu_nocb_poll`

#v(0.5em)

#align(center, [*Workqueues*])

#v(0.5em)

- Deferred execution mechanism

- Can be pinned to CPUs in `/sys/devices/virtual/workqueue/cpumask`

===  tuna

- Tool to easily setup *cpu isolation* and *irq
  affinities*

- Written in *python*

- `tuna isolate -c 3-5`

  - Removes CPUs 3,4 and 5 from every tasks's affinity list

  - Removes CPUs 3,4 and 5 from every IRQ's affinity list

- `tuna run -c 4 -p fifo:3 <cmd>`

  - Runs `cmd` on CPU core *4*, using `SCHED_FIFO` with a
    priority of *3*.

#include "/common/scheduling-classes.typ"

===  Scheduling order

#table(columns: (30%, 70%), stroke:none, gutter: 15pt, [

#align(center, [#image("sched_precedence.pdf", width: 100%)])

],[

- When invoked, the scheduler looks for runnable tasks in a specific
  order

- `SCHED_FIFO` and `SCHED_RR` share the same *runqueue*

- However when a `SCHED_RR` task yields, any same prio `SCHED_FIFO`
  will run until done

- until *v6.6*, `SCHED_OTHER` and `SCHED_BATCH` uses the
  *\C*\ompletely *\F*\air *\S*\cheduler

- It was then replaced by *EEVDF* (Earliest Eligible Virtual
  Deadline First) Scheduler, improved in *v6.12*.

])

===  Realtime Throttling

#align(center, [#image("rt_throttling.pdf", width: 90%)])

#v(0.5em)

- An infinite loop in a high-priority task will starve everything else

- `/proc/sys/kernel/sched_rt_period_us` : Time sharing period (`-1`
  to disable)

- `/proc/sys/kernel/sched_rt_runtime_us` : Amount of time in each
  period dedicated to RT tasks

- The default values allocates 95% of the CPU time to RT tasks

- Can be used *per-cgroup*

===  Deadline Server

- RT Throttling can be overkill, as it fires even when no non-RT tasks
  needs to run

- The Deadline Server is a more precise replacement mechanism

- Uses a dedicated `SCHED_DEADLINE` task, the *deadline server*

- Available in *v6.12*, configurable in *debugfs*

- Won`t trigger if there`s no starving non-realtime task

- The starving task will only use the bandwidth it needs

- Replaces the old throttling mechanism, except for *grouping*

===  System timer

- The Scheduler is invoked on a regular basis to perform time-sharing
  activities

- This is sequenced through the *system ticks*, generated by a
  high resolution timer

- Several policies regarding system ticks are available:

- #kconfig("CONFIG_HZ_PERIODIC"): Always tick at a given rate. This
  introduces small interferences but is deterministic.

- #kconfig("CONFIG_NO_HZ_IDLE"): Disable the tick when idle, for
  powersasving

  - Longer wakeup from Idle, replay the missed ticks (*jiffies*
    housekeeping)

- #kconfig("CONFIG_NO_HZ_FULL"): Actively disables ticking even
  when not idle.

  - Per-CPU setting, through the `nohz_full=<range>` boot parameter

  - Only relevant on multi-core systems, one core must stay in
    nohz_idle mode

  - `nohz_full` cores will automatically offload their *RCU*

  - Slightly more expensive Kernel to User transitions

===  System timer

#[ #set list(spacing: 5em)
#table(columns: (70%, 30%), stroke:none, gutter: 15pt, [

#align(center, [#image("hz.pdf", width: 100%)])

],[

- Tick always enabled 

- Tick disabled in Idle 

- Tick disabled in Idle and when only one runnable task

])]

===  Writing a driver 

A few considerations can be taken when writing a driver

- Avoid using #ksym("raw_spinlock_t") unless really necessary

- Avoid forcing non-threaded interrupts, unless writing a driver
  involved in interrupt dispatch

  - irqchip, gpio-irq drivers

  - cpufreq and cpuidle drivers due to scheduler interaction

- Beware of DMA bus mastering and other serialized IO buffering

  - Certain register writes are buffered until the next register read
