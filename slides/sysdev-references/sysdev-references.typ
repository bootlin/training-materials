#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

= Useful resources

===  Books

#table(columns: (80%, 20%), stroke: none, [

- *Mastering Embedded Linux Programming, 4th Edition*
  #footnote[#link("https://www.amazon.com/dp/1803232595")] 
  By Frank Vasquez, Chris Simmonds, Packt Publishing, May 2025 
  An up-to-date resource covering most aspects of embedded Linux
  development.

- *The Linux Programming Interface*
  #footnote[#link("https://man7.org/tlpi/")] 
  Michael Kerrisk (maintainer of Linux manual pages), 2010, No Starch
  Press 
  A gold mine about Linux system programming

],[

#align(center, [#image("book-mastering-embedded-linux4.jpg", height: 30%)])
#align(center, [#image("/common/linux-programming-interface.png", height: 30%)])

])

===  Web sites

- *ELinux.org*, #link("https://elinux.org"), a Wiki entirely
  dedicated to embedded Linux. Lots of topics covered: real-time,
  filesystems, multimedia, tools, hardware platforms, etc. Interesting
  to explore to discover new things.

- *LWN*, #link("https://lwn.net"), very interesting news site
  about Linux in general, and specifically about the kernel. Weekly
  edition, available for free after one week for non-paying visitors.

===  International conferences (1)

#table(columns: (75%, 25%), stroke: none, gutter: 15pt,[

#include "/common/elc.typ"

#include "/common/lpc.typ"

],[

#align(center, [#image("/common/elc-logo.png", width: 100%)])
#align(center, [#image("/common/lpc-logo.jpg", width: 80%)]) 

])

===  International conferences (2)

#table(columns: (70%, 30%), stroke: none, [

- FOSDEM: #link("https://fosdem.org")

  - Brussels (Belgium), February

  - Community-oriented conference, free, during the week-end

  - Many _developer rooms_, including on low-level, embedded and
    hardware topics

- Embedded Recipes: #link("https://embedded-recipes.org")

  - Nice (France), May

  - 2-day conference about all embedded Linux topics

  - Well attended by known contributors

  - Very affordable conference, thanks to sponsors (like Bootlin).

- Most conferences are now also accessible on-line, which makes them
  much more affordable.
  
],[

#align(center, [#image("fosdem.jpg", width: 80%)])
#align(center, [#image("embedded-recipes.png", width: 80%)]) 

])
