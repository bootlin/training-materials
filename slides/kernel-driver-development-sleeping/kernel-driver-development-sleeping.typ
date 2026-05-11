#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== Sleeping

=== Sleeping

#align(center, [#image("sleeping.svg", width: 100%)])

#align(
  center,
  [Sleeping is needed when a userspace or kernelspace thread is waiting for data.],
)

=== How to sleep with a wait queue 1/3

- Must declare a wait queue, which will be used to store the list of
  threads waiting for an event

- Dynamic queue declaration:

  - Typically one queue per device managed by the driver

  - It's convenient to embed the wait queue inside a per-device data
    structure.

  - Example from #kfile("drivers/net/ethernet/marvell/mvmdio.c"):
    #[ #show raw.where(lang: "c", block: true): set text(size: 16pt)
      ```c
      struct orion_mdio_dev {
              ...
              wait_queue_head_t smi_busy_wait;
      };
      struct orion_mdio_dev *dev;
      ...
      init_waitqueue_head(&dev->smi_busy_wait);
      ```]

- Static queue declaration:

  - Using a global variable when a global resource is sufficient

  - ```c DECLARE_WAIT_QUEUE_HEAD(module_queue); ```

=== How to sleep with a wait queue 2/3

Several ways to make a thread sleep

- ```c void wait_event(queue, condition); ```

  - Sleeps until the wait queue is woken up *and* the given C
    expression is true. Caution: once entered, the thread sleep cannot
    be interrupted!

- ```c int wait_event_killable(queue, condition); ```

  - Can be interrupted, but only by a _fatal_ signal
    (#ksym("SIGKILL")). Returns `-`#ksym("ERESTARTSYS") if
    interrupted.

- ```c int wait_event_interruptible(queue, condition); ```

  - The most common variant

  - Can be interrupted by any signal. Returns `-`#ksym("ERESTARTSYS")
    if interrupted.

=== How to sleep with a wait queue 3/3

- ```c int wait_event_timeout(queue, condition, timeout); ```

  - Also stops sleeping when the thread is woken up *or* the
    timeout expired (a timer is used).

  - Returns `0` if the timeout elapsed, non-zero if the condition was
    met.

- ```c int wait_event_interruptible_timeout(queue, condition, timeout); ```

  - Same as above, interruptible.

  - Returns `0` if the timeout elapsed, `-`#ksym("ERESTARTSYS") if
    interrupted, positive value if the condition was met.

=== How to sleep with a wait queue - Example

#[ #show raw.where(lang: "c", block: true): set text(size: 16pt)
  ```c
  sig = wait_event_interruptible(ibmvtpm->wq,
                                 !ibmvtpm->tpm_processing_cmd);
  if (sig)
          return -EINTR;
  ```]

From #kfile("drivers/char/tpm/tpm_ibmvtpm.c")

=== Waking up!

Typically done by interrupt handlers when data sleeping threads are waiting for become available.

- `wake_up(&queue);`

  - Wakes up all threads in the wait queue

- `wake_up_interruptible(&queue);`

  - Wakes up all threads waiting in an interruptible sleep on the given
    queue

=== Exclusive vs. non-exclusive

- #kfunc("wait_event_interruptible") puts a thread in a
  non-exclusive wait.

  - All non-exclusive threads are woken up by #kfunc("wake_up") /
    #kfunc("wake_up_interruptible")

- #kfunc("wait_event_interruptible_exclusive") puts a thread in an
  exclusive wait.

  - #kfunc("wake_up") / #kfunc("wake_up_interruptible") wakes
    up all non-exclusive threads and only one exclusive thread

  - #kfunc("wake_up_all") /
    #kfunc("wake_up_interruptible_all") wakes up all non-exclusive
    and all exclusive threads

- Exclusive sleeps are useful to avoid waking up multiple threads when
  only one will be able to _consume_ the event.

- Non-exclusive sleeps are useful when the event can _benefit_ to
  multiple threads.

=== Sleeping and waking up - Implementation

#table(
  columns: (45%, 55%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("wait-event.svg", height: 90%)])

  ],
  [

    The scheduler doesn't keep evaluating the sleeping condition!

    - ```c wait_event(queue, cond); ``` \ The thread is put in the \
      #ksym("TASK_UNINTERRUPTIBLE") state.

    - ```c wake_up(&queue); ``` \  All threads waiting in `queue` are woken up,
      so they get scheduled later and have the opportunity to evaluate the
      condition again and go back to sleep if it is not met.

    See #kfile("include/linux/wait.h") for implementation details.

  ],
)

=== How to sleep with completions 1/2

- Use #kfunc("wait_for_completion") when no particular condition
  must be enforced at the time of the wake-up

  - Leverages the power of wait queues

  - Simplifies its use

  - Highly efficient using low level scheduler facilities

- Preparation of the completion structure:

  - Static declaration and initialization: \ ```c DECLARE_COMPLETION(setup_done); ```

  - Dynamic declaration: \ ```c init_completion(&object->setup_done); ```

  - The completion object should get a meaningful name (eg. not just
    "done").

- Ready to be used by signal consumers and providers as soon as the
  completion object is initialized

- See #kfile("include/linux/completion.h") for the full API

- Internal documentation at #kdochtml("scheduler/completion")

=== How to sleep with completions 2/2
<how-to-sleep-with-completions-22>

- Enter a wait state with ```c void wait_for_completion(struct completion *done) ```

  - All #kfunc("wait_event") flavors are also supported, such as: \
    #kfunc("wait_for_completion_timeout"), \
    #kfunc("wait_for_completion_interruptible") /
    #link("https://elixir.bootlin.com/linux/latest/ident/wait_for_completion_interruptible_timeout")[\_timeout()], \

    #kfunc("wait_for_completion_killable") /
    #link("https://elixir.bootlin.com/linux/latest/ident/wait_for_completion_killable_timeout")[\_timeout()],
    etc.

- Wake up consumers with ```c void complete(struct completion *done) ```

  - Several calls to #kfunc("complete") are valid, they will wake up
    the same number of threads waiting on this object (acts as a FIFO).

  - A single #kfunc("complete_all") call would wake up all present
    and future threads waiting on this completion object

- Reset the counter with ```c void reinit_completion(struct completion *done) ```

  - Resets the number of "done" completions still pending

  - Mind not to call #kfunc("init_completion") twice, which could
    confuse the enqueued threads

=== Blocking

- Use helpers which implement software loops or use hardware timers

  - #kfunc("udelay") waste CPU cycles in order to save a couple of
    context switches, suitable for ≤ 10us or in atomic situations

  - #kfunc("usleep")/#kfunc("usleep_range")/#kfunc("msleep")
    put the thread in sleep for a given amount of micro/milliseconds
    (not suitable in atomic contexts)

  - If in doubt, use #kfunc("fsleep"), which will use the more
    suitable internal function depending on the period you've asked!

=== Waiting when hardware is involved

- When hardware is involved in the waiting process

  - but there is no interrupt available

  - or because a context switch would be too expensive

- Specific polling I/O accessors may be used:

  - Exhaustive list in #kfile("include/linux/iopoll.h")
    #[ #show raw.where(lang: "c", block: true): set text(size: 15pt)
      ```c
      int read[bwlq]_poll_timeout_[atomic](addr, val, cond,
                                           delay_us, timeout_us)
      ```]

    - `addr`: I/O memory location

    - `val`: Content of the register pointed with

    - `cond`: Boolean condition based on `val`

    - `delay_us`: Polling delay between reads

    - `timeout_us`: Timeout delay after which the operation fails and
      returns -ETIMEDOUT

  - `_atomic` variant uses #kfunc("udelay") instead of
    #kfunc("usleep").

- Avoid implementing custom busy-wait loops if possible
