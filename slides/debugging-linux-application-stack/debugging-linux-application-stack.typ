#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Linux Application Stack
<linux-application-stack>

== User/Kernel mode
<userkernel-mode>

=== User/Kernel mode

- User mode vs Kernel mode are often used to refer to the privilege
  level of execution.

- This mode actually refers to the processor execution mode which is a
  hardware mode.

  - Might be named differently between architectures but the goal is the
    same

- Allows the kernel to control the full processor state (handle
  exceptions, MMU, etc) whereas the userspace can only do basic control
  and execute under the kernel supervision.

== Introduction to Processes and Threads
<introduction-to-processes-and-threads>

=== Processes and Threads (1/2)

- A process is a group of resources that are allocated by the kernel to
  allow the execution of a program.

  - Memory regions, threads, file descriptors, etc.

- A process is identified by a PID (*P*\rocess *ID*\) and
  all the information that are specific to this process are exposed in
  `/proc/<pid>`.

  - A special file named `/proc/self` accessible by the process
    points to the proc folder associated to it.

- When starting a process, it initially has one execution thread that is
  represented by a #kstruct("task_struct") and that can be
  scheduled.

  - A process is represented in the kernel by a thread associated to
    multiple resources.

=== Processes and Threads (2/2)

- Threads are independent execution units that are sharing common
  resources inside a process.

  - Same address space, file descriptors, etc.

- A new process is created using the fork() system call
  (#manpage("fork", "2")) and a new thread is created using `pthread_create()` (#manpage("pthread_create", "3")).

  - Internally, both will call `clone()` with different flags

- At any moment, only one task is executing on a CPU core and is
  accessible using #kfunc("get_current") function (defined by
  architecture and often stored in a register).

- Each CPU core will execute a different task.

- A task can only be executing on one core at a time.

== MMU and memory management
<mmu-and-memory-management>

=== The MMU

#table(
  columns: (60%, 40%),
  stroke: none,
  gutter: 15pt,
  [

    - Addresses accessed by the CPU are _virtual_

    - The _Memory Management Unit_ (MMU) translates them to
      _physical_ addresses

    - The kernel decides the translation and fills the _page table_

    - The MMU reads the page table and caches recent entries in the
      _Translation lookaside buffers_ (TLB) for zero-delay mapping

  ],
  [

    #align(center, [#image("mmu.pdf", width: 100%)])

  ],
)

=== MMU and memory management

- Physical addresses can be either RAM or I/O (to access devices)

- The MMU allows to restrict access to the page mappings via some
  attributes

  - No Execute, Writable, Readable bits, Privileged/User bit,
    cacheability

- The MMU base unit for mappings is called a page

- Page size is fixed and depends on the architecture/kernel
  configuration.

- Linux can work without an MMU (#kconfigval("CONFIG_MMU", "n")),
  useful for old SoCs without an MMU, but with many limitations

=== Userspace/Kernel memory layout

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [

    - Each process has its own set of virtual memory areas (`mm` field
      of #kstruct("task_struct")).

    - Also have their own page table

      - But share the same kernel mappings

    - By default, all user mapping addresses are randomized to minimize
      attack surface (base of heap, stack, text, data, etc).

      - *A*\ddress *S*\pace *L*\ayout
        *R*\andomization

      - Can be disabled using `norandmaps` command line parameter

  ],
  [

    #align(center, [#image("memory_layout.pdf", height: 90%)])

  ],
)

=== Userspace/Kernel memory layout

Multiple processes have different user memory spaces
#v(0.5em)
#align(center, [#image("multiple_process.pdf", height: 80%)])

=== Kernel memory map

#table(
  columns: (55%, 45%),
  stroke: none,
  gutter: 15pt,
  [

    - The kernel has it own memory mapping.

    - Linear mapping is setup at kernel startup by inserting all the entries
      in the kernel init page table.

    - Multiple areas are identified and their location differs between the
      architectures.

    - *K*\ernel *A*\ddress *S*\pace *L*\ayout
      *R*\andomization also allows to randomize kernel address space
      layout.

      - Can be disabled using ` nokaslr ` command line parameter

  ],
  [

    #align(center, [#image("kernel_layout.pdf", height: 80%)])

  ],
)

=== Userspace memory segments

- When starting a process, the kernel sets up several _Virtual
  Memory Area_\s (VMA), backed by #kstruct("vm_area_struct"), with
  different execution attributes.

- VMA are actually memory zones that are mapped with specific attributes
  (R/W/X).

- A segmentation fault happens when a program tries to access an
  unmapped area or a mapped area with an access mode that is not
  allowed.

  - Writing data in a read-only segment

  - Executing data from a non-executable segment

- New memory zones can be created using `mmap()`
  (#manpage("mmap", "2"))

- Per application mappings are visible in _/proc/<pid>\/maps_

  `
  7f1855b2a000-7f1855b2c000 rw-p 00030000 103:01 3408650  ld-2.33.so
  7ffc01625000-7ffc01646000 rw-p 00000000 00:00 0         [stack]
  7ffc016e5000-7ffc016e9000 r--p 00000000 00:00 0         [vvar]
  7ffc016e9000-7ffc016eb000 r-xp 00000000 00:00 0         [vdso]
  `

=== Virtual memory VS physical memory

- Memory segments can be shared among different processes

- Non-contiguous physical memory can be virtually contiguous
#v(0.5em)
#align(center, [#image("memory_mapping.pdf", height: 80%)])

=== Userspace memory types

#align(center, [#image("mem_type.pdf", height: 80%)])

=== On-demand memory mapping (_Lazy allocation_)

#table(
  columns: (60%, 40%),
  stroke: none,
  gutter: 15pt,
  [

    + Virtual memory is allocated when requested, but not mapped to physical
      memory

    + When the CPU accesses a virtual address not yet physically mapped, a
      _page fault_ happens, and the kernel physically allocates memory

      - For file-backed mappings, implies reading from disk

    + The virtual memory is fully mapped to physical memory only if really
      needed

    - Allows faster program startup, avoids using memory for unused data

    - Execution time not deterministic: for real-time needs, memory can be
      _pre-faulted_

  ],
  [

    #align(center, [#image("lazy_mapping.pdf", height: 85%)])

  ],
)

=== On-demand memory mapping: page faults

- Lazy allocation is implemented based on _Page faults_

  + The CPU accesses a virtual address, valid but not yet physically
    mapped

    - E.g.: executes an instruction or reads/writes data

  + The MMU finds no mapping in the Page table → issues a Page
    fault _exception_ to the CPU

  + The CPU is immediately turned in kernel mode and executes an
    exception vector (a function provided by the kernel)

  + The kernel checks if the virtual address is valid, finds a suitable
    physical page to map, fills the page (reads from disk if needed) and
    creates a page table entry

  + The kernel continues execution normally

  + The MMU now finds a mapping and continues

=== Terms for memory in Linux tools

- When using Linux tools, four terms are used to describe memory:

  - _VSS/VSZ_: Virtual Set Size (Virtual memory size, shared
    libraries included).

  - _RSS_: Resident Set Size (Total physical memory usage, shared
    libraries included).

  - _PSS_: Proportional Set Size (Actual physical memory used,
    divided by the number of times it has been mapped).

  - _USS_: Unique Set Size (Physical memory occupied by the
    process, shared mappings memory excluded).

- VSS >= RSS >= PSS >= USS.

== The process context
<the-process-context>

=== Process context

- The _process context_ can be seen as the content of the CPU
  registers associated to a process: execution register, stack
  register...

- This context also designates an execution state and allows to sleep
  inside kernel mode.

- A process that is executing in process context can be preempted.

- While executing in such context, the current process
  #kstruct("task_struct") can be accessed using
  #kfunc("get_current").
#v(1em)
#align(center, [#image("process_context.pdf", height: 24%)])

== Scheduling
<scheduling>

=== Scheduling

- The scheduler can be invoked for various reasons

  - On a periodic tick caused by interrupt (#kconfig("HZ"))

  - On a programmed interrupt on tickless systems
    (#kconfigval("CONFIG_NO_HZ", "y"))

  - Voluntarily by calling #kfunc("schedule") in code

  - Implicitly by calling functions that can sleep (blocking operations
    such as #kfunc("kmalloc"), #kfunc("wait_event")).

- When entering the schedule function, the scheduler will elect a new
  #kstruct("task_struct") to run and will eventually call the
  #kfunc("switch_to") macro.

- #kfunc("switch_to") is defined by architecture code and it will
  save the current task process context and restore the one of the next
  task to be run while setting the new current task running.

#include "/common/scheduling-classes.typ"

== Execution mode switching
<execution-mode-switching>

=== Execution mode switching

- Execution mode switching is the action of changing the execution mode
  of the processor (Kernel ↔ User).

  - Explicitly by executing system calls instructions (synchronous
    request to the kernel from user mode).

  - Implicitly when receiving exceptions (MMU fault, interrupts,
    breakpoints, etc).

- This state change will end up in a kernel entrypoint (often call
  vectors) that will execute necessary code to setup a correct state for
  kernel mode execution.

- The kernel takes care of saving registers, switching to the kernel
  stack and potentially other things depending on the architecture.

  - Does not use the user stack but a specific kernel fixed size stack
    for security purposes.

=== Exceptions

- Exceptions designate the kind of events that will trigger a CPU
  execution mode change to handle the exception.

- Two main types of exceptions exist: synchronous and asynchronous.

  - Asynchronous exceptions when a fault happens while executing (MMU,
    bus abort, etc) or when an interrupt is received (either software or
    hardware).

  - Synchronous when executing some specific instructions (breakpoint,
    syscall, etc)

- When such exception is triggered, the processor will jump to the
  exception vector and execute the code that was setup for this
  exception.

=== Interrupts

- Interrupts are asynchronous signals that are generated by the hardware
  peripherals.

  - Can also be synchronous when generated using a specific instruction
    (*I*\nter *P*\rocessor *I*\nterrupts for
    instance).

- When receiving an interrupt, the CPU will change its execution mode by
  jumping to a specific vector and switching to kernel mode to handle
  the interrupt.

- When multiple CPUs (cores) are present, interrupts are often directed
  to a single core.

- This is called "IRQ affinity" and it allows to control the IRQ load
  for each CPU

  - See #kdochtml("core-api/irq/irq-affinity") and
    #link("https://linux.die.net/man/1/irqbalance")[man irqbalance(1)]

=== Interrupt context

- While handling the interrupts, the kernel is executing in a specific
  context named _interrupt context_.

- This context does not have access to userspace and should not use
  #kfunc("get_current").

- Depending on the architecture, might use an IRQ stack.

- Interrupts are disabled (no nested interrupt support)!

#v(1em)
#align(center, [#image("interrupt_context.pdf", height: 24%)])

=== System Calls (1/2)

- A system call allows the user space to request services from the
  kernel by executing a special instruction that will switch to the
  kernel mode (#manpage("syscall", "2"))

  - When executing functions provided by the libc (` read() `, `
    write() `, etc), they often end up executing a system call.

- System calls are identified by a numeric identifier that is passed via
  the registers.

  - The kernel exports some defines (in ` unistd.h `) that are named
    ` __NR_<sycall> ` and defines the syscall identifiers.

#v(0.5em)

```C
#define __NR_read 63
#define __NR_write 64
```

=== System Calls (2/2)

- The kernel holds a table of function pointers which matches these
  identifiers and will invoke the correct handler after checking the
  validity of the syscall.

- System call parameters are passed via registers (up to 6).

- When executing this instruction the CPU will change its execution
  state and switch to the kernel mode.

- Each architecture uses a specific hardware mechanism
  (#manpage("syscall", "2"))

#v(0.5em)

```asm
    mov w8, #__NR_getpid
    svc #0
    tstne x0, x1
```

== Kernel execution contexts
<kernel-execution-contexts>

=== Kernel execution contexts

- The kernel runs code in various contexts depending on the event it is
  handling.

- Might have interrupts disabled, specific stack, etc.

=== Kernel threads

- Kernel threads (kthreads) are a special kind of
  #kstruct("task_struct") that do not have any user resources
  associated (`mm == NULL`).

- These processes are cloned from the `kthreadd` process and can be
  created using #kfunc("kthread_create").

- Kernel threads are scheduled and are allowed to sleep much like a
  process executing in process context.

- Kernel threads are visible and their names are displayed between
  brackets under _ps_:

#v(0.5em)

```console
$ ps --ppid 2 -p 2 -o uname,pid,ppid,cmd,cls USER         PID    PPID CMD                         CLS
root           2       0 [kthreadd]                   TS
root           3       2 [rcu_gp]                     TS
root           4       2 [rcu_par_gp]                 TS
root           5       2 [netns]                      TS
root           7       2 [kworker/0:0H-events_highpr  TS
root          10       2 [mm_percpu_wq]               TS
root          11       2 [rcu_tasks_kthread]          TS
```

=== Workqueues

- Workqueues allows to schedule some work to be executed at some point
  in the future

- Workqueues are executing the work functions in kernel threads.

  - Allows to sleep while executing the deferred work.

  - Interrupts are enabled while executing

- Work can be executed either in dedicated work queues or in the default
  workqueue that is shared by multiple users.

=== softirq

- SoftIRQs is a specific kernel mecanism that is executed in software
  interrupt context.

- Allows to execute code that needs to be deferred after interrupt
  handling but needs low latency.

  - Executed right after hardware IRQ have been handled in interrupt
    context.

  - Same context as executing interrupt handler so sleeping is not
    allowed.

- Anyone wanting to run some code in softirq context should likely not
  create its own but prefer some entities implemented on top of it.
  There are for example tasklets, and the BH workqueues (Bottom Half
  workqueues) which aim to replace tasklets since 6.9.

=== Interrupts & Softirqs

#align(center, [#image("softirqs.pdf", width: 100%)])

=== Threaded interrupts

- Threaded interrupts are a mecanism that allows to handle the interrupt
  using a hard IRQ handler and a threaded IRQ handler.

  - Created calling #kfunc("request_threaded_irq") instead of
    #kfunc("request_irq")

- A threaded IRQ handler will allow to execute work that can potentially
  sleep in a kthread.

- One kthread is created for each interrupt line that was requested as a
  threaded IRQ.

  - _kthread_ is named ` irq/<irq>-<name> ` and can be seen
    using _ps_.

=== Allocations and context

- Allocating memory in the kernel can be done using multiple functions:

  - ```c void *kmalloc(size_t size, gfp_t gfp_mask); ```

  - ```c void *kzalloc(size_t size, gfp_t gfp_mask); ```

  - ```c unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order) ```

- All allocation functions take a ` gfp_mask ` parameter which allows
  to designate the kind of memory that is needed.

  - #ksym("GFP_KERNEL"): Normal allocation, can sleep while
    allocating memory (can not be used in interrupt context).

  - #ksym("GFP_ATOMIC"): Atomic allocation, won’t sleep while
    allocating data.

#setuplabframe([Preparing the system], [
  Prepare the STM32MP157D board

  - Build an image using Buildroot

  - Connect the board

  - Load the kernel from SD card

  - Mount the root filesystem over NFS
])
