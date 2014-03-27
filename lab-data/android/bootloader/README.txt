======================================================================
Install U-Boot on the BeagleBone Black's internal flash storage (eMMC)
======================================================================

We use a version of U-Boot that supports the Android fastboot protocol
and can read Android boot image files

Tested on the following board revisions:
- Rev A5C

Make a bootable micro-SD card
-----------------------------

We are going to prepare a bootable micro-SD card that will allow us to
use fastboot comands to write to the internal eMMC memory.

Take a micro-SD card and connect it to your PC:
- Either using a direct SD slot if available.
  In this case, the card should be seen as '/dev/mmcblk0' by
  your computer (check the 'dmesg' command output).
- Either using a memory card reader.
  In this case, the card should be seen as '/dev/sdb', or '/dev/sdc',
  etc.

Now, run the mount command to check for mounted SD card
partitions. Umount them with a command such as
'sudo umount /dev/mmcblk0p1' or 'sudo umount /dev/sdb1',
depending on how the system sees the media card device.

Now type the below command to partition the micro-SD card
(we assume that the card is seen as '/dev/mmcblk0'):

sudo sfdisk --in-order --Linux --unit M /dev/mmcblk0 << EOF
1,48,0xE,*
,,,-
EOF

Now, format the first partition in FAT format:

sudo mkfs.vfat -F 16 /dev/mmcblk0p1 -n boot

Remove the card and insert it again. It should automatically be
mounted '/media/boot' (or '/media/<user>/boot' if you are using Ubuntu
12.10 or later).

Now, copy the files to this partition:

cp MLO u-boot.img /media/boot/

Now, unmount '/media/boot' and you are done!

Using your bootable micro-SD card
---------------------------------

WARNING: this will erase everything in the eMMC storage. If you want
to restore the factory default installation later, follow the
instructions here: http://elinux.org/Beagleboard:Updating_The_Software

As well as the BeagleBone and micro SD card, you will need a serial to
USB cable and it is recommended that you use an external power supply
because the current used whe writing to the eMMC chip may exceed that
supplied by a typical USB port.

With no power on the BeagleBone board, insert the micro-SD card in the
corresponding slot.

Plug in the serial cable. A serial port should appear on your PC as
/dev/ttyUSB0. Start a suitable terminal program such as picocom and
attach to the port:

picocom -b 115200 /dev/ttyUSB0

Now, press and hold the 'Boot Switch' button on the Beaglebone (it is
the only one near the USB host slot), power up the board using the
external 5V power connector and release the button after about 5
seconds.

You should see a U-Boot prompt on the serial console

U-Boot#

Type "fastboot" to enable the fastboot protocol on U-Boot. Make sure
that you have plugged in the USB cable between the micro USB port on
the BeagleBone and the PC. On the PC, check that the BeagleBone is
detected:

fastboot devices
90:59:af:5e:94:81	fastboot

Change into the directory containing MLO and u-boot.bin. Use fastboot
to flash them into the eMMC chip on the BeagleBone:

$ fastboot oem format
$ fastboot flash spl MLO
$ fastboot flash bootloader u-boot.img

Power off the board, remove the SD card and check that it boots from
eMMC with the new U-Boot installed.

Now you can flash Android images into the eMMC partitions using
commands such as

fastboot flash userdata
fastboot flash cache
fastboot flashall

===============================
How the binaries where compiled
===============================

Compiling U-Boot
----------------

Get a copy of the source code:

git clone git://git.free-electrons.com/android/beagleboneblack/u-boot
cd u-boot
git checkout am335x-v2013.01.01-bbb-fb

Since you are likely to be building this along with AOSP, we are using
the Android cross compiler from prebuilts, but probably any recent arm
eabi toolchain will do. If you have sourced build/envsetup.sh and
selected the lunch combo the path will be set up already. If not set
it now, where ${AOSP} is the place where you installed your AOSP. It
was tested with Android 4.3, which has gcc version 4.7:

PATH=${AOSP}/prebuilts/gcc/linux-x86/arm/arm-eabi-4.7/bin:$PATH

Then configure and build:
$ make CROSS_COMPILE=arm-eabi- distclean
$ make CROSS_COMPILE=arm-eabi- am335x_evm_config
$ make CROSS_COMPILE=arm-eabi- 

This produces the two files: MLO and u-boot.img.
