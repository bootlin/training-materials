#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

== Introduction

===  Bootloader role

- The bootloader is a piece of code responsible for

  - Basic hardware initialization

  - Loading of an application binary, usually an operating system
    kernel, from flash storage, from the network, or from another type
    of non-volatile storage.

  - Possibly decompression of the application binary

  - Execution of the application

- Besides these basic functions, most bootloaders provide a shell or
  menu

  - Menu to select the operating system to load

  - Shell with commands to load data from storage or network, inspect
    memory, perform hardware testing/diagnostics

- The first piece of code running by the processor that can be modified
  by us developers.

== Booting on x86 platforms
<booting-on-x86-platforms>

===  Legacy BIOS booting (1)

- x86 platforms shipped before 2005-2006 include a firmware called
  _BIOS_

  - BIOS = Basic Input Output System

  - Part of the hardware platform, closed-source, rarely modifiable

  - Implements the booting process

  - Provides runtime services that can be invoked - not commonly used

  - Stored in some flash memory, outside of regular user-accessible
    storage devices

- To be bootable, the first sector of a storage device is "special"

  - MBR = Master Boot Record

  - Contains the partition table

  - Contains up to 446 bytes of bootloader code, loaded into RAM and
    executed

  - The BIOS is responsible for the RAM initialization

- #link("https://en.wikipedia.org/wiki/BIOS")

===  Legacy BIOS booting (2)

- Due to the limitation in size of the bootloader, bootloaders are split
  into two stages

  - Stage 1, which fits within the 446 bytes constraint

  - Stage 2, which is loaded by stage 1, and can therefore be bigger

- Stage 2 is typically stored outside of any filesystem, at a fixed
  offset → simpler to load by stage 1

- Stage 2 generally has filesystem support, so it can load the kernel
  image from a filesystem

===  Legacy BIOS booting: sequence and storage

#align(center, [#image("legacy-bios-sequence.pdf", width: 70%)])

#align(center, [#image("legacy-bios-storage.pdf", width: 90%)])

===  UEFI booting

- Starting from 2005-2006, UEFI is the new firmware interface on x86
  platforms

  - Unified Extensible Firmware Interface

  - Describes the interface between the operating system and the
    firmware

  - Firmware in charge of booting

  - Firmware also provides runtime services to the operating system

  - Stored in some flash memory, outside of regular user-accessible
    storage devices

- Loads EFI binaries from the _EFI System Partition_

  - Generally a bootloader

  - Can also be directly the Linux kernel, with an _EFI Boot Stub_

- Special partition, formatted with the _FAT_ filesystem

  - MBR: identified by type `0xEF`

  - GPT: identified with a specific _globally unique identifier_

- File `/efi/boot/bootx32.efi`, `/efi/boot/bootx64.efi`

- #link("https://en.wikipedia.org/wiki/UEFI")

===  UEFI booting: sequence and storage

#align(center, [#image("uefi-sequence.pdf", width: 50%)])
#align(center, [#image("uefi-storage.pdf", width: 70%)])

===  ACPI

- Advanced Configuration and Power Interface

- _Open standard that operating systems can use to discover and
  configure computer hardware components, to perform power management,
  to perform auto configuration, and to perform status monitoring_

- _Tables_ with descriptions of the hardware that cannot be
  dynamically discovered at runtime

- Tables provided by the firmware (UEFI or legacy) and used by the
  operating system (Linux kernel in our case)

- #link("https://en.wikipedia.org/wiki/Advanced_Configuration_and_Power_Interface")[https://en.wikipedia.org/wiki/Advanced_Configuration_and_Power_Interface]

===  UEFI and ACPI on ARM

- Historically UEFI and ACPI are technologies coming from the Intel/x86
  world

- ARM is also pushing for the adoption of UEFI and ACPI as part of its
  _ARM System Ready_ certification

  - Mainly for servers/workstations SoCs

  - Does not impact embedded SoCs

  - Currently not common in embedded Linux projects on ARM

  - #link("https://www.arm.com/architecture/system-architectures/systemready-certification-program")

- Also some on-going effort to use UEFI on RISC-V, but not the de-facto
  standard

- When an embedded platform uses UEFI → its booting process is
  similar to an _x86_ platform

== Booting on embedded platforms
<booting-on-embedded-platforms>

===  Booting on embedded platforms: ROM code

- Most embedded processors include a *ROM code* that implements
  the initial step of the boot process

- The ROM code is written by the processor vendor and directly built
  into the processor

  - Cannot be changed or updated

  - Its behavior is described in the processor datasheet

- Responsible for finding a suitable bootloader, loading it and running
  it

  - From NAND/NOR flash, from USB, from SD card, from eMMC, etc.

  - Well defined location/format

- _Generally_ runs with the external RAM not initialized, so it can
  only load the bootloader into an internal SRAM

  - Limited size of the bootloader, due to the size of the SRAM

  - Forces the boot process to be split in two steps: first stage
    bootloader (small, runs from SRAM, initializes external DRAM),
    second stage bootloader (larger, runs from external DRAM)

===  Booting on STM32MP1: datasheet

#table(columns: (50%, 50%), stroke: none, gutter:9pt, [

#align(center, [#image("stm32mp1-rom-code.png", height: 85%)])

],[

#[ #set text(size: 15pt)
Source:
#link("https://www.st.com/resource/en/application_note/dm00389996-getting-started-with-stm32mp151-stm32mp153-and-stm32mp157-line-hardware-development-stmicroelectronics.pdf")[https://www.st.com/resource/en/application_note/dm00389996-getting-started-with-stm32mp151-stm32mp153-and-stm32mp157-line-hardware-development-stmicroelectronics.pdf] \
Useful details: \ 
#link("https://wiki.st.com/stm32mpu/wiki/STM32_MPU_ROM_code_overview")[https://wiki.st.com/stm32mpu/wiki/STM32_MPU_ROM_code_overview]

]])

===  Booting on AM335x (32 bit BeagleBone): datasheet

#table(columns: (50%, 50%), stroke: none, [

#align(center, [#image("am335x-rom-code.png", height: 90%)]) 

],[

#[ #set text(size: 15pt)

Source: #link("https://www.mouser.com/pdfdocs/spruh73h.pdf"), chapter 26]

])

===  Two stage booting sequence

#align(center, [#image("two-step-boot-process.pdf", height: 90%)])

===  ROM code recovery mechanism

#table(columns: (58%, 42%), stroke: none, gutter:15pt, [

  #[
    #set text(size: 17.5pt)

- Most ROM code also provide some sort of _recovery_ mechanism,
  allowing to flash a board with no bootloader or a broken one, usually
  with a vendor-specific protocol over UART or USB.

- Often allows to push a new bootloader into RAM, making it possible to
  reflash the bootloader.

- Vendor-specific tools to run on the workstation

  - STM32MP1:
    #link("https://www.st.com/en/development-tools/stm32cubeprog.html")[STM32 Cube Programmer]

  - NXP i.MX: #link("https://github.com/NXPmicro/mfgtools")[uuu]

  - Microchip AT91/SAM:
    #link("https://www.microchip.com/en-us/development-tool/SAM-BA-In-system-Programmer")[SAM-BA]

  - Allwinner:
    #link("https://github.com/linux-sunxi/sunxi-tools")[sunxi-fel]

  - Some open-source, some proprietary

- Snagboot: new vendor agnostic tool replacing the above ones:
  #link("https://github.com/bootlin/snagboot")

]

],[

#align(center, [#image("stm32mp1-rom-code-recovery.pdf", width: 100%)])])

== Bootloaders
<bootloaders>

===  GRUB

#table(columns: (60%, 40%), stroke: none, gutter: 15pt, [

- _Grand Unified Bootloader_, from the GNU project

- De-facto standard in most Linux distributions for x86 platforms

- Supports x86 legacy and UEFI systems

- Can read many filesystem formats to load the kernel image, modules and
  configuration

- Provides a menu and powerful shell with various commands

- Can load kernel images over the network

- Also supports ARM, ARM64, RISC-V, PowerPC, but less popular than other
  bootloaders on those platforms

- #link("https://www.gnu.org/software/grub/")

- #link("https://en.wikipedia.org/wiki/GNU_GRUB")[https://en.wikipedia.org/wiki/GNU_GRUB]

],[

#align(center, [#image("grub2.png", width: 100%)])

])

===  Syslinux

#table(columns: (80%, 20%), stroke: none, [

- For network and removable media booting (USB key, SD card, CD-ROM)

- `syslinux`: booting from FAT filesystem

- `pxelinux`: booting from the network

- `isolinux`: booting from CD-ROM

- `extlinux`: booting from numerous filesystem types

- A bit rustic to build and configure, not very actively maintained, but
  still useful for specific use-cases

- #link("https://wiki.syslinux.org/")

- #link("https://kernel.org/pub/linux/utils/boot/syslinux/")

],[

#align(center, [#image("syslinux.png", width: 100%)])

])

===  systemd-boot

#table(columns: (70%, 30%), stroke: none, [

- Simple UEFI boot manager

- Useful alternative to GRUB for UEFI systems: simpler than GRUB

- Configured using files stored in the _EFI System Partition_

- Part of the _systemd_ project, even though obviously distinct
  from _systemd_ itself

  - See our slides later in this course for more details on
    _systemd_

- #link("https://www.freedesktop.org/wiki/Software/systemd/systemd-boot/")

],[

#align(center, [#image("systemd-boot.png", width: 100%)])

])

===  shim

- Minimal UEFI bootloader

- Mainly used in secure boot scenario: it is signed by Microsoft and
  therefore successfully verified by UEFI firmware in the field

- Allows to chainload another bootloader (GRUB) or directly the Linux
  kernel, with signature checking

- #link("https://github.com/rhboot/shim")

===  U-Boot

#table(columns: (60%, 40%), stroke: none, [

- The de-facto standard and most widely used bootloader on embedded
  architectures: ARM, ARM64, RISC-V, PowerPC, MIPS, and more.

- Also supports x86 with UEFI firmware.

- Very likely the one provided by your SoC vendor, SoM vendor or board
  vendor for your hardware.

- We will study it in detail in the next section, and use it in all
  practical labs of this course.

- #link("https://www.denx.de/wiki/U-Boot")

],[

#align(center, [#image("u-boot.png", width: 60%)])

])

===  Barebox

#table(columns: (73%, 27%), stroke: none, [

#[

  #set text(size: 20pt)

- Another bootloader for most embedded CPU architectures: ARM/ARM64,
  MIPS, PowerPC, RISC-V, x86, etc.

- Initially developed as an alternative to U-Boot to address some U-Boot
  shortcomings

  - _kconfig_ for the configuration like the Linux kernel

  - well-defined _device model_ internally

  - More Linux-style shell interface

  - Cleaner code base

- Actively maintained and developed, but

  - Less widely used than U-Boot

  - Less platform support than in U-Boot

- #link("https://www.barebox.org/")

- Talk _barebox Bells and Whistles_, by Ahmad Fatoum, ELCE 2020,
  #link("https://youtu.be/Oj7lKbFtyM0")[video] and
  #link("https://elinux.org/images/9/9d/Barebox-bells-n-whistles.pdf")[slides]

]

],[

#align(center, [#image("barebox.png", width: 100%)])

])

== Trusted firmware
<trusted-firmware>

===  Concept

- Traditionally, bootloaders are only used during the booting process

  - Bootloader loads operating system, jumps to it, and is discarded

- Modern SoCs have advanced security mechanisms that require running
  some sort of _trusted firmware_

- This firmware is loaded by the bootloader, or part of the boot chain
  itself

- This _trusted firmware_ *stays resident* after control has
  been passed to the OS

  - It is stored in a dedicated portion of the DDR, or some specific
    SRAM, inaccessible from the OS

  - It provides services to the OS, which the OS cannot perform directly

  - Can also be responsible for running a secure OS alongside the
    regular OS (Linux in our case)

===  ARM

- Modern ARMv7 and ARMv8 processors have

  - 4 privilege levels (_Exception Levels_)

    - EL3, the most privileged, runs secure firmware

    - EL2, typically used by hypervisors, for virtualization

    - EL1, used to run the Linux kernel

    - EL0, used to run Linux user-space applications

  - 2 _worlds_

    - Normal world, used to run a general purpose OS, like Linux

    - Secure world, to run a separate, isolated, secure operating system
      and applications. Also called _TrustZone_ by ARM.

- EL3 only exists in the secure world

- EL2 exists in both secure and normal worlds since ARMv8.4, before that
  EL2 was only in the normal world

- EL1 and EL0 exist in both secure and normal worlds

===  ARM exception levels and worlds

#align(center, [#image("arm-exception-levels.png", height: 75%)])

#[ #set text(size: 16pt)

#align(center, "Source:"+[
#link("https://developer.arm.com/documentation/102412/0102/Execution-and-Security-states")[ARM documentation]])

]

===  Interfaces with secure firmware

#table(columns: (80%, 20%), stroke: none, [

- Standardized by ARM

- Services

  - implemented by the secure firmware

  - called by the operating system

- Prevents the operating system running in normal world from directly
  accessing critical hardware resources

- #link("https://developer.arm.com/documentation/den0022/fb/?lang=en")[PSCI],
  Power State Coordination Interface

  - Power management related: turn CPUs on/off, CPU idle state, platform
    shutdown/reset

- #link("https://developer.arm.com/documentation/den0056/latest")[SCMI],
  System Control and Management Interface

  - Power domain, clocks, sensor, performance

- Secure firmware implementing these interfaces is

  - Mandatory to run Linux on ARMv8

  - Mandatory to run Linux on some ARMv7 platforms, but not all

],[

#align(center, [#image("arm-interfaces.pdf", width: 100%)])

])

===  TF-A

- _Trusted Firmware-A (TF-A) provides a reference implementation of
  secure world software for Armv7-A and Armv8-A, including a Secure
  Monitor executing at Exception Level 3 (EL3)_

- Formerly known as _ATF_, for ARM Trusted Firmware

- Implements the various standard interfaces that operating systems need
  from the secure firmware

- Has drivers for the hardware blocks that are not accessed directly by
  Linux

- Needs to be ported for each SoC

- Depending on the platform, may also need to be ported per board: DDR
  initialization

- Used on the vast majority of ARMv8 platforms, and on a few recent
  ARMv7 platforms

- #link("https://www.trustedfirmware.org/projects/tf-a/")

===  Trusted OS, OP-TEE

- A trusted operating system can run in the _secure world_, also
  called _Trusted Execution Environment_ or _TEE_

- Hardware partitioning between _secure world_ and _normal
  world_

  - Some hardware resources only available in the _secure world_,
    by the trusted OS

- Allows to run trusted applications/services

  - isolated from Linux

  - can provide services to Linux applications

- Most common open-source implementation: _OP-TEE_

  - Supported by most silicon vendors

  - #link("https://www.op-tee.org/")

===  ARM: summary

#align(center, [#image("arm-nomenclature.pdf", height: 70%)])

#[

  #set text(size: 16pt)

Largely inspired from _Ahmad Fatoum_ presentation _From Reset
Vector to Kernel_,
#link("https://archive.fosdem.org/2021/schedule/event/from_reset_vector_to_kernel/attachments/slides/4632/export/events/attachments/from_reset_vector_to_kernel/slides/4632/from_reset_vector_to_kernel.pdf")[slides],
#link("https://www.youtube.com/watch?v=-Ak9MWGxd7M")[video] 
See also
#link("https://trustedfirmware-a.readthedocs.io/en/latest/design/firmware-design.html")[details about the ARM terms: BL1, BL2...]

]

===  RISC-V

#table(columns: (70%, 30%), stroke: none, [

- Linux-class RISC-V processors have several privilege levels

  - M-mode: machine mode

  - S-mode: level at which the Linux kernel runs

  - U-mode: level at which Linux user-space applications run

- Some specific HW resources are not accessible in S-mode

- A more privileged firmware runs in M-mode

- RISC-V has defined SBI, _Supervisor Binary Interface_

  - Standardized interface between the OS and the firmware

  - #link("https://github.com/riscv-non-isa/riscv-sbi-doc")

- OpenSBI is a reference, open-source implementation of SBI

  - #link("https://github.com/riscv-software-src/opensbi")

],[

#align(center, [#image("riscv-boot.pdf", width: 80%)])

])

== Example boot sequences on ARM
<example-boot-sequences-on-arm>

===  TI AM335x (32 bit BeagleBone): ARMv7

#align(center, [#image("sequence-am335x.pdf", width: 80%)])

===  NXP i.MX6: ARMv7

#align(center, [#image("sequence-imx.pdf", height: 70%)])

#[ #set text(size: 16pt)

Note: this diagram shows one possible boot flow on NXP i.MX6, but it is
also possible to use the U-Boot SPL → U-Boot boot flow on i.MX6.

]

===  STM32MP1: ARMv7

#align(center, [#image("/common/sequence-stm32mp1.pdf", width: 80%)])

#[ #set text(size: 18pt)

#align(center, "Note: booting with U-Boot SPL and U-Boot is also possible.")

]

===  Allwinner ARMv8 cores

#align(center, [#image("sequence-allwinner-64-bit.pdf", height: 80%)])

===  TI AM62x (BeaglePlay): ARMv7 and ARMv8 cores

#align(center, [#image("sequence-am62x.pdf", height: 80%)])

#[ #set text(size: 16pt)

#align(center, "See "+[#link("https://u-boot.readthedocs.io/en/latest/board/ti/am62x_sk.html")[https://u-boot.readthedocs.io/en/latest/board/ti/am62x_sk.html]] + "for details.")

]
