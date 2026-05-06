#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Root filesystem in Buildroot

===  Overall rootfs construction steps

#align(center, [#image("overall-steps.pdf", height: 90%)])

===  Root filesystem skeleton

- The base of a Linux root filesystem: UNIX directory hierarchy, a few
  configuration files and scripts in `/etc`. No programs or libraries.

- All target packages depend on the `skeleton` package, so it is
  essentially the first thing copied to `$(TARGET_DIR)` at the
  beginning of the build.

- `skeleton` is a virtual package that will depend on:

  - `skeleton-init-sysv,systemd,openrc,none` depending on the init
    system being selected

  - `skeleton-custom` when a custom skeleton is selected

- All of `skeleton-init-sysv,systemd,openrc,none` depend on
  `skeleton-init-common`

  - Copies `system/skeleton/*` to `$(TARGET_DIR)`

- `skeleton-init-sysv,systemd,openrc` install additional files specific
  to those _init systems_

===  Skeleton packages dependencies

#align(center, [#image("skeleton.pdf", width: 100%)])

===  Custom root filesystem skeleton

- A custom _skeleton_ can be used, through the
  `BR2_ROOTFS_SKELETON_CUSTOM` and
  `BR2_ROOTFS_SKELETON_CUSTOM_PATH` options.

- In this case: `skeleton` depends on `skeleton-custom`

- Completely replaces `skeleton-init-*`, so the custom skeleton must
  provide everything.

- Not recommended though:

  - the base is usually good for most projects.

  - skeleton only copied at the beginning of the build, so a skeleton
    change needs a full rebuild

- Use _rootfs overlays_ or _post-build scripts_ for root
  filesystem customization (covered later)

===  Installation of packages

- All the selected target packages will be built (can be BusyBox, Qt,
  OpenSSH, lighttpd, and many more)

- Most of them will install files in `$(TARGET_DIR)`: programs,
  libraries, fonts, data files, configuration files, etc.

- This is really the step that will bring the vast majority of the files
  in the root filesystem.

- Covered in more details in the section about creating your own
  Buildroot packages.

===  Cleanup step

- Once all packages have been installed, a cleanup step is executed to
  reduce the size of the root filesystem.

- It mainly involves:

  - Removing header files, pkg-config files, CMake files, static
    libraries, man pages, documentation.

  - Stripping all the programs and libraries using `strip`, to remove
    unneeded information. Depends on `BR2_ENABLE_DEBUG` and
    `BR2_STRIP_*` options.

  - Additional specific clean up steps: clean up unneeded Python files
    when Python is used, etc. See `TARGET_FINALIZE_HOOKS` in the
    Buildroot code.

===  Root filesystem overlay

- To customize the contents of your root filesystem, to add
  configuration files, scripts, symbolic links, directories or any other
  file, one possible solution is to use a *root filesystem
  overlay*.

- A _root filesystem overlay_ is simply a directory whose contents
  will be *copied over the root filesystem*, after all packages
  have been installed. Overwriting files is allowed.

- The option `BR2_ROOTFS_OVERLAY` contains a space-separated list of
  overlay paths.

  ```
  $ grep ^BR2_ROOTFS_OVERLAY .config 
  BR2_ROOTFS_OVERLAY="board/myproject/rootfs-overlay"
  $ find -type f board/myproject/rootfs-overlay 
  board/myproject/rootfs-overlay/etc/ssh/sshd_config 
  board/myproject/rootfs-overlay/etc/init.d/S99myapp
  ```

===  Post-build scripts

- Sometimes a _root filesystem overlay_ is not sufficient: you can
  use *post-build scripts*.

- Can be used to *customize existing files*, *remove
  unneeded files* to save space, add *new files that are
  generated dynamically* (build date, etc.)

- Executed before the root filesystem image is created. Can be written
  in any language, shell scripts are often used.

- `BR2_ROOTFS_POST_BUILD_SCRIPT` contains a space-separated list of
  post-build script paths.

- `$(TARGET_DIR)` path passed as first argument, additional arguments
  can be passed in the `BR2_ROOTFS_POST_SCRIPT_ARGS` option.

- Various environment variables are available:

  - `BR2_CONFIG`, path to the Buildroot .config file

  - `HOST_DIR`, `STAGING_DIR`, `TARGET_DIR`, `BUILD_DIR`,
    `BINARIES_DIR`, `BASE_DIR`

===  Post-build script: example

#[ #show raw.where(lang: "bash", block: true): set text(size: 14pt)

#text(size: 15pt)[board/myproject/post-build.sh]
#v(-0.1em)
```bash
#!/bin/sh

# Generate a file identifying the build (git commit and build date)
echo $(git describe) $(date +%Y-%m-%d-%H:%M:%S) > \
    $TARGET_DIR/etc/build-id

# Create /applog mountpoint, and adjust /etc/fstab 
mkdir -p $TARGET_DIR/applog 
grep -q "^/dev/mtdblock7" $TARGET_DIR/etc/fstab || \
    echo "/dev/mtdblock7tt/applogtjffs2tdefaultstt0t0" >> \
    $TARGET_DIR/etc/fstab

# Remove unneeded files 
rm -rf $TARGET_DIR/usr/share/icons/bar
```
]

#v(0.5em)

#[ #show raw.where(block: true): set text(size: 14pt)

#text(size: 15pt)[Buildroot configuration]
#v(-0.1em)
```
BR2_ROOTFS_POST_BUILD_SCRIPT="board/myproject/post-build.sh"
```
]

===  Generating the filesystem images

- In the `Filesystem images` menu, you can select which filesystem image
  formats to generate.

- To generate those images, Buildroot will generate a shell script that:

  - *Changes the owner* of all files to `0:0` (root user)

  - Takes into account the global *permission and device tables*,
    as well as the per-package ones.

  - Takes into account the *global and per-package users tables*.

  - Runs the *filesystem image generation utility*, which depends
    on each filesystem type (`genext2fs`, `mkfs.ubifs`, `tar`, etc.)

- This script is executed using a tool called _fakeroot_

  - Allows to fake being root so that permissions and ownership can be
    modified, device files can be created, etc.

  - Advanced: possibility of running a custom script inside
    _fakeroot_, see `BR2_ROOTFS_POST_FAKEROOT_SCRIPT`.

===  Permission table

- By default, all files are owned by the `root` user, and the
  permissions with which they are installed in `$(TARGET_DIR)` are
  preserved.

- To customize the ownership or the permission of installed files, one
  can create one or several *permission tables*

- `BR2_ROOTFS_DEVICE_TABLE` contains a space-separated list of
  permission table files. The option name contains _device_ for
  backward compatibility reasons only.

- The `system/device_table.txt` file is used by default.

- Packages can also specify their own permissions. See the
  _Advanced package aspects_ section for details.

#v(0.5em)
#text(size: 15pt)[Permission table example]
#v(-0.1em)
#[ #show raw.where(block: true): set text(size: 13pt)

```
#<name>    <type>  <mode>  <uid>   <gid>   <major> <minor> <start> <inc>   <count>
/dev       d       755     0       0       -       -       -       -       -
/tmp       d       1777    0       0       -       -       -       -       -
/var/www   d       755     33      33      -       -       -       -       -
```
]

===  Device table

- When the system is using a static `/dev`, one may need to create
  additional _device nodes_

- Done using one or several *device tables*

- `BR2_ROOTFS_STATIC_DEVICE_TABLE` contains a space-separated list
  of device table files.

- The `system/device_table_dev.txt` file is used by default.

- Packages can also specify their own device files. See the
  _Advanced package aspects_ section for details.

#v(0.5em)
#text(size: 15pt)[Device table example]
#v(-0.1em)
#[ #show raw.where(block: true): set text(size: 13pt)

```
# <name>        <type>  <mode>  <uid>   <gid>   <major> <minor> <start> <inc>   <count>
/dev/mem        c       640     0       0       1       1       0       0       -
/dev/kmem       c       640     0       0       1       2       0       0       -
/dev/i2c-       c       666     0       0       89      0       0       1       4
```
]

===  Users table

- One may need to add specific UNIX users and groups in addition to the
  ones available in the default skeleton.

- `BR2_ROOTFS_USERS_TABLES` is a space-separated list of user tables.

- Packages can also specify their own users. See the _Advanced
  package aspects_ section for details.

#v(0.5em)
#text(size: 15pt)[Users table example]
#v(-0.1em)
#[ #show raw.where(block: true): set text(size: 13pt)

```
# <username> <uid> <group> <gid> <password> <home>    <shell> <groups>    <comment>
foo          -1    bar     -1    !=blabla   /home/foo /bin/sh alpha,bravo Foo user 
test         8000  wheel   -1    =          -         /bin/sh -           Test user
```
]

===  Post-image scripts

- Once all the filesystem images have been created, at the very end of
  the build, *post-image* scripts are called.

- They allow to do any custom action at the end of the build. For
  example:

  - Extract the root filesystem to do NFS booting

  - Generate a final firmware image

  - Start the flashing process

- `BR2_ROOTFS_POST_IMAGE_SCRIPT` is a space-separated list of
  _post-image_ scripts to call.

- Post-image scripts are called:

  - from the Buildroot source directory

  - with the `$(BINARIES_DIR)` path as first argument

  - with the contents of the `BR2_ROOTFS_POST_SCRIPT_ARGS` as other
    arguments

  - with a number of available environment variables: `BR2_CONFIG`,
    `HOST_DIR`, `STAGING_DIR`, `TARGET_DIR`, `BUILD_DIR`,
    `BINARIES_DIR` and `BASE_DIR`.

===  Init mechanism

- Buildroot supports multiple _init_ implementations:

  - *BusyBox init*, the default. Simplest solution.

  - *sysvinit*, the old style featureful _init_
    implementation

  - *systemd*, the modern init system

  - *OpenRC*, the init system used by Gentoo

- Selecting the _init_ implementation in the `System configuration`
  menu will:

  - Ensure the necessary packages are selected

  - Make sure the appropriate init scripts or configuration files are
    installed by packages. See _Advanced package aspects_ for
    details.

===  `/dev` management method

- Buildroot supports four methods to handle the `/dev` directory:

  - Using *devtmpfs*. `/dev` is managed by the kernel
    _devtmpfs_, which creates device files automatically. Default
    option.

  - Using *static /dev*. This is the old way of doing `/dev`, not
    very practical.

  - Using *mdev*. `mdev` is part of BusyBox and can run custom
    actions when devices are added/removed. Requires _devtmpfs_
    kernel support.

  - Using *eudev*. Forked from `systemd`, allows to run custom
    actions. Requires _devtmpfs_ kernel support.

- When _systemd_ is used, the only option is _udev_ from
  _systemd_ itself.

===  Other customization options

- There are various other options to customize the root filesystem:

  - *getty* options, to run a login prompt on a serial port or
    screen

  - *hostname* and *banner* options

  - *DHCP network* on one interface (for more complex setups, use
    an _overlay_)

  - *root password*

  - *timezone* installation and selection

  - *NLS*, Native Language Support, to support message
    translation

  - *locale* files installation and filtering (to install
    translations only for a subset of languages, or none at all)

===  Deploying the images

- By default, Buildroot simply stores the different images in
  `$(O)/images`

- It is up to the user to deploy those images to the target device.

- Possible solutions:

  - For removable storage (SD card, USB keys):

    - manually create the partitions and extract the root filesystem as
      a tarball to the appropriate partition.

    - use a tool like `genimage` to create a complete image of the
      media, including all partitions

  - For NAND flash:

    - Transfer the image to the target, and flash it.

  - NFS booting

  - initramfs

===  Deploying the images: genimage

- `genimage` allows to create the complete image of a block device (SD
  card, USB key, hard drive), including multiple partitions and
  filesystems.

- For example, allows to create an image with two partitions: one FAT
  partition for bootloader and kernel, one ext4 partition for the root
  filesystem.

- Also allows to place the bootloader at a fixed offset in the image if
  required.

- The helper script `support/scripts/genimage.sh` can be used as a
  _post-image_ script to call _genimage_

- More and more widely used in Buildroot default configurations

===  Deploying the images: genimage example

#[ #show raw.where(block: true): set text(size: 11pt)

#text(size: 15pt)[genimage-raspberrypi.cfg]
#v(-0.3em)

#table(columns: (50%, 50%), stroke: none, gutter: 15pt, [

```
image boot.vfat {
        vfat {
                files = {
                        "bcm2708-rpi-b.dtb",
                        "rpi-firmware/bootcode.bin",
                        "rpi-firmware/cmdline.txt",
                        "kernel-marked/zImage"
                        [...]
                }
        }

        size = 32M
}
```
],[

```
image sdcard.img {
        hdimage {
        }

        partition boot {
                partition-type = 0xC
                bootable = "true"
                image = "boot.vfat"
        }

        partition rootfs {
                partition-type = 0x83
                image = "rootfs.ext4"
        }
}
```
])

#text(size: 15pt)[defconfig]
#v(-0.1em)
```
BR2_ROOTFS_POST_IMAGE_SCRIPT="support/scripts/genimage.sh"
BR2_ROOTFS_POST_SCRIPT_ARGS="-c board/raspberrypi/genimage-raspberrypi.cfg"
```

#text(size: 15pt)[flash]
#v(-0.1em)
```
dd if=output/images/sdcard.img of=/dev/sdb
```
]

===  Deploying the image: NFS booting

- Many people try to use `$(O)/target` directly for NFS booting

  - This cannot work, due to permissions/ownership being incorrect

  - Clearly explained in the `THIS_IS_NOT_YOUR_ROOT_FILESYSTEM`
    file.

- Generate a tarball of the root filesystem

- Use `sudo tar -C /nfs -xf output/images/rootfs.tar` to prepare your
  NFS share.

===  Deploying the image: initramfs

- Another common use case is to use an _initramfs_, i.e. a root
  filesystem fully in RAM.

  - Convenient for small filesystems, fast booting or kernel development

- Two solutions:

  - `BR2_TARGET_ROOTFS_CPIO=y` to generate a _cpio_ archive,
    that you can load from your bootloader next to the kernel image.

  - `BR2_TARGET_ROOTFS_INITRAMFS=y` to directly include the
    _initramfs_ inside the kernel image. Only available when the
    kernel is built by Buildroot.

#setuplabframe([Root filesystem construction],[

- Explore the build output

- Customize the root filesystem using a rootfs overlay

- Use a post-build script

- Customize the kernel with patches and additional configuration options

- Add more packages

- Use defconfig files and out of tree build

])
