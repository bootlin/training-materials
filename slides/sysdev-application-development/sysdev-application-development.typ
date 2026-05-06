#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Embedded Linux application development

===  Contents

- Application development

  - Developing applications on embedded Linux

  - Building your applications 

- Debugging and analysis tools

  - Debuggers

  - Remote debugging

  - Tracing and profiling

== Developing applications on embedded Linux
<developing-applications-on-embedded-linux>

===  Application development

- An embedded Linux system is just a normal Linux system, with usually a
  smaller selection of components 

- In terms of application development, developing on embedded Linux is
  exactly the same as developing on a desktop Linux system 

- All existing skills can be re-used, without any particular adaptation 

- All existing libraries, either third-party or in-house, can be
  integrated into the embedded Linux system

  - Taking into account, of course, the limitation of the embedded
    systems in terms of performance, storage and memory 

- Application development could start on x86, even before the hardware
  is available.

===  Leverage existing libraries and languages

- Many developers getting started with embedded Linux limit themselves
  to C, sometimes C++, and the C/C++ standard library. 

- However, there are a lot of libraries and languages that can help you
  accelerate and simplify your application development

  - Compiled languages like Rust and Go are increasingly popular

  - Interpreted languages, especially Python

  - Higher-level libraries: Qt, Glib, Boost, and many more 

- Make sure to evaluate what is the right choice for your project, but
  pay attention to

  - Footprint and performance on low-end platforms

  - Use well-maintained and well-known technologies

===  Building your applications/libraries

- Even for simple applications or libraries, make use of a build system

  - #link("https://cmake.org/")[CMake]

  - #link("https://mesonbuild.com/")[Meson] 

- This will simplify

  - the build process of your application

  - the life of developers joining your project

  - the packaging of your application into an embedded Linux build
    system

===  Getting started with _meson_

Minimal `meson.build`

#text(size: 18pt)[
```
project('example', 'c')
executable('demo', 'main.c')
```
]

`meson.build` for multiple programs and source files

#text(size: 18pt)[
```
project('example', 'c')
src_demo1 = ['demo1.c', 'foo1.c']
executable('demo1', src_demo1)
src_demo2 = ['demo2.c', 'foo2.c']
executable('demo2', src_demo2)
```
]

===  Options with _meson_

`meson_options.txt`

 
```
option('demo-debug', type : 'feature', value : 'disabled')
```

`meson.build`

#text(size: 18pt)[
```
project('tutorial', 'c')
demo_c_args = []
if get_option('demo-debug').enabled()
   demo_c_args += '-DDEBUG'
endif executable('demo', 'main.c', c_args: demo_c_args)
```
]

===  Library dependencies with _meson_
 
`meson.build`
 
```
project('tutorial', 'c')
gtkdep = dependency('gtk+-3.0')
executable('demo', 'main.c', dependencies : gtkdep)
```
The dependency `gtk+-3.0` is searched using `pkg-config`.

== Debugging
<debugging>

#include "/common/gdb.typ"

== Tracing and profiling
<tracing-and-profiling>

#include "/common/strace.typ"

#include "/common/ltrace.typ"

===  ftrace

- In-kernel _tracing_ functionality 

- Can trace

  - Well-defined trace locations in the kernel, called
    _tracepoints_, identifying important events in the kernel:
    scheduling, interrupts, etc.

  - Arbitrary functions in the kernel

  - Arbitrary functions in user-space applications 

- Low-overhead and optimized tracing 

- Accessible using the dedicated _tracefs_ filesystem 

- `trace-cmd` is a higher-level CLI tool to use _ftrace_ 

- Can be used to understand overall system activity (what is my system
  doing?) as well as narrow down specific performance issues 

- #link("https://www.kernel.org/doc/Documentation/trace/ftrace.txt") 

- #link("https://www.trace-cmd.org/")

===  kernelshark

- Visualization tool for _ftrace_ traces 

- #link("https://kernelshark.org/")

#align(center, [#image("kernelshark.png", height: 75%)])

===  perf

- _instrument CPU performance counters, tracepoints, kprobes, and
  uprobes_ 

- Directly included in the Linux kernel source code:
  #kfile("tools/perf") 

- Began as a tool for using the performance counters in Linux, and has
  had various enhancements to add tracing capabilities 

- Supports a list of measurable events: hardware events (cycle count, L1
  cache hits/miss, page faults), software events (tracepoints) 

- #link("https://perf.wiki.kernel.org")

===  perf examples

- List all currently known events  \
  `perf list` 

- List scheduler tracepoints  \
  'perf list `sched:*'` 

- CPU counter statistics for the specified command  \
  `perf stat <command>` 

- CPU counter statistics for the entire system, for 5 seconds  \
  `perf stat -a sleep 5` 

- Profiling: sample on-CPU functions for the specified command, at 99 Hertz  \
  `perf record -F 99 <command>` 

- Tracing: trace all context-switches via sched tracepoint, until Ctrl-C  \
  `perf record -e sched:sched_switch -a` 

- Many more at #link("https://www.brendangregg.com/perf.html")

===  perf GUI: hotspot

#table(columns: (40%, 60%), stroke: none, gutter: 15pt, [

- Hotspot - the Linux perf GUI for performance analysis 

- The main feature of hotspot is visualizing a `perf.data` file
  graphically 

- #link("https://github.com/KDAB/hotspot")[github.com/KDAB/hotspot]

],[

#align(center, [#image("hotspot.png", width: 100%)])

])

===  gprof

- Application-level profiler 

- Part of _binutils_ 

- Requires passing gcc `-pg` option at build/link time 

- Run your program normally, it automatically generates a `gmon.out`
  file when exiting 

- Use the `gprof` tool on `gmon.out` to extract profiling data 

- #link("http://sourceware.org/binutils/docs/gprof/")

===  gprof example

#table(columns: (57%, 43%), stroke: none, gutter: 15pt,[
#text(size: 13pt)[
```
$ ./test-gprof
$ gprof test-gprof gmon.out Flat profile:

Each sample counts as 0.01 seconds.
  %   cumulative   self              self     total
 time   seconds   seconds    calls   s/call   s/call  name
 35.31      7.46     7.46        1     7.46    13.92  func1
 34.03     14.65     7.19        1     7.19     7.19  func2
 30.57     21.11     6.46        1     6.46     6.46  new_func1
  0.09     21.13     0.02                             main
[...]
```]

],[

#align(center, [#image("gprof2dot.pdf", height: 80%)])

#text(size: 19.5pt)[
  #align(center,"Generated with"+[ #link("https://github.com/jrfonseca/gprof2dot")[gprof2dot]])
]
])

== Memory debugging
<memory-debugging>

#include "/common/valgrind.typ"

===  Debugging resources

#table(columns: (65%, 35%), stroke: none, gutter: 15pt, [

- Brendan Gregg
  #link("https://www.brendangregg.com/systems-performance-2nd-edition-book.html")[Systems performance]
  book

- Brendan Gregg
  #link("https://www.brendangregg.com/linuxperf.html")[Linux Performance]
  page

- Bootlin's "Linux debugging, profiling, tracing and performance
  analysis" training course and free training materials (250 pages):  \
  #link("https://bootlin.com/training/debugging/").
 
],[
  
#align(center, [#image("cloud_word.png", height: 70%)])

])

#setuplabframe([Application development and debugging],[

- Creating an application that uses an I2C-connected joystick to control
  an audio player.

- Setting up an IDE to develop and remotely debug an application.

- Using _strace_, _ltrace_, _gdbserver_ and _perf_
  to debug/investigate buggy applications on the embedded board.

])
