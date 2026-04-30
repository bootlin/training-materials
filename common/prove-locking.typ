#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

===  Debugging locking

- Lock debugging: prove locking correctness

  - #kconfig("CONFIG_PROVE_LOCKING")

  - Adds instrumentation to kernel locking code

  - Detect violations of locking rules during system life, such as:

    - Locks acquired in different order (keeps track of locking
      sequences and compares them).

    - Spinlocks acquired in interrupt handlers and also in process
      context when interrupts are enabled.

  - Not suitable for production systems but acceptable overhead in
    development.

  - See #kdochtml("locking/lockdep-design") for details

- #kconfig("CONFIG_DEBUG_ATOMIC_SLEEP") allows to detect code that
  incorrectly sleeps in atomic section (while holding lock typically).

  - Warning displayed in `dmesg` in case of such violation.

===  Concurrency issues

- Kernel Concurrency SANitizer framework

- #kconfig("CONFIG_KCSAN"), introduced in Linux 5.8.

- Dynamic race detector relying on compile time instrumentation.

- Can find concurrency issues (mainly data races) in your system.

- See #kdochtml("dev-tools/kcsan") and
  #link("https://lwn.net/Articles/816850/") for details.
