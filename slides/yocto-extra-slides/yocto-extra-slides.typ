#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

#set list(spacing: 0.8em)
#set enum(spacing: 0.8em)
= Extra slides

== Quilt
<quilt>

===  Overview

- Quilt is a utility to manage patches which can be used without having
  a clean source tree.

- It can be used to create patches for recipes already available in the
  build system.

- Be careful when using this workflow: the modifications won't persist
  across builds!

===  Using Quilt

+ Find the recipe working directory in `$BUILDDIR/tmp/work/`.
+ Create a new `Quilt` patch: `$ quilt new topic.patch`
+ Add files to this patch: `$ quilt add file0.c file1.c`
+ Make the modifications by editing the files.
+ Test the modifications: `$ bitbake -c compile -f recipe`
+ Generate the patch file: `$ quilt refresh`
+ Move the generated patch into the recipe's directory.