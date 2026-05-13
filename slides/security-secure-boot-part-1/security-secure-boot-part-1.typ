#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Secure Boot

=== Purpose

- Start from the following premises:

  - the system's software was installed securely

  - the system enters production and might be exposed to threats

  - some of those threats will know how to install software

- The question is: how do I make sure the software has not been altered?

- The system must be able to assess autonomously

=== Concept

- Chain of verification of software

  - the manufacturer's ROM code verifies the first stage bootloader

  - the last stage bootloader (e.g. U-Boot) verifies the OS kernel

  - the kernel, optionally, verifies the userland

- Compute the hash of the next stage binary

- Use the embedded *public* key to retrieve the signed hash

- Compare re-computed hash to extracted hash

- Refuse to hand over control flow if the hashes do not match

=== Initial bootloader verification

#table(columns: (70%, 30%), stroke: none, gutter: 15pt, [

#align(center, [#image("phase1.pdf", width: 90%)])

],[

- The public key's hash is stored in a once-writable memory

- The BootROM uses it to validate the embeded key

- It uses that key to recompute the hash from the signature

])

=== Initial bootloader verification

- Storing the hash instead of the full public key means the storage is
  independent of the signature algorithm. It only depends on the hash
  algorithm.

- The BootROM must be trusted. It cannot be modified, as it is stored in
  a read-only memory.

- The key hash is stored in a memory that can only be written once. This
  is usually done by burning electrical fuses.

- In some implementations, one more fuse must be burned once the
  implementation has been verified to be correct to enable secure boot.

=== Kernel verification

#table(columns: (70%, 30%), stroke: none, gutter: 15pt, [

#align(center, [#image("phase2.pdf", width: 85%)])

],[

- End of the "traditional" secure boot chain

- Verify the kernel before execution

- Must be supported by the bootloader

])

=== Kernel verification

- This stage no longer depends on hardware

- The root of trust for this stage is the combined:

  - last stage bootloader (e.g. U-Boot proper)

  - last stage signature public key

- _Signature_$""^(-1)$

- Both should have been verified in the previous stage

- This ensures that the kernel that has been started is the one that the
  possessor of the last stage private key expects.

=== Kernel verification

- This leaves some unanswered questions:

  - What happens once the kernel starts _init_?

  - What about the DTB?

  - What about the command line parameters?

- We'll answer these in the next part.

=== Examples

- In the x86/PC world:

  - usually implemented via #link("https://uefi.org/")[UEFI].

  - Pushed by Microsoft,
    #link("https://blogs.windows.com/windows-insider/2021/08/27/update-on-windows-11-minimum-system-requirements-and-the-pc-health-check-app/")[Windows 11 makes it a requirement]

- On Android:
  #link("https://source.android.com/docs/security/features/verifiedboot/avb")[Android Verified Boot]
  (AVB) \
  This is why
  "#link("https://source.android.com/docs/security/features/verifiedboot/boot-flow")[bootloader unlocks]"
  are necessary

- In
  #link("https://docs.u-boot.org/en/latest/usage/fit/verified-boot.html")[U-Boot],
  FIT (Flat Image Tree ) images can be signed.

=== Threat Model

- Secure boot is designed to protect against unauthorized modification
  of software. This includes:

  - Offline modification of the software by reflashing the boot medium.
    This could be how an attacker gain access.

  - Runtime rewriting of the software (persistence). This is
    defense-in-depth against an attacker who already has access.

- It is not designed to protect against:

  - Runtime compromise of the system via a vulnerability

- It can be designed to protect against:

  - Leaking of some of the cryptographic material

- Secure boot is a chain, so its security is a consequence of:

  - The security of the root/anchor.

  - The security of each link, guaranteed by the signature scheme.

=== Threat Model: the root

- The root is made of the elements that are initially trusted at boot:

  - The hash(es) of the secure boot public key(s)

  - The bootROM

  - The CPU

  - Optionally, harware implementations of cryptography

- Of these, only the hash(es) are in an integrator's control

- The SoC vendor is very much part of the trusted perimeter.

== Example: UEFI secure boot
<example-uefi-secure-boot>

=== Example: UEFI secure boot

- Secure boot is part of the UEFI spec

- Theoretically support x86-64, ARM32, aarch64, loongarch and RISC-V

- Mostly used on x86

- UEFI uses a mofified version of Microsoft's Portable Executable (PE)
  file format

- Must be authenticated by the CPU first

  - Intel Boot Guard

  - #link("https://www.ioactive.com/exploring-amd-platform-secure-boot/")[AMD Platform Secure Boot]
    (PSB)

== Example: Raspberry Pi secure boot
<example-raspberry-pi-secure-boot>

=== Raspberry Pi Secure boot support

- Since Raspberry Pi4, RPis support secure boot

- Raspberry Pi Ltd has 2 whitepapers on the topic:

  - #link("https://pip.raspberrypi.com/categories/1260-security/documents/RP-004651-WP/Raspberry-Pi-4-Boot-Security.pdf")[Boot security]

  - #link("https://pip-assets.raspberrypi.com/categories/1260-security/documents/RP-003466-WP-3-Boot%20Security%20Howto.pdf?disposition=inline")[Secure Boot]

- The BootROM holds 4 RSA 2048 public keys

- These keys are held by the RPi foundation, the first one is a dev key

- Broadcom's BCM2711 SoC embeds a
  #link("https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#one-time-programmable-settings")[one-time programmable (OTP) memory].
  It holds:

  - revocation status of the ROM keys

  - Configuration (e.g. boot mode)

  - 1 slot for a SHA256 hash of an OEM key

  - 256-bit device unique private key (readable to root in cleartext)

=== RPi: Secure boot process

- The RPi BootROM first:

  - checks the OTP revocation bits

  - Verifies `bootsys`' signature from EEPROM against a non-revoked key

  - starts `bootsys` (if verification succeeded)

- `bootsys` then:

  - verifies the OEM key in EEPROM against the OTP hash

  - verifies `boot.conf` (in EEPROM) against `boot.sig` with the OEM key

  - verifies `bootmain` (in EEPROM) against the embedded hash (which was
    therefore signed with the RPi ROM key)

  - loads and executes `bootmain` if verification succeeded

- `bootmain` then

  - verifies `boot.img` against `boot.sig` (in boot medium) against the
    OEM key

  - loads the `boot.img` and starts `start.elf`

- Finally, `start.elf` loads the kernel from the `boot.img` ramdisk

=== RPi: Secure boot overview
<rpi-secure-boot-overview>

- It is possible to test the `boot.img` signature

```yaml
3.04 OTP boardrev b04170 bootrom a a
3.06 Customer key hash 8251a63a2edee9d8f710d63e9da5d639064929ce15a2238986a189ac6fcd3cee
3.13 VC-JTAG unlocked
3.36 RP1_BOOT chip ID: 0x20001927
3.41 bootconf.sig
3.41 hash: f71ede8fad8bea2f853bcff41173ffedde48c5b76ed46bc38fa057ce46e5d58b
3.47 rsa2048:  3f215305d5aff620219da94f6f1294787e3a407102a507da96c28e9195d3ccb2f144cac66919f9d86ba9f54a8d20ff57c80d6d269e6e49a16dc23553974489947fe05bf3b7df5cd2c5040a9eebadca754ff4be50600b06fd9f565639adc859d88052e15e0ff6eecf7fec0386d41f81e5d009b04520bb83f17663b62b1271b9d27ec2344c73a20d42dfd68facd741d48c0453e8149448537abfed1d4805872c16182a3e9f25c0b86e002e88949d62c148a561aa8137c257ce0d3e0ae5761aa64c225e9c9782b2bb613de7d90499567c56218bb18a239d4347967b68b3ebd06eaa48215f16316d2a697bb2e67cb3883068f6284e2ca71d25ce0099a1ceb37a85c9
3.94 RSA verify
3.10 rsa-verify pass (0x0)
```

- On RPi4 , it is also possible to test the EEPROM signature

- This is no longer possible on RPi5:

  - The EEPROM image must be counter-signed using the OEM key

  - If the OTP has not been flashed, boot will not proceed

== Example: AHAB on NXP i.MX93
<example-ahab-on-nxp-i.mx93>

=== Detailed example: i.MX93

- i.MX SoCs implement a version of secure boot called High Assurance
  Boot (HAB)

- Starting from i.MX8, moved to
  #link("https://github.com/nxp-imx/uboot-imx/blob/lf_v2025.04/doc/imx/ahab/introduction_ahab.txt")[Advanced HAB]
  (AHAB)

- Uses a table of 4 asymmetric keys called Secure Root Keys (SRKs)

- The hash of the SRK table is stored in the SoC's fuses

- AHAB actions can be performed using NXP's
  #link("https://spsdk.readthedocs.io/en/latest/index.html#")[Secure Provisioning SDK (SPSDK)]

=== The EdgeLock (Secure) Enclave (ELE)

- The ELE is the security subsystem on the i.MX9 family

- Replaces the SEcurity COntroller (SECO) of the i.MX8 family

- Also called "Sentinel"

- Based on a dedicated RISC-V core

- Authenticates all firmware loaded at boot

- ELE firmware implements AHAB. Signed using ELE SRKs provided as a
  binary blob by NXP.

=== The EdgeLock (Secure) Enclave (ELE)

- Described in the ELE API Reference Guide (IMX93ELEAPI) (NXP account
  required for download)

- HSM capability, API described in
  #link("https://www.nxp.com/docs/en/reference-manual/RM00284.pdf")[RM00284]

  - Key generation

  - Key storage (no internal NVM, this is important)

  - Encryption/Decryption

  - Signature (and verification)

- Using the ELE to wrap keys for filesystem encryption is possible

- No ELE support for
  #link("https://docs.kernel.org/security/keys/trusted-encrypted.html")[Trusted Keys]

  - LUKS will not be supported, only "naked" cryptsetup

  - An initramfs will most likely be necessary

  - Will require some provisioning to initially wrap the key

- API accessible from userland via a messaging unit

- NXP has a library for this:
  #link("https://github.com/nxp-imx/imx-secure-enclave")[imx-secure-enclave]

=== Detailed example: i.MX93 - AHAB container

- AHAB containers are custom structured binary files

- They can be built using SPSDK's nxpimage

  - Generate a template: `nxpimage ahab get-template`

- They will include one or several binaries

- The `signer` property will indicate how to sign the binaries

=== Detailed example: i.MX93 - AHAB container template
<detailed-example-i.mx93---ahab-container-template>

#text(size: 17pt)[
```yaml
# Description: NXP chip family identifier.
family: mimx9352
# --------------===== MCU revision [Optional] =====--------------------------------
# Description: Revision of silicon. The 'latest' name, means most current revision.
# Possible options: <a0, a1, latest>
revision: a1
# --------------===== Memory type [Required] =====----------------------------------
# Description: Specify type of memory used by bootable image description.
memory_type: serial_downloader 
init_offset: 0
# --------------===== Primary Image Container Set [Optional] =====-------------------
# Container Set that is validated by ROM and usually contains DDR init and SPL.
# It could be used as pre-prepared binary form of AHAB and also YAML configuration
# file for AHAB. In case that YAML configuration file is used, the Bootable image tool
# builds the AHAB itself.
primary_image_container_set: ahab_primary_container.yaml 
secondary_image_container_set: ahab_secondary_container.yaml
```]

=== Detailed example: i.MX93 - AHAB primary container
<detailed-example-i.mx93---ahab-primary-container>

#text(size: 16pt)[
```yaml
family: mimx9352
revision: a1
target_memory: serial_downloader 
output: ahab-primary-container-set.bin 
containers:
  - binary_container:
      path: mx93a1-ahab-container.img   # ELE firmware, provided and signed by NXP
  - container:
      srk_set: oem
      used_srk_id: 0
      signer: Super_Root_Key_1.pem
      images:
        -
          lpddr_imem_1d: lpddr4_imem_1d_v202201.bin     # LPDDR memory FW in 1D mode
          lpddr_imem_2d: lpddr4_imem_2d_v202201.bin     # LPDDR memory FW in 2D mode
          lpddr_dmem_1d: lpddr4_dmem_1d_v202201.bin     # LPDDR memory data in 1D mode
          lpddr_dmem_2d: lpddr4_dmem_2d_v202201.bin     # LPDDR memory data in 2D mode
          spl_ddr: u-boot-spl.bin       # SPL
      srk_table:
        flag_ca: false
        hash_algorithm: default
        srk_array:
          - Super_Root_Key_1.pub    # 4 lines, one for each SRK
```]

=== Detailed example: i.MX93 - AHAB secondary container
<detailed-example-i.mx93---ahab-secondary-container>

#text(size: 15pt)[
```yaml
[...]
containers:
  -
    container:
      srk_set: oem
      used_srk_id: 0
      signer: Super_Root_Key_1.pem
      images:
        - atf: bl31-imx93.bin-optee
        - uboot: u-boot.bin
        - tee: tee.bin
      srk_table:
        flag_ca: false
        hash_algorithm: default
        srk_array:
          - Super_Root_Key_1.pub    # 4 lines, one for each SRK
```]

=== Detailed example: i.MX93 - AHAB
<detailed-example-i.mx93---ahab>

- As mentioned, the hashes of the SRKs must be flashed to the SoC's
  fuses.

- The
  #link("https://github.com/nxp-mcuxpresso/spsdk/blob/master/spsdk/data/devices/mimx9352/fuses.json#L6638")[SPSDK sources]
  show that those fuses are index `0x80` to `0x87`

- On i.MX93, the hash function being used is SHA256, so the hash will be
  spread over 8 32-bit fuses.

- This hash is calculated over all 4 SRKs, they are not fully
  independent

- The fuses will be flashed by the ELE, via the usual message interface

  - U-Boot has an
    #link("https://github.com/nxp-imx/uboot-imx/blob/lf_v2025.04/arch/arm/mach-imx/ele_ahab.c#L874")[ele_message]
    command

- This is a sensitive step, so SPSDK can generate a script to automate
  it

=== #link("https://github.com/nxp-mcuxpresso/spsdk/blob/master/tests/nxpimage/data/ahab/fuses_scripts/mimx9352_ahab_oem0_srk0_hash_nxpele.bcf")[Example]
<example>

#text(size: 13pt)[
```yaml
# nxpele AHAB SRK fuses programming script
# Generated by SPSDK 3.0.0.dev68+g99003d2be
# Family: mimx9352, Revision: latest

# Value: 0xCB2CC774B2DCEC92C840ECA0646B78F8D3661D3A43ED265A490A13ACA75E190A
# Description: SHA256 hash digest of hash of four SRK keys
# Grouped register name: SRKH

# OTP ID: OEM_SRKH7, Value: 0x74C72CCB
write-fuse --index 128 --data 0x74C72CCB
# OTP ID: OEM_SRKH6, Value: 0x92ECDCB2
write-fuse --index 129 --data 0x92ECDCB2
# OTP ID: OEM_SRKH5, Value: 0xA0EC40C8
write-fuse --index 130 --data 0xA0EC40C8
# OTP ID: OEM_SRKH4, Value: 0xF8786B64
write-fuse --index 131 --data 0xF8786B64
# OTP ID: OEM_SRKH3, Value: 0x3A1D66D3
write-fuse --index 132 --data 0x3A1D66D3
# OTP ID: OEM_SRKH2, Value: 0x5A26ED43
write-fuse --index 133 --data 0x5A26ED43
# OTP ID: OEM_SRKH1, Value: 0xAC130A49
write-fuse --index 134 --data 0xAC130A49
# OTP ID: OEM_SRKH0, Value: 0x0A195EA7
write-fuse --index 135 --data 0xA195EA7
```]

=== AHAB status
<ahab-status>

- The signature of an AHAB container is always verified

- Before the fuses are flashed, this will result in the following error:
  #text(size: 12pt)[
  ```yaml
     > ahab_status 
     Lifecycle: 0x00000008, OEM Open

          0x0287fad6
          IPC = MU APD (0x2)
          CMD = ELE_OEM_CNTN_AUTH_REQ (0x87)
          IND = ELE_BAD_KEY_HASH_FAILURE_IND (0xFA)
          STA = ELE_SUCCESS_IND (0xD6)

          0x0287fad6
          IPC = MU APD (0x2)
          CMD = ELE_OEM_CNTN_AUTH_REQ (0x87)
          IND = ELE_BAD_KEY_HASH_FAILURE_IND (0xFA)
          STA = ELE_SUCCESS_IND (0xD6)
  ```]

- Once they are, AHAB should report no events:
  #text(size: 12pt)[
  ```yaml
      > ahab_status 
      Lifecycle: 0x00000008, OEM Open


          No Events Found!
  ```]

- Then the board can be set to `OEM Closed`, and signatures will be
  enforced
