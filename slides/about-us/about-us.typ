#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= About Bootlin
<about-bootlin>

===  Bootlin introduction

#table(
columns: (70%, 30%), stroke: none,
[

- Engineering company

  - In business since 2004

  - Before 2018: _Free Electrons_ 

- Team based in France and Italy 

- Serving *customers worldwide* 

- *Highly focused and recognized expertise*

  - Embedded Linux

  - Linux kernel

  - Embedded Linux build systems 

- *Strong open-source* contributor 

- Activities

  - *Engineering* services

  - *Training* courses 

- #link("https://bootlin.com")
],
[

#align(center, [#image("/common/bootlin-logo.pdf", width: 100%)])

]
)

===  Bootlin engineering services

#align(center, [#image("engineering-services.pdf", height: 80%)])

===  Bootlin training courses

#align(center, [#image("training-courses.pdf", height: 70%)])

===  Bootlin, an open-source contributor

- Strong contributor to the *Linux* kernel

  - In the top 30 of companies contributing to Linux worldwide

  - Contributions in most areas related to hardware support

  - Several engineers maintainers of subsystems/platforms

  - 9000 patches contributed

  - #link("https://bootlin.com/community/contributions/kernel-contributions/") 

- Contributor to *Yocto Project*

  - Maintainer of the official documentation

  - Core participant to the QA effort 

- Contributor to *Buildroot*

  - Co-maintainer

  - 6000 patches contributed 

- Significant contributions to U-Boot, OP-TEE, Barebox, etc. 

- Fully *open-source training materials*

===  Bootlin on-line resources

#table(columns: (70%, 30%), stroke: none, 
  [

- Website with a technical blog:  \ 
  #link("https://bootlin.com")

- Engineering services:  \ 
  #link("https://bootlin.com/engineering")

- Training services:  \ 
  #link("https://bootlin.com/training")

- LinkedIn:  \ 
  #link("https://www.linkedin.com/company/bootlin")

- Elixir - browse Linux kernel sources on-line:  \ 
  #link("https://elixir.bootlin.com")

],[

#align(center, [#image("www.png", width: 85%)]) 
#[ #set text(size: 13pt)
#align(center, [_Icon by Freepik, Flaticon_])
]

])
