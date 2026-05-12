#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Application Profiling

=== Profiling

- Profiling is the act of gathering data from a program execution in
  order to analyze them and then optimize or fix performance issues.

- Profiling is achieved by using programs that insert instrumentation in
  the code or leverage kernel/userspace mechanisms.

  - Profiling function calls and count of calls allow to optimize
    performance.

  - Profiling processor usage allows to optimize performance and reduce
    power usage.

  - Profiling memory usage allows to optimize memory consumption.

- After profiling, the data set must be analyzed to identify potential
  improvements (and not the reverse!).

=== Performance issues

#align(
  center,
  [_"Premature optimization is the root of all evil", Donald Knuth_],
)

#v(1em)

- Profiling is often useful to identify and fix performance issues.

- Performance can be affected by memory usage, IOs overload, or CPU
  usage.

- Gathering profiling data before trying to fix performance issues is
  needed to do the correct choices.

- Profiling is often guided by a first coarse-grained analysis using
  some classic tools.

- Once the class of problems has been identified, a fine-grained
  profiling analysis can be done.

=== Profiling metrics

#align(center, [#image("metrics.png", width: 30%)])

- Multiple tools allow to profile various metrics.

- Memory usage with _Massif_, `heaptrack` or memusage.

- Function calls using _perf_ and callgrind.

- CPU hardware usage (Cache, MMU, etc) using _perf_.

- Profiling data can include both the user space application and kernel.

== Memory profiling
<memory-profiling>

=== Memory profiling

- Profiling memory usage (heap/stack) in an application is useful for
  optimization.

- Allocating too much memory can lead to system memory exhaustion.

- Allocating/freeing memory too often can lead to the kernel spending a
  considerable amount of time in `clear_page()`.

  - The kernel clears pages before giving them to processes to avoid
    data leakage.

- Reducing application memory footprint can allow optimizing cache usage
  as well as page miss.

=== Massif usage

- _Massif_ is a tool provided by _valgrind_ which allows to
  profile heap usage during the program execution (user-space only).

- Works by making snapshots of allocations.
#v(0.5em)
#[
  #show raw.where(lang: "console", block: true): set text(size: 19pt)
  ```console
  $ valgrind --tool=massif --time-unit=B program
  ```
  #v(0.5em)

  - Once executed, a _massif.out.<pid>_ file will be generated in
    the current directory

  - `ms_print` tool can then be used to display a graph of heap
    allocation
  #v(0.5em)

  ```console
  $ ms_print massif.out.275099
  ```]
#v(0.5em)

- `#`: Peak allocation

- `@`: Detailed snapshot (count can be adjusted thanks to
  `–detailed-freq`)

=== Massif report

```console
    KB
547.0^                                               # :: : :@ : :: :
     |                                             @:#:::::::@::::::::@
     |                                           ::@:#:::::::@::::::::@::
     |                                        :::::@:#:::::::@::::::::@:::::
     |                                      :::::::@:#:::::::@::::::::@:::::::
     |                                      :::::::@:#:::::::@::::::::@:::::::
     |                                      :::::::@:#:::::::@::::::::@:::::::
     |                                      :::::::@:#:::::::@::::::::@:::::::
     |                              @@@@@@@@:::::::@:#:::::::@::::::::@:::::::
     |                              @       :::::::@:#:::::::@::::::::@:::::::
     |                              @       :::::::@:#:::::::@::::::::@:::::::
     |                       :::::::@       :::::::@:#:::::::@::::::::@:::::::
     |                       :      @       :::::::@:#:::::::@::::::::@:::::::
     |                 :::::::      @       :::::::@:#:::::::@::::::::@:::::::
     |                 :     :      @       :::::::@:#:::::::@::::::::@:::::::
     |            ::::::     :      @       :::::::@:#:::::::@::::::::@:::::::
     |            :    :     :      @       :::::::@:#:::::::@::::::::@:::::::
     |        :::::    :     :      @       :::::::@:#:::::::@::::::::@:::::::
     |     ::::   :    :     :      @       :::::::@:#:::::::@::::::::@:::::::
     |  ::::  :   :    :     :      @       :::::::@:#:::::::@::::::::@:::::::
   0 +----------------------------------------------------------------------->KB
     0                                                                   830.5

Number of snapshots: 52
 Detailed snapshots: [9, 19, 22 (peak), 32, 42]
```

=== `massif-visualizer` - Visualizing massif profiling data

#align(center, [#image("massif_visualizer.png", height: 90%)])

=== heaptrack usage

- _heaptrack_ is a heap memory profiler for Linux.

  - Works with `LD_PRELOAD` library.

- Finer tracking than with Massif and visualizing tool is more advanced.

  - Each allocation is associated to a stacktrace.

  - Allows finding memory leaks, allocation hotspots and temporary
    allocations.

- Results can be seen using GUI (`heaptrack_gui`) or CLI tool
  (`heaptrack_print`).

- #link("https://github.com/KDE/heaptrack")
#v(0.5em)
#[
  #show raw.where(lang: "console", block: true): set text(size: 19pt)
  ```console
  $ heaptrack program
  ```
]
#v(0.5em)
- This will generate a `heaptrack.<process_name>.<pid>.zst` file
  that can be analyzed using `heaptrack_gui` on another computer.

=== `heaptrack_gui` - Visualizing heaptrack profiling data

#align(center, [#image("heaptrack_gui.png", height: 90%)])

=== `heaptrack_gui` - Flamegraph view

#align(center, [#image("heaptrack_gui_flamegraph.png", height: 90%)])

=== memusage

#table(
  columns: (70%, 30%),
  stroke: none,
  gutter: 15pt,
  [

    - memusage is a program that leverages `libmemusage.so` to profile
      memory usage (#manpage("memusage", "1")) (user-space only).

    - Can profile heap, stack and also mmap memory usage.

    - Profiling information can be shown on the console, logged to a file
      for post-treatment or visualized in a PNG file.

    - Lightweight solution compared to valgrind _Massif_ tool since it
      uses the `LD_PRELOAD` mechanism.

  ],
  [

    #align(center, [#image("memusage.png", width: 100%)])

  ],
)
=== memusage usage

```console
$ memusage convert foo.png foo.jpg
Memory usage summary: heap total: 2635857, heap peak: 2250856, stack peak: 83696
         total calls   total memory   failed calls
 malloc|       1496        2623648              0
realloc|          6           3744              0  (nomove:0, dec:0, free:0)
 calloc|         16           8465              0
   free|       1480        2521334
Histogram for block sizes:
    0-15            329  21% ==================================================
   16-31            239  15% ====================================
   32-47            287  18% ===========================================
   48-63            321  21% ================================================
   64-79             43   2% ======
   80-95            141   9% =====================
  ...
21424-21439           1  <1%
32768-32783           1  <1%
32816-32831           1  <1%
   large              3  <1%
```

== Execution profiling
<execution-profiling>

=== Execution profiling

- In order to optimize a program, one may have to understand what
  hardware resources are used.

- Many hardware elements can have an impact on the program execution:

  - CPU cache performance can be degraded by an application without
    memory spatial locality.

  - Page miss due to using too much memory without spatial locality.

  - Alignment faults when doing misaligned accesses.

=== Using _perf stat_

- `perf stat` allows to profile an application by gathering performance
  counters.

  - Using performance counters might require _root_ permissions.
    This can be modified using \
    `# echo -1 > /proc/sys/kernel/perf_event_paranoid`

- The number of performance counters that are present on the hardware
  are often limited.

- Requesting more events than possible will result in multiplexing and
  perf will scale the results.

- Collected performance counters are then approximate.

  - To acquire more precise numbers, reduce the number of events
    observed and run `perf` multiple times changing the events set to
    observe all the expected events.

  - See #link("https://perfwiki.github.io/main/")[perf wiki] for more
    information.

=== perf stat example (1/2)

```console
$ perf stat convert foo.png foo.jpg

Performance counter stats for 'convert foo.png foo.jpg':

           45,52 msec task-clock                #    1,333 CPUs utilized
               4      context-switches          #   87,874 /sec
               0      cpu-migrations            #    0,000 /sec
           1 672      page-faults               #   36,731 K/sec
     146 154 800      cycles                    #    3,211 GHz                      (81,16%)
       6 984 741      stalled-cycles-frontend   #    4,78% frontend cycles idle     (91,21%)
      81 002 469      stalled-cycles-backend    #   55,42% backend cycles idle      (91,36%)
     222 687 505      instructions              #    1,52  insn per cycle
                                                #    0,36  stalled cycles per insn  (91,21%)
      37 776 174      branches                  #  829,884 M/sec                    (74,51%)
         567 408      branch-misses             #    1,50% of all branches          (70,62%)

     0,034156819 seconds time elapsed

     0,041509000 seconds user
     0,004612000 seconds sys
```

#v(0.5em)

- _NOTE: the percentage displayed at the end denotes the time
  during which the kernel measured the event due to multiplexing_

=== perf stat example (2/2)

- List all events:
#v(0.5em)
```console
$ perf list
  List of pre-defined events (to be used in -e):

  branch-instructions OR branches                    [Hardware event]
  branch-misses                                      [Hardware event]
  cache-misses                                       [Hardware event]
  cache-references                                   [Hardware event]
  ...
```
#v(0.5em)
- Count _L1-dcache-load-misses_ and _branch-load-misses_
  events for a specific command
#v(0.5em)
```console
$ perf stat -e L1-dcache-load-misses,branch-load-misses cat /etc/fstab
...
Performance counter stats for 'cat /etc/fstab':

23 418      L1-dcache-load-misses
 7 192      branch-load-misses
...
```

=== Cachegrind

- _Cachegrind_ is a tool provided by _valgrind_ for profiling
  program interactions with the instruction and data cache hierarchy.

  - _Cachegrind_ also profiles branch prediction success.

- Simulate a machine with independent `I$` and `D$` backed with a
  unified L2 cache.

- Really helpful to detect cache usage problems (too many misses, etc).
#v(0.5em)
#[
  #show raw.where(lang: "console", block: true): set text(size: 17pt)
  ```console
  $ valgrind --tool=cachegrind --cache-sim=yes ./my_program
  ```
]
#v(0.5em)
- It generates a `cachegrind.out.<pid>` file containing the measures

- `cg_annotate` is a CLI tool used to visualize cachegrind simulation
  results.

- It also has a `–diff` option to allow comparing two measures files

=== Kcachegrind - Visualizing Cachegrind profiling data

#align(center, [#image("kcachegrind_cachegrind.png", height: 90%)])

=== Callgrind

- Provided by _valgrind_ and allowing to profile an application
  call graph (user-space only).

- Collects the number of instructions executed during your program
  execution and associate these data with the source lines

- Records the call relationship between functions and their call count.
#v(0.5em)
#[
  #show raw.where(lang: "console", block: true): set text(size: 17pt)
  ```console
  $ valgrind --tool=callgrind ./my_program
  ```
]
#v(0.5em)
- `callgrind_annotate` is a CLI tool used to visualize callgrind
  simulation results.

- Kcachegrind can visualize _callgrind_ results too.

- The cache simulation (done using cachegrind) has some accuracy
  shortcomings (See
  #link("https://valgrind.org/docs/manual/cg-manual.html#cg-manual.annopts.accuracy")[Cachegrind accuracy])

=== Kcachegrind - Visualizing Callgrind profiling data

#align(center, [#image("kcachegrind_callgrind.png", height: 90%)])

#setuplabframe([Profiling applications], [
  Profiling an application
  using various tools

  - Profiling application heap using _Massif_.

  - Profiling an application with _Cachegrind_, _Callgrind_ and
    _KCachegrind_.

  - Analyzing application performance with _perf_.

])
