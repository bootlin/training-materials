#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

=== GDB: GNU Project Debugger

#table(
  columns: (80%, 20%),
  stroke: none,
  [

    - The debugger on GNU/Linux, available for most embedded architectures.

    - Supported languages: C, C++, Pascal, Objective-C, Fortran, Ada...

    - Command-line interface

    - Integration in many graphical IDEs

    - Can be used to

      - control the execution of a running program, set breakpoints or
        change internal variables

      - to see what a program was doing when it crashed: post mortem
        analysis

    - #link("https://www.gnu.org/software/gdb/")

    - #link("https://en.wikipedia.org/wiki/Gdb")

    - New alternative: _lldb_ (#link("https://lldb.llvm.org/"))
      from the LLVM project.

  ],
  [

    #align(center, [#image("gdb.png", width: 90%)])

  ],
)

=== GDB crash course (1/3)

- GDB is used mainly to debug a process by starting it with _gdb_

  - `$ gdb <program>`

- GDB can also be attached to running processes using the program PID

  - `$ gdb -p <pid>`

- When using GDB to start a program, the program needs to be run with

  - `(gdb) run [prog_arg1 [prog_arg2] ...]`

=== GDB crash course (2/3)

A few useful GDB commands

- `break foobar` (`b`)  \
  Put a breakpoint at the entry of function `foobar()`

- `break foobar.c:42`  \
  Put a breakpoint in `foobar.c`, line 42

- `print var`, `print $reg` or `print task->files[0].fd` (`p`)  \
  Print the variable `var`, the register `$reg` or a more complicated
  reference. GDB can also nicely display structures with all their
  members

- `info registers`  \
  Display architecture registers

=== GDB crash course (3/3)

- `continue` (`c`)   \
  Continue the execution after a breakpoint

- `next` (`n`)   \
  Continue to the next line, stepping over function calls

- `step` (`s`)   \
  Continue to the next line, entering into subfunctions

- `stepi` (`si`)   \
  Continue to the next instruction

- `finish`   \
  Execute up to function return

- `backtrace` (`bt`)   \
  Display the program stack

#if sys.inputs.training == "debugging" {
  [

    === GDB advanced commands (1/3)

    - `info threads` (`i threads`) \
      Display the list of threads that are available

    - `info breakpoints` (`i b`) \
      Display the list of breakpoints/watchpoints

    - `delete <n>` (`d <n>`) \
      Delete breakpoint <n>

    - `thread <n>` (`t <n>`) \
      Select thread number <n>

    - `frame <n>` (`f <n>`) \
      Select a specific frame from the backtrace, the number being the one
      displayed when using `backtrace` at the beginning of each line

    === GDB advanced commands (2/3)

    - `watch <variable>` or `watch <address>` \
      Add a watchpoint on a specific variable/address.

    - `break foobar.c:42 if condition` \
      Break only if the specified condition is true

    - `watch <variable> if condition` \
      Trigger the watchpoint only if the specified condition is true

    - `display <expr>` \
      Automatically prints expression each time program stops

    - `x/<n><u> <address>` \
      Display memory at the provided address. `n` is the amount of memory to
      display, `u` is the type of data to be displayed (`b/h/w/g`).
      Instructions can be displayed using the `i` type.

    === GDB advanced commands (3/3)

    - `list <expr>` \
      Display the source code associated to the current program counter
      location.

    - `disassemble <location,start_offset,end_offset>` (`disas`) \
      Display the assembly code that is currently executed.

    - `print variable = value` (`p variable = value`) \
      Modify the content of the specified variable with a new value

    - `p function(arguments)` \
      Execute a function using GDB. NOTE: be careful of any side effects
      that may happen when executing the function

    - `p $newvar = value` \
      Declare a new gdb variable that can be used locally or in command
      sequence

    - `define <command_name>` \
      Define a new command sequence. GDB will prompt for the sequence of
      commands.
  ]
}

=== Remote debugging

#text(size: 19pt)[
  - In a non-embedded environment, debugging takes place using `gdb` or
    one of its front-ends.

  - `gdb` has direct access to the binary and libraries compiled with
    debugging symbols, which is often false for embedded systems (binaries
    are stripped, without debug_info) to save storage space.

  - For the same reason, embedding the `gdb` program on embedded targets
    is rarely desirable (2.4 MB on x86).

  - Remote debugging is preferred

    - `ARCH-linux-gdb` is used on the development workstation, offering
      all its features.

    - `gdbserver` is used on the target system (only 400 KB on arm).
]

#align(center, [#image("gdb-vs-gdbserver.svg", width: 50%)])

=== Remote debugging: architecture

#align(center, [#image("gdb-vs-gdbserver-architecture.svg", width: 100%)])

=== Remote debugging: target setup

- On the target, run a program through `gdbserver`.  \
  Program execution will not start immediately.  \
  `gdbserver :<port> <executable> <args>`  \
  `gdbserver /dev/ttyS0 <executable> <args>`

- Otherwise, attach `gdbserver` to an already running program:  \
  `gdbserver –attach :<port> <pid>`

- You can also start gdbserver without passing any program to start or
  attach (and set the target program later, on client side):  \
  `gdbserver –multi :<port>`

=== Remote debugging: host setup

- Then, on the host, start `ARCH-linux-gdb <executable>`,
  and use the following `gdb` commands:

  - To tell `gdb` where shared libraries are:  \
    `gdb> set sysroot <library-path>` (typically path to build space
    without `lib/`)

  - To connect to the target:  \
    `gdb> target remote <ip-addr>:<port>` (networking)  \
    `gdb> target remote /dev/ttyUSB0` (serial link)

    - Make sure to replace `target remote` with `target extended-remote`
      if you have started gdbserver with the `–multi` option

  - If you did not set the program to debug on gdbserver commandline:  \
    `gdb> set remote exec-file <path_to_program_on_target>`

=== Coredumps for post mortem analysis

- It is sometime not possible to have a debugger attached when a crash
  occurs

- Fortunately, Linux can generate a `core` file (a snapshot of the whole
  process memory at the moment of the crash), in the ELF format. gdb can
  use this `core` file to let us analyze the state of the crashed
  application

- On the target

  - Use `ulimit -c unlimited` in the shell starting the application, to
    enable the generation of a `core` file when a crash occurs

  - The output name and path for the coredump file can be modified using
    `/proc/sys/kernel/core_pattern` (see #manpage("core", "5"))

    - Example: `echo /tmp/mycore > /proc/sys/kernel/core_pattern`

  - Depending on the system configuration, the `core_pattern` file may
    be rewritten automatically by some software to handle core files or
    even disable core generation (eg: systemd)

- On the host

  - After the crash, transfer the `core` file from the target to the
    host, and run `ARCH-linux-gdb application-binary core-file`

=== minicoredumper

- Coredumps can be huge for complex applications

- minicoredumper is a userspace tool based on the standard core dump
  feature

  - Based on the possibility to redirect the core dump output to a user
    space program via a pipe

- Based on a JSON configuration file, it can:

  - save only the relevant sections (stack, heap, selected ELF sections)

  - compress the output file

  - save additional information from `/proc`

- #link("https://github.com/diamon/minicoredumper")

- "Efficient and Practical Capturing of Crash Data on Embedded Systems"

  - Presentation by minicoredumper author John Ogness

  - Video:
    #link(
      "https://www.youtube.com/watch?v=q2zmwrgLJGs",
    )[https://www.youtube.com/watch?v=q2zmwrgLJGs]

  - Slides:
    #link(
      "https://elinux.org/images/8/81/Eoss2023_ogness_minicoredumper.pdf",
    )[elinux.org/images/8/81/Eoss2023_ogness_minicoredumper.pdf]
