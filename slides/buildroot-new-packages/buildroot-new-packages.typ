#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Integrating new packages in Buildroot

=== Why adding new packages in Buildroot?

- A _package_ in Buildroot-speak is the *set of
  meta-information needed to automate the build process* of a certain
  component of a system.

- Can be used for open-source, third party proprietary components, or
  in-house components.

- Can be used for user space components (libraries and applications) but
  also for firmware, kernel drivers, bootloaders, etc.

- Do not confuse with the notion of _binary package_ in a regular
  Linux distribution.

=== Basic elements of a Buildroot package

- A directory, `package/foo`

- A `Config.in` file, written in _kconfig_ language, describing the
  configuration options for the package.

- A `<pkg>.mk` file, written in _make_, describing where to fetch
  the source, how to build and install it, etc.

- An optional `<pkg>.hash` file, providing hashes to check the
  integrity of the downloaded tarballs and license files.

- Optionally, `.patch` files, that are applied on the package source
  code before building.

- Optionally, any additional file that might be useful for the package:
  init script, example configuration file, etc.

== Config.in file
<config.in-file>

=== `package/<pkg>/Config.in`: basics

- Describes the configuration options for the package.

- Written in the _kconfig_ language.

- One option is mandatory to enable/disable the package, it
  *must* be named `BR2_PACKAGE_<PACKAGE>`.

#[ #show raw.where(block: true): set text(size: 12pt)

  ```
  config BR2_PACKAGE_VTUN
          bool "vtun"
      [...]
          help
            Tool for easily creating Virtual Tunnels over TCP/IP networks
            with traffic shaping, compression, and encryption.

            It supports IP, PPP, SLIP, Ethernet and other tunnel types.

            http://vtun.sourceforge.net/
  ```
]

- The main package option is a `bool` with the package name as the
  prompt. Will be visible in `menuconfig`.

- The help text give a quick description, and the homepage of the
  project.

=== `package/<pkg>/Config.in`: inclusion

- The hierarchy of configuration options visible in `menuconfig` is
  built by reading the top-level `Config.in` file and the other
  `Config.in` file it includes.

- All `package/<pkg>/Config.in` files are included from
  `package/Config.in`.

- The location of a package in one of the package sub-menu is decided in
  this file.

#v(0.5em)
#text(size: 15pt)[package/Config.in]
#v(-0.1em)
#[ #show raw.where(block: true): set text(size: 12pt)

  ```
  menu "Target packages"
  menu "Audio and video applications"
          source "package/alsa-utils/Config.in"
          ...
  endmenu
  ...
  menu "Libraries"
  menu "Audio/Sound"
          source "package/alsa-lib/Config.in"
          ...
  endmenu
  ...
  ```
]

=== `package/<pkg>/Config.in`: dependencies

- _kconfig_ allows to express dependencies using `select` or
  `depends on` statements

  - `select` is an automatic dependency: if option _A_ `select`
    option _B_, as soon as _A_ is enabled, _B_ will be
    enabled, and cannot be unselected.

  - `depends on` is a user-assisted dependency: if option _A_
    `depends on` option _B_, _A_ will only be visible when
    _B_ is enabled.

- Buildroot uses them as follows:

  - `depends on` for architecture, toolchain feature, or _big_
    feature dependencies. E.g: package only available on x86, or only if
    wide char support is enabled, or depends on Python.

  - `select` for enabling the necessary other packages needed to build
    the current package (libraries, etc.)

- Such dependencies only ensure consistency at the configuration level.
  They *do not guarantee build ordering*!

=== `package/<pkg>/Config.in`: dependency example

#table(
  columns: (60%, 40%),
  stroke: none,
  gutter: 15pt,
  [

    #text(size: 15pt)[btrfs-progs package]
    #v(-0.1em)
    #[ #show raw.where(block: true): set text(size: 11pt)
      ```
      config BR2_PACKAGE_BTRFS_PROGS
              bool "btrfs-progs"
              depends on BR2_USE_MMU # util-linux
              depends on BR2_TOOLCHAIN_HAS_THREADS
              select BR2_PACKAGE_LZO
              select BR2_PACKAGE_UTIL_LINUX
              select BR2_PACKAGE_UTIL_LINUX_LIBBLKID
              select BR2_PACKAGE_UTIL_LINUX_LIBUUID
              select BR2_PACKAGE_ZLIB$$
              help
                Btrfs filesystem utilities

                https://btrfs.wiki.kernel.org/index.php/Main_Page

      comment "btrfs-progs needs a toolchain w/ threads"
              depends on BR2_USE_MMU
              depends on !BR2_TOOLCHAIN_HAS_THREADS
      ```
    ]

  ],
  [

    #text(size: 16pt)[
      - `depends on BR2_USE_MMU`, because the package uses `fork()`. Note
        that there is no comment displayed about this dependency, because it's
        a limitation of the architecture.

      - `depends on BR2_TOOLCHAIN_HAS_THREADS`, because the package
        requires thread support from the toolchain. There is an associated
        comment, because such support can be added to the toolchain.

      - Multiple `select BR2_PACKAGE_*`, because the package needs numerous
        libraries.
    ]
  ],
)

=== Dependency propagation

- A limitation of _kconfig_ is that it doesn't propagate `depends
  on` dependencies accross `select` dependencies.

- Scenario: if package _A_ has a `depends on FOO`, and package
  _B_ has a `select A`, then package _B_ must replicate the
  `depends on FOO`.

#v(0.5em)

#table(
  columns: (50%, 53%),
  stroke: none,
  gutter: 15pt,
  [

    #text(size: 15pt)[libglib2 package]
    #v(-0.1em)
    #[ #show raw.where(block: true): set text(size: 9pt)
      ```
      config BR2_PACKAGE_LIBGLIB2
              bool "libglib2"
              depends on BR2_USE_WCHAR # gettext
              depends on BR2_TOOLCHAIN_HAS_THREADS
              depends on BR2_USE_MMU # fork()
              select BR2_PACKAGE_HOST_QEMU if ...
              select BR2_PACKAGE_HOST_QEMU_LINUX_USER_MODE if ...
              select BR2_PACKAGE_LIBICONV if !BR2_ENABLE_LOCALE
              select BR2_PACKAGE_LIBFFI
              select BR2_PACKAGE_PCRE2
              select BR2_PACKAGE_ZLIB
      [...]
      ```
    ]

  ],
  [

    #text(size: 15pt)[neard package]
    #v(-0.1em)
    #[ #show raw.where(block: true): set text(size: 9pt)
      ```
      config BR2_PACKAGE_NEARD
              bool "neard"
              depends on BR2_USE_WCHAR # libglib2
              depends on BR2_TOOLCHAIN_HAS_THREADS # libnl, dbus, libglib2
              depends on BR2_USE_MMU # dbus, libglib2
              depends on !BR2_STATIC_LIBS # dlopen
              depends on BR2_TOOLCHAIN_HAS_SYNC_4
              select BR2_PACKAGE_DBUS
              select BR2_PACKAGE_LIBGLIB2
              select BR2_PACKAGE_LIBNL
      [...]
      ```
    ]
  ],
)

=== `Config.in.host` for host packages?

- Most of the packages in Buildroot are _target_ packages, i.e.
  they are cross-compiled for the target architecture, and meant to be
  run on the target platform.

- Some packages have a _host_ variant, built to be executed on the
  build machine. Such packages are needed for the build process of other
  packages.

- The majority of _host_ packages are not visible in `menuconfig`:
  they are just dependencies of other packages, the user doesn't really
  need to know about them.

- A few of them are potentially directly useful to the user (flashing
  tools, etc.), and can be shown in the _Host utilities_ section of
  `menuconfig`.

- In this case, the configuration option is in a `Config.in.host` file,
  included from `package/Config.in.host`, and the option must be named
  `BR2_PACKAGE_HOST_<PACKAGE>`.

=== `Config.in.host` example

#text(size: 15pt)[package/Config.in.host]
#v(-0.1em)
#[ #show raw.where(block: true): set text(size: 12pt)

  ```
  menu "Host utilities"

          source "package/genimage/Config.in.host"
          source "package/lpc3250loader/Config.in.host"
          source "package/openocd/Config.in.host"
          source "package/qemu/Config.in.host"

  endmenu
  ```

  #v(0.5em)

  #text(size: 15pt)[package/openocd/Config.in.host]
  #v(-0.1em)

  ```
  config BR2_PACKAGE_HOST_OPENOCD
          bool "host openocd"
          depends on BR2_HOST_GCC_AT_LEAST_4_9 # host-libusb
          help
            OpenOCD - Open On-Chip Debugger

            http://openocd.org
  ```
]

=== `Config.in` sub-options

#table(
  columns: (40%, 60%),
  stroke: none,
  gutter: 15pt,
  [

    - Additional sub-options can be defined to further configure the
      package, to enable or disable extra features.

    - The value of such options can then be fetched from the package `.mk`
      file to adjust the build accordingly.

    - Run-time configuration does not belong to `Config.in`.

  ],
  [

    #text(size: 15pt)[package/pppd/Config.in]
    #v(-0.1em)
    #[ #show raw.where(block: true): set text(size: 12pt)

      ```
      config BR2_PACKAGE_PPPD
              bool "pppd"
              depends on !BR2_STATIC_LIBS
              depends on BR2_USE_MMU
              ...

      if BR2_PACKAGE_PPPD

      config BR2_PACKAGE_PPPD_FILTER
              bool "filtering"
              select BR2_PACKAGE_LIBPCAP
              help
                Packet filtering abilities for pppd. If enabled,
                the pppd active-filter and pass-filter options
                are available.

      endif
      ```
    ]

  ],
)

== Package infrastructures
<package-infrastructures>

=== Package infrastructures: what is it?

- Each software component to be built by Buildroot comes with its own
  _build system_.

- Buildroot does not re-invent the build system of each component, it
  simply uses it.

- Numerous build systems available: hand-written Makefiles or shell
  scripts, _autotools_, _Meson_, _CMake_ and also some
  specific to languages: Python, Perl, Lua, Erlang, etc.

- In order to avoid duplicating code, Buildroot has _package
  infrastructures_ for well-known build systems.

- And a generic package infrastructure for software components with
  non-standard build systems.

=== Package infrastructures

#align(center, [#image("package-infrastructures.pdf", height: 90%)])

=== `generic-package` infrastructure

- To be used for software components having non-standard build systems.

- Implements a default behavior for the downloading, extracting and
  patching steps of the package build process.

- Implements init script installation, legal information collection,
  etc.

- Leaves to the package developer the responsibility of describing what
  should be done for the configuration, building and installation steps.

=== `generic-package`: steps

#align(center, [#image("generic-package.pdf", height: 90%)])

=== Other package infrastructures

- The other package infrastructures are meant to be used when the
  software component uses a well-known build system.

- They _inherit_ all the behavior of the `generic-package`
  infrastructure: downloading, extracting, patching, etc.

- And in addition to that, they typically implement a default behavior
  for the configuration, compilation and installation steps.

- For example, `autotools-package` will implement the configuration step
  as a call to the `./configure` script with the right arguments.

- `pkg-kconfig` is an exception, it only provides some helpers for
  packages using Kconfig, but does not implement the configure, build
  and installation steps.

== .mk file for generic-package
<mk-file-for-generic-package>

=== The `<pkg>.mk` file

- The `.mk` file of a package does not look like a normal Makefile.

- It is a succession of variable definitions, which must be prefixed by
  the uppercase package name.

  - `FOOBAR_SITE = https://foobar.com/downloads/`

  - ```make
    define FOOBAR_BUILD_CMDS
           $(MAKE) -C $(@D)
    endef
    ```

- And ends with a call to the desired package infrastructure macro.

  - `$(eval $(generic-package))`

  - `$(eval $(autotools-package))`

  - `$(eval $(host-autotools-package))`

- The variables tell the package infrastructure what to do for this
  specific package.

=== Naming conventions

- The Buildroot package infrastructures make a number of assumption on
  variables and files naming.

- The following *must* match to allow the package infrastructure
  to work for a given package:

  - The directory where the package description is located *must*
    be `package/<pkg>/`, where `<pkg>` is the lowercase name of the
    package.

  - The `Config.in` option enabling the package *must* be named
    `BR2_PACKAGE_<PKG>`, where `<PKG>` is the uppercase name of
    the package.

  - The variables in the `.mk` file *must* be prefixed with
    `<PKG>_`, where `<PKG>` is the uppercase name of the package.

- Note: a `-` in the lower-case package name is translated to `_` in
  the upper-case package name.

=== Naming conventions: global namespace

- The package infrastructure expects all variables it uses to be
  prefixed by the uppercase package name.

- If your package needs to define additional private variables not used
  by the package infrastructure, they *should* also be prefixed
  by the *uppercase package name*.

- The *namespace of variables is global* in Buildroot!

  - If two packages created a variable named `BUILD_TYPE`, it will
    silently conflict.

=== Behind the scenes

- Behind the scenes, `$(eval $(generic-package))`:

  - is a _make_ macro that is expanded

  - infers the name of the current package by looking at the directory
    name: `package/<pkg>/<pkg>.mk`: `<pkg>` is the package name

  - will use all the variables prefixed by `<PKG>_`

  - and expand to a set of _make_ rules and variable definitions
    that describe what should be done for each step of the package build
    process

=== `.mk` file: accessing the configuration

- The Buildroot `.config` file is a succession of lines `name = value`

  - This file is valid _make_ syntax!

- The main Buildroot `Makefile` simply includes it, which turns every
  Buildroot configuration option into a _make_ variable.

- From a package `.mk` file, one can directly use such variables:

  #[
    #show raw.where(lang: "make", block: true): set text(size: 12pt)
    ```make
    ifeq ($(BR2_PACKAGE_LIBCURL),y)
    ...
    endif

    FOO_DEPENDENCIES += $(if $(BR2_PACKAGE_TIFF),tiff)
    ```

    - Hint: use the _make_ `qstrip` function to remove double quotes on
      string options:

      ```make
      NODEJS_MODULES_LIST = $(call qstrip,$(BR2_PACKAGE_NODEJS_MODULES_ADDITIONAL))
      ```
  ]

=== Download related variables

- `<pkg>_SITE`, *download location*

  - HTTP(S) or FTP URL where a tarball can be found, or the address of a
    version control repository.

  - `CAIRO_SITE = http://cairographics.org/releases`

  - `FMC_SITE = git://git.freescale.com/ppc/sdk/fmc.git`

- `<pkg>_VERSION`, *version of the package*

  - version of a tarball, or a commit, revision or tag for version
    control systems

  - `CAIRO_VERSION = 1.14.2`

  - `FMC_VERSION = fsl-sdk-v1.5-rc3`

- `<pkg>_SOURCE`, *file name* of the tarball

  - The full URL of the downloaded tarball is
    `$(<pkg>_SITE)/$(<pkg>_SOURCE)`

  - When not specified, defaults to
    `<pkg>-$(<pkg>_VERSION).tar.gz`

  - `CAIRO_SOURCE = cairo-$(CAIRO_VERSION).tar.xz`

=== Available download methods

#[
  #set list(spacing: 0.3em)

  - Buildroot can fetch the source code using different methods:

    - `wget`, for FTP/HTTP downloads

    - `scp`, to fetch the tarball using SSH/SCP

    - `svn`, for Subversion

    - `cvs`, for CVS

    - `git`, for Git

    - `hg`, for Mercurial

    - `bzr`, for Bazaar

    - `file`, for a local tarball

    - `local`, for a local directory

  - In most cases, the fetching method is guessed by Buildroot using the
    `<pkg>_SITE` variable.

  - Exceptions:

    - Git, Subversion or Mercurial repositories accessed over HTTP or SSH.

    - `file` and `local` methods

  - In such cases, use `<pkg>_SITE_METHOD` explicitly.
]

=== Download methods examples

- Subversion repository accessed over HTTP:

  ```make
  LIBXMLRPC_VERSION = r3176
  LIBXMLRPC_SITE = https://svn.code.sf.net/p/xmlrpc-c/code/advanced
  LIBXMLRPC_SITE_METHOD = svn
  ```

- Git repository accessed over HTTP:

  ```make
  LIBUCI_VERSION = 4b3db1179747b6a6779029407984bacef851325c
  LIBUCI_SITE = https://git.openwrt.org/project/uci.git
  LIBUCI_SITE_METHOD = git
  ```

- Source code available in a local directory:

  ```make
  MYAPP_SITE = $(TOPDIR)/../apps/myapp
  MYAPP_SITE_METHOD = local
  ```

  - The "_download_" will consist in copying the source code from
    the designated directory to the Buildroot per-package build
    directory.

=== Downloading more elements

- `<pkg>_PATCH`, a list of patches to download and apply before
  building the package. They are automatically applied by the package
  infrastructure.

- `<pkg>_EXTRA_DOWNLOADS`, a list of additional files to download
  together with the package source code. It is up to the package `.mk`
  file to do something with them.

- Two options:

  - Just a file name: assumed to be relative to `<pkg>_SITE`.

  - A full URL: downloaded over HTTP, FTP.

- Examples:

  #text(size: 15pt)[sysvinit.mk]
  #v(-0.1em)
  #[ #show raw.where(block: true): set text(size: 13pt)

    ```make
    UNZIP_PATCH = unzip_$(UNZIP_VERSION)-27.debian.tar.xz
    ```
    #v(1em)

    #text(size: 15pt)[perl.mk]
    #v(-0.1em)
    ```make
    PERL_CROSS_SITE = http://raw.github.com/arsv/perl-cross/releases
    PERL_CROSS_SOURCE = perl-$(PERL_CROSS_BASE_VERSION)-cross-$(PERL_CROSS_VERSION).tar.gz
    PERL_EXTRA_DOWNLOADS = $(PERL_CROSS_SITE)/$(PERL_CROSS_SOURCE)
    ```
  ]

=== Hash file

- In order to validate the integrity of downloaded files and license
  files, and make sure the user uses the version which was tested by the
  Buildroot developers, _cryptographic hashes_ are used

- Each package may contain a file named `<package>.hash`, which gives
  the hashes of the files downloaded by the package.

- When present, the hashes for *all* files downloaded by the
  package must be documented.

- The _hash file_ can also contain the hashes for the license files
  listed in `<pkg>_LICENSE_FILES`. This allows to detect changes in
  the license files.

- The syntax of the file is:
  #text(size: 15pt)[
    ```
    <hashtype>  <hash>  <file>
    ```]

  Note: the separator between fields is 2 spaces.

=== Hash file examples

#text(size: 15pt)[package/perl/perl.hash]
#v(-0.1em)
#text(size: 14pt)[
  ```
  # Hashes from: https://www.cpan.org/src/5.0/perl-5.40.1.tar.xz.{md5,sha1,sha256}.txt
  md5  bab3547a5cdf2302ee0396419d74a42e  perl-5.40.1.tar.xz
  sha1  4ffe5246c791df884363aed05ba81ba41cb02084  perl-5.40.1.tar.xz
  sha256  dfa20c2eef2b4af133525610bbb65dd13777ecf998c9c5b1ccf0d308e732ee3f  perl-5.40.1.tar.xz

  # Hash from: https://github.com/arsv/perl-cross/releases/download/1.6.1/perl-cross-1.6.1.hash
  sha256  b5f4b4457bbd7be37adac8ee423beedbcdba8963a85f79770f5e701dabc5550f  perl-cross-1.6.1.tar.gz

  # Locally calculated sha256  dd90d4f42e4dcadf5a7c09eea0189d93c7b37ae560c91f0f6d5233ed3b9292a2 Artistic
  sha256  d77d235e41d54594865151f4751e835c5a82322b0e87ace266567c3391a4b912  Copying
  sha256  af805523b88a8ebb60afc009caaf247a498208502f7b8b3d9d3e329fcfb1dc3b  README
  ```]

#v(1em)

#text(size: 15pt)[package/ipset/ipset.hash]
#v(-0.1em)
#text(size: 14pt)[
  ```
  # From https://ipset.netfilter.org/ipset-7.16.tar.bz2.sha512sum.txt
  sha512  e69ddee956f0922c8e08e7e5d358d6b5b24178a9f08151b20957cc3465baaba9ecd6aa938ae157f2cd286ccd7f0b7a279cfd89cec2393a00b43e4d945c275307  ipset-7.16.tar.bz2
  # Locally calculated
  sha256  231f7edcc7352d7734a96eef0b8030f77982678c516876fcb81e25b32d68564c  COPYING
  ```]

=== Describing dependencies

- Dependencies expressed in `Config.in` do not enforce build order.

- The `<pkg>_DEPENDENCIES` variable is used to describe the
  dependencies of the current package.

- Packages listed in `<pkg>_DEPENDENCIES` are guaranteed to be built
  before the _configure_ step of the current package starts.

- It can contain both target and host packages.

- It can be appended conditionally with additional dependencies.

#v(0.5em)
#text(size: 15pt)[python.mk]
#v(-0.1em)
#text(size: 15pt)[

  ```make
  PYTHON_DEPENDENCIES = host-python libffi

  ifeq ($(BR2_PACKAGE_PYTHON_READLINE),y)
  PYTHON_DEPENDENCIES += readline
  endif
  ```
]

=== Mandatory vs. optional dependencies

- Very often, software components have some *mandatory
  dependencies* and some *optional dependencies*, only needed for
  optional features.

- Handling mandatory dependencies in Buildroot consists in:

  - Using a `select` or `depends on` on the main package option in
    `Config.in`

  - Adding the dependency in `<pkg>_DEPENDENCIES`

- For optional dependencies, there are two possibilities:

  - Handle it automatically: in the `.mk` file, if the optional
    dependency is available, use it.

  - Handle it explicitly: add a package sub-option in the `Config.in`
    file.

- _Automatic_ handling is usually preferred as it reduces the
  number of `Config.in` options, but it makes the possible dependency
  less visible to the user.

=== Dependencies: `ntp` example

- Mandatory dependency: `libevent`

- Optional dependency handled automatically: `openssl`

#v(0.5em)
#text(size: 15pt)[package/ntp/Config.in
  #v(-0.1em)

  ```
  config BR2_PACKAGE_NTP
          bool "ntp"
          select BR2_PACKAGE_LIBEVENT
  [...]
  ```
  #v(0.5em)

  package/ntp/ntp.mk

  ```make
  [...]
  NTP_DEPENDENCIES = host-pkgconf libevent
  [...]
  ifeq ($(BR2_PACKAGE_OPENSSL),y)
  NTP_CONF_OPTS += --with-crypto --enable-openssl-random
  NTP_DEPENDENCIES += openssl
  else
  NTP_CONF_OPTS += --without-crypto --disable-openssl-random
  endif
  [...]
  ```]

=== Dependencies: `mpd` example (1/2)

#v(0.5em)
#text(size: 15pt)[package/mpd/Config.in
  #v(-0.1em)

  ```
  menuconfig BR2_PACKAGE_MPD
          bool "mpd"
          depends on BR2_INSTALL_LIBSTDCPP
  [...]
          select BR2_PACKAGE_BOOST
          select BR2_PACKAGE_LIBGLIB2
          select BR2_PACKAGE_LIBICONV if !BR2_ENABLE_LOCALE
  [...]

  config BR2_PACKAGE_MPD_FLAC
          bool "flac"
          select BR2_PACKAGE_FLAC
          help
            Enable flac input/streaming support.
            Select this if you want to play back FLAC files.
  ```]

=== Dependencies: `mpd` example (2/2)

#v(0.5em)
#text(size: 15pt)[package/mpd/mpd.mk
  #v(-0.1em)

  ```make
  MPD_DEPENDENCIES = host-pkgconf boost libglib2

  [...]

  ifeq ($(BR2_PACKAGE_MPD_FLAC),y)
  MPD_DEPENDENCIES += flac
  MPD_CONF_OPTS += --enable-flac
  else
  MPD_CONF_OPTS += --disable-flac
  endif
  ```]

=== Defining where to install (1)

- Target packages can install files to different locations:

  - To the _target_ directory, `$(TARGET_DIR)`, which is what
    will be the target root filesystem.

  - To the _staging_ directory, `$(STAGING_DIR)`, which is the
    compiler _sysroot_

  - To the _images_ directory, `$(BINARIES_DIR)`, which is where
    final images are located.

- There are three corresponding variables, to define whether or not the
  package will install something to one of these locations:

  - `<pkg>_INSTALL_TARGET`, defaults to `YES`. If `YES`, then
    `<pkg>_INSTALL_TARGET_CMDS` will be called.

  - `<pkg>_INSTALL_STAGING`, defaults to `NO`. If `YES`, then
    `<pkg>_INSTALL_STAGING_CMDS` will be called.

  - `<pkg>_INSTALL_IMAGES`, defaults to `NO`. If `YES`, then
    `<pkg>_INSTALL_IMAGES_CMDS` will be called.

=== Defining where to install (2)

- A package for an application:

  - installs to `$(TARGET_DIR)` only

  - `<pkg>_INSTALL_TARGET` defaults to `YES`, so there is nothing to
    do

- A package for a shared library:

  - installs to both `$(TARGET_DIR)` and `$(STAGING_DIR)`

  - must set `<pkg>_INSTALL_STAGING = YES`

- A package for a pure header-based library, or a static-only library:

  - installs only to `$(STAGING_DIR)`

  - must set `<pkg>_INSTALL_TARGET = NO` and
    `<pkg>_INSTALL_STAGING = YES`

- A package installing a bootloader or kernel image:

  - installs to `$(BINARIES_DIR)`

  - must set `<pkg>_INSTALL_IMAGES = YES`

=== Defining where to install (3)

#[ #show raw.where(lang: "make", block: true): set text(size: 15pt)

  #v(0.5em)
  #text(size: 15pt)[libyaml.mk]
  #v(-0.1em)

  ```make
  LIBYAML_INSTALL_STAGING = YES
  ```

  #v(0.5em)
  #text(size: 15pt)[eigen.mk]
  #v(-0.1em)
  ```make
  EIGEN_INSTALL_STAGING = YES
  EIGEN_INSTALL_TARGET = NO
  ```
  #v(0.5em)
  #text(size: 15pt)[linux.mk]
  #v(-0.1em)
  ```make
  LINUX_INSTALL_IMAGES = YES
  ```
]

=== Describing actions for `generic-package`

- In a package using `generic-package`, only the download, extract and
  patch steps are implemented by the package infrastructure.

- The other steps should be described by the package `.mk` file:

  - `<pkg>_CONFIGURE_CMDS`, always called

  - `<pkg>_BUILD_CMDS`, always called

  - `<pkg>_INSTALL_TARGET_CMDS`, called when
    `<pkg>_INSTALL_TARGET = YES`, for target packages

  - `<pkg>_INSTALL_STAGING_CMDS`, called when
    `<pkg>_INSTALL_STAGING = YES`, for target packages

  - `<pkg>_INSTALL_IMAGES_CMDS`, called when
    `<pkg>_INSTALL_IMAGES = YES`, for target packages

  - `<pkg>_INSTALL_CMDS`, always called for host packages

- Packages are free to not implement any of these variables: they are
  all optional.

=== Describing actions: useful variables

Inside an action block, the following variables are often useful:

- `$(@D)` is the source directory of the package

- `$(MAKE)` to call `make`

- `$(MAKE1)` when the package doesn't build properly in parallel mode

- `$(TARGET_MAKE_ENV)` and `$(HOST_MAKE_ENV)`, to pass in the
  `$(MAKE)` environment to ensure the `PATH` is correct

- `$(TARGET_CONFIGURE_OPTS)` and `$(HOST_CONFIGURE_OPTS)` to pass
  `CC`, `LD`, `CFLAGS`, etc.

- `$(TARGET_DIR)`, `$(STAGING_DIR)`, `$(BINARIES_DIR)` and
  `$(HOST_DIR)`.

=== Describing actions: `iodine.mk` example

#text(size: 15pt)[
  ```make
  IODINE_VERSION = 0.7.0
  IODINE_SITE = http://code.kryo.se/iodine
  IODINE_DEPENDENCIES = zlib
  IODINE_LICENSE = MIT
  IODINE_LICENSE_FILES = README

  IODINE_CFLAGS = $(TARGET_CFLAGS)
  [...]

  define IODINE_BUILD_CMDS
          $(TARGET_CONFIGURE_OPTS) CFLAGS="$(IODINE_CFLAGS)" \
                  $(MAKE) ARCH=$(BR2_ARCH) -C $(@D)
  endef

  define IODINE_INSTALL_TARGET_CMDS
          $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) install DESTDIR="$(TARGET_DIR)" prefix=/usr
  endef

  $(eval $(generic-package))
  ```]

=== Describing actions: `libzlib.mk` example

#text(size: 13pt)[
  ```make
  LIBZLIB_VERSION = 1.2.11
  LIBZLIB_SOURCE = zlib-$(LIBZLIB_VERSION).tar.xz
  LIBZLIB_SITE = http://www.zlib.net
  LIBZLIB_INSTALL_STAGING = YES

  define LIBZLIB_CONFIGURE_CMDS
          (cd $(@D); rm -rf config.cache; \
                  $(TARGET_CONFIGURE_ARGS) \
                  $(TARGET_CONFIGURE_OPTS) \
                  CFLAGS="$(TARGET_CFLAGS) $(LIBZLIB_PIC)" \
                  ./configure \
                  $(LIBZLIB_SHARED) \
                  --prefix=/usr \
          )
  endef

  define LIBZLIB_BUILD_CMDS
          $(TARGET_MAKE_ENV) $(MAKE1) -C $(@D)
  endef

  define LIBZLIB_INSTALL_STAGING_CMDS
          $(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR=$(STAGING_DIR) LDCONFIG=true install
  endef

  define LIBZLIB_INSTALL_TARGET_CMDS
          $(TARGET_MAKE_ENV) $(MAKE1) -C $(@D) DESTDIR=$(TARGET_DIR) LDCONFIG=true install
  endef

  $(eval $(generic-package))
  ```]

=== List of package infrastructures (1/2)

- `generic-package`, for packages not using a well-known build system.
  Already covered.

- `autotools-package`, for _autotools_ based packages, covered
  later.

- `python-package`, for _distutils_ and _setuptools_ based
  Python packages

- `perl-package`, for _Perl_ packages

- `luarocks-package`, for Lua packages hosted on `luarocks.org`

- `cmake-package`, for _CMake_ based packages

- `waf-package`, for _Waf_ based packages

- `qmake-package`, for _QMake_ based packages

=== List of package infrastructures (2/2)

- `golang-package`, for packages written in Go

- `meson-package`, for packages using the Meson build system

- `cargo-package`, for packages written in Rust

- `kconfig-package`, to be used in conjunction with `generic-package`,
  for packages that use the _kconfig_ configuration system

- `kernel-module-package`, to be used in conjunction with another
  package infrastructure, for packages that build kernel modules

- `rebar-package` for _Erlang_ packages that use the _rebar_
  build system

- `virtual-package` for _virtual_ packages, covered later.

== autotools-package infrastructure
<autotools-package-infrastructure>

=== The `autotools-package` infrastructure: basics

- The `autotools-package` infrastructure inherits from `generic-package`
  and is specialized to handle _autotools_ based packages.

- It provides a default implementation of:

  - `<pkg>_CONFIGURE_CMDS`. Calls the `./configure` script with
    appropriate environment variables and arguments.

  - `<pkg>_BUILD_CMDS`. Calls `make`.

  - `<pkg>_INSTALL_TARGET_CMDS`, `<pkg>_INSTALL_STAGING_CMDS`
    and `<pkg>_INSTALL_CMDS`. Call `make install` with the
    appropriate `DESTDIR`.

- A normal _autotools_ based package therefore does not need to
  describe any action: only metadata about the package.

=== The `autotools-package`: steps

#align(center, [#image("autotools-package.pdf", height: 90%)])

=== The `autotools-package` infrastructure: variables

- It provides additional variables that can be defined by the package:

  - `<pkg>_CONF_ENV` to pass additional values in the environment of
    the `./configure` script.

  - `<pkg>_CONF_OPTS` to pass additional options to the
    `./configure` script.

  - `<pkg>_INSTALL_OPTS`, `<pkg>_INSTALL_STAGING_OPTS` and
    `<pkg>_INSTALL_TARGET_OPTS` to adjust the _make_ target
    and options used for the installation.

  - `<pkg>_AUTORECONF`. Defaults to `NO`, can be set to `YES` if
    regenerating `Makefile.in` files and `configure` script is needed.
    The infrastructure will automatically make sure _autoconf_,
    _automake_, _libtool_ are built.

  - `<pkg>_GETTEXTIZE`. Defaults to `NO`, can be set to `YES` to
    _gettextize_ the package. Only makes sense if
    `<pkg>_AUTORECONF = YES`.

=== Canonical `autotools-package` example

#text(size: 16pt)[libyaml.mk
  #v(-0.1em)
  ```make
  ################################################################################
  #
  # libyaml
  #
  ################################################################################

  LIBYAML_VERSION = 0.2.5
  LIBYAML_SOURCE = yaml-$(LIBYAML_VERSION).tar.gz
  LIBYAML_SITE = http://pyyaml.org/download/libyaml
  LIBYAML_INSTALL_STAGING = YES
  LIBYAML_LICENSE = MIT
  LIBYAML_LICENSE_FILES = License
  LIBYAML_CPE_ID_VENDOR = pyyaml

  $(eval $(autotools-package))
  $(eval $(host-autotools-package))
  ```]

=== More complicated `autotools-package` example

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [

    #[ #show raw.where(lang: "make", block: true): set text(size: 10pt)

      ```make
      GNUPG2_VERSION = 2.4.7
      GNUPG2_SOURCE = gnupg-$(GNUPG2_VERSION).tar.bz2
      GNUPG2_SITE = https://gnupg.org/ftp/gcrypt/gnupg
      GNUPG2_LICENSE = GPL-3.0+
      GNUPG2_LICENSE_FILES = COPYING
      GNUPG2_CPE_ID_VENDOR = gnupg
      GNUPG2_CPE_ID_PRODUCT = gnupg
      GNUPG2_DEPENDENCIES = zlib libgpg-error libgcrypt libassuan libksba libnpth
              $(if $(BR2_PACKAGE_LIBICONV),libiconv) host-pkgconf

      ifeq ($(BR2_PACKAGE_BZIP2),y)
      GNUPG2_CONF_OPTS += --enable-bzip2 --with-bzip2=$(STAGING_DIR)
      GNUPG2_DEPENDENCIES += bzip2
      else
      GNUPG2_CONF_OPTS += --disable-bzip2
      endif

      ifeq ($(BR2_PACKAGE_GNUTLS),y)
      GNUPG2_CONF_OPTS += --enable-gnutls
      GNUPG2_DEPENDENCIES += gnutls
      else
      GNUPG2_CONF_OPTS += --disable-gnutls
      endif
      ```]

  ],
  [

    #[ #show raw.where(lang: "make", block: true): set text(size: 10pt)

      ```make
      [...]

      ifeq ($(BR2_PACKAGE_LIBUSB),y)
      GNUPG2_CONF_ENV += CPPFLAGS="$(TARGET_CPPFLAGS)
                                  -I$(STAGING_DIR)/usr/include/libusb-1.0"
      GNUPG2_CONF_OPTS += --enable-ccid-driver
      GNUPG2_DEPENDENCIES += libusb
      else
      GNUPG2_CONF_OPTS += --disable-ccid-driver
      endif

      ifeq ($(BR2_PACKAGE_READLINE),y)
      GNUPG2_CONF_OPTS += --with-readline=$(STAGING_DIR)
      GNUPG2_DEPENDENCIES += readline
      else
      GNUPG2_CONF_OPTS += --without-readline
      endif

      $(eval $(autotools-package))
      ```]

  ],
)

== Target vs. host packages
<target-vs.-host-packages>

=== Host packages

- As explained earlier, most packages in Buildroot are cross-compiled
  for the target. They are called *target packages*.

- Some packages however may need to be built natively for the build
  machine, they are called *host packages*. They can be needed
  for a variety of reasons:

  - Needed as a tool to build other things for the target. Buildroot
    wants to limit the number of host utilities required to be installed
    on the build machine, and wants to ensure the proper version is
    used. So it builds some host utilities by itself.

  - Needed as a tool to interact, debug, reflash, generate images, or
    other activities around the build itself.

  - Version dependencies: building a Python interpreter for the target
    needs a Python interpreter of the same version on the host.

=== Target vs. host: package name and variable prefixes

- Each package infrastructure provides a `<foo>-package` macro and a
  `host-<foo>-package` macro.

- For a given package in `package/baz/baz.mk`, `<foo>-package` will
  create a package named `baz` and `host-<foo>-package` will create a
  package named `host-baz`.

- `<foo>-package` will use the variables prefixed with `BAZ_`

- `host-<foo>-package` will use the variables prefixed with
  `HOST_BAZ_`

=== Target vs. host: variable inheritance

- For many variables, when `HOST_BAZ_<var>` is not defined, the
  package infrastructure _inherits_ from `BAZ_<var>` instead.

  - True for `<PKG>_SOURCE`, `<PKG>_SITE`, `<PKG>_VERSION`,
    `<PKG>_LICENSE`, `<PKG>_LICENSE_FILES`, etc.

  - Defining `<PKG>_SITE` is sufficient, defining
    `HOST_<PKG>_SITE` is not needed.

  - It is still possible to override the value specifically for the host
    variant, but this is rarely needed.

- But not for all variables, especially commands

  - E.g. `HOST_<PKG>_BUILD_CMDS` is not inherited from
    `<PKG>_BUILD_CMDS`

=== Example 1: a pure build utility

- _bison_, a general-purpose parser generator.

- Purely used as build dependency in packages

  - `FBSET_DEPENDENCIES = host-bison host-flex`

- No `Config.in.host`, not visible in `menuconfig`.

#v(0.5em)
#text(size: 15pt)[package/bison/bison.mk]
#text(size: 13pt)[
  ```make
  BISON_VERSION = 3.8.2
  BISON_SOURCE = bison-$(BISON_VERSION).tar.xz
  BISON_SITE = $(BR2_GNU_MIRROR)/bison
  BISON_LICENSE = GPL-3.0+
  BISON_LICENSE_FILES = COPYING
  BISON_CPE_ID_VENDOR = gnu
  # parallel build issue in examples/c/reccalc/
  BISON_MAKE = $(MAKE1)
  HOST_BISON_DEPENDENCIES = host-m4
  HOST_BISON_CONF_OPTS = --enable-relocatable
  HOST_BISON_CONF_ENV = ac_cv_libtextstyle=no

  $(eval $(host-autotools-package))
  ```]

=== Example 2: filesystem manipulation tool

- `fatcat`, is designed to manipulate FAT filesystems, in order to
  explore, extract, repair, recover and forensic them.

- Not used as a build dependency of another package $$visible in
  `menuconfig`.

#v(0.5em)
#text(size: 15pt)[package/fatcat/Config.in.host]
#text(size: 13pt)[
  ```
  config BR2_PACKAGE_HOST_FATCAT
          bool "host fatcat"
          help
            Fatcat is designed to manipulate FAT filesystems, in order
            to explore, extract, repair, recover and forensic them. It
            currently supports FAT12, FAT16 and FAT32.

            https://github.com/Gregwar/fatcat
  ```]

#v(0.5em)
#text(size: 15pt)[package/fatcat/fatcat.mk]
#text(size: 13pt)[
  ```make
  FATCAT_VERSION = 1.1.1
  FATCAT_SITE = $(call github,Gregwar,fatcat,v$(FATCAT_VERSION))
  FATCAT_LICENSE = MIT
  FATCAT_LICENSE_FILES = LICENSE

  $(eval $(host-cmake-package))
  ```]

=== Example 3: target and host of the same package

#text(size: 15pt)[package/e2tools/e2tools.mk]
#text(size: 15pt)[
  ```make
  E2TOOLS_VERSION = 0.0.16.4
  E2TOOLS_SITE = $(call github,ndim,e2tools,v$(E2TOOLS_VERSION))

  # Source coming from GitHub, no configure included.
  E2TOOLS_AUTORECONF = YES
  E2TOOLS_LICENSE = GPL-2.0
  E2TOOLS_LICENSE_FILES = COPYING
  E2TOOLS_DEPENDENCIES = e2fsprogs
  E2TOOLS_CONF_ENV = LIBS="-lpthread"
  HOST_E2TOOLS_DEPENDENCIES = host-e2fsprogs
  HOST_E2TOOLS_CONF_ENV = LIBS="-lpthread"

  $(eval $(autotools-package))
  $(eval $(host-autotools-package))
  ```]

#setuplabframe([New packages in Buildroot], [

  - Practical creation of several new packages in Buildroot, using the
    different package infrastructures.

])
