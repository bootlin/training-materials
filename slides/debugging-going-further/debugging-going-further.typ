#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Going further

===  Debugging resources

- Brendan Gregg
  #link("https://www.brendangregg.com/systems-performance-2nd-edition-book.html")[Systems performance]
  book

- Brendan Gregg
  #link("https://www.brendangregg.com/linuxperf.html")[Linux Performance]
  page

- #emph[Tools and Techniques to Debug an Embedded Linux System], talk
  from Sergio Prado,
  #link("https://www.youtube.com/watch?v=dgPkZnGuIMg")[video],
  #link("https://elinux.org/images/c/cf/Slides-debugging.pdf")[slides]

- #emph[Tracing with Ftrace: Critical Tooling for Linux Development],
  talk from Steven Rostedt,
  #link("https://www.youtube.com/watch?v=mlxqpNvfvEQ")[video]

- #emph[Tutorial: Debugging Embedded Devices using GDB], tutorial from
  Chris Simmonds,
  #link("https://www.youtube.com/watch?v=JGhAgd2a_Ck")[video]

===  Going further (Tracing & Profiling)

#table(columns: (65%, 35%), stroke: none, gutter: 15pt, [

- Great book from Brendan Gregg, an expert in tracing and profiling

- #link("https://www.brendangregg.com/blog/2020-07-15/systems-performance-2nd-edition.html")

- Covers concepts, strategy, tools, and tuning for Linux kernel and
  applications.

], [

#align(center, [#image("/slides/debugging-system-wide-profiling/sysperf2nd_bookcover.png", height: 70%)])

])

===  Going further (BPF)

#table(columns: (65%, 35%), stroke: none, gutter: 15pt, [

- Still from Brendan Gregg!

- Covers more than 150 tools that use BPF.

- Explains how to analyze the results from these tools to optimize your
  system.

- #link("https://www.brendangregg.com/bpf-performance-tools-book.html")

], [


#align(center, [#image("/slides/debugging-system-wide-profiling/bpfperftools_bookcover.png", height: 70%)])

])