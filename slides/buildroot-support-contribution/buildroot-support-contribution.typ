#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Buildroot community: support and contribution

===  Documentation

- Buildroot comes with its own documentation

- Pre-built versions available at
  #link("https://buildroot.org/docs.html") (PDF, HTML, text)

- Source code of the manual located in `docs/manual` in the Buildroot
  sources

  - Written in _Asciidoc_ format

- The manual can be built with:

  - `make manual`

  - or just `make manual-html`, `make manual-pdf`, `make manual-epub`,
    `make manual-text`, `make manual-split-html`

  - A number of tools need to be installed on your machine, see the
    manual itself.

===  Getting support

- Free support

  - The _mailing list_ for e-mail discussion \
    #link("http://lists.busybox.net/mailman/listinfo/buildroot") \
    1400+ subscribers, quite heavy traffic.

  - The IRC channel, `#buildroot` on the OFTC network, for interactive
    discussion \
    60+ people, most available during European daylight hours

  - Bug tracker \
    #link("https://bugs.busybox.net/buglist.cgi?product=buildroot")[https://bugs.busybox.net/buglist.cgi?product=buildroot]

- Commercial support

  - A number of embedded Linux services companies, including Bootlin,
    can provide commercial services around Buildroot.

===  Tips to get free support

- If you have a build issue to report:

  - Make sure to reproduce after a `make clean all` cycle

  - Include the Buildroot version, Buildroot `.config` that reproduces
    the issue, and last 100-200 lines of the build output in your
    report.

  - Use _pastebin_ sites like `https://paste.ack.tf/` when
    reporting issues over IRC.

- The community will be much more likely to help you if you use a recent
  Buildroot version.

===  Release schedule

- The Buildroot community publishes stable releases every three months.

- YYYY.02, YYYY.05, YYYY.08 and YYYY.11 every year.

- The three months cycle is split in two periods

  - Two first months of active development

  - One month of stabilization before the release

- At the beginning of the stabilization phase, `-rc1` is released.

- Several `-rc` versions are published during this stabilization phase,
  until the final release.

- Development not completely stopped during the stabilization, a `next`
  branch is opened.

- Long-term maintenance of YYYY.02, with a _LTS initiative_

===  Contribution process

- Contributions are made in the form of patches

- Created with `git` and sent by e-mail to the mailing list

  - Use `git send-email` to avoid issues

  - Use `get-developers` to know to who patches should be sent

- The patches are reviewed, tested and discussed by the community

  - You may be requested to modify your patches, and submit updated
    versions

- Once ready, they are applied by one of the project maintainers

- Some contributions may be rejected if they do not fall within the
  Buildroot principles/ideas, as discussed by the community.

===  Patchwork

- Tool that records all patches sent on the mailing list

- Allows the community to see which patches need review/testing, and the
  maintainers which patches can be applied.

- Everyone can create an account to manage his own patches

- #link("https://patchwork.ozlabs.org/project/buildroot/list/")

#v(0.5em)

#align(center, [#image("patchwork.png", height: 60%)])

===  Automated build testing

- The enormous number of configuration options in Buildroot make it very
  difficult to test all combinations.

- Random configurations are therefore built 24/7 by multiple machines.

  - Random choice of architecture/toolchain combination from a
    pre-defined list

  - Random selection of packages using `make randpackageconfig`

  - Random enabling of features like static library only, or
    `BR2_ENABLE_DEBUG=y`

- Scripts and tools publicly available at \
  #link("https://gitlab.com/buildroot.org/buildroot-test/")

- Results visible at #link("http://autobuild.buildroot.org/")

- Daily e-mails with the build results of the past day

===  autobuild.buildroot.org

#align(center, [#image("autobuild.png", width: 90%)])

===  Autobuild daily reports

#text(size: 11.2pt)[
`
Subject: [Buildroot] [autobuild.buildroot.net] Build results for 2019-03-19

Build statistics for 2019-03-19
===============================

      branch |  OK | NOK | TIM | TOT |
   2018.02.x |  18 |   3 |   0 |  21 |
   2018.11.x |  36 |   1 |   0 |  37 |
   2019.02.x |  25 |   4 |   0 |  29 |
      master | 166 | 105 |   3 | 274 |

Results for branch 'master'
===========================

Classification of failures by reason
------------------------------------

                       unknown | 22
          angularjs-legal-info | 15
      host-uboot-tools-2019.01 | 11
[...]

Detail of failures
------------------

       sparc | android-tools-4.2.2+git2013... | NOK | http://autobuild.buildroot.net/results/f1648f245d77f85661bc0d2f1e8097c3695206d8 |     
    mips64el |           angularjs-legal-info | NOK | http://autobuild.buildroot.net/results/fdf6b64648dfa58ec74de31104a1a71248242d80 |     
[...]
         arm |         glib-networking-2.58.0 | NOK | http://autobuild.buildroot.net/results/fc2e68921bd84d13d2e9bc900a91e46b08d698fe |     
`
]

===  Additional testing effort

- Run-time test infrastructure in `support/testing`

  - Contains a number of test cases that verify that specific Buildroot
    configurations build correctly, and boot correctly under Qemu.

  - Validates filesystem format support, specific packages, core
    Buildroot functionality.

  - `./support/testing/run-tests -l`

  - `./support/testing/run-tests tests.fs.test_ext.TestExt2`

  - Run regularly on _Gitlab CI_

- All _defconfigs_ in `configs/` are built every week on
  _Gitlab CI_
