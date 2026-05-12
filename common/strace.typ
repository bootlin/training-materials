#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

=== strace

#table(
  columns: (75%, 25%),
  stroke: none,
  gutter: 15pt,
  [

    System call tracer - #link("https://strace.io")

    - Available on all GNU/Linux systems
      Can be built by your cross-compiling toolchain generator or by your
      build system.

    - Allows to see what any of your processes is doing: accessing files,
      allocating memory... Often sufficient to find simple bugs.

    - Usage:  \
      `strace <command>` (starting a new process)  \
      `strace -f <command>` (*\f*\ollow child processes too)  \
      `strace -p <pid>` (tracing an existing process)  \
      `strace -c <command>` (time statistics per system call)  \
      `strace -e <expr> <command>` (use *\e*\xpression for advanced filtering)
    See
    #link(
      "https://man7.org/linux/man-pages/man1/strace.1.html",
    )[the strace manual]
    for details

  ],
  [

    #text(size: 12pt)[
      #align(center, [#image("strace-mascot.png", height: 70%)])
      Image credits: #link("https://strace.io/")]
  ],
)

=== strace example output

#align(center, [#image("strace-output.pdf", height: 80%)])
#text(size: 19pt)[
  Hint: follow the open file descriptors returned by `open()`. This tells
  you what files are handled by further system calls.
]

=== strace filtering

- Display only a specific set of system calls:
#[
  #show raw.where(lang: "console", block: true): set text(size: 16pt)

  ```console
    $ strace -e 'openat,write' cat Makefile
  ```
  #v(0.5em)
  - Filter out specific system calls:
  ```console
    $ strace -e '!poll' cat Makefile
  ```
  #v(0.5em)

  - Show only system calls returning a specific status
  ```console
    $ strace -e 'status=failed' cat Makefile
  ```
  #v(0.5em)

  - Trace how a file is accessed and used among different system calls
  ```console
    $ strace -P '/etc/ld.so.cache' cat Makefile
  ```
  #v(0.5em)
]
- Run `strace –tips` to learn new commands !
