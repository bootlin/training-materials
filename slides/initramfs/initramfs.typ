#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

===  Root filesystem in memory: initramfs

It is also possible to boot the system with a filesystem in memory: _initramfs_

- Either from a compressed CPIO archive integrated into the kernel image

- Or from such an archive loaded by the bootloader into memory

- At boot time, this archive is extracted into the Linux file cache

- It is useful for two cases:

  - Fast booting of very small root filesystems. As the filesystem is
    completely loaded at boot time, application startup is very fast.

  - As an intermediate step before switching to a real root filesystem,
    located on devices for which drivers are not part of the kernel
    image (storage drivers, filesystem drivers, network drivers). This
    is always used on the kernel of desktop/server distributions to keep
    the kernel image size reasonable.

- Details (in kernel documentation): 
  #kdochtml("filesystems/ramfs-rootfs-initramfs") 

===  External initramfs

- To create one, first create a compressed CPIO archive:

  ```
  cd rootfs/
  find . | cpio -H newc -o > ../initramfs.cpio cd ..
  gzip initramfs.cpio
  ```

- If you're using U-Boot, you'll need to include your archive in a
  U-Boot container:

  ```
  mkimage -n 'Ramdisk Image' -A arm -O linux -T ramdisk -C gzip 
          -d initramfs.cpio.gz uInitramfs
  ```

- Then, in the bootloader, load the kernel binary, DTB and `uInitramfs`
  in RAM and boot the kernel as follows:

  ```
  bootz kernel-addr initramfs-addr dtb-addr
  ```

===  Built-in initramfs

#table(columns: (80%, 20%), stroke: none, [ To have the kernel
Makefile include an initramfs archive in the kernel image: use the
#kconfig("CONFIG_INITRAMFS_SOURCE") option.

- It can be the path to a directory containing the root filesystem
  contents

- It can be the path to a ready made cpio archive

- It can be a text file describing the contents of the initramfs

See the kernel documentation for details:
#kdochtml("driver-api/early-userspace/early_userspace_support") 
*WARNING*: only binaries from GPLv2 compatible code are allowed
to be included in the kernel binary using this technique. Otherwise, use
an external initramfs. ],[
#align(center, [#image("initramfs.pdf", width: 90%)]) ])
