#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Secure Boot - Later stages

== U-Boot components
<u-boot-components>

=== Early boot

- The system (most likely) has 2 type of RAM:

  - A small on-chip RAM (640 KB for i.MX93, 200KB for RK3399)

  - One or several big (GiB) *external* memory ((LP)DDR) bank(s)

- The on-chip RAM is *static* and requires little initialization,
  which can be done by the BootROM.

- The *external* RAM is *dynamic*, it and its controller
  needs to be initialized

- At startup, we must start running from the on-chip RAM, so at least
  the *external* RAM init logic must have a small memory
  footprint.

- The same goes for using NAND flash as a boot medium.

- Modern bootloaders have a lot of features, and therefore are too big.
  Our i.MX93 U-Boot is 850 kiB

- We need to split up the boot: a small loader will initialize the
  *external* RAM, and load the main bootloader there

=== Secondary Program Loader (SPL)

- Usually started by the bootROM, also at EL3

- In ARM terms, this is *BL2*

- Runs either from SRAM or directly from flash

- Initializes DRAM and DRAM controller, usually using firmware

- Loads the *proper* bootloader

- Can be stripped down to save space

- On TrustZone systems, actually loads TF-A, as well, which returns to
  U-Boot

- Some SoCs (e.g. Rockchip) split DRAM initialization into another
  loader, the TPL.

=== Boot sequence refresher

#image("/common/armv8-boot-sequence-common-names.pdf", width: 60%)

=== The "proper" bootloader

- On TrustZone platforms, started by TF-A, running at NS-EL2

- In ARM terms, this is *BL32*

- Runs from *external* DRAM

- More complex, has support for more peripherals and filesystems

- Goal is to load and start the kernel with proper boot arguments

- In case of secure boot, verifies the kernel's signature

== (Das) U-Boot
<das-u-boot>

=== #link("https://u-boot.org/")[U-Boot]

- U-Boot is the de-facto default embedded systems bootloader

- Has extensive SoC and boards support

- Supports building a
  #link("https://elixir.bootlin.com/u-boot/v2026.01/A/ident/CONFIG_TPL")[TPL]
  and
  #link("https://elixir.bootlin.com/u-boot/v2026.01/A/ident/CONFIG_SPL")[SPL]

=== U-Boot image formats

- U-Boot needs to load several components:

  - the kernel

  - on ARM, the Device Tree Blob (DTB)

  - on ARM, SPL needs to load TF-A

  - on ARM, optionally OP-TEE

  - optionally, an external ramdisk

- We could install all those components separately, and have U-Boot load
  each

- Having one or two images bundling all components would be more
  practical

- This is the role of U-Boot's
  #link("https://elixir.bootlin.com/u-boot/v2026.01/source/tools/mkimage.c")[mkimage]

=== U-boot image formats

- U-boot and mkimage support various
  #link("https://elixir.bootlin.com/u-boot/v2026.01/source/boot/image.c#L141")[image formats]

- Some are SoC vendor-specific

- U-Boot can only boot 3:

  - #link("https://elixir.bootlin.com/u-boot/v2026.01/C/ident/IMAGE_FORMAT_LEGACY")[legacy image],
    which is concatenated files with a simple
    #link("https://elixir.bootlin.com/u-boot/v2026.01/source/include/image.h#L324")[header]

  - #link("https://elixir.bootlin.com/u-boot/v2026.01/C/ident/IMAGE_FORMAT_FIT")[FIT (Flattened Image Tree)]

  - #link("https://elixir.bootlin.com/u-boot/v2026.01/C/ident/IMAGE_FORMAT_ANDROID")[Android boot image],
    which uses this
    #link("https://source.android.com/docs/core/architecture/bootloader/boot-image-header")[header]

- FIT is the current format for non-Android devices

=== Flattened Image Tree (FIT)

- The FIT image #link("https://fitspec.osfw.foundation/")[specification]
  was split off of U-Boot

- FIT images are Flattened Device Trees/
  #link("https://devicetree-specification.readthedocs.io/en/stable/flattened-format.html")[Device Tree Blobs]
  that respect additional constraints.

- They are essentially containers for
  sub-#link("https://fitspec.osfw.foundation/#align(center, [#images-node")[images]

- Each of these images can include a
  #link("https://fitspec.osfw.foundation/#align(center, [#image-signature-nodes")[signature]

- The FIT image can also list
  #link("https://fitspec.osfw.foundation/#configuration-nodes")[configurations],
  which list combinations of the images that can be used.

- Configurations can be
  #link("https://fitspec.osfw.foundation/#configuration-signature-nodes")[signed].
  The `sign-images` property will list the images to include in the
  signature.

- Support must be enabled via #projconfig("u-boot","CONFIG_FIT")

=== FIT generation

- U-Boot uses #projdir("u-boot", "tools/binman") to generate images

- This relies on a "configuration file" in the form of a DTS

  - that file is named `<pattern>-u-boot.dtsi`

  - the file should be in `arch/<arch>/boot/dts`

  - as documented in #projfile("u-boot",
    "tools/binman/binman.rst"), binman will look for the following
    files, in order:

    - `<dts>-u-boot.dtsi` where <dts> is the base name of the .dts
      file

    - `<`#projconfig("u-boot","CONFIG_SYS_SOC")`>“-u-boot.dtsi`

    - `<`#projconfig("u-boot","CONFIG_SYS_CPU")`>“-u-boot.dtsi`

    - `<`#projconfig("u-boot","CONFIG_SYS_VENDOR")`>“-u-boot.dtsi`

    - `u-boot.dtsi`

=== Example: #projfile("u-boot", "arch/arm/dts/imx93-u-boot.dtsi")
<example-projfileu-boot-archarmdtsimx93-u-boot.dtsi>

#[ #show raw.where(lang: "c", block: true): set text(size: 9pt)
```c
/ { binman: binman { multiple-images; }; };
...
&binman {
        u-boot-spl-ddr {
                align = <4>;
                align-size = <4>;
                filename = "u-boot-spl-ddr.bin";
                pad-byte = <0xff>;
                u-boot-spl     { filename = "u-boot-spl.bin"; align-end = <4>; };
                ddr-1d-imem-fw { filename = "lpddr4_imem_1d_v202201.bin"; align-end = <4>; type = "blob-ext"; };
                ...
                ddr-2d-dmem-fw { filename = "lpddr4_dmem_2d_v202201.bin"; align-end = <4>; type = "blob-ext"; };
        };

        spl { filename = "spl.bin";
              mkimage { args = "-n spl/u-boot-spl.cfgout -T imx8image -e 0x2049A000"; blob { filename = "u-boot-spl-ddr.bin"; }; };
        };

        u-boot-container {
                filename = "u-boot-container.bin";
                mkimage { args = "-n u-boot-container.cfgout -T imx8image -e 0x0"; blob { filename = "u-boot.bin"; }; };
        };

        imx-boot {
                filename = "flash.bin";
                pad-byte = <0x00>;
                spl: blob-ext@1 { filename = "spl.bin"; offset = <0x0>; align-size = <0x400>; align = <0x400>; };
                uboot: blob-ext@2 { filename = "u-boot-container.bin"; };
        };
};
```]

=== Configuring FIT verification
<configuring-fit-verification>

- The feature is documented in #projfile("u-boot",
  "doc/usage/fit/signature.rst")

- #projconfig("u-boot","CONFIG_FIT_SIGNATURE") must be set

  - this will disable
    #projconfig("u-boot","CONFIG_LEGACY_IMAGE_FORMAT"), as this
    format cannot be signed

  - it is not enough for signatures to be *required*

- The signing key itself will need to be loaded using a `.dtsi` file

  - This file can be generated using #projfile("u-boot", "tools/key2dtsi.py") \ `tools/key2dtsi.py --required-image fit_signing_key.pub fit_signing_key.dtsi`

- You can then either

  - `#include` your `fit_signing_key.dtsi` from your main device tree

  - Use #projconfig("u-boot","CONFIG_DEVICE_TREE_INCLUDES") to
    do it for you

=== fit_signing_key.dtsi
<fit_signing_key.dtsi>

#[ #show raw.where(lang: "c", block: true): set text(size: 15pt)
```c
      / {
        signature {
            key-fit_signing_key {
                key-name-hint = "fit_signing_key";
                algo = "sha256,rsa4096";
                rsa,num-bits = <4096>;
                rsa,modulus = [bd 32 f6 a6 5d f7 9a ed 
[...]
                               7c 0b 2f 8e 8f d0 4d 95];
                rsa,exponent = [00 00 00 00 00 01 00 01];
                rsa,r-squared = [bc 5b f8 07 15 a2 36 92 
[...]
                                 49 1f da e8 b9 74 07 3a];
               rsa,n0-inverse = <0x7bec6a43>;
               required = "image";
            };
        };
    };
```]

=== Configuring FIT signing
<configuring-fit-signing>

- Now that U-Boot is configured to verify FIT signature we need to:

  - pack the kernel and DTB into a FIT

  - sign the FIT image

- Both can be done by
  #link("https://elixir.bootlin.com/u-boot/v2026.01/source/tools/mkimage.c")[mkimage] \
  `tools/mkimage -k keys_dir -f kernel_fit.its kernel_fit.itb -r`

- The `-r` option marks the key as required.

=== fit.its
<fit.its>

#[ #show raw.where(lang: "c", block: true): set text(size: 9pt)
```c
/dts-v1/;
/ {
        description = "Image for Linux Kernel";
        images {
                kernel {
                        description = "Linux Kernel";
                        data = /incbin/("Image.gz");
                        ...
                        compression = "gzip";
                        load =  <0xDEADBEEF>;
                        entry = <0xDEADBEEF>;
                        hash-1 { algo = "sha256";};
                };
                fdt {
                        description = "fdt";
                        data = /incbin/("platform.dtb");
                        ...
                };
        };
        configurations {
                default = "config-1";
                config-1 {
                        description = "Linux configuration";
                        kernel = "kernel";
                        fdt = "fdt";
                        signature-1 {
                                algo = "sha256,rsa2048";
                                key-name-hint = "fit_signing_key";
                                sign-images = "fdt", "kernel";
                        };

                };
        };
};
```]

== Last stage: rootFS verification
<last-stage-rootfs-verification>

=== Root filesystem verification

- We have verified software up to the kernel, what about userland?

- We want to check the integrity of the root filesystem

  - The system cannot modify the root filesystem, so it might as well be
    mounted read-only.

  - We need a hash of the rootFS but a rootFS is usually several orders
    of magnitude larger than the kernel.

- The hash will be the linchpin of the verification scheme, so it needs
  to be signed

  - We cannot put the signing key onto the system, so the signature must
    be generated off the system

- The kernel must verify the rootFS *before* it loads anything
  from it, so this will introduce a significant delay in the boot
  process.

=== The device mapper (dm)

- The device mapper will wrap a block device and create a new block
  device

- It defines several types of wrapped devices, called "targets". they
  include:

  - dm-crypt: #kdochtml("admin-guide/device-mapper/dm-crypt")

  - dm-integrity: #kdochtml("admin-guide/device-mapper/dm-integrity")

  - dm-verity: #kdochtml("admin-guide/device-mapper/dm-verity")

  among others

- These targets can be stacked on top of each other

=== dm-verity

- Read-only target of the device-mapper

- Needs the #kconfig("CONFIG_DM_VERITY") option enabled

- Splits the block device into *blocks*

- Each block then gets hashed to give the leaves of a hash tree

- The rest of the tree is built iteratively by aggregating hashes into
  blocks of the data block size, and hashing them.

- After `math.ceil(math.log(num_blocks, block_size/hash_size))`
  iterations, we are left with one single hash: the *root hash*

- The tree can have maximum #ksym("DM_VERITY_MAX_LEVELS") (63 in
  6.18) levels

=== dm-verity
<dm-verity>

#align(center, [#image("VerityHashing.pdf", width: 70%)])

=== dm-verity: verification

- On `read()`, dm-verity will perform a block I/O. Before completing it,
  it will call #kfunc("verity_verify_io")

- For each block of the I/O, it will

  - Lookup whether the block was already verified in the
    #ksym("validated_blocks") bitfield cache

  - If not, dm-verity will walk the hash tree down from the root, and
    for each level, recalculate the hashes.

  - It will then hash the *actual block data* and compare the
    hash to the hash from the tree that was used in the calculations.

  - The behaviour on error depends on the device configuration, but can
    be set to #ksym("DM_VERITY_MODE_PANIC")

=== dm-verity: setup

- To properly setup the `verity` device, the kernel will need the
  following parameters (described in
  #kdochtml("admin-guide/device-mapper/verity")):
  #[ #set list(spacing: 0.2em)
  - `version`

  - `dev`

  - `hash_dev`

  - `data_block_size`

  - `hash_block_size`

  - `num_data_blocks`

  - `hash_start_block`

  - `algorithm`

  - `digest`

  - `salt`
  ]
- This assumes that the root hash has already been calculated, and the
  hash tree generated.

- These arguments can be passed on the kernel command line

- The value of the root hash is *sensitive*, but not
  *secret*

- Its *integrity* must be protected, not its
  *confidentiality*

=== Storing the root hash

- The parameters can be stored in an on-disk verity header

  - Modifying most parameters will be a functional problem, but not a
    security issue

  - This is clearly not true for the root hash

- The header needs to be signed, or at least the root hash

  - The kernel can do that, using
    #kconfig("CONFIG_DM_VERITY_VERIFY_ROOTHASH_SIG")

  - It will use the kernel's trusted keyring (see
    #kdochtml("security/keys/trusted-encrypted")) via the
    #kfunc("sys_add_key") system call

  - The signature will be verified using:

    - the trusted keyring built into the kernel,

    - the secondary keyring if
      #kconfig("DM_VERITY_VERIFY_ROOTHASH_SIG_SECONDARY_KEYRING")
      is enabled.

    - the platform keyring if
      #kconfig("DM_VERITY_VERIFY_ROOTHASH_SIG_PLATFORM_KEYRING")
      is enabled

=== crypt/veritysetup

- Interacting with the device can be done using cryptesetup's
  #link("https://gitlab.com/cryptsetup/cryptsetup/-/blob/main/src/veritysetup.c")[veritysetup]

  - `veritysetup format`

  - `veritysetup open`

  - `veritysetup close`

- The root hash signature can be passed using the
  `—-root-hash-signature` option

=== Setup using an initramFS

- `veritysetup` is a userland tool, so it needs a userland to run

- We can use an initramFS, see
  #kdochtml("filesystems/ramfs-rootfs-initramfs")

- To avoid breaking our secure boot chain, it must be *signed*

- Fortunately, this is one of the images that can be included in the
  FIT: `FIT_RAMDISK_PROP`

- We can then even store the root hash as a file in the initramFS

- If we use kernel verification, the signature can be passed from a file

=== Setup at kernel init

- The kernel supports boot arguments to create mapped devices:
  `dm-mod.create`

- This must be enabled using #kconfig("CONFIG_DM_INIT")

- The root hash and salt are then going to be passed as boot arguments

- Unfortunately, there is no boot argument to load the signature into
  the keyring, so we can no longer use
  #kconfig("CONFIG_DM_VERITY_VERIFY_ROOTHASH_SIG")

- This means that the kernel command line is now security sensitive, and
  must be signed

  - The FIT spec include a `cmdline` property, but it is not implemented
    in U-Boot

  - We can use a U-Boot 'script` to set the `bootargs' environment
    variable. The script can be added to the FIT image as a script entry
