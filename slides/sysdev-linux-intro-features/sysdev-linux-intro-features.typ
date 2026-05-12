#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

#if sys.inputs.training == "linux-kernel" {
  [
    === Origin

    #table(
      columns: (78%, 22%),
      stroke: none,
      gutter: 15pt,
      [

        - The Linux kernel was created as a hobby in 1991 by a Finnish student, Linus Torvalds.
          - Linux quickly started to be used as the kernel for free software operating systems

        - Linux Torvalds has been able to create a large and dynamic developer and user community around Linux.
        - As of today, about 2000+ people contribute to each kernel release, individuals or companies big and small.

      ],
      [
        #[ #set par(leading: 0.4em)
          #align(center, [#image("linus-torvalds.jpg", width: 100%)])
          #text(size: 16.5pt)[Linus Torvalds in 2014] \
          #text(size: 13pt)[Image credits (Wikipedia):] \
          #text(size: 13pt)[#link("https://bit.ly/2UIa1TD")]
        ]
      ],
    )
  ]
}
=== Linux kernel in the system

#align(center, [#image("linux-kernel-in-system.pdf", height: 90%)])

=== Linux kernel main roles

- *Manage all the hardware resources*: CPU, memory, I/O.

- Provide a *set of portable, architecture and hardware
  independent APIs* to allow user space applications and libraries to
  use the hardware resources.

- *Handle concurrent accesses and usage* of hardware resources
  from different applications.

  - Example: a single network interface is used by multiple user space
    applications through various network connections. The kernel is
    responsible for "multiplexing" the hardware resource.

=== System calls

#table(
  columns: (70%, 30%),
  stroke: none,
  [

    - The main interface between the kernel and user space is the set of
      system calls

    - About 400 system calls that provide the main kernel services

      - File and device operations, networking operations, inter-process
        communication, process management, memory mapping, timers, threads,
        synchronization primitives, etc.

    - This system call interface is wrapped by the C library, and user space
      applications usually never make a system call directly but rather use
      the corresponding C library function

  ],
  [

    #align(center, [#image("system-calls.pdf", width: 100%)])
    #text(size: 18pt)[
      Image credits (Wikipedia):]  \
    #text(size: 17pt)[#link("https://bit.ly/2U2rdGB")]
  ],
)

=== Pseudo filesystems

- Linux makes system and kernel information available in user space
  through *pseudo filesystems*, sometimes also called
  *virtual filesystems*

- Pseudo filesystems allow applications to see directories and files
  that do not exist on any real storage: they are created and updated on
  the fly by the kernel

- The two most important pseudo filesystems are

  - `proc`, usually mounted on `/proc`:  \
    Operating system related information (processes, memory management
    parameters...)

  - `sysfs`, usually mounted on `/sys`:  \
    Representation of the system as a tree of devices connected by
    buses. Information gathered by the kernel frameworks managing these
    devices.
