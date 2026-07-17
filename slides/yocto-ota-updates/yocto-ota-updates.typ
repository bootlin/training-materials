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

- See the #link(<runtime-package-management-annex>)[extra slides] for details on
  how to set it up.
