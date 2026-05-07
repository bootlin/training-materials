#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Automating layer management

===  Release management 

There are multiple tasks that OE/bitbake based projects let you do on your own to ensure build reproducibility:

- Code distribution and project setup.

- Release tagging

#v(0.5em)

A separate tool is needed for that, usual solutions are:

- git submodules + setup script. Great example in YOE: \ 
  #link("https://github.com/YoeDistro/yoe-distro")

- repo and `templateconf` or setup script

- kas

===  Google repo

- A good way to distribute a distribution (Poky, custom layers, BSP,
  `.templateconf`…) is to use Google's `repo`.

- `Repo` is used in Android to distribute its source code, which is
  split into many `git` repositories. It's a wrapper to handle several
  `git` repositories at once.

- The only requirement is to use `git`.

- The `repo` configuration is stored in a `manifest` file, usually
  available in its own `git` repository.

- It could also be in a specific branch of your custom layer.

- It only handles fetching code, handling `local.conf` and
  `bblayers.conf` is done separately

===  Manifest example

#text(size: 17pt)[
```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="yocto-project" fetch="git.yoctoproject.org" />
  <remote name="private" fetch="git.example.net" />

  <default revision="scarthgap" remote="private" />

  <project name="poky" remote="yocto-project" />
  <project name="meta-ti" remote="yocto-project" />
  <project name="meta-custom" />
  <project name="meta-custom-bsp" />
  <project path="meta-custom-distro" name="distro">
    <copyfile src="templateconf" dest="poky/.templateconf" />
  </project>
</manifest>
```]

===  Retrieve the project using `repo`

`
$ mkdir my-project; cd my-project
$ repo init -u https://git.example.net/manifest.git
$ repo sync -j4
`

- `repo init` uses the `default.xml` manifest in the repository, unless
  specified otherwise.

- You can see the full `repo` documentation at \
  #link("https://source.android.com/source/using-repo.html").

===  repo: release 

To tag a release, a few steps have to be taken:

- Optionally tag the custom layers

- For each project entry in the manifest, set the revision parameter to
  either a tag or a commit hash.

- Commit and tag this version of the manifest.

===  kas

- Specific tool developed by Siemens for OpenEmbedded: \
  #link("https://github.com/siemens/kas")

- Will fetch layers and build the image in a single command

- Uses a single JSON or YAML configuration file part of the custom layer

- Can generate and run inside a Docker container

- Can setup `local.conf` and `bblayers.conf`

===  kas configuration

#text(size: 16.5pt)[
```yaml
header:
  version: 8
machine: mymachine 
distro: mydistro 
target:
  - myimage

repos:
  meta-custom:

  bitbake:
    url: "https://git.openembedded.org/bitbake"
    # tag 2.0
    commit: c212b0f3b542efa19f15782421196b7f4b64b0b9
    layers:
      .: excluded

  openembedded-core:
    url: "https://git.openembedded.org/openembedded-core"
    branch: scarthgap
    layers:
      meta:
```]

===  kas configuration

#text(size: 16.5pt)[
```yaml
  meta-freescale:
    url: "https://github.com/Freescale/meta-freescale"
    branch: scarthgap

  meta-openembedded:
   url: https://git.openembedded.org/meta-openembedded
   branch: scarthgap
   layers:
     meta-oe:
     meta-python:
     meta-networking:
```]

- Then a single command will build all the listed targets for the
  machine:

#text(size: 17pt)[
  ```sh
  $ kas build meta-custom/mymachine.yaml
  ```]

- Or, alternatively, invoke `bitbake` commands:

#text(size: 17pt)[
  ```sh
  $ kas shell /path/to/kas-project.yml -c 'bitbake dosfsutils-native'
  ```]
