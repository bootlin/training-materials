#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== mmap

===  mmap

- Possibility to have parts of the virtual address space of a program
  mapped to the contents of a file

- Particularly useful when the file is a device file

- Allows to access device I/O memory and ports without having to go
  through (expensive) read, write or ioctl calls

- One can access to current mapped files by two means:

  - `/proc/<pid>/maps`

  - `pmap <pid>`

===  /proc/\<pid>/maps

#text(size: 15pt)[
```
       start-end          perm offset major:minor inode  mapped file name
...
7f4516d04000-7f4516d06000 rw-s 1152a2000 00:05 8406   /dev/dri/card0
7f4516d07000-7f4516d0b000 rw-s 120f9e000 00:05 8406   /dev/dri/card0
...
7f4518728000-7f451874f000 r-xp 00000000 08:01 268909  /lib/x86_64-linux-gnu/libexpat.so.1.5.2
7f451874f000-7f451894f000 ---p 00027000 08:01 268909  /lib/x86_64-linux-gnu/libexpat.so.1.5.2
7f451894f000-7f4518951000 r--p 00027000 08:01 268909  /lib/x86_64-linux-gnu/libexpat.so.1.5.2
7f4518951000-7f4518952000 rw-p 00029000 08:01 268909  /lib/x86_64-linux-gnu/libexpat.so.1.5.2
...
7f451da4f000-7f451dc3f000 r-xp 00000000 08:01 1549    /usr/bin/Xorg
7f451de3e000-7f451de41000 r--p 001ef000 08:01 1549    /usr/bin/Xorg
7f451de41000-7f451de4c000 rw-p 001f2000 08:01 1549    /usr/bin/Xorg
...
```]

===  mmap overview

#align(center, [#image("mmap-overview.pdf", height: 90%)])

===  How to Implement mmap - User space

- Open the device file

- Call the `mmap` system call (see `man mmap` for details):
  #[ #show raw.where(lang: "c", block: true): set text(size: 14pt)
  ```c
  void * mmap(
      void *start,   /* Often 0, preferred starting address */
      size_t length, /* Length of the mapped area */
      int prot,      /* Permissions: read, write, execute */
      int flags,     /* Options: shared mapping, private copy... */
      int fd,        /* Open file descriptor */
      off_t offset   /* Offset in the file */
  );
  ```]

- You get a virtual address you can write to or read from.

===  How to Implement mmap - Kernel space

- Character driver: implement an `mmap` file operation and add it to the
  driver file operations:

  #[ #show raw.where(lang: "c", block: true): set text(size: 14pt)
  ```c
  int (*mmap) (
      struct file *,           /* Open file structure */
      struct vm_area_struct *  /* Kernel VMA structure */
  );
  ```]

- Initialize the mapping.

  - Can be done in most cases with the #kfunc("remap_pfn_range")
    function, which takes care of most of the job.

===  remap_pfn_range()

- #emph[pfn]: page frame number

- The most significant bits of the page address (without the bits
  corresponding to the page size).

#[ #show raw.where(lang: "c", block: true): set text(size: 14pt)

```c
#include <linux/mm.h>

int remap_pfn_range(
    struct vm_area_struct *, /* VMA struct */
    unsigned long virt_addr, /* Starting user
                              * virtual address */
    unsigned long pfn,       /* pfn of the starting
                              * physical address */
    unsigned long size,      /* Mapping size */
    pgprot_t prot            /* Page permissions */
);
```]

===  Simple mmap implementation

#[ #show raw.where(lang: "c", block: true): set text(size: 15pt)
```c
static int acme_mmap
    (struct file * file, struct vm_area_struct *vma)
{
      size = vma->vm_end - vma->vm_start;

      if (size > ACME_SIZE)
          return -EINVAL;

      if (remap_pfn_range(vma,
                    vma->vm_start,
                    ACME_PHYS >> PAGE_SHIFT,
                    size,
                    vma->vm_page_prot))
          return -EAGAIN;

      return 0;
    }
```]

===  devmem2

- #link("https://bootlin.com/pub/mirror/devmem2.c"), by Jan-Derk Bakker

- Very useful tool to directly peek (read) or poke (write) I/O addresses
  mapped in physical address space from a shell command line!

  - Very useful for early interaction experiments with a device, without
    having to code and compile a driver.

  - Uses `mmap` to `/dev/mem`.

  - Examples (`b`: byte, `h`: half, `w`: word)

    - `devmem2 0x000c0004 h` (reading)

    - `devmem2 0x000c0008 w 0xffffffff` (writing)

  - `devmem` is now available in BusyBox, making it even easier to use.

===  mmap summary

- The device driver is loaded. It defines an `mmap` file operation.

- A user space process calls the `mmap` system call.

- The `mmap` file operation is called.

- It initializes the mapping using the device physical address.

- The process gets a starting address to read from and write to
  (depending on permissions).

- The MMU automatically takes care of converting the process virtual
  addresses into physical ones.

- Direct access to the hardware without any expensive `read` or `write`
  system calls
