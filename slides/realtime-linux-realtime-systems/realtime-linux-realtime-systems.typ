#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Realtime Systems

=== Realtime Operating System

A real-time system is a time-bound system which has well-defined, fixed time constraints.
Processing must be done within the defined constraints or the system will fail.
#v(0.5em)
#align(center, [Wikipedia])
#v(0.5em)
- The correctness of the program's computations is important

- The time taken to perform the computation is equally important

=== Determinism

The same input must always yield the same output

- In an Realtime system, the timing for event and data processing must
  be consistent

- This is trivial on single-task single-core systems

- On multi-tasking systems, critical tasks should be deterministic

- The influence of CPU sharing and external interrupts must be fully
  predictable

=== Latencies

Time elapsed between an event and the reaction to the event

- The Worst Case Execution Time is very difficult to predict

- We therefore want bounds on the Worst Case Reaction Time

- Latencies are the main focus for Realtime Operating Systems

#v(0.5em)

#align(center, [#image("latency-basic.pdf", width: 90%)])

=== Design constraints - Throughput

#table(
  columns: (40%, 60%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("triangle_design_throughput.pdf", width: 100%)])

  ],
  [

    - Optimize most-likely scenario

    - Might have a fast path and a slow path

    - Use Hardware Offloading and caches

    - Use Branch-Prediction and Speculative execution

    - Latencies are acceptable for cold-start

    - Most modern hardware implement such features

  ],
)

=== Design constraints - Low Power

#table(
  columns: (40%, 60%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("triangle_design_power.pdf", width: 100%)])

  ],
  [

    - Opportunistic sleeping modes

    - Dynamic Frequency Scaling

    - Only go fast when required

    - Long wakeup latencies

    - Power-Management firmware can preempt the whole system

  ],
)

=== Design constraints - Determinism

#table(
  columns: (40%, 60%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("triangle_design_determinism.pdf", width: 100%)])

  ],
  [

    - Avoid unpredictable effects

    - Caches, Hardware Offload are hard to predict

    - Avoid sleeping too deep, to wakeup fast

    - Make the system fully preemptible

    - Try to keep control over every aspect of the system

  ],
)

=== Security Features and Fixes

- Hardware security flaws are discovered quite often

- Spectre, Meltdown, Foreshadow, Rowhammer

- Some can only be mitigated through software fixes...

- ... that can introduce some latencies

- In other cases, security features are actually beneficial for Realtime

- To mitigate timing-based attacks, making the system predictable is
  crucial

- *core scheduling* is also a good example, to deal with
  Hyperthreading issues

=== Multi-tasking

- Modern OSes are designed to be multi-task

- The CPU time is shared between applications

- The Scheduler decides who runs at any given time

- The scheduler is invoked at several occasions:

  - When an application waits for external data or events

  - When external data or events needs to be processed

  - Periodically, at every *System Tick* (between 300Hz and 1KHz)

  - Tickless systems are throughput oriented, but can also be useful for
    RT

- Switching between tasks is called *context switching*

=== Preemption

- Ability to stop whatever the CPU is running to run another task

- Useful for general-purpose OS, to share execution time

- Critical for an RTOS, to run critical tasks

- Any task should be preemptible, both in userspace and kernelspace

=== Understanding preemption (1)

- Most multi-tasking OSes are preemptive operating systems, including
  Linux

- When a task runs in user space mode and gets interrupted by an
  interrupt, if the interrupt handler wakes up another task, this task
  can be scheduled as soon as we return from the interrupt handler.

#v(0.5em)

#align(center, [#image("userspace-preemption.pdf", width: 90%)])

=== Understanding preemption (2)

- However, when the interrupt comes while the task is executing a system
  call, this system call has to finish before another task can be
  scheduled.

- By default, the Linux kernel does not do kernel preemption.

- This means that the time before which the scheduler will be called to
  schedule another task is unbounded.

#v(0.5em)

#align(center, [#image("kernel-preemption.pdf", width: 100%)])

=== Interrupts and events

- Hardware interrupts are a common source of latencies

- Interrupts run in a dedicated context

- Other interrupts are disabled while the interrupt handler runs

- Non-important interrupts can preempt critical tasks

#v(0.5em)

#align(center, [#image("irq_preemption.pdf", height: 60%)])

=== Scheduling and proritizing

- The Scheduler is a key component in guaranteeing RT behaviour

- There exist realtime and non-realtime scheduling algorithms

- Most realtime OSes rely on task prioritization

- Tasks with the same priority can be handled in a FIFO or Round-Robin
  manner

=== Locking

- Multitasking implies concurrent accesses to resources

- Critical resources must be protected by a dedicated mechanism

- Mutexes and semaphores help synchronize (or serialize) accesses

- This needs to be looked at closely in RT context

- A low-priority task migh hold a lock, blocking a high-priority task

- *mutex*: Two states (taken, free). The task that has taken the
  mutex is the *owner*

- *semaphore*: Shared variable that is incremented by multiple
  users.

=== Lock Families

#align(center, [*Semaphores*])

#v(0.5em)

- Semaphores rely on a *counter* that is positive or null

- A task trying to access the critical section decrements a counter

- A task is blocked if the counter can't be decremented

- Multiple tasks can be in a critical section, hence there's no single
  owner

#v(0.5em)

#align(center, [*Mutexes*])

#v(0.5em)

- *Mut*ually *ex*clusive

- Have two states: Taken, Free

- The task that has taken the mutex is the *owner*

- Other tasks wait for the mutex to be free before taking it

- A Mutex is a semaphore with a counter that can only be incremented
  once

=== Priority inversion

- Priority inversion arises when strict priority-based scheduling
  interfers with locking

- It creates a scenario where a critical task is prevented from running
  by a lower priority task

=== Priority inversion

#align(center, [#image("priority_inversion.pdf", height: 50%)])

#v(0.5em)

- Task A (high priority) needs to access a lock, hold by task C (low
  priority)

- The scheduler runs task C so that it can release the lock

- Task B has a higher priority than C, but lower than A, preempts task C

=== Priority Inheritance

- The solution for the Priority Inversion issue is *priority
  inheritance*

- The scheduler detects that task C holds a lock needed by task A

- Task C`s priority is boosted to A`s priority until it releases the
  lock

- Task B can no longer preempt task C!

#v(0.5em)

#align(center, [#image("priority_inheritance.pdf", height: 50%)])

=== Priority Inheritance (2)

- *\P*\riority *\I*\nheritance (PI) only works with Mutexes

- Semaphores don't have owners, so we can't apply this mechanism

- Another way to prevent Priority Inversion is by careful design

- Limit critical section accesses only to tasks with the same priority

- PI support exists for `pthread_mutex_t` in Linux
