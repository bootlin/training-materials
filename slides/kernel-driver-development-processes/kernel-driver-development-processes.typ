#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Processes, scheduling and interrupts

== Processes and scheduling
<processes-and-scheduling>

===  Process, thread?

- Confusion about the terms #emph[process], #emph[thread] and
  #emph[task]

- In UNIX, a process is created using `fork()` and is composed of

  - An address space, which contains the program code, data, stack,
    shared libraries, etc.

  - A single thread, which is the only entity known by the scheduler.

- Additional threads can be created inside an existing process, using
  `pthread_create()`

  - They run in the same address space as the initial thread of the
    process

  - They start executing a function passed as argument to
    `pthread_create()`

===  Process, thread: kernel point of view

- In kernel space, each thread running in the system is represented by a
  structure of type #kstruct("task_struct")

- From a scheduling point of view, it makes no difference between the
  initial thread of a process and all additional threads created
  dynamically using `pthread_create()`

#v(0.5em)

#align(center, [#image("address-space.pdf", height: 60%)])

===  Relation between execution mode, address space and context

- When speaking about #emph[process] and #emph[thread], these concepts
  need to be clarified:

  - #emph[Mode] is the level of privilege allowing to perform some
    operations:

    - #emph[Kernel Mode]: in this level CPU can perform any operation
      allowed by its architecture; any instruction, any I/O operation,
      any area of memory accessed.

    - #emph[User Mode]: in this level, certain instructions are not
      permitted (especially those that could alter the global state of
      the machine), some memory areas cannot be accessed.

  - Linux splits its #emph[address space] in #emph[kernel space] and
    #emph[user space]

    - #emph[Kernel space] is reserved for code running in #emph[Kernel
      Mode].

    - #emph[User space] is the place were applications execute
      (accessible from #emph[Kernel Mode]).

  - #emph[Context] represents the current state of an execution flow.

    - The #emph[process context] can be seen as the content of the
      registers associated to this process: execution register, stack
      register...

    - The #emph[interrupt context] replaces the #emph[process context]
      when the interrupt handler is executed.

===  A thread life

#align(center, [#image("threads-life.pdf", height: 90%)])

===  Execution of system calls

#align(center, [#image("syscalls.pdf", width: 100%)])

The execution of system calls takes place in the context of the thread
requesting them.
