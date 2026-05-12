#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

#show raw.where(lang: "console", block: true): set text(size: 17pt)

#show raw.where(lang: "c", block: true): set text(size: 15pt)

= Application Tracing

== strace
<strace>

#include "/common/strace.typ"

== ltrace
<ltrace>

#include "/common/ltrace.typ"

== LD_PRELOAD
<ld_preload>

=== Shared libraries

- Shared libraries are provided as _.so_ files that are actually
  ELF files

  - Loaded at startup by `ld.so` (the dynamic loader)

  - Or at runtime using `dlopen()` from your code

- When starting a program (an ELF file actually), the kernel will parse
  it and load the interpreter that needs to be invoked.

  - Most of the time `PT_INTERP` program header of the ELF file is set
    to `ld-linux.so`.

- At loading time, the dynamic loader `ld.so` will resolve all the
  symbols that are present in dynamic libraries.

- Shared libraries are loaded only once by the OS and then mappings are
  created for each application that uses the library.

  - This allows to reduce the memory used by libraries.

=== Hooking Library Calls

- In order to do some more complex library call hooks, one can use the
  _LD_PRELOAD_ environment variable.

- _LD_PRELOAD_ is used to specify a shared library that will be
  loaded before any other library by the dynamic loader.

- Allows to intercept all library calls by preloading another library.

  - Overrides libraries symbols that have the same name.

  - Allows to redefine only a few specific symbols.

  - "Real" symbol can still be loaded and used with `dlsym`
    (#manpage("dlsym", "3"))

- Used by some debugging/tracing libraries (_libsegfault_,
  _libefence_)

- Works for C and C++.

=== LD_PRELOAD example 1/2

- Library snippet that we want to preload using _LD_PRELOAD_:
#v(0.5em)
```c
#include <string.h>
#include <unistd.h>

ssize_t read(int fd, void *data, size_t size) {
  memset(data, 0x42, size);
  return size;
}
```
#v(0.5em)
- Compilation of the library for _LD_PRELOAD_ usage:
#v(0.5em)
```console
$ gcc -shared -fPIC -o my_lib.so my_lib.c
```
#v(0.5em)
- Preloading the new library using _LD_PRELOAD_:
#v(0.5em)
```console
$ LD_PRELOAD=./my_lib.so ./exe
```

=== LD_PRELOAD example 2/2

- Chaining a call to the real symbol to avoid altering the application
  behavior:

#[ #show raw.where(lang: "c", block: true): set text(size: 12pt)
  ```c
  #include <stdio.h>
  #include <unistd.h>
  #include <dlfcn.h>

  ssize_t read(int fd, void *data, size_t size)
  {
      size_t (*read_func)(int, void *, size_t);
      char *error;

      read_func = dlsym(RTLD_NEXT, "read");
      if (!read_func) {
          fprintf(stderr, "Can not find read symbol: %sn", dlerror());
          return 0;
      }
      fprintf(stderr, "Trying to read %lu bytes to %p from file descriptor %dn", size, data, fd);
      return read_func(fd, data, size);
  }
  ```
]

== uprobes and perf
<uprobes-and-perf>

=== Probes in linux

- The linux kernel is able to dynamically add some instrumentation (or
  "*probes*") to almost any code running on a platform, either
  in userspace, kernel space, or both.

- This mechanism works by "patching" the code at runtime to insert the
  probe. When the patched code is executed, the probe records the
  execution. It can also collect additional data.

- There are different kinds of probes exposed by the kernel:

  - *uprobes*: hook on almost any userspace instruction and
    capture local data

  - *uretprobes*: hook on userspace function exit and capture
    return value

  - *entry fprobe*: hook on kernel function entry

  - *exit fprobe*: hook on kernel function exit

  - *kprobes*: hook on almost any kernel instruction and capture
    local data

  - *kretprobe*: hook on kernel function exit and capture return
    value

=== uprobes

- _uprobe_ is a probe mechanism offered by the kernel allowing to
  trace userspace code.

- Can target any userspace instruction

  - Internally patches the loaded `.text` section with breakpoints that
    are handled by the kernel trace system

- Exposed by file `/sys/kernel/tracing/uprobe_events`

- User is expected to compute the offset of the targeted instruction
  inside the corresponding VMA (containing the `.text` section) of the
  targeted process

```bash
echo 'p /bin/bash:0x4245c0' > /sys/kernel/tracing/uprobe_events
```

- Uprobes are wrapped by some common tools (e.g: `perf`, `bcc`) for
  easier usage

- #kdochtml("trace/uprobetracer")

=== The perf tool

- _perf_ tool was started as a tool to profile application under
  Linux using performance counters (#manpage("perf", "1")).

- It became much more than that and now allows to manage tracepoints,
  kprobes and uprobes.

- _perf_ can profile both user-space and kernel-space execution.

- _perf_ is based on the `perf_event` interface that is exposed by
  the kernel.

  - Needs #kconfigval("CONFIG_PERF_EVENTS", "y") at kernel build
    time

- Provides a set of operations, each having specific arguments (see
  _perf_ help).

  - `stat`, `record`, `report`, `top`, `annotate`, `ftrace`, `list`,
    `probe`, etc

- Some of those commands operate on an intermediate `perf.data`,
  containing data from a recording session.

=== Probing userspace functions

- List functions that can be probed in a specific executable:

  ```C
  $ perf probe --source=<source_dir> -x my_app -F
  ```

- List lines number that can be probed in a specific
  executable/function:

  ```C
  $ perf probe --source=<source_dir> -x my_app -L my_func
  ```

- Create uprobes on user-space library/executable functions:

  ```C
  $ perf probe -x /lib/libc.so.6 printf
  $ perf probe -x my_app my_func:3 my_var
  $ perf probe -x my_app my_func%return \$retval
  ```

- Record the execution of these tracepoints:

  ```C
  $ perf record -e probe_my_app:my_func_L3 -e probe_libc:printf
  ```

#setuplabframe([Application tracing], [
  Analyzing of application
  interactions

  - Analyze dynamic library calls from an application using _ltrace_.

  - Overriding a library function with `LD_PRELOAD`.

  - Using _strace_ to analyze program syscalls.

])
