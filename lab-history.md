# lab history

Linux Kernel and Driver Development Training

## Training Setup

```shell
tar xvf linux-kernel-labs.tar.xz
```

## Downloading kernel source code

### Setup and git configuration

```shell
mkdir linux-kernel-labs/src
cd linux-kernel-labs/src
sudo apt install git gitk git-email
git config --global user.name ’My Name’
git config --global user.email me@mydomain.net
git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
```

### Linux stable releases

```shell
cd linux-kernel-labs/src/linux/
git remote add stable git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
git fetch stable
```

## Kernel Source Code - Exploring

### Setup

```shell
sudo apt-get install cscope
```

### Exploring

```shell
cd linux-kernel-labs/src/linux/
git checkout -b 4.19.y stable/linux-4.19.y
cat Makefile | head 
find ./ -iname mvneta*
./scripts/get_maintainer.pl -f ./drivers/net/ethernet/marvell/mvneta.c
cscope -Rk
```

> **Note**: If using `git@github.com:dagmcr/linux.git` then,
`git checkout stable/linux-4.19.y`.

#### cscope 

*  `[Tab]`: move the cursor between search results and commands
*  `[Ctrl] [D]`: exit cscope

## Kernel compiling and booting

### Setup

```shell
sudo apt install gcc-arm-linux-gnueabi
sudo apt install libssl-dev bison flex bc
sudo apt install libncurses-dev
dpkg -L gcc-arm-linux-gnueabi
```

```shell
make ARCH=arm omap2plus_defconfig
make ARCH=arm xconfig
make ARCH=arm menuconfig
```
> **Note**: With ``menuconfig`` type ``/`` and the string you want to search (e.g. ``ROOT_NFS``) and navigate to it.

```shell
CONFIG_ROOT_NFS=y
CONFIG_USB_GADGET=y
CONFIG_USB_MUSB_HDRC=y
CONFIG_USB_MUSB_GADGET=y
CONFIG_USB_MUSB_DSPS=y
CONFIG_AM335X_PHY_USB
CONFIG_AM335X_PHY_USB=y
CONFIG_USB_ETH=y
CONFIG_PROVE_LOCKING=n
```

> **Note**: If using `git@github.com:dagmcr/linux.git` then,
`make ARCH=arm omap2plus-bootlin-kernel-training_defconfig`

```shell
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j 8
```

```shell
ls arch/arm/boot/zImage
ls arch/arm/boot/dts/am335x-boneblack.dtb
```

> **Note**: repo `git@github.com:dagmcr/linux.git`, branch: `4.19.y` includes `omap2plus-bootlin-kernel-training_defconfig`

## Board Setup

### Setup

```shell
sudo apt install picocom
sudo adduser $USER dialout
```

### Setting up serial communication with the board

```shell
picocom -b 115200 /dev/ttyUSB0
```

+---------+----------------------+-------+---------------+
| PIN BBB | Connector USB-Serial | Color | Connector BBB |
+=========+======================+=======+===============+
| 1       | GND                  | Blue  | GND           |
+---------+----------------------+-------+---------------+
| 4       | TX                   | Red   | RX            |
+---------+----------------------+-------+---------------+
| 5       | RX                   | Green | TX            |
+---------+----------------------+-------+---------------+

> **Note**: If you wish to exit picocom, press `[Ctrl][a]` followed by
`[Ctrl][x]`.

### Bootloader interaction

```
=> help saveenv
saveenv - save environment variables to persistent storage

Usage:
saveenv 
```

```
=> env default -f -a
## Resetting to default environment
=> saveenv
Saving Environment to MMC... Writing to redundant MMC(1)... OK
```

If above command is not available then, check the instructions in https://raw.githubusercontent.com/bootlin/training-
materials/master/lab-data/common/bootloader/beaglebone-black/README.txt to
fix it. Below sections sum-up the steps.

#### Setup microSD

```shell
sudo sfdisk /dev/sde << EOF
1,,0xE,*
EOF
```

Remove SD card and insert it again.

```shell
sudo mkfs.vfat -F 32 /dev/sde1 -n boot
```

Remove SD card and insert it again. Check `/media/$USER/boot`

```shell
cd lab-data/common/bootloader/beaglebone-black/
cp zImage dtb MLO MLO.final u-boot.img u-boot.img.final MBR /media/$USER/boot
```

> **Note**: 'Compiling U-boot' step is not needed if you just have copied above files.

> **Note**: The rest of the files are generated also, following this guide:
> *  https://raw.githubusercontent.com/bootlin/training-materials/master/lab-data/common/bootloader/beaglebone-black/README.txt

#### Compiling U-Boot

```
git clone git://git.denx.de/u-boot.git
git checkout v2018.05
export CROSS_COMPILE=arm-linux-gnueabi-
make am335x_boneblack_defconfig
```

or...

```shell
cd linux-kernel-labs/src/u-boot/
CROSS_COMPILE=arm-linux-gnueabi- make am335x_boneblack_defconfig
cp ../../../lab-data/common/bootloader/beaglebone-black/src/u-boot/u-boot-2018.05.config .config
CROSS_COMPILE=arm-linux-gnueabi- make -j 8
```

```shell
cp MLO /media/$USER/boot
cp u-boot.img /media/$USER/boot
```

```shell
cd linux-kernel-labs/src/u-boot/
CROSS_COMPILE=arm-linux-gnueabi- make am335x_boneblack_defconfig
cp ../../../lab-data/common/bootloader/beaglebone-black/src/u-boot-final/u-boot-2018.05.config .config
cp ../../../lab-data/common/bootloader/beaglebone-black/src/u-boot-final/uEnv.txt .
CROSS_COMPILE=arm-linux-gnueabi- make -j 8
```

```shell
cp MLO /media/$USER/boot/MLO.final
cp u-boot.img /media/$USER/boot/u-boot.img.final
```

```shell
cp ../../../lab-data/common/bootloader/beaglebone-black/MBR /media/$USER/boot
cp ../../../lab-data/common/bootloader/beaglebone-black/dtb /media/$USER/boot/
cp ../../../lab-data/common/bootloader/beaglebone-black/zImage /media/$USER/boot/
```

Unmount `/media/$USER/boot/`.

> **Note**: 
> *  `u-boot-2018.05.config`: `lab-data/common/bootloader/beaglebone-black/src/u-boot/u-boot-2018.05.config`.
> *  final `u-boot-2018.05.config`: `lab-data/common/bootloader/beaglebone-black/src/u-boot-final/u-boot-2018.05.config`.
> *  final `uEnv.txt`: `lab-data/common/bootloader/beaglebone-black/src/u-boot-final/uEnv.txt`.
> *  `MBR`: `lab-data/common/bootloader/beaglebone-black/MBR`.

#### Using your bootable micro-SD card

> **Note**: This section is copy pasted from:
> *  https://raw.githubusercontent.com/bootlin/training-materials/master/lab-data/common/bootloader/beaglebone-black/README.txt

*Your bootable micro-SD card should be easy to use. In particular, it allows
to reflash multiple boards without even needing to connect them to a serial
line.*

*First, insert the micro-SD card in the corresponding slot in the board.*

*Then, press and hold the 'Boot Switch' button (the only one near the USB
host slot), power up the board (either through the power or USB device
connectors), and release the button.*

*After about 20 to 30 seconds, you should see the 4 LEDs next to the Ethernet
connector turned on. This confirms that reflashing went well. You are done!

Don't switch off the board violently by removing the USB power.
Otherwise, you could damage some components (see the slides for details).
To power off the board in a clean way, first press the POWER button for 8
seconds and wait for the LEDs to switch off. Then you can safely
remove the USB power.*

### Setting up networking (TFTP & NFS)

#### Board

```
=> setenv ipaddr 192.168.0.100
=> setenv serverip 192.168.0.1
=> setenv ethact usb_ether
=> setenv usbnet_devaddr f8:dc:7a:00:00:02
=> setenv usbnet_hostaddr f8:dc:7a:00:00:01
=> saveenv
```

#### TFTP

##### TFTP requirements

```shell
sudo apt-get install tftp tftpd-hpa
```

##### TFTP configuration

```shell
cat /etc/default/tftpd-hpa
```

```shell
# /etc/default/tftpd-hpa
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/var/lib/tftpboot"
TFTP_ADDRESS="[::]:69"
TFTP_OPTIONS="--secure"
```

```shell
sudo chmod -R 755 /srv/tftp
sudo chown -R $USER.$USER /srv/tftp
```

```shell
cp <kernel-output-dir>/Image /var/lib/tftpboot/
cp <dtb-output-dir>/<machine>.dtb /var/lib/tftpboot/
```

##### TFTP test

```shell
touch /var/lib/tftpboot/test 
tftp localhost
tftp> get test
```

#### NFS

##### NFS requirements

```shell
sudo apt-get install nfs-kernel-server nfs-common
```

##### NFS configuration

```shell
cat /etc/exports
```

```shell
# /etc/exports: the access control list for filesystems which may be exported
#        to NFS clients.  See exports(5).
#
# Example for NFSv2 and NFSv3:
# /srv/homes       hostname1(rw,sync,no_subtree_check) hostname2(ro,sync,no_subtree_check)
#
# Example for NFSv4:
# /srv/nfs4        gss/krb5i(rw,sync,fsid=0,crossmnt,no_subtree_check)
# /srv/nfs4/homes  gss/krb5i(rw,sync,no_subtree_check)
#
/srv/nfs *(rw,no_subtree_check,sync,no_root_squash,no_all_squash)
```

```shell
sudo mkdir -p /srv/nfs/rootfs
sudo /etc/init.d/nfs-kernel-server start
sudo exportfs -a
sudo tar xvf <rootfs-output-dir>/<rootfs>.tar.bz2 -C /srv/nfs/rootfs/
```

##### NFS test

```shell
showmount -e localhost
Export list for localhost:
/srv/nfs *
```

```shell
mount -t nfs localhost:/srv/nfs /mnt/
```

#### Quick commands

```shell
sudo service tftpd-hpa restart
sudo /etc/init.d/nfs-kernel-server restart
```
