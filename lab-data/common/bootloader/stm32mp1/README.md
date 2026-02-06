# Install U-boot on the STM32MP1 SD card

This is needed for some aspects of Bootlin's kernel, Yocto Project and Buildroot labs,
such as saving U-Boot environment settings to non volatile storage.

Tested on the following board revisions:
- STM32MP157D-DK1

## 1. Download the images

We suggest you to clone this repository, where all binary images are
ready to be used. You can also build them on your own if you wish, all
instructions are provided in chapter 3.

```
git clone https://github.com/bootlin/training-materials.git
cd training-materials/lab-data/common/bootloader/stm32mp1/
```

## 2. Flashing

Take a micro-SD card and connect it to your PC:
- Either using a direct SD slot if available.
  In this case, the card should be seen as `/dev/mmcblk0` by
  your computer (check the `dmesg` command output).
- Either using a memory card reader.
  In this case, the card should be seen as `/dev/sdb`, or `/dev/sdc`, etc.

Run the mount command to check for mounted SD card
partitions. Umount them with a command such as
`sudo umount /dev/mmcblk0p*` or `sudo umount /dev/sdb*`,
depending on how the system sees the media card device.

Erase the existing partition table and partition contents by simply
zero-ing the first 128 MiB of the SD card
(we assume that the card is seen as `/dev/mmcblk0`):

    $ sudo dd if=/dev/zero of=/dev/mmcblk0 bs=1M count=128

Let’s use the parted command to create the partitions that we are going to use
(we assume that the card is seen as `/dev/mmcblk0`):

    $ sudo parted /dev/mmcblk0

The ROM monitor handles GPT partition tables, let’s create one:
    
    (parted) mklabel gpt

Then, the 3 partitions are created with:

    (parted) mkpart fsbl1 0% 4095s
    (parted) mkpart fsbl2 4096s 6143s
    (parted) mkpart fip 6144s 14335s

You can verify everything looks right with:

    (parted) print
    Model: SD SD16G (sd/mmc)
    Disk /dev/mmcblk0: 15,5GB
    Sector size (logical/physical): 512B/512B
    Partition Table: gpt
    Disk Flags: 

    Number  Start   End     Size    File system  Name   Flags
    1      1049kB  2097kB  1049kB               fsbl1
    2      2097kB  3146kB  1049kB               fsbl2
    3      3146kB  7340kB  4194kB               fip

    (parted)

Once done, quit:

    (parted) quit

Now type the below command to flash your micro-SD card (we assume that
the card is seen as `/dev/mmcblk0`):

    $ sudo dd if=tf-a-stm32mp157a-dk1.stm32 of=/dev/mmcblk0p1 bs=1M conv=fdatasync
    $ sudo dd if=tf-a-stm32mp157a-dk1.stm32 of=/dev/mmcblk0p2 bs=1M conv=fdatasync
    $ sudo dd if=fip.bin of=/dev/mmcblk0p3 bs=1M conv=fdatasync


## 3. How images were built

### Download bootlin toolchain

Please download stable-2024.05.1 bootlin toolchain:
https://toolchains.bootlin.com/downloads/releases/toolchains/armv7-eabihf/tarballs/armv7-eabihf--glibc--stable-2024.05-1.tar.xz

### Compiling U-Boot

```
git clone https://github.com/u-boot/u-boot.git
cd u-boot
git checkout v2026.1
export CROSS_COMPILE=<path-to>/armv7-eabihf--glibc--stable-2024.05-1/bin/arm-linux-
make stm32mp15_defconfig
make DEVICE_TREE=st/stm32mp157a-dk1 all
```

### Compiling TF-A

```
git clone https://github.com/ARM-software/arm-trusted-firmware.git
cd arm-trusted-firmware
git checkout lts-v2.12.8
make ARM_ARCH_MAJOR=7 ARCH=aarch32 PLAT=stm32mp1 DTB_FILE_NAME=stm32mp157a-dk1.dtb STM32MP_SDMMC=1 AARCH32_SP=sp_min \
BL33=../u-boot/u-boot-nodtb.bin \
BL33_CFG=../u-boot/u-boot.dtb fip all
```

