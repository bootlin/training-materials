#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

===  The full system

#columns(gutter: 8pt)[

- Beagle Bone Black board (of course). The Wireless variant should work
  fine too.

- Beagle Bone Black 4.3" LCD cape from 4D Systems (not the one shown on
  this picture) 
  #link("https://4dsystems.com.au/products/4dcape-43/")

- Standard USB webcam (supported through the ``` uvcvideo ``` driver).

#colbreak() #align(center, [#image("/common/beaglecam.jpg", width: 100%)]) 
]
