#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Preempt RT

===  The PREEMPT_RT preemption level

- One way to implement a multi-task Real-Time Operating System is to
  have a preemptible system

- Any task can be interrupted at any point so that higher priority tasks
  can run

- Userspace preemption already exists in Linux

- The Linux Kernel also supports real-time scheduling policies

- However, code that runs in kernel mode isn't fully preemptible

- Preempt-RT aims at making all code running in kernel mode preemptible

- `PREEMPT_RT` is a *compile-time* configuration option

  - It may only accessible after applying a patch, the *Preempt
    RT Patch*

  - The patch is being included as part of the Linux kernel

===  PREEMPT_RT mainlining status

- The project has made steady progress since it got funding from the
  Linux Foundation in 2015 (Linux version 4.1 at that time).

- The `PREEMPT_RT` option no longer requires applying the "Preempt RT
  patch" on some architectures, starting from v6.12

  - `x86_64`, `arm64` and `RISCV` are supported so far

  - Other architectures still require the patch on v6.12.

- Stable versions of the patch are still maintained for older kernels

===  Why use PREEMPT_RT?

- Allow using the POSIX/Linux API, which is portable and familiar

- Benefit from the huge hardware support provided by Linux

- Run common software in non-RT mode, and custom critical software in
  parallel

- Benefit from the community support and help

===  Why not to use PREEMPT_RT?

- The hardware Linux typically runs on isn't designed with RT in mind

- The RT patch makes the Kernel deterministic and preemptible...

- ... but the goal is not to have the lowest latencies possible

- Using the `PREEMPT_RT` mode has performance impacts

  - Use it when you know your requirements

===  Getting the patch

- Starting from *v6.12*, applying a patch isn't needed on
  *x86*, *arm64* and *RiscV*

- For other architectures, or older kernels, the patch is still needed.

- It can be downloaded as a set of patches or a single patch: 
  #link("https://cdn.kernel.org/pub/linux/kernel/projects/rt/")

- Kernel trees with the patch applied are also available:

  - #link("https://git.kernel.org/cgit/linux/kernel/git/rt/linux-rt-devel.git")

  - #link("https://git.kernel.org/cgit/linux/kernel/git/rt/linux-stable-rt.git")

- Most build-systems like Buildroot or Yocto Project support building an
  RT Kernel

===  The legacy of the RT patch 

Many current features in the Linux Kernel originated from the RT patch:

- Kernel-side preemption

- High Resolution Timers

- Threaded interrupts

- Priority-Inheritance support for locking primitives

- Tickless operation

- Earliest-Deadline First scheduler

- Realtime locks - Locking primitives conversion

- Tracing

- Printk

===  Execution contexts

- Code running in kernel mode can do so in different contexts :

  - *NMI* context

  - *hardirq* context

  - *softirq* context

  - *task* context

- Some operations are forbidden depending on the context :

  - Blocking (sleeping) operations are forbidden in *atomic*
    context

- *atomic* context means preemption is forbidden :

  - When not in *task* mode

  - When `preempt_disable()` was called

  - e.g. holding a spinning lock

===  Locking inside the Linux Kernel

- Locks are synchronisation primitives that arbitrate concurrent
  accesses to a resource

- Several locking primitives exist in the Kernel and in Userspace

- Kernel lock families are:

  - Sleeping locks

  - CPU Local locks

  - Spinning locks

===  Sleeping locks

- Sleeping locks will sleep and schedule while waiting

- There are several types of sleeping locks:

  - #ksym("mutex")

  - #ksym("rt_mutex")

  - #ksym("semaphore")

  - #ksym("rw_semaphore")

- Can't be used in *NMI*, *hardirq* and *softirq*
  contexts

===  Spinlocks

- Spinlocks will busy-wait until the lock is freed

- There exist several types of spinlocks:

  - #ksym("spinlock_t")

  - #ksym("rwlock_t")

  - #ksym("raw_spinlock_t")

- Spinlocks will *disable preemption* when taken

- They can be used in *any* context, but with precaution

- With PREEMPT_RT, #ksym("spinlock_t") and #ksym("rwlock_t")
  will become sleeping locks

===  Critical sections

- Spinning locks can be taken with interrupts constraints

- Spinlock functions have variants with some suffixes:

  - `_bh()`

    - Disable / Enable soft interrupts (bottom halves)

  - `_irq()`

    - Disable / Enable interrupts

  - `_irqsave()` / `_irqrestore()`

    - Save and disable or restore interrupt state (if previously
      disabled)

- Dedicated functions also exist, but should be used only for the Kernel
  core

- #kfunc("preempt_disable") / #kfunc("preempt_enable")

  - Disable / Enable preemption, to protect per-CPU data

- #kfunc("migrate_disable") / #kfunc("migrate_enable")

  - Disable / Enable migration, also to protect per-CPU data

===  High resolution timers

- The resolution of the timers used to be bound to the resolution of the
  regular system tick

  - Usually 100 Hz or 250 Hz, depending on the architecture and the
    configuration

  - A resolution of only 10 ms or 4 ms.

  - Increasing the regular system tick frequency is not an option as it
    would consume too many resources

- The high-resolution timers infrastructure allows to use the available
  hardware timers to program interrupts at the right moment.

  - Hardware timers are multiplexed, so that a single hardware timer is
    sufficient to handle a large number of software-programmed timers.

  - Usable directly from user space using the usual timer APIs

===  Printk

- `printk()` is one of the main logging mechanism in the kernel

- It works in all execution context

- It was the last item preventing the RT-patch from being fully upstream

- The last kernel task who printed was in charge of printing the full
  buffer

- A low priority task could block a high priority task by printing lots
  of data

===  Interrupt handlers

- Interrupt handlers run with interrupts disabled

- In PREEMPT_RT, almost all interrupt handlers are *threaded*

- Very small hardware interrupt handlers are used, that have a
  well-defined execution time

- They acknowledge the interrupts, and enqueues the "real" interrupt
  handler

- The interrupt handler runs in a dedicated Kernel thread

- Threaded interrupts are well established in the mainline kernel

- Exceptions: `IRQF_NOTHREAD`, `IRQF_PERCPU`, `IRQS_ONESHOT`

===  Hard interrupts vs. Threaded interrupts

#table(columns: (50%, 50%), stroke:none, gutter: 15pt, [

#figure([#align(center, [#image("/slides/realtime-linux-realtime-systems/irq_preemption.pdf", height: 35%)])],
  caption: [
    Hardware interrupt processing
  ]
)

#figure([#align(center, [#image("softirq_preemption.pdf", height: 35%)])],
  caption: [
    Threaded interrupt processing
  ]
)

],[

- Small, well-defined hard irq handlers

- Irq handlers run in a dedicated task

- It has a PID, and can be assigned a priority

- Critical tasks can run regardless of interrupts

- Use `ps -e` to list tasks

- Use `chrt -p <prio> <pid>` to change the priority

])

===  Uncompatible options
 
- Some configuration options don't play well with realtime

- #kconfig("CONFIG_LOCKUP_DETECTOR") and
  #kconfig("CONFIG_DETECT_HUNG_TASK")

  - Kernel tasks with a priority of 99, can introduce latencies

- `CONFIG_DEBUG_*`

  - Debugging options are very useful

  - Most of them introduce latencies due to heavy logging

  - Some options adds security checks and verifiers (lockdep)

===  Preemption models 

The Linux kernel Scheduler has several preemption models available:

- #kconfig("CONFIG_PREEMPT_NONE") - No Forced Preemption (server)

- #kconfig("CONFIG_PREEMPT_VOLUNTARY") - Voluntary Kernel
  Preemption (Desktop)

- #kconfig("CONFIG_PREEMPT") - Preemptible Kernel (Low-latency
  Desktop)

- #kconfig("CONFIG_PREEMPT_RT") - Fully Preemptible Kernel
  (Real-Time)

===  1st option: no forced preemption

#kconfig("CONFIG_PREEMPT_NONE") \
Kernel code (interrupts, exceptions, system calls) never preempted.
Default behavior in standard kernels.

- Best for systems making intense computations, on which overall
  throughput is key.

- Best to reduce task switching to maximize CPU and cache usage (by
  reducing context switching).

- Still benefits from some Linux real-time improvements: O(1) scheduler,
  increased multiprocessor safety (work on RT preemption was useful to
  identify hard to find SMP bugs).

- Can also benefit from a lower timer frequency (several possible values
  between 100 Hz and 1000 Hz).

===  2nd option: voluntary kernel preemption

#kconfig("CONFIG_PREEMPT_VOLUNTARY") \
Kernel code can preempt itself

- Typically for desktop systems, for quicker application reaction to
  user input.

- Adds explicit rescheduling points (#kfunc("might_sleep"))
  throughout kernel code.

- Minor impact on throughput.

- Still used in: Ubuntu Desktop 20.04

===  3rd option: preemptible kernel 

#kconfig("CONFIG_PREEMPT") \
Most kernel code can be involuntarily preempted at any time. When a
process becomes runnable, no more need to wait for kernel code
(typically a system call) to return before running the scheduler.

- Exception: kernel critical sections (holding spinlocks):

#v(0.5em)

  #align(center, [#image("/common/spinlock-deadlock-with-preemption.pdf", width: 90%)])

#v(0.5em)

- Typically for desktop or embedded systems with latency requirements in
  the milliseconds range. Still a relatively minor impact on throughput.

===  4th option: fully preemptible kernel

#kconfig("CONFIG_PREEMPT_RT") \
Almost all kernel code can be involuntarily preempted at any time.

- spinlocks are turned into sleeping locks

- Only #ksym("raw_spinlock_t") remains a real spinning lock

- All interrupt handlers are threaded, except for a few that explicitely
  need hard irq

  - This is the case for drivers involved in interrupt dispatching

  - cpufreq and cpuidle drivers too

- For use on systems with Realtime requirements

- If you find a kernel-side unbounded latency, *this is a bug*
