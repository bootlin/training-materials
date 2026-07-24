#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= OTA updates

== Runtime Package Management
<runtime-package-management>

=== Runtime Package Management

- BitBake always builds packages selected in
  #yoctovar("IMAGE_INSTALL").

- The binary packages are used to generate the root filesystem.

- It is also possible to update the system at runtime using these
  packages, for many use cases:

  - In-field security updates.

  - System updates over the wire.

  - System, packages or configuration customization at runtime.

  - Remote debugging.

- Using the Runtime Package Management is an optional feature.

- Can be useful for local development, but rarely used in production.

- See the #link(<runtime-package-management-annex>)[extra slides] for details on
  how to set it up.

== A/B updates

=== A/B updates: principle

- Mechanism for Over-The-Air (OTA) _image_ updates

- Key idea: avoid one update bricking the device
  - Even if tested, one update might prevent the system from booting
  - Enable the device to recover from a bad update automatically

- The key idea is to maintain 2 copies of the system, in two *slots*
  - minimum is 2 rootFS
  - usually also includes the kernel
  - can involve the bootloader, depending on the bootROM

=== A/B updates: Yocto support

- Three main solutions:

  - #link("https://sbabic.github.io/swupdate/swupdate.html")[SWUpdate]:
    - DIY approach, very flexible
    - Open-source
    - Yocto layer: #link("https://github.com/sbabic/meta-swupdate")[meta-swupdate]

  - #link("https://mender.io/")[Mender]:
    - Fully-integrated solution, requires `systemd`
    - Open-source, but server side is commercial
    - Yocto layer: #link("https://github.com/mendersoftware/meta-mender")[meta-mender]

  - #link("https://rauc.io/")[RAUC]:
    - Good middleground
    - Open-source
    - Yocto layer: #link("https://github.com/rauc/meta-rauc")[meta-rauc]

- See our #link("https://bootlin.com/training/security/")[Security training]
  for in-depth details on A/B updates.
