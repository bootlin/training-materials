#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== TF-A: Trusted Firmware

===  Concept of FIP

- FIP = _Firmware Image Package_

- Concept specific to TF-A

- _packaging format used by TF-A to package firmware images in a
  single binary_

- Typically used to bundle the BL33, i.e. the U-Boot bootloader that
  will be loaded by TF-A.

- #text(size: 18pt)[#link("https://trustedfirmware-a.readthedocs.io/en/latest/getting_started/tools-build.html")[https://trustedfirmware-a.readthedocs.io/en/latest/getting_started/tools-build.html]]

- #link("https://wiki.st.com/stm32mpu/wiki/How_to_configure_TF-A_FIP")[https://wiki.st.com/stm32mpu/wiki/How_to_configure_TF-A_FIP]

===  Configuring TF-A

- TF-A does not use _Kconfig_ for configuration

- All the configuration is based on variables passed on the `make`
  command line

- Most variables are documented at:
  #link("https://trustedfirmware-a.readthedocs.io/en/latest/getting_started/build-options.html")[https://trustedfirmware-a.readthedocs.io/en/latest/getting_started/build-options.html]

===  Configure TF-A: important variables

- `CROSS_COMPILE`, cross-compiler prefix

- `ARCH`, CPU architecture: `aarch32` or `aarch64`

- `ARM_ARCH_MAJOR`, `7` for ARMv7, `8` for ARMv8

- `PLAT`, SoC family, any directory name in `plat` that contains
  `platform.mk`

- `AARCH32_SP`, the Secure Payload, specific to ARMv7. Either OP-TEE or
  the built-in _SP-MIN_ provided by TF-A

- `DTB_FILE_NAME`, path to the Device Tree describing our board

- `BL33`, path to the second stage bootloader, usually U-Boot, to
  include in the FIP image

- Specific to STM32MP1

  - `BL33_CFG`, path to the U-Boot Device Tree

  - `STM32MP_SDMMC=1`, enable support for SD card/eMMC in TF-A

===  Building TF-A for STM32MP1

```
$ make CROSS_COMPILE=arm-linux- 
        ARM_ARCH_MAJOR=7 
        ARCH=aarch32 
        PLAT=stm32mp1 
        AARCH32_SP=sp_min 
        DTB_FILE_NAME=stm32mp157a-dk1.dtb 
        BL33=/path/to/u-boot/u-boot-nodtb.bin 
        BL33_CFG=/path/to/u-boot/u-boot.dtb 
        STM32MP_SDMMC=1 
        fip all
```
Build results in `build/stm32mp1/release`. Important files:

- `tf-a-stm32mp157a-dk1.stm32`, TF-A itself

- `fip.bin`, the FIP image, containing U-Boot and other elements

===  FIP image contents

fiptool info

```
$ ./tools/fiptool/fiptool info build/stm32mp1/release/fip.bin Secure Payload BL32 (Trusted OS): offset=0x100, size=0x8AEC, cmdline="--tos-fw"
Non-Trusted Firmware BL33: offset=0x8BEC, size=0xECE6C, cmdline="--nt-fw"
FW_CONFIG: offset=0xF5A58, size=0x226, cmdline="--fw-config"
HW_CONFIG: offset=0xF5C7E, size=0x16A98, cmdline="--hw-config"
TOS_FW_CONFIG: offset=0x10C716, size=0x3CF6, cmdline="--tos-fw-config"
```

===  STM32MP1 partition layout

#table(columns: (50%, 50%), stroke: none, [

#align(center, [#image("stm32mp1-tfa.pdf", width: 90%)])

#[ #set text(size: 18pt)

#align(center, "Reminder: boot sequence with TF-A on STM32MP1")

]

],[

#align(center, [#image("/common/sequence-stm32mp1.pdf", width: 90%)])

])

===  AM62x (BeaglePlay) partition layout

#table(columns: (50%, 50%), stroke: none, [

#align(center, [#image("am62x-tfa.pdf", width: 90%)])

#[ #set text(size: 18pt)

#align(center, "Reminder: boot sequence with TF-A on AM62x")

]

],[

#align(center, [#image("../sysdev-bootloaders-sequence/sequence-am62x.pdf", width: 90%)])

])
