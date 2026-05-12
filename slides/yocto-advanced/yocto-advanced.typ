#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Using Yocto Project - advanced usage

=== Advanced build usage and configuration

- Variable operators and overrides.

- Select package variants.

- Manually add packages to the generated image.

- Run specific tasks with BitBake.

=== A little reminder

- A _Recipe_ describes how to fetch, configure, compile and install
  a software component (application, library, …).

- These tasks can be run independently (if their dependencies are met).

- All the available packages in the project layer are not selected by
  default to be built and included in the images.

- Some recipes may provide the same functionality, e.g. OpenSSH and
  Dropbear.

== Variables
<variables>

=== Overview

- The OpenEmbedded build system uses configuration _variables_ to
  hold information.

- Variable _names_ are in upper-case by convention, e.g.
  `CONF_VERSION`

- Variable _values_ are strings

- To make configuration easier, it is possible to prepend, append or
  define these variables in a conditional way.

- Variables defined in *Configuration Files* have a
  *global* scope

  - Files ending in `.conf`

- Variables defined in *Recipes* have a *local* scope

  - Files ending in `.bb`, `.bbappend` and `.bbclass`

- Recipes can also access the global scope

=== Operators: basic assignment

- `VAR = "value"` simply assigns a value

- Re-assigning overwrites variable value

  ```sh
  VAR = "this"
  VAR = "that"
  ```

  Result: `VAR = "that"`

- Newlines need to be escaped (this does not apply to functions)

  ```sh
  LIST = "this
          and that"
  ```

- Variable assignments can contain expansion of other variables

  ```sh
  COLOUR = "blue"
  SKY = "the sky is ${COLOUR}"
  ```

=== Operators: immediate expansion

- With `=`, expansion happens when the variable is used

- Use `:=` for immediate expansion

#v(0.5em)

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [

    ```sh
    COLOUR = "blue"
    SKY = "the sky is ${COLOUR}"
    COLOUR = "grey"
    PHRASE = "Look, ${SKY}"
    ```

    Result: \ `PHRASE = "Look, the sky is grey"`

  ],
  [

    ```sh
    COLOUR  = "blue"
    SKY := "the sky is ${COLOUR}"
    COLOUR  = "grey"
    PHRASE = "Look, ${SKY}"
    ```

    Result: \ `PHRASE = "Look, the sky is blue"`

  ],
)

#v(1em)

- Normal expansion is correct in most cases. Only use `:=` when really
  needed.

=== Operators: appending and prepending

- Variable values can be modified by composition: #v(0.5em)

  / +=: append (with space)

  / =+: prepend (with space)

  / .=: append (without space)

  / =.: prepend (without space)

=== Operators: default and weak default values

- The `?=` operator assigns a value only if the variable has not been
  assigned when the statement is parsed

  #v(0.5em)

  #table(
    columns: (50%, 50%),
    stroke: none,
    gutter: 15pt,
    [

      ```sh
      COLOUR = "blue"
      COLOUR ?= "unknown"
      ```

      Result: `COLOUR = "blue"`

    ],
    [

      ```sh
      COLOUR ?= "unknown"
      ```

      Result: `COLOUR = "unknown"`

    ],
  )

#v(1em)

- The `??=` operator assigns a value only if the variable has not been
  assigned when the statement is parsed, not even using a `?=` operator

- The
  #link(
    "https://docs.yoctoproject.org/bitbake/bitbake-user-manual/bitbake-user-manual-metadata.html#setting-a-default-value",
  )[BitBake documentation]
  explains the differences in details.

=== Operators caveats

- The operators apply their effect during parsing

- Example:

  #v(0.5em)

  #table(
    columns: (50%, 50%),
    stroke: none,
    gutter: 15pt,
    [

      ```text
      VAR ?= "a"
      VAR += "b"
      ```

      Result: `VAR = "a b"`

    ],
    [

      ```text
      VAR += "b"
      VAR ?= "a"
      ```

      Result: `VAR = " b"`

    ],
  )

  #v(0.5em)

- The parsing order of files is difficult to predict, no assumption should be made about it.

- To avoid the problem, avoid using `+=`, `=+`, `.=` and `=.` in `$BUILDDIR/conf/local.conf`. Always use overrides (see following slides).

=== `bitbake-getvar`

- `bitbake-getvar` can be used to understand and debug how variables are
  assigned

- `bitbake-getvar <VARIABLE>`

- Lists each configuration file touching the variable, the pre-expansion
  value and the final value

#v(0.5em)

```console
$ bitbake-getvar DEPLOY_DIR
NOTE: Starting bitbake server...
#
# $DEPLOY_DIR [2 operations]
#   set? /home/user/yocto-labs/poky/meta/conf/bitbake.conf:440
#     "${TMPDIR}/deploy"
#   set /home/user/yocto-labs/poky/meta/conf/documentation.conf:137
#     [doc] "Points to the general area that the OpenEmbedded build system uses to place images, [...]"
# pre-expansion value:
#   "${TMPDIR}/deploy"
DEPLOY_DIR="/home/user/yocto-labs/build/tmp/deploy"
$
```

=== Overrides

- Bitbake *overrides* allow appending, prepending or modifying a
  variable at expansion time, when the variable's value is read

- Overrides are written as `<VARIABLE>:<override> = "some_value"`

- A different syntax was used before *Honister* (3.4), with no
  retrocompatibility: `<VARIABLE>_<override> = "some_value"`

=== Overrides to modify variable values

- The `append` override adds *at the end* of the variable
  (without space).

  - `IMAGE_INSTALL:append = " dropbear"` adds `dropbear` to the
    packages installed on the image.

- The `prepend` override adds *at the beginning* of the variable
  (without space).
  - `PATH:prepend = "${COREBASE}/scripts/native-intercept:"` adds before the ones already present.

- The `remove` override removes all occurrences of a value within a
  variable.

  - `IMAGE_INSTALL:remove = "i2c-tools"`

=== Order of variable assignment

#table(
  columns: (55%, 45%),
  stroke: none,
  gutter: 15pt,
  [

    #align(center, [#image("yocto-operators-order.pdf", width: 100%)])

  ],
  [

    + All the operators are applied,
      in parsing order

    + `:append` overrides are applied

    + `:prepend` overrides are applied

    + `:remove` overrides are applied

  ],
)

=== Overrides for conditional assignment

- Append the machine name to only define a configuration variable for a
  given machine.

- It tries to match with values from #yoctovar("OVERRIDES") which
  includes #yoctovar("MACHINE"), #yoctovar("SOC_FAMILY"), and
  more.

- If the override is in #yoctovar("OVERRIDES"), the assignment is
  applied, otherwise it is ignored.

#v(0.5em)

```sh
OVERRIDES="arm:armv7a:ti-soc:ti33x:beaglebone:poky"

KERNEL_DEVICETREE:beaglebone = "am335x-bone.dtb" # This is applied
KERNEL_DEVICETREE:dra7xx-evm = "dra7-evm.dtb"    # This is ignored
```

=== Overrides for conditional assignment: precedence

- The most specific assignment takes precedence.

- Example:

  `
  IMAGE_INSTALL:beaglebone = "busybox mtd-utils i2c-tools"
  IMAGE_INSTALL = "busybox mtd-utils"
  `

- If the machine is `beaglebone`:

  - `IMAGE_INSTALL = "busybox mtd-utils i2c-tools"`

- Otherwise:

  - `IMAGE_INSTALL = "busybox mtd-utils"`

=== Combining overrides

- The previous methods can be combined.

- If we define:

  - `IMAGE_INSTALL = "busybox mtd-utils"`

  - `IMAGE_INSTALL:append = " dropbear"`

  - `IMAGE_INSTALL:append:beaglebone = " i2c-tools"`

- The resulting configuration variable will be:

  - `IMAGE_INSTALL = "busybox mtd-utils dropbear i2c-tools"` if the
    machine being built is `beaglebone`.

  - `IMAGE_INSTALL = "busybox mtd-utils dropbear"` otherwise.

== Virtual providers
<virtual-providers>

=== Introduction to virtual providers

- Some recipes have the same purpose, and only one can be used at a
  time.

- The build system uses *virtual providers* to reflect this.

- Only one of the recipes that provides the functionality will be
  compiled and integrated into the resulting image.

=== Variant examples

- The virtual provider names are often in the form `virtual/<name>`

- Example of available virtual providers with some of their variants:

  - `virtual/bootloader`: u-boot, u-boot-ti-staging…

  - `virtual/kernel`: linux-yocto, linux-yocto-tiny, linux-yocto-rt,
    linux-ti-staging…

  - `virtual/libc`: glibc, musl, newlib

  - `virtual/xserver`: xserver-xorg

=== Provider selection

- Providers are selected thanks to the
  #yoctovar("PREFERRED_PROVIDER") configuration variable.

- The recipe names *have to* suffix this variable.

- Examples:

  - `PREFERRED_PROVIDER_virtual/kernel ?= "linux-ti-staging"`

  - `PREFERRED_PROVIDER_virtual/libgl = "mesa"`

=== Version selection

- By default, Bitbake will try to build the recipe with the highest
  version number, from the highest priority layer, unless the recipe
  defines `DEFAULT_PREFERENCE = "-1"`

- When multiple recipe versions are available, it is also possible to
  explicitly pick one with #yoctovar("PREFERRED_VERSION").

- The recipe names *have to* suffix this variable.

- *%* can be used as a wildcard.

- Example:
  - `PREFERRED_VERSION_nginx = "1.20.1"`
  - `PREFERRED_VERSION_linux-yocto = "5.14%"`

== Selection of packages to install
<selection-of-packages-to-install>

=== Selection of packages to install

- Building recipes will result in binary packages being generated.

- The set of packages installed into the image is defined by the target
  you choose (e.g. `core-image-minimal`).

- It is possible to have a custom set by defining our own target, and we
  will see this later.

- When developing or debugging, adding packages can be useful, without
  modifying the recipes.

- Packages are controlled by the #yoctovar("IMAGE_INSTALL")
  configuration variable.

== The power of BitBake
<the-power-of-bitbake>

=== Common BitBake options

- BitBake can be used to run a full build for a given target with
  `bitbake [target]`

  - `target` is a recipe name, possibly with modifiers, e.g. `-native`

  - `bitbake ncurses`

  - `bitbake ncurses-native`

- But it can be more precise, with additional options:

  / `-c <task>`: #block[
      execute the given task
    ]

  / `-s`: #block[
      list all available recipes and their versions
    ]

  / `-f`: #block[
      force the given task to be run by removing its stamp file
    ]

  / `world`: #block[
      keyword for all recipes
    ]

=== BitBake examples

- `bitbake -c listtasks virtual/kernel`

  - Gives a list of the available tasks for the recipe providing the
    package `virtual/kernel`. Tasks are prefixed with `do_`.

- `bitbake -c menuconfig virtual/kernel`

  - Execute the task `menuconfig` on the recipe providing the
    `virtual/kernel` package.

- `bitbake -f dropbear`

  - Force the `dropbear` recipe to run all tasks.

- `bitbake –runall=fetch core-image-minimal`

  - Download all recipe sources and their dependencies.

- For a full description: `bitbake –help`

=== shared state cache

- BitBake stores the output of each task in a directory, the shared
  state cache.

- This cache is used to speed up compilation.

- Its location is defined by the #yoctovar("SSTATE_DIR") variable
  and defaults to `build/sstate-cache`.

- Over time, as you compile more recipes, it can grow quite big. It is
  possible to clean old data with:
#v(0.5em)
#[ #show raw.where(lang: "console", block: true): set text(size: 16pt)
  ```console
  $ find sstate-cache/ -type f -atime +30 -delete
  ```
] #v(0.5em)
This removes all files that have last been accessed more than 30 days
ago (for example).
