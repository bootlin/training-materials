#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

=== The Linux Kernel Scheduler

- The Linux Kernel Scheduler is a key piece in having a real-time
  behaviour

- It is in charge of deciding which *runnable* task gets executed

- It also elects on which CPU the task runs, and is tightly coupled to
  CPUidle and CPUFreq

- It schedules both *userspace* tasks and *kernel* tasks

- Each task is assigned one *scheduling class* or *policy*

- The class determines the algorithm used to elect each task

- Tasks with different scheduling classes can coexist on the system

=== Non-Realtime Scheduling Classes

There are 3 *Non-RealTime* classes

- `SCHED_OTHER`: The default policy, using a time-sharing algorithm

  - This policy is actually called #ksym("SCHED_NORMAL") by the
    kernel

- #ksym("SCHED_BATCH"): Similar to `SCHED_OTHER`, but designed for
  CPU-intensive loads that affect the wakeup time

- #ksym("SCHED_IDLE"): Very low priority class. Tasks with this
  policy will run only if nothing else needs to run.

- `SCHED_OTHER` and #ksym("SCHED_BATCH") use the *nice*
  value to increase or decrease their scheduling frequency

  - A higher nice value means that the tasks gets scheduled
    *less* often

=== Realtime Scheduling Classes

There are 3 *Realtime* classes

- Runnable tasks will preempt any other lower-priority task

- #ksym("SCHED_FIFO"): All tasks with the same priority are
  scheduled *First in, First out*

- #ksym("SCHED_RR"): Similar to #ksym("SCHED_FIFO") but with a
  time-sharing round-robin between tasks with the same priority

- Both #ksym("SCHED_FIFO") and #ksym("SCHED_RR") can be assigned
  a priority between 1 and 99

- #ksym("SCHED_DEADLINE"): For tasks doing recurrent jobs, extra
  attributes are attached to a task

  - A computation time, which represents the time the task needs to
    complete a job

  - A deadline, which is the maximum allowable time to compute the job

  - A period, during which only one job can occur

- Using one of these classes is necessary but not sufficient to get
  real-time behavior

=== Changing the Scheduling Class

- The Scheduling Class is set per-task, and defaults to `SCHED_OTHER`

- The #manpage("sched_setscheduler", "2") syscall allows changing
  the class of a task

- The `chrt` tool uses it to allow changing the class of a running task:

  - `chrt -f/-b/-o/-r/-d -p PRIO PID`

- It can also be used to launch a new program with a dedicated class:

  - `chrt -f/-b/-o/-r/-d PRIO CMD`

- To show the current class and priority:

  - `chrt -p PID`

- New processes will inherit the class of their parent except if the
  #ksym("SCHED_RESET_ON_FORK") flag is set with
  #manpage("sched_setscheduler", "2")

- See #manpage("sched", "7") for more information
