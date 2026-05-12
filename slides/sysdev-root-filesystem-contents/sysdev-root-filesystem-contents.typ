#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== Contents

=== Root filesystem organization

- The organization of a Linux root filesystem in terms of directories is
  well-defined by the *Filesystem Hierarchy Standard*

- #link("https://refspecs.linuxfoundation.org/fhs.shtml")

- Most Linux systems conform to this specification

  - Applications expect this organization

  - It makes it easier for developers and users as the filesystem
    organization is similar in all systems

=== Important directories (1)

/ /bin: Basic programs

/ /boot: Kernel images, configurations and initramfs (only when the kernel is loaded from a filesystem, not common on non-x86 architectures)

/ /dev: Device files (covered later)

/ /etc: System-wide configuration

/ /home: Directory for the users home directories

/ /lib: Basic libraries

/ /media: Mount points for removable media

/ /mnt: Mount point for a temporarily mounted filesystem

/ /proc: Mount point for the proc virtual filesystem

=== Important directories (2)

/ /root: Home directory of the `root` user

/ /run: Run-time variable data (previously `/var/run`)

/ /sbin: Basic system programs

/ /sys: Mount point of the sysfs virtual filesystem

/ /tmp: Temporary files

/ /usr: / /usr/bin: Non-basic programs

  / /usr/lib: Non-basic libraries

  / /usr/sbin: Non-basic system programs

/ /var: Variable data files, for system services. This includes spool directories and files, administrative and logging data, and transient and temporary files

=== Separation of programs and libraries

- Basic programs are installed in `/bin` and `/sbin` and basic libraries
  in `/lib`

- All other programs are installed in `/usr/bin` and `/usr/sbin` and all
  other libraries in `/usr/lib`

- In the past, on UNIX systems, `/usr` was very often mounted over the
  network, through NFS

- In order to allow the system to boot when the network was down, some
  binaries and libraries are stored in `/bin`, `/sbin` and `/lib`

- `/bin` and `/sbin` contain programs like `ls`, `ip`, `cp`, `bash`,
  etc.

- `/lib` contains the C library and sometimes a few other basic
  libraries

- All other programs and libraries are in `/usr`

- Update: distributions are now making `/bin` link to `/usr/bin`, `/lib`
  to `/usr/lib` and  \ `/sbin` to `/usr/sbin`. Details on
  #link("https://systemd.io/THE_CASE_FOR_THE_USR_MERGE/")[https://systemd.io/THE_CASE_FOR_THE_USR_MERGE/].
