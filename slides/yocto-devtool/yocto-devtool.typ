#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Devtool

===  Overview

- `Devtool` is a set of utilities to ease the integration and the
  development of OpenEmbedded recipes.

- It can be used to:

  - Generate a recipe for a given upstream application.

  - Modify an existing recipe and its associated sources.

  - Upgrade an existing recipe to use a newer upstream application.

- `Devtool` adds a new layer, automatically managed, in
  `$BUILDDIR/workspace/`.

- It then adds or appends recipes to this layer so that the recipes
  point to a local path for their sources. In
  `$BUILDDIR/workspace/sources/`.

  - Local sources are managed by `git`.

  - All modifications made locally should be committed.

===  `devtool usage 1/3` 
There are three ways of creating a new
`devtool` project:

- To create a new recipe: `devtool add <recipe> <fetchuri>`

  - Where `recipe` is the recipe's name.

  - `fetchuri` can be a local path or a remote _uri_.

- To modify the source for an existing recipe: `devtool modify <recipe>`

- To upgrade a given recipe: `devtool upgrade -V <version> <recipe>`

  - Where `version` is the new version of the upstream application.

===  `devtool usage 2/3` 

Once a `devtool` project is started, commands
can be issued:

- `devtool edit-recipe <recipe>`: edit `recipe` in a text editor (as
  defined by the `EDITOR` environment variable).

- `devtool build <recipe>`: build the given `recipe`.

- `devtool build-image <image>`: build `image` with the additional
  `devtool` recipes' packages.

===  `devtool usage 3/3`

- `devtool deploy-target <recipe> <target>`: upload the `recipe`'s
  packages on `target`, which is a live running target with an SSH
  server running (`user@address`).

- `devtool update-recipe <recipe>`: generate patches from git commits
  made locally.

- `devtool reset <recipe>`: remove `recipe` from the control of
  `devtool`. Standard layers and remote sources are used again as usual.
