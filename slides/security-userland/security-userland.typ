#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Userland security measures

== Access Control paradigms: MAC/DAC
<access-control-paradigms-macdac>

=== Access control in computer security
<access-control-in-computer-security>

- Access control defines relations between two groups of entities:

  - Subjects: entities who can perform an action

  - Objects: resources that need to be controlled

- Access control makes sure only legitimate #emph[subjects] can access
  an #emph[object]

- Most systems use one of the following paradigms:

  - Discretionary access control (DAC), the most widespread on general
    purpose systems

  - Mandatory access control (MAC), on systems needing a more
    fine-grained access control

=== Discretionary access control
<discretionary-access-control>

- Access control is determined by the object owner

  - Each object has an owner, e.g. the object creator.

  - The owner assigns permissions to the object, for himself and others.

- Typical access model:

  - Access control list (ACL) based: subjects appear in an authorization
    list linked with the object

  - Capability based: subjects hold a #emph[capability] that allows to
    manipulate an object

#align(center, [#image("DAC.pdf", width: 60%)])

=== POSIX permissions
<posix-permissions>

- POSIX permission is a typical example of a DAC based on ACL

- UNIX philosophy: everything is a file, so each object is represented
  by a file, including devices.

- Files metadata include:

  - Owning user and owning group

  - Permissions for each classes: owning user, owning group and others

    - Read: grants the ability to read file content

    - Write: grants the ability to write file content

    - Execute: grants the ability to execute a file, or read metadata of
      child files when applied on a folder.

  - Additional permission bits, such as `setuid` or `setgid`

#v(0.5em)

#text(size: 13pt)[
```
$ ls -l /run/
drwxr-xr-x  2 root              root         60 Jan 22 15:51 blkid
-rw-r--r--  1 root              root          5 Jan 22 15:51 blkmapd.pid 
drwxr-xr-x  3 root              lp          100 Feb  6 10:26 cups
-rw-r--r--  1 statd             nogroup       5 Jan 22 15:52 rpc.statd.pid
-rw-------  1 root              root          5 Jan 22 15:52 sm-notify.pid
```]

=== Mandatory access control

#place(right, dx: -40pt, dy: 80pt, [#image("MAC.pdf", width: 60%)])

#v(-3.5em)

- Access control is determined by rules
- Rules are controlled by the system administrator
- Every time a subject tries to access an object, the operating system
  looks for a corresponding rule
- Objects can be accessed only if an existing rule allows this access
- Allows to enforce better rules, but more complex to maintain than DAC
- Three main implementations for Linux:
  - SELinux
  - AppArmor
  - TOMOYO Linux

== Linux capabilities: usage and examples
<linux-capabilities-usage-and-examples>

=== Capability based security
<capability-based-security>

- Theoretical concepts:

  - Subjects have capabilities: unforgeable tokens of authority

  - Capabilities control if and how the subject can manipulate a given
    object

  - A given capability specifies access right on a given object.

  - Completely removes the need of ACL

  - Examples:

    - Subject #emph[user1] can read object #emph[/etc/motd]

    - Subject #emph[user2] can listen on #emph[TCP port 22] object.

- POSIX standard comes with a capabilities specification, differing on
  various points:

  - Capabilities are not associated with objects

  - Capabilities are used in complement of ACL

  - Examples:

    - #emph[CAP_NET_BIND_SERVICE] allows to listen on any privileged
      ports.

=== Linux capabilities
<linux-capabilities>

- Capabilities are a per-thread attribute, allowing to gain privileges
  traditionally associated with superuser

- Fully integrated since Linux 2.6.24

- Capabilities can be independently enabled and disabled

- Capabilities can be attached to executable files, pre-setting runtime
  capabilities

- Threads may voluntarily enable or disable a capability they are
  permitted to use, allowing to only use them in code paths needing it

- Threads may voluntarily preserve capabilities while executing another
  executable (`execve()`).

=== Linux capability examples
<linux-capability-examples>

#[ #set list(spacing: 0.5em)

All capabilities are documented in the
#link("https://manned.org/capabilities.7")[capabilities(7)] manpage

- #link("https://elixir.bootlin.com/linux/v6.19/source/include/uapi/linux/capability.h#L148")[CAP_KILL]:
  Bypass permission checks for sending signals

- #link("https://elixir.bootlin.com/linux/v6.19/source/include/uapi/linux/capability.h#L205")[CAP_NET_ADMIN]:
  Perform various network-related operations

  - interface configuration, firewalling, routes, TOS, promiscuous mode,
    multicasting…

- #link("https://elixir.bootlin.com/linux/v6.19/source/include/uapi/linux/capability.h#L185")[CAP_NET_BIND_SERVICE]:
  Bind a socket to Internet domain privileged ports (port numbers less
  than 1024).

- #link("https://elixir.bootlin.com/linux/v6.19/source/include/uapi/linux/capability.h#L211")[CAP_NET_RAW]:
  Use RAW and PACKET sockets

- #link("https://elixir.bootlin.com/linux/v6.19/source/include/uapi/linux/capability.h#L154")[CAP_SETGID],
  #link("https://elixir.bootlin.com/linux/v6.19/source/include/uapi/linux/capability.h#L159")[CAP_SETUID]:
  Make arbitrary manipulations of process GIDs/UIDs

- #link("https://elixir.bootlin.com/linux/v6.19/source/include/uapi/linux/capability.h#L343")[CAP_SETFCAP]:
  Set arbitrary capabilities on a file.

- #link("https://elixir.bootlin.com/linux/v6.19/source/include/uapi/linux/capability.h#L281")[CAP_SYS_ADMIN]
  Gives #emph[a lot] of system administration related powers:

  - mounts, hostname, privileged log operations, monitoring, tracing…

- #link("https://elixir.bootlin.com/linux/v6.19/source/include/uapi/linux/capability.h#L285")[CAP_SYS_BOOT]:
  Use reboot(2) and kexec_load(2)

- #link("https://elixir.bootlin.com/linux/v6.19/source/include/uapi/linux/capability.h#L224")[CAP_SYS_MODULE]:
  Load and unload kernel modules

- #link("https://elixir.bootlin.com/linux/v6.19/source/include/uapi/linux/capability.h#L296")[CAP_SYS_NICE]:
  Lower the process nice value and change the nice value for arbitrary
  processes, set real-time scheduling policies, set CPU affinity…

- …

]

=== Thread capability sets
<thread-capability-sets>

- Each thread has 5 different capability sets:

  - Controlling capabilities a thread is allowed to use:

    - Permitted: limits capabilities that might be in #emph[Effective]
      and #emph[Inheritable] sets. 
      Thread can drop but never add capabilities to this set, except
      while using `execve()` on a file granting capabilities or with the
      set-uid bit.

  - Controlling capabilities effective at the moment:

    - Effective: used by the kernel to perform permission checks for the
      thread

  - Controlling capabilities present while executing a new program:

    - Inheritable: capabilities preserved across `execve()` on
      privileged process

    - Ambient: capabilities that are preserved across an `execve()` of a
      program that is not privileged. 
      Can be used to add capabilities to an unprivileged program

    - Bounding: capabilities that might be gained on `execve()`. Can be
      used to limit capabilities that will be acquired from file
      capability sets

=== File capability sets
<file-capability-sets>

- Files can be associated with capabilities that will impact thread
  capabilities on `execve()`:

  - Permitted: capabilities automatically permitted to the thread,
    regardless of the thread's inheritable capabilities

  - Inheritable: capabilities that can be permitted, if they also appear
    in thread #emph[Inheritable] set.

  - Effective: a single bit determining if #emph[Permitted] set has to
    be copied into the thread #emph[Effective] set.

- When executing a program with the #emph[set-user-ID] mode bit set,
  file #emph[Inheritable] and #emph[Permitted] sets are ignored and are
  considered to be all ones.

=== Manipulating file capability sets
<manipulating-file-capability-sets>

- `getcap` can be used to show file capabilities
#text(size: 12pt)[
```
  $ getcap /usr/lib/x86_64-linux-gnu/gstreamer1.0/gstreamer-1.0/gst-ptp-helper
  /usr/lib/x86_64-linux-gnu/gstreamer1.0/gstreamer-1.0/gst-ptp-helper cap_net_bind_service cap_net_admin,cap_sys_nice=ep
  $ getcap -r /usr/bin
  /usr/bin/clockdiff cap_net_raw,cap_sys_nice=ep
  /usr/bin/dumpcap cap_net_admin,cap_net_raw=eip
```]

  - `gst-ptp-helper` has `CAP_NET_BIND_SERVICE`, `CAP_NET_ADMIN` and
    `CAP_SYS_NICE` in its #emph[Permitted] and #emph[Effective] sets but
    not in its #emph[Inheritable] set

  - `/usr/bin/clockdiff` has `CAP_NET_RAW` and `CAP_SYS_NICE` in its
    #emph[Permitted] and #emph[Effective] sets but not in its
    #emph[Inheritable] set

  - `/usr/bin/dumpcap` has `CAP_NET_ADMIN` and `CAP_NET_RAW` in all
    three sets

- `setcap` can be used to set file capabilities
#text(size: 12pt)[
```
  # getcap /usr/bin/dumpcap
  /usr/bin/dumpcap cap_net_admin,cap_net_raw=eip
  # setcap cap_net_admin=eip /usr/bin/dumpcap
  # getcap /usr/bin/dumpcap
  /usr/bin/dumpcap cap_net_admin=eip
```]

- Capabilities syntax is described in
  #link("https://manned.org/cap_from_text.3")[cap_from_text(3)]
  manpage.

=== Manipulating thread capabilities I
<manipulating-thread-capabilities>

- Capabilities can be manipulated through the `cap_t` structure.

- `cap_init()`, `cap_dup()` and `cap_free()` are used to allocate or
  free a `cap_t` instance.

- `cap_get_proc()` and `cap_set_proc()` allow to retrieve or apply the
  `cap_t` structure corresponding to the current thread.

- `cap_clear()`, `cap_set_flag()` and `cap_get_flag()` can be used to
  manipulate `cap_t` structure values.

- Additional functions and full behaviour are described in
  #link("https://manned.org/cap_get_proc.3")[cap_get_proc(3)] and
  #link("https://manned.org/cap_clear.3")[cap_clear(3)] manpages.

=== Manipulating thread capabilities II 

#text(size: 13pt)[
```
...
cap_t caps; 
const cap_value_t cap_list[2] = {CAP_FOWNER, CAP_SETFCAP};

if (!CAP_IS_SUPPORTED(CAP_SETFCAP))
     /* handle error */

caps = cap_get_proc(); if (caps == NULL)
     /* handle error */;

if (cap_set_flag(caps, CAP_EFFECTIVE, 2, cap_list, CAP_SET) == -1)
     /* handle error */;

if (cap_set_proc(caps) == -1)
     /* handle error */;

if (cap_free(caps) == -1)
     /* handle error */;
...
```]

#v(0.5em)

#align(center, [
Example from
#link("https://manned.org/cap_get_proc.3")[cap_get_proc(3)] manpage,
adding `CAP_FOWNER` and `CAP_SETFCAP` effective capabilities to the
calling thread.
])

=== setuid and capabilities
<setuid-and-capabilities>

- The `setuid()` and `setgid()` syscalls set the effective user and
  group ids

  - Can be used by privileged processes to drop privileges or regain
    them later

- `setuid` and `setgid` flags can be added to file permissions to
  automatically execute them with owner user and group as effective IDs

- Securebits control the interactions of capabilities and processes with
  UID 0

  - `SECBIT_KEEP_CAPS`: controls if the process retains capabilities
    when switching to non-zero effective UID

  - `SECBIT_NO_SETUID_FIXUP`: controls if the kernel should adjust
    capabilities while transitioning between zero and non-zero effective
    UID

  - `SECBIT_NOROOT`: controls if the process is granted capabilities
    while executing a program with the `setuid` flag

  - `SECBIT_NO_CAP_AMBIENT_RAISE`: controls if the process can add new
    capabilities to the ambient set

  - Four corresponding `_LOCKED_` flags exist, preventing from ever
    removing the base flag

=== Capabilities transformation during execve()
<capabilities-transformation-during-execve>

- The #link("https://manned.org/capabilities.7")[capabilities(7)]
  manpage provides a summary of capabilities transformations:
  #v(0.5em)
  #text(size: 19pt)[
  ```
             P'(ambient)     = (file is privileged) ? 0 : P(ambient)
             P'(permitted)   = (P(inheritable) & F(inheritable)) |
                               (F(permitted) & P(bounding)) | P'(ambient)
             P'(effective)   = F(effective) ? P'(permitted) : P'(ambient)
             P'(inheritable) = P(inheritable)    [i.e., unchanged]
             P'(bounding)    = P(bounding)       [i.e., unchanged]

         where:
             P()    denotes the value of a thread capability set before the
                    execve(2)
             P'()   denotes the value of a thread capability set after the
                    execve(2)
             F()    denotes a file capability set
  ```]

== Process isolation: namespaces
<process-isolation-namespaces>

=== Linux Namespaces
<linux-namespaces>

- A way to partition kernel resources

- Different groups of processes will see different resources

- In each namespaces, resources appear isolated from the other
  namespaces

- One fundamental principle behind software containers

- One namespace of each type is created at boot, processes can create or
  join different namespaces during their runtime

- Most features were introduced in Linux 3.8 (2013) or before, but some
  new features keep being added

- Namespace features are optional: they have to be enabled at kernel
  build time to be used

=== Linux Namespaces types I
<linux-namespaces-types-I>

- Mount namespaces: allowing separation of the filesystem hierarchy.
  Different namespaces will see different mounted filesystems

- UTS namespaces: allowing separation of nodename and domainname

- IPC namespaces: allowing separation of some IPC resources, such as
  SysV `shmget()` IPC mechanism

- PID namespaces: allowing separation of PIDs. Each namespace can reuse
  the same PID for different processes, e.g. PID 1. \
  The PID will still appear in the host namespace but with a different
  PID

- Network namespaces: allowing separation of networking resources. Each
  namespace had a different network configuration: devices, IP
  addresses, routing, firewalling…

=== Linux Namespaces types II 
<linux-namespaces-types-II>
- User namespaces: allowing to isolate user ids and group ids. Ids
  inside and outside of a namespace can be different, allowing an
  unprivileged user to have the ID 0 inside of the namespace, i.e. being
  able to make privileged operations on the namespace resources.

- Control group namespaces (introduced in Linux 4.6): allowing cgroup
  hierarchies isolation

- Time namespace (introduced in Linux 5.6): allowing namespaces to see a
  different system time

=== Namespaces example
<namespaces-example>

- Namespaces are often combined together

#align(center, [#image("namespaces.pdf", width: 85%)])

=== Namespace related syscalls (1)
<namespace-related-syscalls-1>

- Processes can change namespace during their runtime

- Various syscalls exist to create or join namespaces

- They all take a flag to describe the types of namespaces to
  manipulate: \ `CLONE_NEWNS` (mount namespaces), `CLONE_NEWUTS`,
  `CLONE_NEWIPC`, `CLONE_NEWPID`, `CLONE_NEWNET`, `CLONE_NEWUSER`,
  `CLONE_NEWCGROUP`, `CLONE_NEWTIME`

- Namespaces are deleted automatically when no process is running in
  them and nobody is using a corresponding `proc/pid/ns/` link file

=== Namespace related syscalls (2)
<namespace-related-syscalls-2>

- `clone()`:

  - Namespace related flags can be specified

  - The newly created child process will be in different namespace

- `unshare()`:

  - Create a new namespace without forking

  - Also wrapped by the `unshare` command-line tool

- `setns()`:

  - Join an existing namespace

  - Pointing to a specific namespace:

    - First argument: a link file in `proc/pid/ns/`

    - Second argument: a single flag describing the namespace type

  - Pointing to a running process:

    - First argument: a PID file descriptor obtained with `pidfd_open()`

    - Second argument: a bit mask of flags describing the namespaces to
      join

  - Also wrapped by the `nsenter` command-line tool

== Process isolation: cgroups
<process-isolation-cgroups>

=== Linux cgroups
<linux-cgroups>

- Control groups are a way to control resource usages by a group of
  processes

- Resources might include CPU time, RAM, disk…

- Such possibilities existed before cgroups, but were enforced per
  process

- Control groups allow to:

  - Limit resources allocated to a group: CPU time, CPU set, memory,
    number of file descriptors…

  - Prioritize one group over another one

  - Measure resource usage, without enforcing any particular limit

- cgroup v2 was introduced in Linux kernel 4.5 (2016) with breaking
  changes and a new configuration interface

=== Cgroup interface: creating cgroups
<cgroup-interface-creating-cgroups>

- cgroups are configured through a virtual filesystem, generally mounted
  on `/sys/fs/cgroup`

- A new cgroup can be created by creating a new folder in
  `/sys/fs/cgroup` or an already existing subfolder

  ```
  mkdir /sys/fs/cgroup/mygroup
  ```

- Processes can be assigned to a particular cgroup by writing their PID
  to the `cgroup.procs` file:

  ```
  echo 1234 > /sys/fs/cgroup/mygroup/cgroup.procs
  ```

- cgroups with no associated processes can be removed by removing the
  associated folder in `/sys/fs/cgroup`

  ```
  rmdir /sys/fs/cgroup/mygroup
  ```

=== Cgroup interfaces: controllers I
<cgroup-interfaces-controllers-I>

- Enforcing limits or accessing statistics of a group can be done using
  files of the associated folder in `/sys/fs/cgroup`

#text(size: 13pt)[
```
  cat /sys/fs/cgroup/mygroup/memory.current
  45056
  echo 10000 > /sys/fs/cgroup/mygroup/memory.max
```]

- List of all supported controllers can be found in kernel
  documentation:
  #link("https://elixir.bootlin.com/linux/v6.18/source/Documentation/admin-guide/cgroup-v2.rst#L1091")[Documentation/admin-guide/cgroup-v2.rst]

- A few examples:

  - cpu.stat: read-only file of CPU usage statistics

  - cpu.max: maximum CPU bandwidth limit

  - memory.current: read-only file of current memory usage

  - memory.max: memory usage hard limit

  - io.stat: read-only file of I/O statistics

  - pids.max: Hard limit of number of processes

  - cpuset.cpus: CPUs to be used by tasks of this group

=== Cgroup interfaces: controllers II
<cgroup-interfaces-controllers-II>

- Parent cgroups control whether controllers will be present in their
  childs through the `cgroup.subtree_control` control file:

#text(size: 13pt)[
```
  # echo +cpu -memory -pids > /sys/fs/cgroup/mygroup/cgroup.subtree_control
  # cat /sys/fs/cgroup/mygroup/cgroup.subtree_control 
  cpu
  # cat /sys/fs/cgroup/mygroup/mysubgroup/cgroup.controllers 
  cpu 
  bootlin-mathieu# ls /sys/fs/cgroup/mygroup/mysubgroup/pids* | wc -l
  0
```]

- Some statistics files will still be present when the controller is
  disabled:

#text(size: 13pt)[
```
  #ls -l /sys/fs/cgroup/mygroup/mysubgroup/memory.*
  /sys/fs/cgroup/mygroup/mysubgroup/memory.pressure
```]

=== Cgroups example
<cgroups-example>

#align(center, [#image("cgroups.pdf", width: 90%)])

== Process isolation: seccomp
<process-isolation-seccomp>

=== Linux seccomp
<linux-seccomp>

- The linux kernel exposes hundreds of syscalls, but most applications
  only need a few of them

- Secure Computing (seccomp) is a kernel feature, allowing to restrict
  the syscalls that a process can use

- Processes can voluntarily use the seccomp syscall, restricting
  themselves to use only a few system calls:

  - `read()`

  - `write()`

  - `exit()`

  - `sigreturn()`

- If the process later tries to use another syscall, it will be killed
  by the kernel

- The seccomp syscall is not wrapped by the glibc: `syscall()` must be
  used

#text(size: 13pt)[
```
  syscall(SYS_seccomp, SECCOMP_SET_MODE_STRICT, 0, NULL);
```]

=== Seccomp filters
<seccomp-filters>

- Some programs might need more than just reading and writing already
  opened files

- Seccomp filters were introduced with Linux 3.5

- Processes can install a custom BPF program that will filter authorized
  syscalls

  #text(size: 13pt)[
  ```
  struct sock_fprog prog = { /* BPF program description */ }; 
  syscall(SYS_seccomp, SECCOMP_SET_MODE_FILTER, 0, &prog);
  ```]

- Supported filters are described in
  #link("https://manned.org/seccomp.2")[seccomp(2)] manpage.

- This possibility is used by various applications: openSSH, Systemd,
  sudo, Firefox, QEMU…

=== Using Seccomp filters
<using-seccomp-filters>

- Some care must be used when selecting syscalls to filter:

  - Most syscalls are abstracted by the libc wrappers: the underlying
    syscall might be different than expected

  - The same wrapper might used different syscalls on different
    architectures or different libc versions

- Additionally, writing BPF code can be tricky

- The #emph[libseccomp] library provides a higher level abstraction

  - Easier to use

  - Function based filtering

  - Platform independent

=== Going further on process isolation
<going-further-on-process-isolation>

- Namespaces:

  - A namespaces article series:
    #link("https://lwn.net/Articles/531114/")

- Control groups:

  - A control groups article series:
    #link("https://lwn.net/Articles/604609/")

- seccomp:

  - A seccomp overview: #link("https://lwn.net/Articles/656307/")

  - About seccomp caveats: #link("https://lwn.net/Articles/738694/")

== Linux Security Modules: SELinux
<linux-security-modules-selinux>

=== Security-Enhanced Linux (SELinux)
<security-enhanced-linux-selinux>

- Originally developed by the National Security Agency of the United
  States

- Part of mainline Linux since 2.6.0 in 2003

- Based on the Linux Security Module (LSM) framework of the kernel

- Introduces mandatory access control for userspace components

- Additional access control: traditional access control list mechanism
  is still present

- SELinux can be used to precisely control which activities a system
  allows each user, process, and daemon

- Provided by all major distributions, Yocto and Buildroot

- Used on all Android devices

=== SELinux context

- Each object (files, users, processes) has a context composed by 3 or 4 fields:
  - user
    - An identifier, different from POSIX user
    - Determines which roles can be used
    - Each POSIX user is mapped to only one SELinux user
    - SELinux users can be shared among several POSIX users
    - Generally used to represent a class of users
    - E.g. `user_u`, `staff_u`, `sysadm_u`
    - Mapping between system users and SELinux users can be shown with `semanage login`:
```console
# semanage login -l

Login Name           SELinux User         MLS/MCS Range        Service

__default__          unconfined_u         s0-s0:c0.c1023       *
root                 unconfined_u         s0-s0:c0.c1023       *
sddm                 xdm                  s0-s0                *
```

=== SELinux context

- Each object (files, users, processes) has a context composed by 3 or 4 fields:
  - user
    - An identifier, different from POSIX user
    - Determines which roles can be used
  - role
    - Determines what domains can be accessed
    - Each SELinux user can play a fixed set of roles
    - E.g. `system_r`, `staff_r`
    - List of possible roles for a user can be seen with `seinfo`:
```console
# seinfo -uunconfined_u -x

Users: 1
    user unconfined_u roles { system_r unconfined_r } level s0 range s0 - s0:c0.c1023;
```

=== SELinux context

- Each object (files, users, processes) has a context composed by 3 or 4 fields:
  - user
    #[ #set list(spacing: 0.3em)
    - An identifier, different from POSIX user
    - Determines which roles can be used
    ]
  - role
    #[ #set list(spacing: 0.3em)
    - Determines what domains can be accessed
    - Each SELinux user can play a fixed set of roles
    ]
  - domain or type
    #[ #set list(spacing: 0.3em)
    - Defines the security context
    - Most SELinux rules will rely on it
    - E.g. `bin_t`, `httpd_t`, `my_application_t`
    - List of types for a given role can be seen with `seinfo`
    ]
#[ #show raw.where(lang: "console", block: true): set text(size: 9pt)
```console
# seinfo -rstaff_r -x

Roles: 1
   role staff_r types { auditadm_screen_t bluetooth_helper_t chfn_t chkpwd_t
   chromium_naclhelper_t chromium_renderer_t chromium_sandbox_t chromium_t
   container_engine_t container_kvm_t container_t crio_t ddclient_t dirmngr_t
   dockerc_user_t dockerd_t dockerd_user_t evolution_alarm_t evolution_exchange_t
   evolution_server_t evolution_t evolution_webcal_t exim_t games_t gconfd_t gpg_agent_t
    ...
   };
```]

=== SELinux context

- Each object (files, users, processes) has a context composed by 3 or 4 fields:
  - user
    - An identifier, different from POSIX user
    - Determines which roles can be used
  - role
    - Determines what domains can be accessed
    - Each SELinux user can play a fixed set of roles
  - domain or type
    - Defines the security context
    - Most SELinux rules will rely on it
  - range (optional)
    - Sometimes referred as _security level_
    - Can be used as part of _Multi-level security_ or _Multi-category security_
  - This context is generally represented as a single string:
    - `user:role:type[:range]`

=== Multi-Level and Multi-Category Security
<multi-level-and-multi-category-security>

- Multi-Level Security (MLS)

  - Allows a hierarchical structure representing different level of
    sensitivity

  - Levels can be used to represent data classification

    - Unclassified, Restricted, Confidential, Secret…

- Multi-Category Security (MCS)

  - Allows to compartment data with different categories

  - Categories can be used to represent different departments

- SELinux allows to mix both levels and categories

=== SELinux Multi-Level and Multi-Category Security
<selinux-multi-level-and-multi-category-security>

- Context #emph[range] can be composed by two parts:

  - The sensitivity level, as an integer

    - Order is defined by the #emph[dominance], s0 is generally the
      lowest

    - For MCS, only one level is used: typically s0

  - Optionally, the category set, as integers

- Ranges are represented as strings

  - `s0`: sensitivity level 0

  - `s1:c4,c7`: sensitivity level 1, categories 4 and 7

- Domains will be affected a clearance

  - Determines which level and categories can be accessed

  - `s2:c1.c4,c7`: sensitivity level 2, categories 1 to 4 and 7

  - #emph[dominance] determinates other allowed security levels

=== SELinux file context
<selinux-file-context>

- On creation, files and directories will by default inherit the context
  of parent folder

- `ls -Z` can be used to show file context:

#text(size: 13pt)[
```
  # ls -lZ /
  lrwxrwxrwx.   1 root root system_u:object_r:bin_t:s0                   7 Feb 19 08:09 bin -> usr/bin
  drwxr-xr-x.   3 root root system_u:object_r:boot_t:s0               4096 Feb 19 08:11 boot 
  drwxr-xr-x.  19 root root system_u:object_r:device_t:s0             3300 Feb 19 08:29 dev 
  drwxr-xr-x.  78 root root system_u:object_r:etc_t:s0                4096 Feb 19 08:28 etc 
  drwxr-xr-x.   3 root root system_u:object_r:home_root_t:s0          4096 Feb 19 08:11 home
  ...
```]

- `chcon` can be used to change file context:

#text(size: 13pt)[
```
  # ls -lZ hello.sh
  -rwxr-xr-x. 1 root root unconfined_u:object_r:user_home_t:s0 23 Feb 19 08:29 hello.sh
  # chcon system_u:object_r:bin_t:s0 hello.sh
  # ls -lZ hello.sh
  -rwxr-xr-x. 1 root root system_u:object_r:bin_t:s0 23 Feb 19 08:29 hello.sh
```]

- `restorecon` can be used to set file context to policy default values

=== SELinux process context
<selinux-process-context>

- On creation, processes will by default inherit the context of parent
  process

- `id -Z` can be used to show own context in a shell:

#text(size: 13pt)[
```
  # id -Z
  unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```]

- `ps -Z` can be used to show processes contexts:

#text(size: 13pt)[
```
  # ps -Z
  LABEL                               PID TTY          TIME CMD
  unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 738 pts/0 00:00:00 bash
  unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 1608 pts/0 00:00:00 ps
```]

- `runcon` can be used to start a process with a different context:

  - The transition must be allowed by SELinux policy rules

#text(size: 13pt)[
```
    # id -Z
    unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
    # runcon -r system_r bash
    # id -Z
    unconfined_u:system_r:unconfined_t:s0-s0:c0.c1023
```]

=== SELinux modes
<selinux-modes>

- SELinux can be used in two different modes

  - Permissive: rules are not enforced, but all violations are logged

    - Can be useful during the configuration phase to ensure all needed
      rules have been set.

    - The `audit2allow` tool can then be used to generate some rules
      based on this log

  - Enforcing: rules are strictly enforced

- Mode can be configured in `/etc/selinux/config` or with `setenforce`

- Additionally, SELinux can be completely disabled

- Active mode can be seen with `sestatus`

#text(size: 13pt)[
```
  # sestatus 
  SELinux status:                 enabled 
  SELinuxfs mount:                /sys/fs/selinux 
  SELinux root directory:         /etc/selinux 
  Loaded policy name:             default 
  Current mode:                   permissive
  ...
```]

=== SELinux policies
<selinux-policies>

- Policies will describe what is permitted on the system

  - By default, everything is forbidden

  - Rules will allow processes to use objects, based on the context of
    both the source and the target

- Policies can be dynamically loaded during runtime

- Policies will have to adapt to system needs:

  - They can only isolate a few processes

  - They can implement a full multi-level security system

  - Or implement anything in-between

=== SELinux rules
<selinux-rules>

- SELinux rules are based on a #emph[access vector] describing the
  access, composed by:

  - The source context

  - The target context

  - The class of the target

    - Describes the type of the resource

    - E.g. `file`, `socket`, `process`, `dbus`

  - the permission or activity

    - Describes the action the access tries to make

    - Possible values depend on the class

    - E.g. `create`, `read`, `write`, `execute`, `bind`, `connect`

=== SELinux rules examples
<selinux-rules-examples>

- Most SELinux rules rely on the type, but other context fields can also
  be used

- The most common rule is `allow`, allowing a specific access

#text(size: 13pt)[
```
  allow user_t lib_t : file { execute };
```]

  - Allows processes from `user_t` domain

  - To `execute` `files`

  - Of the `lib_t` type

- Other types of rules exist, such as `type_transition`, allowing
  process transition to a different context:

#text(size: 13pt)[
```
  type_transition init_t initrc_exec_t : process initrc_t;
```]

  - Processes running in `init_t` domain

  - Executing a file with `initrc_exec_t` type

  - Shall transition to the `initrc_t` domain

=== Listing SELinux rules
<listing-selinux-rules>

- The `sesearch` command can be used to query rules present on the
  system

  - Filters can be added on the type of rules:

    - `–allow`

    - `–role_transition`

    - …

  - Filters can also be added on context fields:

    - `-s`: source context

    - `-t`: target context

    - `-c`: object class

    - …

#text(size: 13pt)[
```
  # sesearch --allow --source wireshark_t --target proc_net_t 
  allow wireshark_t proc_net_t:dir { getattr ioctl lock open read search }; 
  allow wireshark_t proc_net_t:file { getattr ioctl lock open read }; 
  allow wireshark_t proc_net_t:lnk_file { getattr read };
```]

=== SELinux policy modules
<selinux-policy-modules>

- SELinux comes with the concept of modules, providing rules

- Policy modules can be dynamically loaded or unloaded with `semodule`

  - `–list-modules`

  - `–enable`

  - `–disable`

#text(size: 13pt)[
```
  # semodule --list-modules | head -5
  accountsd 
  acct 
  afs 
  aide 
  alsa
  # semodule --disable alsa 
  libsemanage.add_user: user sddm not in password file 
  root@setest:~# semodule --list-modules | grep alsa
```]

- Generic policies might be provided by projects, distributions or the
  #link("https://github.com/SELinuxProject/refpolicy")[SELinux refpolicy project]

=== Creating SELinux policies
<creating-selinux-policies>

- You will sometimes need to write your own policies

  - For your own custom context

  - For a project you are maintaining

- Typical policy modules will consist of:

  - A `.te` file containing policy rules for your application, such as
    `allow` or transition rules

  - A `.if` file defining the interfaces: policy macros used by other
    policy modules to interact with this policy

  - A `.fc` file defining application security contexts: instructions
    for labeling files related to the application

=== Creating SELinux policies: sepolicy generate
<creating-selinux-policies-sepolicy-generate>

- The `sepolicy generate` command can be used to create module template
  files

- SELinux can be generated from the above files with `checkmodule` and
  `semodule_package` or more easily with some helper script

#text(size: 13pt)[
```
  # mkdir myapp && cd myapp
  # sepolicy generate --init -n myapp /bin/myapp 
  Failed to retrieve rpm info for selinux-policy 
  Created the following files:
  /root/myapp/myapp.te # Type Enforcement file
  /root/myapp/myapp.if # Interface file
  /root/myapp/myapp.fc # File Contexts file
  /root/myapp/myapp_selinux.spec # Spec file
  /root/myapp/myapp.sh # Setup Script
  # ... Define your custom rules ...
  # ./myapp.sh
  # semodule -l | grep myapp 
  myapp
```]

- In most cases, audit2allow can help you to define those rules

== Linux Security Modules: AppArmor
<linux-security-modules-apparmor>

=== AppArmor
<apparmor>

- Developed by Immunix in 1998

- Supported by Canonical since 2009

- Allows limiting program capabilities with profiles

- Provides an alternative to SELinux:

  - Allows to introduce MAC in Linux systems

  - Based on the Linux Security Module (LSM) framework of the kernel

=== AppArmor differences with SELinux
<apparmor-differences-with-selinux>

- Files are identified by their path instead of attaching #emph[security
  labels] to inodes

  - Creating a hardlink to a restricted file might help to bypass
    restrictions

- As no data is stored in file inodes, the configuration is more
  centralized

- AppArmor only supports about 20 #emph[Access Modes]:

  - SELinux supports hundreds of different permissions, depending on the
    type of object

  - Basic modes: `read`, `write`, `append`

  - Execution mode, with various variants

  - Link files and lock files management

- There is no support for multi-level security

- Overall, AppArmor tends to provide less advanced features but to be
  also easier to use

=== AppArmor profile files
<apparmor-profile-files>

- AppArmor relies on #emph[Profiles] to describe applications
  confinement

- Simple text files stored in `/etc/apparmor.d`, one file per binary

  - Files are named to reflect binary path, `/` being replaced by `.`

  - E.g. `/etc/apparmor.d/bin.ping` for `/bin/ping`

- Profiles will contain rules:

  - Paths of files that can be accessed

  - Capabilities that can be used

- `aa-genprof` can be used to automatically create a new profile

  - Target application is launched, all actions are logged

  - The user is then prompted for actions that need to be allowed by
    profile rules

  - Similarly, `aa-logprof` can be used to interactively add rules from
    audit logs

=== AppArmor profile example
<apparmor-profile-example>

- `/etc/apparmor.d/bin.ping` content:

#text(size: 11pt)[
```
  abi <abi/4.0>,

  include <tunables/global>
  profile ping /{usr/,}bin/{,iputils-}ping flags=(complain) {
    include <abstractions/base>
    include <abstractions/consoles>
    include <abstractions/nameservice>

    capability net_raw,
    capability setuid,
    network inet raw,
    network inet6 raw,

    /{,usr/}bin/{,iputils-}ping mixr,
    /etc/modules.conf r,
    @{PROC}/sys/net/ipv6/conf/all/disable_ipv6 r,
  }
```]

- This profile can be used by `ping` and `iputils-ping` binaries

- Allows to use `net_raw` and `setuid` capabilities

- Add m (executable mapping), ix (inherit execute mode) and r (read)
  access modes to the `ping` binary

- Add r (read) access mode to `/etc/modules.conf` and
  `/proc/sys/net/ipv6/conf/all/disable_ipv6` files

=== AppArmor base commands (1)
<apparmor-base-commands-1>

- `aa-status`

  - Shows current AppArmor status

#text(size: 13pt)[
```
  # aa-status 
  apparmor module is loaded.
  126 profiles are loaded.
  6 profiles are in enforce mode.
    /usr/bin/man
    lsb_release
    ...
  44 profiles are in complain mode.
    Xorg
    avahi-daemon
    dnsmasq
    ...
```]

- `aa-complain` and `aa-enforce`

  - Either enter complain (audit) or enforce mode for a given profile

#text(size: 13pt)[
```
# aa-enforce /bin/ping
```]

=== AppArmor base commands (2)
<apparmor-base-commands-2>

- `apparmor_parser`

  - Load or reload a profile file

#text(size: 13pt)[
```
# apparmor_parser -r /etc/apparmor.d/bin.ping
```]

- `aa-exec`

  - Execute a program with non-default profile

#text(size: 13pt)[
```
# aa-exec -p unconfined -- ping bootlin.com
```]

=== AppArmor audit log
<apparmor-audit-log>

- AppArmor log will list rules violations

  - We can test with a modified #emph[ping] profile, with `net_raw`
    capability removed

#text(size: 11.5pt)[ 
```
# aa-enforce /bin/ping
# ping -N name bootlin.com 
ping: socktype: SOCK_RAW
ping: socket: Permission denied
# grep success=no /var/log/audit/audit.log  
type=SYSCALL msg=audit(1771853258.629:191): arch=c000003e syscall=41 success=no exit=-13 a0=2 a1=3 a2=1 a3=6 items=0 ppid=849 pid=869
auid=0 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts0 ses=1 comm="ping" exe="/usr/bin/ping" subj=ping 
key=(null)ARCH=x86_64 SYSCALL=socket AUID="root" UID="root" GID="root" EUID="root" SUID="root" FSUID="root" EGID="root" SGID="root"
FSGID="root"
```]

== Application hardening via systemd
<application-hardening-via-systemd>

=== Systemd
<systemd>

- Modern #emph[init] system used by almost all Linux desktop/server
  distributions

- Provides features such as

  - Parallel startup of services, taking into account dependencies

  - Monitoring of services

  - On-demand startup of services, through #emph[socket activation]

  - Resource-management of services: CPU limits, memory limits

- Configuration based on #emph[unit files]

  - Declarative language, instead of shell scripts used in other init
    systems

=== Capabilities related settings
<capabilities-related-settings>

- Systemd execution units allow to specify capabilities related settings

  - `CapabilityBoundingSet=` controls which capabilities should be in
    the process bounding set

  - `AmbientCapabilities=` controls which capabilities should be in the
    process ambient set

  - `SecureBits=` controls which Securebits should be set

  - `NoNewPrivileges=` is a boolean value, controlling if
    `PR_SET_NO_NEW_PRIVS` flag should be applied with `prctl()`. If set,
    ensure no new privilege is ever gained through `execve()`: effective
    UID and GID are not affected by 'setuid` and 'setgid` bits,
    capabilities cannot be added.

=== SELinux and AppArmor control
<selinux-and-apparmor-control>

- Systemd execution units allow to control SELinux context or AppArmor
  profile

  - `SELinuxContext=` Sets the SELinux security context, overriding the
    default transition. The transition must be allowed by the SELinux
    policy.

  - `AppArmorProfile=` Sets the AppArmor profile to use. The profile
    must already be loaded in the kernel.

=== Process sandboxing
<process-sandboxing>

- Systemd execution units allow to sandbox processes

  - Can be used to limit the system exposure

  - Sandboxing options relies on various kernel features: seccomp,
    namespaces…

  - Highly simplifies usage of various security features

- All options are described in the #emph[SANDBOXING] section of the
  #link("https://manned.org/systemd.exec.5")[systemd.exec(5)] manpage

- A good practice is to enable as much as possible of these options

=== Process sandboxing examples
<process-sandboxing-examples>

- Data access:

  - Some directories can be made inaccessible, read-only, or replaced by
    a temporary empty folder

- Device access:

  - `/dev` can be replaced by a folder with only a few pseudo devices,
    such as `/dev/null` or \ `/dev/zero`

  - A separate network namespace or a completely isolated network can be
    used. Alternatively, communication can be restricted to some socket
    families

- System configuration:

  - Various parts of `/proc` can be made read-only

  - Kernel modules loading can be blocked

  - Realtime scheduling can be limited

- Dedicated namespaces can be used: IPC, PID, UTS, clocks…

=== Syscall filtering with Systemd
<syscall-filtering-with-systemd>

- Systemd allows to filter syscalls used by launched process

- Relies on `seccomp` kernel feature

- The `SystemCallFilter=` settings can be used to define the list of
  allowed or forbidden syscalls

- As for using seccomp directly, remember getting the correct list of
  syscalls might be tricky

- Syscalls are grouped in predefined sets that can be used instead of
  listing them individually:

  - `@basic-io`, system calls for basic I/O: `read()`, `write()` and
    related calls

  - `@mount`, mounting and unmounting of file system: `mount()`,
    `chroot()`, and related calls

  - `@reboot`, System calls for rebooting and reboot preparation:
    `reboot()`, `kexec()`, and related calls

  - …

=== Systemd resource control
<systemd-resource-control>

- Systemd allows to limit process resources, relying on Linux cgroups

  - Controlling CPU usage: `CPUAccounting=`, `CPUQuota=`,
    `AllowedCPUs=`…

  - Controlling memory usage: `MemoryAccounting=`, `MemoryMin=`,
    `MemoryHigh=`, `MemoryMax=`…

  - Controlling number of tasks: `TasksAccounting=`, `TasksMax=`

  - Controlling I/O throughput: `IOAccounting=`, `IOReadBandwidthMax=`,
    `IOReadIOPSMax=`…

  - Controlling network usage: `IPAccounting=`, `SocketBindAllow=`,
    `RestrictNetworkInterfaces=`…

- All settings are described in
  #link("https://manned.org/systemd.resource-control.5")[systemd.resource-control(5)]
  manpage.

=== Systemd service example: openvpn@.service
<systemd-service-example-openvpn.service>

#text(size: 12pt)[
```
[Unit]
Description=OpenVPN connection to %i
...

[Service]
Type=notify 
PrivateTmp=true 
WorkingDirectory=/etc/openvpn 
ExecStart=/usr/sbin/openvpn --daemon ovpn-%i --status /run/openvpn/%i.status 10 --cd /etc/openvpn --config /etc/openvpn/%i.conf
    --writepid /run/openvpn/%i.pid 
PIDFile=/run/openvpn/%i.pid 
KillMode=process 
CapabilityBoundingSet=CAP_IPC_LOCK CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW CAP_SETGID CAP_SETUID CAP_SETPCAP CAP_SYS_CHROOT
    CAP_DAC_OVERRIDE CAP_AUDIT_WRITE
TasksMax=10
DeviceAllow=/dev/null rw 
DeviceAllow=/dev/net/tun rw 
ProtectSystem=true 
ProtectHome=true 
RestartSec=5s 
Restart=on-failure
```]