# Install U-boot on the i.MX93 FRDM SD card

This is needed for some aspects of Bootlin's kernel, Yocto Project and
Buildroot labs, such as saving U-Boot environment settings to non
volatile storage.

## 1. Download the images

We suggest you to clone this repository, where all binary images are
ready to be used. Instructions to build them on your own will come soon.

```
git clone https://github.com/bootlin/training-materials.git
cd training-materials/lab-data/common/bootloader/imx93-frdm
```

### 2. Flash the image using a micro-SD card

Take a micro-SD card and connect it to your PC:
- Either using a direct SD slot if available.
  In this case, the card should be seen as `/dev/mmcblk0` by
  your computer (check the `dmesg` command output).
- Either using a memory card reader.
  In this case, the card should be seen as `/dev/sdb`, or `/dev/sdc`, etc.

Now, run the mount command to check for mounted SD card
partitions. Umount them with a command such as
`sudo umount /dev/mmcblk0p1` or `sudo umount /dev/sdb1`,
depending on how the system sees the media card device.

Now type the below command to flash your micro-SD card (we assume that
the card is seen as `/dev/mmcblk0`):

	sudo dd if=flash.bin of=/dev/mmcblk0 bs=1k seek=32 oflag=sync

### 3. Use your bootable micro-SD card

Insert the micro-SD card in the corresponding slot in the board.

Set the boot switches to the \code{SD 1100} position.

Power-up the board, you should almost immediately get a prompt.
