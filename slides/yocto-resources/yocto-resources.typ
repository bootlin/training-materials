#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Yocto Project Resources

=== Yocto Project documentation

- #link("https://docs.yoctoproject.org/")

- Wiki:
  #link(
    "https://wiki.yoctoproject.org/wiki/Main_Page",
  )[https://wiki.yoctoproject.org/wiki/Main_Page]

- #link("https://layers.openembedded.org/")

=== Contributing

- Friendly community to newcomers of the project

- Mailing list based upstreaming workflow: \
  #link("https://docs.yoctoproject.org/contributor-guide")

- Ask questions and help people on IRC: \
  #link(
    "https://web.libera.chat/?channels=#yocto",
  )[https://web.libera.chat/?channels=#yocto]

- Try to solve newcomer bugs reported on the official Bugzilla: \
  #link(
    "https://wiki.yoctoproject.org/wiki/Newcomers#Newcomer_Bugs",
  )[https://wiki.yoctoproject.org/wiki/Newcomers#Newcomer_Bugs]

- The Wiki contains a lot of useful information: \
  #link(
    "https://wiki.yoctoproject.org/wiki/Main_Page",
  )[https://wiki.yoctoproject.org/wiki/Main_Page]

=== Useful Reading

#table(
  columns: (70%, 30%),
  stroke: none,
  gutter: 15pt,
  [

    Embedded Linux Development Using Yocto Project - Third Edition,
    April 2023

    - #link(
        "https://www.packtpub.com/en-us/product/embedded-linux-development-using-yocto-project-9781804615065",
      )

    - By Daiane Angolini and Otavio Salvador

    - From basic to advanced usage, helps writing better, more flexible
      recipes. A good reference to jumpstart your Yocto Project development.

  ],
  [

    #align(center, [#image("ELDYP.jpg", width: 100%)])

  ],
)
