#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Concurrent Access to Resources: Locking

=== Sources of concurrency issues

- In terms of concurrency, the kernel has the same constraint as a
  multi-threaded program: its state is global and visible in all
  executions contexts

- Concurrency arises because of

  - #emph[Interrupts], which interrupts the current thread to execute an
    interrupt handler. They may be using shared resources (memory
    addresses, hardware registers...)

  - #emph[Kernel preemption], if enabled, causes the kernel to switch
    from the execution of one thread to another. They may be using
    shared resources.

  - #emph[Multiprocessing], in which case code is really executed in
    parallel on different processors, and they may be using shared
    resources as well.

- The solution is to keep as much local state as possible and for the
  shared resources that can't be made local (such as hardware ones), use
  locking.

=== Concurrency protection with locks

#align(center, [#image("concurrency-protection.svg", height: 90%)])

=== Linux mutexes #emph[mutex = #strong[mut]ual #strong[ex]clusion]

- The kernel's main locking primitive. It's a #emph[binary lock]. Note
  that #emph[counting locks] (#emph[semaphores]) are also available, but
  used 30x less frequently.

- The process requesting the lock blocks when the lock is already held.
  Mutexes can therefore only be used in contexts where sleeping is
  allowed.

- Mutex definition:

  - ```c #include <linux/mutex.h> ```

- Initializing a mutex statically (unusual case):

  - ```c DEFINE_MUTEX(name); ```

- Or initializing a mutex dynamically (the usual case, on a per-device
  basis):

  - ```c void mutex_init(struct mutex *lock); ```

=== Locking and unlocking mutexes 1/2

- ```c void mutex_lock(struct mutex *lock); ```

  - Tries to lock the mutex, sleeps otherwise.

  - Caution: cannot be interrupted, resulting in processes you cannot
    kill!

- ```c int mutex_lock_killable(struct mutex *lock); ```

  - Same, but can be interrupted by a fatal (#ksym("SIGKILL"))
    signal. If interrupted, returns a non zero value and doesn't hold
    the lock. Test the return value!!!

- ```c int mutex_lock_interruptible(struct mutex *lock); ```

  - Same, but can be interrupted by any signal.

- ```c void mutex_unlock(struct mutex *lock); ```

  - Releases the lock. Do it as soon as you leave the critical section.

=== Spinlocks

- Locks to be used for code that is not allowed to sleep (interrupt
  handlers), or that doesn't want to sleep (critical sections). Be very
  careful not to call functions which can sleep!

- Originally intended for multiprocessor systems

- Spinlocks never sleep and keep spinning in a loop until the lock is
  available.

- The critical section protected by a spinlock is not allowed to sleep.

#v(0.5em)

#align(center, [#image("spinlock.svg", width: 40%)])

=== The spinlock API

- Spinlocks can be initialized:

  - Statically (unusual)

    - ```c DEFINE_SPINLOCK(my_lock); ```

  - Dynamically (the usual case, on a per-device basis)

    - ```c void spin_lock_init(spinlock_t *lock); ```

- They can be acquired and released with:

  - ```c void spin_lock(spinlock_t *lock); ```

    - Used for locking in process context (critical sections in which
      you do not want to sleep) as well as atomic sections.

  - ```c void spin_unlock(spinlock_t *lock); ```

=== Using spinlocks 1/2

- Manipulating spinlocks implies some care:

#align(center, [#image(
  "/common/spinlock-deadlock-with-preemption.svg",
  width: 90%,
)])

#v(0.5em)

- So, kernel preemption on the local CPU is disabled. We need to avoid
  deadlocks (and unbounded latencies) because of preemption from
  processes that want to get the same lock.

- Disabling kernel preemption also disables migration to avoid the same
  kind of issue as pictured above from happening.

=== Using spinlocks 2/2

- We also need to avoid deadlocks because of interrupts that could want
  to get the same lock:

#align(center, [#image(
  "/common/spinlock-deadlock-with-interrupt.svg",
  width: 80%,
)])

- ```c void spin_lock_irqsave(spinlock_t *lock, unsigned long flags); ```

- ```c void spin_unlock_irqrestore(spinlock_t *lock, unsigned longflags); ```

  - Disables/restores IRQs on the local CPU.

  - Typically used when the lock can be accessed in both process and
    interrupt context.

=== Using spinlocks 3/3

- ```c void spin_lock_bh(spinlock_t *lock); ```

- ```c void spin_unlock_bh(spinlock_t *lock); ```

  - Disables software interrupts, but not hardware ones.

  - Useful to protect shared data accessed in process context and in a
    soft interrupt \ (#emph[bottom half]).

  - No need to disable hardware interrupts in this case.

- Note that reader/writer spinlocks also exist, allowing for multiple
  simultaneous readers.

=== Spinlock example

- From #kfile("drivers/tty/serial/uartlite.c")

- Spinlock structure embedded into #kstruct("uart_port")

  #[ #show raw.where(lang: "c", block: true): set text(size: 15pt)
    ```c
    struct uart_port {
            spinlock_t lock;
            /* Other fields */
    };
    ```]

- Spinlock taken/released with protection against interrupts

  #[ #show raw.where(lang: "c", block: true): set text(size: 15pt)
    ```c
    static unsigned int ulite_tx_empty(struct uart_port *port) {
            unsigned long flags;

            spin_lock_irqsave(&port->lock, flags);
            /* Do something */
            spin_unlock_irqrestore(&port->lock, flags);
    }
    ```]

=== More deadlock situations

They can lock up your system. Make sure they never happen!

#v(0.5em)

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [

    Rule 1: don't call a function that can try to get access to the same
    lock
    #align(center, [#image("deadlock-same-lock.pdf", width: 90%)])

  ],
  [

    Rule 2: if you need multiple locks, always acquire them in the same
    order!
    #align(center, [#image("deadlock-two-locks.pdf", width: 90%)])

  ],
)

#include "/common/prove-locking.typ"

=== Alternatives to locking

As we have just seen, locking can have a strong negative impact on system performance. In some situations, you
could do without it.

- By using lock-free algorithms like #emph[Read Copy Update] (RCU).

  - RCU API available in the kernel

  - See #link("https://en.wikipedia.org/wiki/Read-copy-update") for a
    coverage of how it works.

- When relevant, use atomic operations.

=== RCU API

- Conditions where RCU is useful:

  - Frequent reads but infrequent writes

  - Focus on getting consistent data rather than getting the latest data

- Kind of enforces ownership by enforcing space/time synchronization

- RCU API (#kfile("Documentation/RCU/whatisRCU.rst")):

  - #kfunc("rcu_read_lock") and #kfunc("rcu_read_unlock"):
    reclaim/release read access

  - #kfunc("synchronize_rcu"), #kfunc("call_rcu") or
    #kfunc("kfree_rcu"): wait for pre-existing readers

  - #kfunc("rcu_assign_pointer"): update RCU-protected pointer

  - #kfunc("rcu_dereference"): load RCU-protected pointer

- RCU mentorship session by Paul E. McKenney:
  #link("https://youtu.be/K-4TI5gFsig")

=== RCU example: ensuring consistent accesses (1/2)

#text(size: 15pt)[Unsafe read/write]

#v(-0.2em)

```c
struct myconf { int a, b; } *shared_conf; /* initialized */

unsafe_get(int *cur_a, int *cur_b)
{
        *cur_a = shared_conf->a;
        /* What if *shared_conf gets updated now? The assignement is inconsistent! */
        *cur_b = shared_conf->b;
};

unsafe_set(int new_a, int new_b)
{
        shared_conf->a = new_a;
        shared_conf->b = new_b;
};
```

=== RCU example: ensuring consistent accesses (2/2)

#text(size: 15pt)[Safe read/write with RCU]

#v(-0.2em)

#[ #show raw.where(lang: "c", block: true): set text(size: 10pt)
  ```c
  struct myconf { int a, b; } *shared_conf; /* initialized */

  safe_get(int *cur_a, int *cur_b)
  {
          struct myconf *temp;

          rcu_read_lock();
          temp = rcu_dereference(shared_conf);
          *cur_a = temp->a;
          /* If *shared_conf is updated, temp->a and temp->b will remain consistent! */
          *cur_b = temp->b;
          rcu_read_unlock();
  };

  safe_set(int new_a, int new_b)
  {
          struct myconf *newconf = kmalloc(...);
          struct myconf *oldconf;

          oldconf = rcu_dereference(shared_conf);
          newconf->a = new_a;
          newconf->b = new_b;
          rcu_assign_pointer(shared_conf, newconf);
          /* Readers might still have a reference over the old struct here... */
          synchronize_rcu();
          /* ...but not here! No more readers of the old struct, kfree() is safe! */
          kfree(oldconf);
  };
  ```]

=== Atomic variables 1/2

```c #include <linux/atomic.h> ```

- Useful when the shared resource is an integer value

- Even an instruction like `n++` is not guaranteed to be atomic on all
  processors!

- Ideal for RMW (Read-Modify-Write) operations

- Main atomic operations on #ksym("atomic_t") (signed integer, at
  least 24 bits):

  - Set or read the counter:

    - ```c void atomic_set(atomic_t *v, int i); ```

    - ```c int atomic_read(atomic_t *v); ```

  - Operations without return value:

    - ```c void atomic_inc(atomic_t *v); ```

    - ```c void atomic_dec(atomic_t *v); ```

    - ```c void atomic_add(int i, atomic_t *v); ```

    - ```c void atomic_sub(int i, atomic_t *v); ```

=== Atomic variables 2/2

- Similar functions testing the result:

  - ```c int atomic_inc_and_test(...); ```

  - ```c int atomic_dec_and_test(...); ```

  - ```c int atomic_sub_and_test(...); ```

- Functions returning the new value:

  - ```c int atomic_inc_return(...); ```

  - ```c int atomic_dec_return(...); ```

  - ```c int atomic_add_return(...); ```

  - ```c int atomic_sub_return(...); ```

=== Atomic bit operations

- Supply very fast, atomic operations

- On most platforms, apply to an `unsigned long *` type.

- Apply to a `void *` type on a few others.

- Ideal for bitmaps

- Set, clear, toggle a given bit:

  - ```c void set_bit(int nr, unsigned long *addr); ```

  - ```c void clear_bit(int nr, unsigned long *addr); ```

  - ```c void change_bit(int nr, unsigned long *addr); ```

- Test bit value:

  - ```c int test_bit(int nr, unsigned long *addr); ```

- Test and modify (return the previous value):

  - ```c int test_and_set_bit(...); ```

  - ```c int test_and_clear_bit(...); ```

  - ```c int test_and_change_bit(...); ```

=== Kernel locking: summary and references

#table(
  columns: (65%, 35%),
  stroke: none,
  gutter: 15pt,
  [

    - Use mutexes in code that is allowed to sleep

    - Use spinlocks in code that is not allowed to sleep (interrupts) or for
      which sleeping would be too costly (critical sections)

    - Use atomic operations to protect integers or addresses

    See #kdochtml("kernel-hacking/locking") in kernel documentation for
    many details about kernel locking mechanisms.

  ],
  [


    #text(size: 17pt)[
      Further reading: see the classical
      #emph[#link(
        "https://en.wikipedia.org/wiki/Dining_philosophers_problem",
      )[dining philosophers problem]]
      for a nice illustration of synchronization and concurrency issues.]

    #align(center, [#image(
      "An_illustration_of_the_dining_philosophers_problem.jpg",
      width: 90%,
    )])

    #text(size: 11pt)[Image source:
      #link("https://en.wikipedia.org/wiki/Dining_philosophers_problem")[https://en.wikipedia.org/wiki/Dining_philosophers_problem])
    ]
  ],
)

#setuplabframe([Locking], [

  - Add locking to the driver to prevent concurrent accesses to shared
    resources

])
