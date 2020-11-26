=====================================================================================================
Install U-boot 2018.05 on the BeagleBone Black (including BBB Wireless) internal flash storage (eMMC)
=====================================================================================================

This is needed for some aspects of Bootlin's kernel, Yocto Project and Buildroot labs,
such as saving U-Boot environment settings to eMMC storage.

Tested on the following board revisions:
- Original release of the board

Caution: this procedure can erase data installed on the board eMMC.
This won't make your board unusable though.

If you want to install a distribution again on the eMMC, just go to
http://beagleboard.org/latest-images and follow instructions.

Make a bootable micro-SD card
-----------------------------

We are going to prepare a bootable micro-SD card that will automatically
reflash the eMMC with the U-Boot binaries provided in this directory.

Take a micro-SD card and connect it to your PC:
- Either using a direct SD slot if available.
  In this case, the card should be seen as '/dev/mmcblk0' by
  your computer (check the 'dmesg' command output).
- Either using a memory card reader.
  In this case, the card should be seen as '/dev/sdb', or '/dev/sdc', etc.

Now, run the mount command to check for mounted SD card
partitions. Umount them with a command such as
'sudo umount /dev/mmcblk0p1' or 'sudo umount /dev/sdb1',
depending on how the system sees the media card device.

Now type the below command to partition the micro-SD card
(we assume that the card is seen as '/dev/mmcblk0'):

sudo sfdisk /dev/mmcblk0 << EOF
1,,0xE,*
EOF

Remove the SD card and insert it again (to make sure new
partitions are detected properly)

Now, format the first partition in FAT format:

sudo mkfs.vfat -F 32 /dev/mmcblk0p1 -n boot

Remove the card and insert it again. It should automatically be mounted
on '/media/$USER/boot'.

Now, copy the below files to this partition:

cp zImage dtb MLO MLO.final u-boot.img u-boot.img.final MBR /media/$USER/boot

Note that we're using two versions of U-Boot:
- MLO, u-boot.img: just used for booting from external MMC and booting the kernel/rootfs
  that will reflash U-Boot
- MLO.final, u-boot.img.final: corresponding to U-Boot that we flash
  on the board.

Now, unmount '/media/$USER/boot' and you are done!

Using your bootable micro-SD card
---------------------------------

Your bootable micro-SD card should be easy to use. In particular, it allows
to reflash multiple boards without even needing to connect them to a serial
line.

First, insert the micro-SD card in the corresponding slot in the board.

Then, press and hold the 'Boot Switch' button (the only one near the USB
host slot), power up the board (either through the power or USB device
connectors), and release the button.

After about 20 to 30 seconds, you should see the 4 LEDs next to the Ethernet
connector turned on. This confirms that reflashing went well. You are done!

Don't switch off the board violently by removing the USB power.
Otherwise, you could damage some components (see the slides for details).
To power off the board in a clean way, first press the POWER button for 8
seconds and wait for the LEDs to switch off. Then you can safely
remove the USB power.

Fixing issues (if any)
----------------------

If after 1 minute, you got nothing special on the 4 LEDs, this probably
means that you didn't manage to boot your board from the external micro-SD
card. This happens as the button to press is tiny. Try again!

See the 'boot.log' file in this directory for the exact messages
your should get in the serial console (if you connected it).

If the LEDs all blink at the same time, this means that the reflashing
operation actually started but failed. If this happens, you will have
to connect your PC to the serial line of your board, and do this again.
You should see the error message on the serial line, and will have a
command line shell to fix it manually.

What you will need to do is copy the 'MLO' and 'u-boot.img' files from
the micro-SD card boot partition (should be seen as '/dev/mmcblk0p1') to the
eMMC boot partition (should be seen as '/dev/mmcblk1p1').

If the partitions need fixing and reformating, the root filesystem
you will boot on contains many useful commands, in particular 'fdisk'
and 'mkfs.vfat'.

The provided root filesystem may not be sufficient for all needs though.
For example, we failed to create a partition table with correct eMMC
geometry settings with the provided fdisk command. fsck.vfat is not
available either.

Should you need more standard tools, you may boot the board with
an MMC card with Debian on it (see http://beagleboard.org/latest-images).

==============================
How the binaries were compiled
==============================

Caution: instructions for people already familiar with embedded Linux.
See our Embedded Linux course (https://bootlin.com/training/embedded-linux/)
if you are not comfortable with these instructions.

Toolchain
---------

Tested on Ubuntu 18.04

Install the cross compiling toolchain:
sudo apt install gcc-arm-linux-gnueabi
(the version at the time of our testing was 4:7.3.0-3ubuntu2)

Compiling U-Boot
----------------

Clone the mainline U-boot sources:
git clone git://git.denx.de/u-boot.git
git checkout v2018.05
export CROSS_COMPILE=arm-linux-gnueabi-
make am335x_boneblack_defconfig

To compile u-boot.img and MLO:
Copy the src/u-boot/u-boot-2018.05.config file to .config
make

To compile u-boot.img.final and MLO.final:
Copy the src/u-boot-final/u-boot-2018.05.config file to .config
and the src/u-boot-final/uEnv.txt file to the U-boot toplevel source directory
(this contains default environment settings)
make

This produces the MLO and u-boot.img files.

Root filesystem
---------------

The root filesystem is available in src/rootfs.tar.xz

To rebuild your kernel, extract the contents of this archive,
as the kernel binary will contain the root filesystem (initramfs)
too.

This root filesystem just contains BusyBox utilities and a
few custom scripts. It is very easy to update (you don't need
tools like Buildroot).

If you to need to update it, get the latest BusyBox 1.21.x sources,
and configure them with src/busybox-1.21.x.config

If you don't, just go to the next section.

Assuming you extracted the rootfs archive in the 'rootfs' directory,
(in the same directory as the BusyBox source directory)
just run:

export CROSS_COMPILE=arm-linux-gnueabi-
make
make install

Linux kernel
------------

Clone the mainline git tree for the Linux kernel
and checkout the v4.17 tag

Now configure and compile the sources as follows
(we are using the same toolchain as for compiling U-Boot)
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabi-
Copy the src/linux-4.17.config file to .config
make -j 8

This produces:
arch/arm/boot/zImage
arch/arm/boot/dts/am335x-boneblack-wireless.dtb

Copy the arch/arm/boot/dts/am335x-boneblack-wireless.dtb to "dtb"
(this dtb will work fine for both BeagleBone Black
and BeagleBoneBlack Wireless, at least for the purpose of
reflashing U-Boot).
