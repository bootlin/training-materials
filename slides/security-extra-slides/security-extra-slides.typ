#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

#set list(spacing: 0.8em)
#set enum(spacing: 0.8em)
= Extra slides

== Linux Security Modules: Smack
<linux-security-modules-smack>

=== Smack
<smack>

#place(right, dx: -40pt, dy: 120pt, [#image("Smack-tux.pdf", width: 25%)])

- Developed by Casey Schaufler in 2008

- Used by the Tizen Embedded Linux system

- Part of Automotive Grade Linux until 2021, when it was replaced by SELinux

- Provides a MAC framework focused on simplicity

  - Policies are based in security labels, like in SELinux

  - These labels are simple strings

  - Access rules have the following format:
    - _"Subject label"_ _"Object label"_ _Access_

    - e.g. TFTPSERVICE TFTPFILE rwat

=== Smack labels I
<smack-labels>

- Processes and files inherit labels from file metadata

  - _SMACK64_ defines the security label of a file
  - _SMACK64EXEC_ defines the label taken on by a process which executes the file
  - _SMACK64MMAP_ restricts which subjects can mmap() the file
  - _SMACK64TRANSMUTE_ flags a directory as passing on its label to new files created inside of it
  - _SMACK64IPIN_ defines access control for packets ingressing socket files
  - _SMACK64IPOUT_ defines access control for packets egressing socket files

- A process can read its security label from _/proc/self/attr/smack/current_
- Tasks with _CAP_MAC_OVERRIDE_ can ignore Smack policy decisions
  - As a consequence, root threads are unconstrained by Smack

=== Smack labels II
<smack-labels-2>

Some labels have special meaning:

- '\*' subjects cannot access any object
- '\*' and '@' objects can be accessed by any subject
- '@' subjects can access any object, this is reserved for kthreads
- '^' subjects can read or lock any object
- '\_' objects can be read or locked by any subject
- '?' is only used internally by Smack
