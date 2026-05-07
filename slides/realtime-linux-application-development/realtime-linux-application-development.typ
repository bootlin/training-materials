#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Application development

===  Real-time application development

- A few best-practices should be followed when developing a real-time
  application

- Some POSIX APIs weren't designed with RT behaviour in mind

- Some syscalls and memory-access patterns will lead to kernel-side
  latencies

- Following the good practises is important

- But benchmarking the application is also crucial

===  Initialization

- Usually, the initialization section of the application doesn't need to
  be RT

- This init section will configure various settings:

  - Allocate and lock the memory

  - Start the threads and configure them

  - Initialize the locks

  - Configure the scheduling parameters (priority, deadlines)

  - Configure the CPU affinity

===  Development and compilation

- No special library is needed, the POSIX real-time API is part of the
  standard C library

- The glibc C library is recommended, as support for some real-time
  features is not mature in other C libraries

  - Priority inheritance mutexes or NPTL on some architectures, for
    example

- Compile a program

  - `ARCH-linux-gcc -o myprog myprog.c -lrt`

- To get the documentation of the POSIX API

  - Install the `manpages-posix-dev` package

  - Run `man function-name`

===  Process, thread?

- Confusion about the terms _process_, _thread_ and
  _task_

- In UNIX, a process is created using `fork()` and is composed of

  - An address space, which contains the program code, data, stack,
    shared libraries, etc.

  - One thread, that starts executing the `main()` function.

  - Upon creation, a process contains one thread

- Additional threads can be created inside an existing process, using
  `pthread_create()`

  - They run in the same address space as the initial thread of the
    process

  - They start executing a function passed as argument to
    `pthread_create()`

===  Process, thread: kernel point of view

- The kernel represents each thread running in the system by a
  #kstruct("task_struct") structure.

- From a scheduling point of view, it makes no difference between the
  initial thread of a process and all additional threads created
  dynamically using `pthread_create()`

#v(0.5em)

#align(center, [#image("thread-vs-process.pdf", width: 80%)])

===  Creating threads

#[ #show raw.where(block: true): set text(size: 14pt)

- Linux supports the POSIX thread API

- To create a new thread

  ```
  pthread_create(pthread_t *thread, pthread_attr_t *attr,
                 void *(*routine)(void*), void *arg);
  ```

- The new thread will run in the same address space, but will be
  scheduled independently

- Exiting from a thread

  ```
  pthread_exit(void *value_ptr);
  ```

- Waiting for the termination of a thread

  ```
  pthread_join(pthread_t *thread, void **value_ptr);
  ```
]

===  Using scheduling classes (1)

#[ #show raw.where(block: true): set text(size: 16pt)

- An existing program can be started in a specific scheduling class with
  a specific priority using the `chrt` command line tool

  - Example: `chrt -f 99 ./myprog` \
    `-f`: #ksym("SCHED_FIFO") \
    `-r`: #ksym("SCHED_RR") \
    `-d`: #ksym("SCHED_DEADLINE")

- The `sched_setscheduler()` API can be used to change the scheduling
  class and priority of a threads

  ```
  int sched_setscheduler(pid_t pid, int policy,
                  const struct sched_param *param);
  ```

  - `policy` can be `SCHED_OTHER`, #ksym("SCHED_FIFO"),
    #ksym("SCHED_RR"), #ksym("SCHED_DEADLINE"), etc. (others
    exist).

  - `param` is a structure containing the priority
]

===  Using scheduling classes (2)

#[ #show raw.where(block: true): set text(size: 15pt) 

- The priority can be set on a per-thread basis when a thread is created

  ```
  struct sched_param parm; 
  pthread_attr_t attr;

  pthread_attr_init(&attr); 
  pthread_attr_setinheritsched(&attr, PTHREAD_EXPLICIT_SCHED); 
  pthread_attr_setschedpolicy(&attr, SCHED_FIFO); 
  parm.sched_priority = 42; 
  pthread_attr_setschedparam(&attr, &parm);
  ```

- Then the thread can be created using `pthread_create()`, passing the
  `attr` structure.

- Several other attributes can be defined this way: stack size, etc.

]

===  Memory layout and allocation

#table(columns: (30%, 70%), stroke:none, gutter: 15pt, [

#align(center, [#image("process_memory.pdf", width: 100%)])

],[

- The *stack* grows down from high addresses

- The *heap* is used for dynamic allocations, grows up to the
  *program break*

- `mmap()` can also be used to allocate memory in-between

- `malloc` uses both `brk` and `mmap`

- Allocated memory needs to be *mapped* to physical memory

- Mapping is done per *page*, usually 4 Kilobytes

- It is created when the page is *first accessed* through a
  *page fault*

- Each page fault will raise an exception, preempt the process and
  introduce latency

])

===  Pre-faulting the stack

#table(columns: (35%, 65%), stroke:none, gutter: 15pt, [

#align(center, [#image("prefault_stack.pdf", width: 100%)])

],[
  
+ Allocate huge buffers on the stack in a sub-function

+ Access (read or write) the whole buffer

+ return from the sub-function

#text(size: 15pt)[stack prefault]
#v(-0.2em)
```c
#define BUFSZ (1024 * 1024 * 8)
static void stack_prefault() {
        volatile char buff[BUFSZ];
        long page_sz;
        int i;

        page_sz = sysconf(_SC_PAGESIZE);

        for (i = 0; i < BUFSZ; i += page_sz)
                buff[i] = 0;
}
```

Each thread's stack must be pre-faulted

])

===  Pre-faulting the heap

#table(columns: (25%, 75%), stroke:none, gutter: 15pt, [

#align(center, [#image("prefault_heap.pdf", width: 100%)])

],[

- The *program break* defines the size of the `.data` segment

- `malloc` uses the `.data` segment as a pool for small buffers

- Prevent the program break from shrinking

  - `mallopt(M_TRIM_THRESHOLD, -1);`

- Prevent `malloc` from using `mmap`

  - By default, `malloc` uses `mmap` for large buffers

  - Once free`d, mmap`d pages won't be re-used

  - `mallopt(M_MMAP_MAX, 0);`

- allocate a huge buffer to move the program break

- Access the whole buffer

- `free()` the buffer

- Subsequent calls to `malloc` will re-use pre-faulted memory

- For multi-threaded applications, pre-fault each *arena*

  - see `M_ARENA_TEST` and `M_ARENA_MAX` `mallopt` options
])
===  Memory management

- Call `mlockall(MCL_CURRENT | MCL_FUTURE)` at init to lock all memory
  regions

- This prevents mapping from being removed

- Beware of `fork()`, since the child will copy-on-write pages

- `malloc`'s implementation is libC specific

- *glibc* implements all the necessary options

- *musl* doesn't implement `mallopt` and may use `mmap`

- *ftrace* can be used to trace pagefaults : \

  - `trace-cmd record -e page_fault* <cmd>`

===  Locking

- When creating multi-threaded applications, use `pthread_mutex_t`

- Avoid using semaphores, which don't have an owner

- These are POSIX mutexes, which have a notion of *ownership*

- Ownership allows to handle *Priority Inheritance* (PI)

- PI needs to be explicitely enabled:
  `pthread_mutexattr_setprotocol(&mattr, PTHREAD_PRIO_INHERIT);`

===  Synchronizing and signaling

- Application might need to wait or react to external events

- Inter-thread signaling should be done with `pthread_cond_wait()`

- Conditions can be attached to mutexes

- Avoid using UNIX Signals

===  timekeeping

- Usually, real-time applications will need timing information

- This can be done by using `clock_gettime(clk_id, &ts)`

- Although counter-intuitive, don't use the `CLOCK_REALTIME` clock id

- `CLOCK_REALTIME` gives the current time, which can be adjusted and is
  non-consistent

- Instead, use `CLOCK_MONOTONIC` which is never adjusted and strictly
  increasing
