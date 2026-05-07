#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= The Yocto Project SDK

===  Overview

- An SDK (Software Development Kit) is a set of tools allowing the
  development of applications for a given target (operating system,
  platform, environment, …).

- It generally provides a set of tools including:

  - Compilers or cross-compilers.

  - Linkers.

  - Library headers.

  - Debuggers.

  - Custom utilities.

===  The Yocto Project SDK

- The Poky reference system is used to generate images, by building many
  applications and doing a lot of configuration work.

  - When developing an application, we only care about the application
    itself.

  - We want to be able to develop, test and debug easily.

- The Yocto Project SDK is an application development SDK, which can be
  generated to provide a full environment compatible with the target.

- It includes a toolchain, libraries headers and all the needed tools.

- This SDK can be installed on any computer and is self-contained. The
  presence of Poky is not required for the SDK to fully work.

===  Available SDKs

- Two different SDKs can be generated:

  - A generic SDK, including:

    - A toolchain.

    - Common tools.

    - A collection of basic libraries.

  - An image-based SDK, including:

    - The generic SDK.

    - The sysroot matching the target root filesystem.

- The toolchain in the SDKs is self-contained (linked to an SDK embedded
  libc).

- The SDKs generated with Poky are distributed in the form of a shell
  script.

- Executing this script extracts the tools and sets up the environment.

===  The generic SDK

- Mainly used for low-level development, where only the toolchain is
  needed:

  - Bootloader development.

  - Kernel development.

- The recipe `meta-toolchain` generates this SDK:

  - `bitbake meta-toolchain`

- The generated script, containing all the tools for this SDK, is in:

  - `$BUILDDIR/tmp/deploy/sdk`

  - Example: \
    `poky-glibc-x86_64-meta-toolchain-cortexa8hf-neon-toolchain-5.0.sh`

- The SDK will be configured to be compatible with the specified
  #yoctovar("MACHINE").

===  The image-based SDK

- Used to develop applications running on the target.

- One task is dedicated to the process. The task behavior can vary
  between the images.

  - `populate_sdk`

- To generate an SDK for `core-image-minimal`:

  - `bitbake -c populate_sdk core-image-minimal`

- The generated script, containing all the tools for this SDK, is in:

  - `$BUILDDIR/tmp/deploy/sdk`

  - Example:
    `poky-glibc-x86_64-core-image-minimal-cortexa8hf-neon-toolchain-5.0.sh`

- The SDK will be configured to be compatible with the specified
  #yoctovar("MACHINE").

===  Adding packages to the SDK

- Two variables control what will be installed in the SDK:

  - #yoctovar("TOOLCHAIN_TARGET_TASK"): List of target packages to
    be included in the SDK

  - #yoctovar("TOOLCHAIN_HOST_TASK"): List of host packages to be
    included in the SDK

- Both can be appended to install more tools or libraries useful for
  development.

- Example: to have native `curl` on the SDK:

#v(0.5em)

#text(size: 17pt)[
```bash
TOOLCHAIN_HOST_TASK:append = " nativesdk-curl"
```]

===  SDK format

- Both SDKs are distributed as shell scripts.

- These scripts self extract themselves to install the toolchains and
  the files they provide.

- To install an SDK, retrieve the generated script and execute it.

  - The script asks where to install the SDK. Defaults to
    `/opt/poky/<version>`

  - Example: `/opt/poky/5.0`

#v(0.5em)

#[ #show raw.where(lang: "console", block: true): set text(size: 14.5pt)
```console
    $ ./poky-glibc-x86_64-meta-toolchain-cortexa8hf-neon-toolchain-5.0.sh 
    Poky (Yocto Project Reference Distro) SDK installer version 5.0
    ===============================================================
    Enter target directory for SDK (default: /opt/poky/5.0):
    You are about to install the SDK to "/opt/poky/5.0". Proceed[Y/n]?
    Extracting SDK.................done 
    Setting it up...done 
    SDK has been successfully set up and is ready to be used.
    Each time you wish to use the SDK in a new shell session, you need to source 
    the environment setup script e.g.
     $ . /opt/poky/5.0/environment-setup-cortexa8hf-neon-poky-linux-gnueabi
```]

===  Use the SDK

- To use the SDK, a script is available to set up the environment:
#[ #show raw.where(lang: "console", block: true): set text(size: 14.5pt)
```console
  $ cd /opt/poky/5.0
  $ source ./environment-setup-cortexa8hf-neon-poky-linux-gnueabi
```]

- The `PATH` is updated to take into account the binaries installed
  alongside the SDK.

- Environment variables are exported to help using the tools.

===  SDK installation

/ environment-setup-cortexa8hf-neon-poky-linux-gnueabi: #block[
Exports environment variables.
]

/ site-config-cortexa8hf-neon-poky-linux-gnueabi: #block[
Variables used during the toolchain creation
]

/ sysroots: #block[
SDK binaries, headers and libraries. Contains one directory for the host
and one for the target.
]

/ version-cortexa8hf-neon-poky-linux-gnueabi: #block[
Version information.
]

===  SDK environment variables

- #yoctovar("CC"): Full path to the C compiler binary.

- #yoctovar("CFLAGS"): C flags, used by the C compiler.

- #yoctovar("CXX"): C++ compiler.

- #yoctovar("CXXFLAGS"): C++ flags, used by `CPP`

- #yoctovar("LD"): Linker.

- #yoctovar("LDFLAGS"): Link flags, used by the linker.

- #yoctovar("ARCH"): For kernel compilation.

- #yoctovar("CROSS_COMPILE"): For kernel compilation.

- #yoctovar("GDB"): SDK GNU Debugger.

- #yoctovar("OBJDUMP"): SDK objdump.

#v(0.5em)

To see the full list, open the environment script.

===  Examples

- To build an application for the target:

#v(0.5em)

#[ #show raw.where(lang: "console", block: true): set text(size: 18pt)
  ```console
  $ $CC -o example example.c
  ```]

#v(0.5em)

- The #yoctovar("LDFLAGS") variable is set to be used with the C
  compiler (`gcc`).
