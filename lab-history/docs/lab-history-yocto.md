title: OpenEmbedded/Yocto
description: Lab history for the Yocto Project and OpenEmbedded Training offered by Bootlin
hero: Yocto Project and OpenEmbedded Training

*These are the notes and commands to solve the yocto training offered by Bootlin
company.*

## Training Setup

```shell
cd yocto-labs/poky
git checkout sumo-19.0.0-yocto-labs
```

!!! Note
	You would find [yocto-labs](https://github.com/dagmcr/yocto-labs) repository as a submodule of the [training-materials](https://github.com/dagmcr/training-materials) project.

	```shell
	cd training-materials
	git submodule update
	```

### Set up the build environment

This labs are going to use [docker](https://docs.docker.com/install/) for doing 
the practical labs. You can use your computer instead as it is in the original
Bootlin training.

```shell
sudo apt-get install docker.io
```

!!! info
	crops/poky would be the container to be used for the labs. To enter in
	the container just remember or create a script with the following:

	```shell
	docker run --rm -it -v $PWD:/workdir crops/poky:debian-9 \
	--workdir=/workdir
	```

Now, you can start creating the yocto build directory by executing:

```shell
/workdir/build$ source poky/oe-init-build-env
```

!!! Note
	When `/workdir/build$` appears means that docker container is being
	used.

Now we can `meta-ti` layer to the `bblayers.conf` file to be able to use it:

```shell
cat build/conf/bblayers.conf
...
BBLAYERS ?= " \
  /workdir/poky/meta \
  /workdir/poky/meta-poky \
  /workdir/meta-ti \
  "
```

### Build your first image

In this case we are going to select `beaglebone` as our target `'MACHINE'`. You
can specify it under the `build/conf/local.conf` or provide it as a variable
in the bitbake command:

```shell
/workdir/build$ MACHINE=beaglebone bitbake core-image-minimal
```

Now, you can go and drink a :beer:. Maybe :beer: :beer:. If you still remember 
to come back after a while, you can check output:

```shell
ls -l yocto-labs/build/deploy/images/beaglebone
```

### Setup SD card

Plug your microSD card in your machine and check which device is created. In my
case SD card would be: `/dev/sde`. Unmount and format it:

```shell
cd yocto-labs/bootlin-lab-data/script/
sudo umount /dev/sde1
sudo ./format_sdcard.sh /dev/sde
```

Remove the SD card and insert it again to copy all the BSP and rootfs:

```shell
cp yocto-labs/build/tmp/deploy/images/beaglebone/{MLO,u-boot.img,zImage} \
/media/$USER/boot

cp yocto-labs/build/tmp/deploy/images/beaglebone/zImage-am335x-boneblack-wireless.dtb \
/media/$USER/boot/dtb

sudo tar xpf yocto-labs/build/tmp/deploy/images/beaglebone/\
core-image-minimal-beaglebone.tar.xz -C /media/$USER/rootfs

sync
```

## Setting up serial communication with the board

picocom, why not? Others might prefer (gtk-term)[http://gtkterm.feige.net/]. I
would go with the first one as it is the one used in the training.

```shell
sudo apt install picocom
sudo adduser $USER dialout
```

Log out and log in. 

> Yeap... 

Now, we can connect the UART to see the logs of the board. In this case, my 
usb serial is located in `/dev/ttyUSB0`.

```shell
picocom -b 115200 /dev/ttyUSB0
```

| PIN BBB | Connector USB-Serial | Color | Connector BBB |
|---------|----------------------|-------|---------------|
| 1       | GND                  | Blue  | GND           |
| 4       | TX                   | Red   | RX            |
| 5       | RX                   | Green | TX            |

!!! info
	If you wish to exit picocom, press `[Ctrl][a]` followed by
	`[Ctrl][x]`.

### Configure the U-Boot environment and boot

In our U-Boot enviroment, we would need to type save `bootcmd` command which
would be used for the booting process:

```
setenv bootcmd 'mmc rescan; fatload mmc 0 0x80200000 zImage; fatload mmc 0
0x82000000 dtb; bootz 0x80200000 - 0x82000000'
setenv bootargs 'console=ttyS0,115200 root=/dev/mmcblk0p2 rootwait rw'
saveenv
```

!!! info
	Remember how to boot properly from the SD card every time you reboot
	the board by pressing `'S2'` button when starting.

## Lab 2: Advanced Yocto configuration

### Set up the Ethernet communication and NFS on the board

Board:

```
setenv ipaddr 192.168.5.100
setenv serverip 192.168.5.1
setenv ethact usb_ether
setenv usbnet_devaddr f8:dc:7a:00:00:02
setenv usbnet_hostaddr f8:dc:7a:00:00:01
saveenv
```

!!! info

	Bootlin: *Make sure that this address belongs to a separate network segment from the one used by your PC to connect to the network.*

#### Test TFTP server

```shell
sudo apt install tftpd-hpa
```

Configuration in `/etc/default/tftpd-hpa`: `TFTP_DIRECTORY="/srv/tftp"`

```shell
sudo mkdir -p /srv/tftp
sudo chown -R $USER.$USER /srv/tftp
sudo chmod 755 -R /srv/tftp
touch /srv/tftp/textfile.txt
echo "hello world" > /srv/tftp/textfile.txt
```

```
tftp 0x81000000 textfile.txt
md 0x81000000
```

```shell
sudo service tftpd-hpa restart
```

##### Set up the Ethernet communication on the workstation

```shell
nmcli con add type ethernet ifname enxf8dc7a000001 ip4 192.168.5.1/24
```

!!! tip 
	Extra options (modify/delete):

	```shell
	nmcli con modify ethernet-enxf8dc7a000001 ip4 192.168.5.1/24
	nmcli con del ethernet-enxf8dc7a000001
	```

!!! warning
	When booting rootfs from NFS, check if usb-eth device registers a
	different random name.

	Check NFS logs:

	```shell
	[    1.663572] using random self ethernet address
	[    1.668049] using random host ethernet address
	[    1.672515] using host ethernet address: f8:dc:7a:00:00:01
	[    1.672520] using self ethernet address: f8:dc:7a:00:00:02
	[    1.678723] usb0: HOST MAC f8:dc:7a:00:00:01
	[    1.688646] usb0: MAC f8:dc:7a:00:00:02
	[    1.692520] using random self ethernet address
	[    1.697007] using random host ethernet address
	[    1.701535] g_ether gadget: Ethernet Gadget, version: Memorial Day 2008
	[    1.708244] g_ether gadget: g_ether ready
	```

	Host:

	```shell
	[12798.983385] cdc_eem 1-12:1.0 enp0s20f0u12: renamed from usb0
	```

In my case, device was renamed to `enp0s20f0u12`. So, I proceed as follows:

Check new eth-usb interface:

```shell
sudo ifconfig enp0s20f0u12
```

Configure it:

```shell
nmcli con add type ethernet ifname enp0s20f0u12 ip4 192.168.5.1/24
nmcli con modify ethernet-enp0s20f0u12 ip4 192.168.5.1/24
```

### Set up the NFS server on the workstation

```shell
sudo apt install nfs-kernel-server
sudo mkdir -m 777 /nfs
```

Append `/nfs` to `/etc/exports`:
```shell
/nfs 192.168.5.100(rw,no_root_squash,no_subtree_check)
```

```shell
sudo service nfs-kernel-server restart
```

!!! note
	You can also restart the service by executing:

	```shell
	sudo /etc/init.d/nfs-kernel-server restart
	```

Check NFS server:

```shell
showmount -e localhost
Export list for localhost:
/nfs *
```

Now, we can verify if it is up and running...

```shell
sudo mkdir -p /mnt/nfs
mount -t nfs localhost:/nfs /mnt/nfs
```

### Add a package to the rootfs image

Append `dropbear` :bear: package to the `build/conf/local.conf`:

```
IMAGE_INSTALL_append = " dropbear"
```
### Regenerate image

```shell
MACHINE=beaglebone bitbake core-image-minimal
```

```
sudo tar xpf $BUILDDIR/tmp/deploy/images/beaglebone/\
core-image-minimal-beaglebone.tar.xz -C /nfs
```

### Set up bootargs and boot rootfs over NFS

```
setenv bootargs 'console=ttyS0,115200 root=/dev/nfs rw nfsroot=192.168.5.1:/nfs,nfsvers=3
ip=192.168.5.100:::::usb0 g_ether.dev_addr=f8:dc:7a:00:00:02
g_ether.host_addr=f8:dc:7a:00:00:01'
saveenv
```

bootargs tested:
```
setenv bootargs root=/dev/nfs rw ip=192.168.5.100:::::usb0 console=ttyO0,115200n8 g_ether.dev_addr=f8:dc:7a:00:00:02 g_ether.host_addr=f8:dc:7a:00:00:01 nfsroot=192.168.5.1:/nfs,nfsvers=3
```

!!! info
	Check this step by step [guide](https://bootlin.com/blog/tftp-nfs-booting-beagle-bone-black-wireless-pocket-beagle/) if somehow you can't configure tftp properly.

Remember to check random self ethernet address log and reconfigure the new eth
device in your host:

```
[    1.663572] using random self ethernet address
[    1.668049] using random host ethernet address
[    1.672515] using host ethernet address: f8:dc:7a:00:00:01
[    1.672520] using self ethernet address: f8:dc:7a:00:00:02
[    1.678723] usb0: HOST MAC f8:dc:7a:00:00:01
[    1.688646] usb0: MAC f8:dc:7a:00:00:02
[    1.692520] using random self ethernet address
[    1.697007] using random host ethernet address
[    1.701535] g_ether gadget: Ethernet Gadget, version: Memorial Day 2008
[    1.708244] g_ether gadget: g_ether ready
[    1.721482] hctosys: unable to open rtc device (rtc0)
[    1.727483] IPv6: ADDRCONF(NETDEV_UP): usb0: link is not ready
[    2.191455] g_ether gadget: high-speed config #1: CDC Ethernet (EEM)
[    2.212972] IPv6: ADDRCONF(NETDEV_CHANGE): usb0: link becomes ready
[    2.243045] IP-Config: Guessing netmask 255.255.255.0
[    2.248132] IP-Config: Complete:
[    2.251383]      device=usb0, hwaddr=f8:dc:7a:00:00:02, ipaddr=192.168.5.100, mask=255.255.255.0, gw=255.255.255.255
[    2.262455]      host=192.168.5.100, domain=, nis-domain=(none)
[    2.268666]      bootserver=255.255.255.255, rootserver=192.168.5.1, rootpath=
```

> Target

```shell
[12798.983385] cdc_eem 1-12:1.0 enp0s20f0u12: renamed from usb0
```
> Host

Check:

```shell
sudo ifconfig enp0s20f0u12
```

Configure:

```shell
nmcli con add type ethernet ifname enp0s20f0u12 ip4 192.168.5.1/24
nmcli con modify ethernet-enp0s20f0u12 ip4 192.168.5.1/24
```

### Check dropbear

Try to connect to the board over ssh and then, we will verify `dropbear` package
is running properly:

```shell
ssh root@192.168.0.100
```

### Choose a package variant

### Tips

```shell
bitbake -c listtasks virtual/kernel
bitbake -c <task> virtual/kernel
bitbake -f virtual/kernel
bitbake --runall=fetch world
bitbake -s
bitbake -h
```

https://layers.openembedded.org/rrs/recipes/OE-Core/2.8/M3/

...

## Lab 3: Add a custom application

```
setenv bootcmd 'tftp 0x81000000 zImage; tftp 0x82000000 dtb; bootz 0x81000000 - 0x82000000'
```

