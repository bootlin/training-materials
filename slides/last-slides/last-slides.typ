#import "@local/bootlin:0.1.0": *

#import "/typst/local/common.typ": *

#show: bootlin-theme

#let trainer = if "trainer" in sys.inputs {
  sys.inputs.trainer
}else{none}

= Last slides

#if trainer == none{}else{[

===  Evaluation and final quiz

- Rate this training session and provide your feedback:

  #link("sessionurl/survey.html")[sessionurl/survey.html]

===  Evaluation and final quiz

- Rate this training session and provide your feedback:

  #link("sessionurl/survey.html")[sessionurl/survey.html]

- Fill in the final quiz to assess your level of knowledge on the topics
  covered in this course. To get the training certificate, you must have
  attended all sessions, and get at least 50% of correct answers at this
  final quiz:

  #link("sessionurl/quiz-after.html")[sessionurl/quiz-after.html]

  The final quiz must be filled in within two weeks of the training
  end's date.

  The training certificate is sent two weeks after the training end's
  date.
- Fill in the final quiz to assess your level of knowledge on the topics
  covered in this course. To get the training certificate, you must have
  attended all sessions, and get at least 50% of correct answers at this
  final quiz:

  #link("sessionurl/quiz-after.html")[sessionurl/quiz-after.html]

  The final quiz must be filled in within two weeks of the training
  end's date.

  The training certificate is sent two weeks after the training end's
  date.
]}

===  Last slide

#align(center,
[#text(size: 50pt)[
Thank you! 
]  \ 

#v(0.5em)
#text(size: 40pt)[
And may the Source be with you 
]]
)

===  Rights to copy 

#text(size: 17pt)[
© Copyright 2004-#datetime.today().display("[year]"), Bootlin  \ 
*License: Creative Commons Attribution - Share Alike 3.0*  \ 
#link("https://creativecommons.org/licenses/by-sa/3.0/legalcode")  \ 
You are free:

- to copy, distribute, display, and perform the work

- to make derivative works

- to make commercial use of the work

Under the following conditions:

- *Attribution*. You must give the original author credit.

- *Share Alike*. If you alter, transform, or build upon this
  work, you may distribute the resulting work only under a license
  identical to this one.

- For any reuse or distribution, you must make clear to others the
  license terms of this work.

- Any of these conditions can be waived if you get permission from the
  copyright holder.

Your fair use and other rights are in no way affected by the above.
#v(0.5em)
*Document sources:* 
#link("https://github.com/bootlin/training-materials/") 
]