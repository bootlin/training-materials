#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Kernel Resources

=== Kernel Development News
<kernel-development-news>

#table(
  columns: (65%, 35%),
  stroke: none,
  gutter: 15pt,
  [

    Linux Weekly News

    #v(0.5em)

    - #link("https://lwn.net/")

    - The weekly digest off all Linux and free software information sources

    - In depth technical discussions about the kernel

    - Coverage of the features accepted in each merge window

    - Subscribe to finance the editors (\$7 / month)

    - Articles available for non subscribers after 1 week.

  ],
  [

    #align(center, [#image("lwn.png", width: 100%)])

  ],
)

=== Useful Online Resources

#[
  #set list(spacing: 0.3em)
  #set text(size: 18pt)
  - Kernel documentation
    - #link("https://kernel.org/doc/")
  - Linux kernel mailing list FAQ
    #[
      #set list(spacing: 0.3em)
      - #link("https://subspace.kernel.org/etiquette.html")

      - Complete Linux kernel FAQ

      - Read this before asking a question to the mailing list
    ]
  - Linux kernel mailing lists
    #[
      #set list(spacing: 0.3em)
      - #link("https://lore.kernel.org/")

      - Easy browsing and referencing of all e-mail threads

      - Easy access to an mbox in order to answer to e-mails you were not
        Cc'ed to
    ]
  - Kernel Newbies
    #[
      #set list(spacing: 0.3em)
      - #link("https://kernelnewbies.org/")

      - Articles, presentations, HOWTOs, recommended reading, useful tools
        for people getting familiar with Linux kernel or driver development.

      - Glossary: #link("https://kernelnewbies.org/KernelGlossary")

      - In depth coverage of the new features in each kernel release:
        #link("https://kernelnewbies.org/LinuxChanges")
    ]
  - The #link("https://elinux.org") wiki
]

=== International Conferences (1)

#table(
  columns: (75%, 25%),
  stroke: none,
  gutter: 15pt,
  [

    #include "/common/elc.typ"

    #include "/common/lpc.typ"

  ],
  [

    #align(center, [#image("/common/elc-logo.png", width: 100%)])
    #v(1em)
    #align(center, [#image("/common/lpc-logo.jpg", width: 90%)])

  ],
)

=== International Conferences (2)

#table(
  columns: (70%, 30%),
  stroke: none,
  gutter: 15pt,
  [

    - Kernel Recipes: #link("https://kernel-recipes.org/")

      - Well attended conference in Europe (Paris), only one track at a
        time, with a format that really allows for discussions.

    - linux.conf.au: #link("https://linux.org.au/linux-conf-au/")

      - In Australia / New Zealand

      - Features a few presentations by key kernel hackers.

    - Currently, most conferences are available on-line. They are much more
      affordable and often free.

  ],
  [

    #align(center, [#image("kernel-recipes-logo.png", width: 90%)])
    #v(1em)
    #align(center, [#image("/common/lca-logo.png", width: 90%)])

  ],
)

=== After the course

#table(
  columns: (50%, 50%),
  stroke: none,
  gutter: 15pt,
  [

    Continue to learn:

    - Run your labs again on your own hardware. The Nunchuk lab should be
      rather straightforward, but the serial lab will be quite different if
      you use a different processor.

    - Learn by reading the kernel code by yourself, ask questions and
      propose improvements.

    - Implement and share drivers for your own hardware, of course!

  ],
  [

    Hobbyists can make their first contributions by:

    - Helping with tasks keeping the kernel code clean and up-to-date:
      #link("https://kernelnewbies.org/KernelJanitors/Todo")

    - Proposing fixes for issues reported by the #emph[Coccinelle] tool:
      `make coccicheck`

    - Participating to improving drivers in #kdir("drivers/staging")

    - Investigating and do the triage of issues reported by Coverity Scan:
      #link("https://scan.coverity.com/projects/linux")

  ],
)

=== Contribute your changes

Recommended resources

- See #kdochtml("process/submitting-patches") for guidelines and \
  #link("https://kernelnewbies.org/UpstreamMerge") for very helpful
  advice to have your changes merged upstream (by Rik van Riel).

- Watch the #emph[Write and Submit your first Linux kernel Patch] talk
  by Greg. K.H:
  #link(
    "https://www.youtube.com/watch?v=LLBrBBImJt4",
  )[https://www.youtube.com/watch?v=LLBrBBImJt4]

- How to Participate in the Linux Community (by Jonathan Corbet). \
  A guide to the kernel development process. \
  #text(size: 16pt)[#link(
      "https://www.static.linuxfound.org/sites/lfcorp/files/How-Participate-Linux-Community_0.pdf",
    )[https://www.static.linuxfound.org/sites/lfcorp/files/How-Participate-Linux-Community_0.pdf]
  ]
