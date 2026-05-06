#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

  #show: bootlin-theme

#titleframe()
#let sessionurl = if "session_url" in sys.inputs{
  sys.inputs.session_url
}else{none}

#let trainer = if "trainer" in sys.inputs {
  sys.inputs.trainer
}else{none}
#if trainer==none{

  [

  === #trainingtitle training
      
  #table(columns: (77%, 23%), stroke: none, gutter: 15pt, 
  [
    - These slides are the training materials for Bootlin's
      #emph[#trainingtitle] training course.
    - If you are interested in following this course with an
        experienced Bootlin trainer, we offer:
        - *Public online sessions*, opened to individual
          registration. Dates announced on our site, registration
          directly online.
        - *Dedicated online sessions*, organized for a team of
          engineers from the same company at a date/time chosen by our
          customer.
        - *Dedicated on-site sessions*, organized for a team of
          engineers from the same company, we send a Bootlin trainer
          on-site to deliver the training.
          
    - Details and registrations:  \  
        #link("https://bootlin.com/training/"+sys.inputs.training)
    - Contact: `training@bootlin.com`
      ],[
      #image("/common/training.png")
      #[
        #set text(size: 12.5pt)
      #align(center, [_Icon by Eucalyp, Flaticon_])
    ]
    ])]
    
    }else{
      include trainer+".typ"
    }

// If the materials a generated for a real session, not for the website

#if trainer==none{}else{
  [
    === Electronic copies of these documents
        - Electronic copies of your particular version of the materials are available on: #link(sessionurl)
        - You can download and open these documents to follow lectures and labs, to look for explanations gidven earlier by the trainer and to copy and paste text during labs.
        - This specific URL will remain available for a long time. This way, you can always access the exact instructions corresponding to the labs performed in this session.
        - If you are interested in the latest versions of our training materials, visit the description of each course on #link("https://bootlin.com/training")
  ]
}
