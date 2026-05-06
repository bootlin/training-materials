#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Analyzing the build

=== Analyzing the build: available tools

- Buildroot provides several useful tools to analyze the build:

  - The *licensing report*, covered in a previous section, which allows
    to analyze the list of packages and their licenses.

  - The *dependency graphing* tools

  - The *build time graphing* tools

  - The *filesystem size* tools

=== Dependency graphing

- Exploring the dependencies between packages is useful to understand

  - why a particular package is being brought into the build

  - if the build size and duration can be reduced

- `make graph-depends` to generate a full dependency graph, which can
  be huge!

- `make <pkg>-graph-depends` to generate the dependency graph of a
  given package

- The graph is done according to the current Buildroot configuration.

- Resulting graphs in `$(O)/graphs/`

=== Dependency graph example

#align(center, [#image("graph-depends.pdf", height: 90%)])

=== Build time graphing

- When the generated embedded Linux system grows bigger and bigger, the
  build time also increases.

- It is sometimes useful to analyze this build time, and see if certain
  packages are particularly problematic.

- Buildroot collects build duration data in the file
  `$(O)/build/build-time.log`

- `make graph-build` generates several graphs in `$(O)/graphs/`:

  - `build.hist-build.pdf`, build time in build order

  - `build.hist-duration.pdf`, build time by duration

  - `build.hist-name.pdf`, build time by package name

  - `build.pie-packages.pdf`, pie chart of the per-package build time

  - `build.pie-steps.pdf`, pie chart of the per-step build time

- Note: only works properly after a complete clean rebuild.

=== Build time graphing: example

#align(center, [#image("build-hist-build.pdf", width: 100%)])

=== Filesystem size graphing

- In many embedded systems, storage resources are limited.

- For this reason, it is useful to be able to analyze the size of your
  root filesystem, and see which packages are consuming the biggest
  amount of space.

- Allows to focus the size optimizations on the relevant packages.

- Buildroot collects data about the size installed by each package.

- `make graph-size` produces:

  - `file-size-stats.csv`, CSV with the raw data of the per-file size

  - `package-size-stats.csv`, CSV with the raw data of the per-package
    size

  - `graph-size.pdf`, pie chart of the per-package size consumption

=== Filesystem size graphing: example

#align(center, [#image("graph-size.pdf", height: 90%)])