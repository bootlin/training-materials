#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= A/B updates

===  A/B updates

- Mecanism for Over-The-Air (OTA) #emph[image] updates

- Key idea: avoid one update bricking the device

  - Even if tested, one update might prevent the system from booting

  - Enable the device to recover from a bad update automatically

  - Avoid RMAs or in-the-field intervention

- The key idea is to maintain 2 copies of the system, in two
  #strong[slots]

  - minimum is 2 rootFS

  - usually also includes the kernel

  - can involve the bootloader, depending on the bootROM

- Non-A/B OTAs are
  #link("https://source.android.com/docs/core/ota/nonab")[deprecated in Android]
  since Android 6 (pre August 2016)

===  A/B updates: slots

- A/B systems have 2 slots: slot A and slot B

- They each have dedicated boot locations (usually boot medium
  partitions)

- On the running system, the slot booted is the #strong[current] slot

- An OTA should never touch boot locations from the #strong[current]
  slot

- Each slot can be marked #strong[bootable]

- Updates will usually be built independently from the slot they will
  occupy

===  A/B updates: strategy

- At boot, the system detect which slot (A or B) is the #strong[current]
  slot

- The updater will locate the boot locations for the #strong[alternate]
  slot

- The updater then applies the update to the #strong[alternate] boot
  locations

- The updater marks the #strong[alternate] slot as #strong[next] to be
  booted

- Eventually, the system reboots. Possibly triggered at the end of the
  update

- At boot, the bootloader detects the #strong[next] slot and boots it

  - If the system fails to boot, the watchdog reboots the system. If the
    slot fails to boot several times, the system boots the other slot.

  - If the boot succeed, the system runs checks and if they pass, marks
    the #strong[current] slot as #strong[primary]

===  A/B updates: bootloader

- The bootloader is responsible for:

  - Booting the #strong[primary] slot by default

  - Keeping track of boot failures per slot

  - Trying out the #strong[alternate] slot if it is marked as
    #strong[next]

  - Optionally, telling the kernel which slot has been booted (A or B)

- Communication between bootloader and the system is short

===  Updater: SWUpdate

- Open source project

- #link("https://swupdate.org/")[website] –
  #link("https://github.com/sbabic/swupdate")[code] –
  #link("https://sbabic.github.io/swupdate/index.html")[doc]

- Used e.g. by the
  #link("https://cip-project.org/")[Civil Infrastructure Project]

- Integrated in both Buildroot and Yocto

- Written in C

- Uses `libconfig` syntax for configuration

===  SWUpdate: configuration

#text(size: 12pt)[
```yaml
software =
{
        version = "0.1.0";
        description = "Firmware update for XXXXX Project";

        hardware-compatibility: [ "1.0", "1.2", "1.3"];

        partitions: (
                { name = "rootfs"; device = "mtd4"; size = 104896512; },
                { name = "data"; device = "mtd5"; size = 50448384; }
        );

        images: (
                { filename = "rootfs.ubifs"; volume = "rootfs"; },
                { filename = "swupdate.ext3.gz.u-boot"; volume = "fs_recovery"; },
                { filename = "sdcard.ext3.gz"; device = "/dev/mmcblk0p1"; compressed = "zlib";},
                { filename = "bootlogo.bmp"; volume = "splash"; },
                { filename = "uImage.bin"; volume = "kernel"; },
                { filename = "fpga.txt"; type = "fpga"; },
                { filename = "bootloader-env"; type = "bootloader"; }
        );

        files: ({ filename = "README"; path = "/README"; device = "/dev/mmcblk0p1"; filesystem = "vfat"; });

        scripts: ( { filename = "erase_at_end"; type = "lua"; }, { filename = "display_info"; type = "lua"; });

        bootenv: (
                { name = "vram"; value = "4M"; },
                { name = "addfb"; value = "setenv bootargs ${bootargs} omapfb.vram=1:2M,2:2M,3:2M omapdss.def_disp=lcd"; }
        );
}
```]

===  Updater: RAUC

- Robust Auto-Update Controller

- Also open source

- #link("https://rauc.io/")[website] –
  #link("https://github.com/rauc/rauc")[code] –
  #link("https://rauc.readthedocs.io/en/latest/")[doc]

- Integrated in Buildroot and Yocto

- Written in python

- Uses a configuration and `manifest` in INI format

- Updates are handled in the form of `bundles`

===  RAUC: configuration

```sh
[system]
compatible=rauc-demo-x86
bootloader=grub 
mountprefix=/mnt/rauc 
bundle-formats=-plain

[keyring]
path=demo.cert.pem

[slot.rootfs.0]
device=/dev/sda2
type=ext4
bootname=A

[slot.rootfs.1]
device=/dev/sda3
type=ext4
bootname=B
```

===  RAUC: Bundle #link("https://rauc.readthedocs.io/en/latest/reference.html#sec-ref-manifest")[manifest]

- Must be called `manifest.raucm`

```sh
[update]
compatible=Test Platform 
version=2023.11.0

[bundle]
format=verity

[image.rootfs]
filename=system-image.ext4

[image.bootloader]
filename=barebox.img
```

===  Updates backend: #link("https://hawkbit.eclipse.dev")[hawkBit]

- Open Source project from the Eclipse foundation

- Back-end for update rollout

- Can break down shipping updates into groups

- Includes a management interface and visualisation

- Supported by both RAUC and SWUpdate

== Examples
<examples>

===  A/B updates using RAUC + U-Boot

- U-Boot is natively supported by RAUC

- RAUC will use U-Boot's environment to affect boot order

  - `BOOT_ORDER`: Names of all slots, in order of priority

  - `BOOT_<slot_name>_LEFT`: remaining boot attempts for the slot

- The environments variables will be read and set by a boot script

  - RAUC includes an
    #link("https://github.com/rauc/rauc/blob/master/contrib/uboot.sh")[example]
    (see next slide)

- Alternatively, one can configure U-Boot to use the
  #link("https://docs.u-boot.org/en/latest/develop/bootstd/rauc.html")[RAUC bootmeth]

===  A/B updates using RAUC + U-Boot

#text(size: 12pt)[
```sh
test -n "${BOOT_ORDER}" || setenv BOOT_ORDER "A B"
test -n "${BOOT_A_LEFT}" || setenv BOOT_A_LEFT 3
test -n "${BOOT_B_LEFT}" || setenv BOOT_B_LEFT 3

setenv bootargs for BOOT_SLOT in "${BOOT_ORDER}"; do
  if test "x${bootargs}" != "x"; then
    # skip remaining slots
  elif test "x${BOOT_SLOT}" = "xA"; then
    if test 0x${BOOT_A_LEFT} -gt 0; then
      echo "Found valid slot A, ${BOOT_A_LEFT} attempts remaining"
      setexpr BOOT_A_LEFT ${BOOT_A_LEFT} - 1
      setenv load_kernel "nand read ${kernel_loadaddr} ${kernel_a_nandoffset} ${kernel_size}"
      setenv bootargs "${default_bootargs} root=/dev/mmcblk0p1 rauc.slot=A"
    fi
  elif test "x${BOOT_SLOT}" = "xB"; then
    if test 0x${BOOT_B_LEFT} -gt 0; then
      setexpr BOOT_B_LEFT ${BOOT_B_LEFT} - 1
      setenv load_kernel "nand read ${kernel_loadaddr} ${kernel_b_nandoffset} ${kernel_size}"
      setenv bootargs "${default_bootargs} root=/dev/mmcblk0p2 rauc.slot=B"
    fi
  fi done

if test -n "${bootargs}"; then
  saveenv else
  echo "No valid slot found, resetting tries to 3"
  setenv BOOT_A_LEFT 3
  setenv BOOT_B_LEFT 3
  saveenv
  reset fi

run load_kernel bootm ${loadaddr_kernel}
```]

===  A/B updates on RPi 5

- Raspberry Pis have an interesting
  #link("https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#boot-sequence")[boot sequence]

- the boot actually stats on the VideoCore, which is the GPU

- this lets users configure the CPU's bootloader via `.txt` files

  - #link("https://www.raspberrypi.com/documentation/computers/config_txt.html#what-is-config-txt")[`config.txt`]

  - #link("https://www.raspberrypi.com/documentation/computers/config_txt.html#autoboot-txt")[`autoboot.txt`]

- the RPi bootloader already supports A/B updates, via its
  #link("https://www.raspberrypi.com/documentation/computers/config_txt.html#the-tryboot-filter")[`tryboot`]
  feature

- It also supports dynamically changing configuration based on the
  #link("https://www.raspberrypi.com/documentation/computers/config_txt.html#boot_partition-2")[`boot_partition`]

  - This helps making the OTA update slot-agnostic
