=============================================================================================
Install U-boot on the BeagleBone Black (including BBB Wireless) internal flash storage (eMMC)
=============================================================================================

This is needed for some aspects of Bootlin's kernel, Yocto Project and Buildroot labs,
such as saving U-Boot environment settings to eMMC storage.

Tested on the following board revisions:
- Original release of the board

Caution: this procedure can erase data installed on the board eMMC.
This won't make your board unusable though. If you want to install a
distribution again on the eMMC, just go to
http://beagleboard.org/latest-images and follow instructions.

1. Download the images
2a. Flash the image using Ethernet over USB with 'snagboot' (recommended)
2b. Flash the image using a micro-SD card (legacy)
3a. How snagboot images were built
3b. How the images for SD card recovery were built

======================
1. Download the images
======================

We suggest you to clone this repository, where all binary images are
ready to be used. You can also build them on your own if you wish, all
instructions are provided in chapter 3.

===========================================
2a. Flash the image using Ethernet over USB
===========================================

Follow the installation instructions at
https://github.com/bootlin/snagboot to install snagboot.

Setup the snagboot recovery environment
by running the am335x setup script:
```
snagrecover --am335x-setup > am335x_usb_setup.sh
chmod a+x am335x_usb_setup.sh
sudo ./am335x_usb_setup.sh
```

If you have trouble with this step, you can find more detailed instructions
in the snagboot documentation:
https://github.com/bootlin/snagboot/blob/main/docs/board_setup.md#ti-am335x-usb-recovery

Put the BBB into recovery mode by unplugging and replugging the power cable
while pressing the S2 switch. Please beware that a warm reset performed
with the reset button won't work, as it does not affect the boot source!

Check that the following USB device is present:

    $ lsusb | grep AM335x
    Bus 001 Device 024: ID 0451:6141 Texas Instruments, Inc. AM335x USB

Run snagrecover from the snagboot recovery shell:

    # snagrecover -s am3358 \
                  -F "{'spl': {'path': 'u-boot-spl.bin'}}" \
		  -F "{'u-boot': {'path': 'u-boot.img'}}"

Once you get a U-Boot prompt on the serial console, enable fastboot:

    => env default -a
    => unbind ethernet 1
    => fastboot usb 0

Don't be upset by the following message, it's expected...

    musb-hdrc: peripheral reset irq lost!

Then from the host, flash the image:

    $ snagflash -P fastboot -p 0451:d022 -f oem_format -f download:sdcard.img -f flash:1:0

Finally, return to U-Boot, exit fastboot mode using Ctrl+c and save the
environment:

    => saveenv

Reboot by unplugging the power supply cable and the micro-usb cable (just
resetting won't change the boot source), and enjoy the training!

=========================================
2b. Flash the image using a micro-SD card
=========================================

These instructions are given as reference only, they will install an old
U-Boot. Prefer using method 2a using Snagboot.

Make a bootable micro-SD card
-----------------------------

We are going to prepare a bootable micro-SD card that will automatically
reflash the eMMC with the U-Boot binaries provided in the sdcard/
directory.

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

Now type the below command to flash your micro-SD card (we assume that
the card is seen as '/dev/mmcblk0'):

sudo dd if=sdcard.img of=/dev/mmcblk0 bs=1M

Using your bootable micro-SD card
---------------------------------

Your bootable micro-SD card should be easy to use. In particular, it allows
to reflash multiple boards without even needing to connect them to a serial
line.

First, insert the micro-SD card in the corresponding slot in the board.

Then, press and hold the 'Boot Switch' button (the only one close to the
micro-SD slot), power up the board (either through the power or USB device
connectors), and release the button.

After about 10 to 20 seconds, you should see the 4 LEDs turned on next to:
- the Ethernet connector on BeagleBoneBlack
- the micro-USB connector on BeagleBoneBlack wireless
This confirms that reflashing went well. You are done!

Then, remove the micro-SD card.

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

========================================================
3a. How the binaries were compiled for Snagboot recovery
========================================================

Compiling U-Boot
----------------

git checkout v2024.01
cp src/snagboot/u-boot/uEnv.txt ~/u-boot/
cp src/snagboot/u-boot/u-boot-2024.01.config ~/u-boot/.config
make

You can as well re-create this configuration with:
make am335x_evm_defconfig
make menuconfig
# select CONFIG_USE_DEFAULT_ENV_FILE
# set CONFIG_DEFAULT_ENV_FILE=uEnv.txt
# set CONFIG_ENV_FAT_DEVICE_AND_PART="1:1"
# set CONFIG_SYS_MMC_ENV_DEV=1

Assembling all files into sdcard.img
------------------------------------

This is done using the ./gen.sh script, which itself uses the genimage
tool.

=======================================================
3b. How the binaries were compiled for SD-card recovery
=======================================================

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
git clone https://git.denx.de/u-boot
git checkout v2018.05
export CROSS_COMPILE=arm-linux-gnueabi-
make am335x_boneblack_defconfig

To compile sdcard/u-boot.img and sdcard/MLO:
Copy src/sdcard/u-boot/u-boot-2018.05.config file to .config
make

To compile sdcard/u-boot.img.final and sdcard/MLO.final:
Copy src/sdcard/u-boot-final/u-boot-2018.05.config to .config
Copy src/sdcard/u-boot-final/uEnv.txt to the U-boot toplevel source
directory (this contains default environment settings)
make

This produces the sdcard/MLO and sdcard/u-boot.img files.

Root filesystem
---------------

The root filesystem is available in src/sdcard/rootfs.tar.xz

To rebuild your kernel, extract the contents of this archive,
as the kernel binary will contain the root filesystem (initramfs)
too.

This root filesystem just contains BusyBox utilities and a
few custom scripts. It is very easy to update (you don't need
tools like Buildroot).

If you to need to update it, get the latest BusyBox 1.21.x sources,
and configure them with src/sdcard/busybox-1.21.x.config

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
Copy src/sdcard/linux-4.17.config file to .config
make -j 8

This produces:
arch/arm/boot/zImage
arch/arm/boot/dts/am335x-boneblack-wireless.dtb

Copy the arch/arm/boot/dts/am335x-boneblack-wireless.dtb to sdcard/dtb
(this dtb will work fine for both BeagleBone Black
and BeagleBoneBlack Wireless, at least for the purpose of
reflashing U-Boot) and the zImage file as well.

Assembling all files into sdcard.img
------------------------------------

This is done using the sdcard/gen.sh script, which itself uses the
genimage tool.
