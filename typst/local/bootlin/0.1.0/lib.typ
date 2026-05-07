#import "@preview/touying:0.6.0": *

/* Inputs */
#let trainingtitle
#let trainer
#if sys.inputs.training == "embedded-linux" {
  trainingtitle = "Embedded Linux system development"
}
#if sys.inputs.training == "audio" {
  trainingtitle = "Audio with embedded Linux"
}
#if sys.inputs.training == "debugging" {
  trainingtitle = "Linux debugging, profiling and tracing"
}
#if sys.inputs.training == "yocto" {
  trainingtitle = "Yocto Project and OpenEmbedded system development"
}
#if sys.inputs.training == "linux-kernel" {
  trainingtitle = "Linux kernel and driver development"
}
#if sys.inputs.training == "buildroot" {
  trainingtitle = "Buildroot system development"
}
#if sys.inputs.training == "preempt-rt" {
  trainingtitle = "Understanding Linux real-time with PREEMPT_RT"
}
#if sys.inputs.training == "networking" {
  trainingtitle = "Embedded Linux networking"
}
#if sys.inputs.training == "security" {
  trainingtitle = "Embedded Linux Security"
}
#let last_update = datetime.today()

/* Colors */
#let bootlin-orange = rgb("#FF631A")
#let color-link = rgb("#2c4cdb")
#let color-code = rgb("#595959")

#let boldtext = rgb("#000000")
#let blcode = rgb("#595959")
#let blcodebg = rgb("#E6E6E6")

/* Generic utils/macros */
#let link(dest, ..body) = {
  if body == none { body = dest }
  text(fill: color-link, std.link(
    dest,
    ..body,
  ))
}

#let code(body) = text(
  font: "DejaVu Sans Mono",
  size: 0.8em,
  fill: color-code,
  body,
)

#show raw.where(block: false): it => text(
  font: "DejaVu Sans Mono",
  size: 0.8em,
  fill: color-code,
  it,
)

#let codelink(title, body) = text(fill: rgb("#4040BF"), std.link(body)[#title])

#let codeblock(body) = block(
  fill: blcodebg,
  inset: 8pt,
  radius: 6pt,
)[
  #set text(font: "Inconsolata", fill: blcode, size: 9pt)
  #body
]

#let todo(arg1) = {
  "TODO: " + arg1
}

/* Touying configuration */
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let header(self) = {
    set text(size: 26pt)
    h(26mm) + utils.call-or-display(self, self.store.header)
    v(-0.1em)
    line(length: 100%, stroke: 2pt + bootlin-orange)
    v(4mm)
    place(top + left, dx: 6mm, dy: 4mm, box(
      image("logo-penguins.svg"),
      width: 18mm,
    ))
  }
  let footer(self) = {
    set text(size: 8pt)
    line(length: 100%, stroke: 0.2pt + black)
    v(-0.9em)
    (
      h(0.5em)
        + utils.call-or-display(self, self.store.footer)
        + h(1fr)
        + utils.call-or-display(self, self.store.footer-right)
        + h(0.5em)
    )
  }
  let self = utils.merge-dicts(
    self,
    config-page(header: header, footer: footer),
  )
  let new-setting = body => {
    show: setting
    v(1fr)
    body
    v(2fr)
  }
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: new-setting,
    composer: composer,
    ..bodies,
  )
})

#let lab-slide(config: (:), body) = touying-slide-wrapper(self => {
  let header(self) = {
    set text(size: 26pt)
    h(26mm) + utils.call-or-display(self, self.store.header)
    v(-0.8em)
    line(length: 100%, stroke: 2pt + bootlin-orange)
    v(4mm)
    place(top + left, dx: 6mm, dy: 4mm, box(
      image("logo-penguins.svg"),
      width: 18mm,
    ))
  }
  self = utils.merge-dicts(
    self,
    config,
    config-page(
      margin: (x: 2em, top: 20mm, bottom: 1em),
      header: header,
    ),
  )
  let body = {
    box(width: 40%, height: 100%, image("lab-penguins.svg"))
    box(width: 60%, height: 100%, body)
  }
  touying-slide(self: self, body)
})

#let title-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  let header(self) = {
    set text(size: 12pt)
    [#h(1fr) Embedded Linux and kernel engineering #h(1em)]
    v(-0.8em)
    line(length: 100%, stroke: 2pt + bootlin-orange)
    v(4mm)
    place(top + left, dx: 6mm, dy: 4mm, box(
      image("logo-penguins.svg"),
      width: 18mm,
    ))
  }
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(
      margin: (x: 2em, top: 20mm, bottom: 1em),
      header: header,
    ),
  )
  let info = self.info + args.named()
  let body = {
    box(
      width: 60%,
      height: 100%,
      stack(
        spacing: 3em,
        if info.title != none { text(size: 40pt, info.title) },
        if info.author != none {
          text(size: 28pt, weight: "regular", info.author)
        },
        if info.date != none {
          text(size: 20pt, utils.display-info-date(self))
        },
      )
        + text(
          size: 8pt,
          [© Copyright 2004-#datetime.today().display("[year]"), Bootlin. \
            Creative Commons BY-SA 3.0 license. \
            Corrections, suggestions, contributions and translations are welcome!],
        ),
    )
    box(width: 40%, height: 100%, image("logo-square.svg"))
  }
  touying-slide(self: self, body)
})

#let new-section-slide(
  config: (:),
  level: 1,
  numbered: false,
  body,
) = touying-slide-wrapper(self => {
  let header(self) = {
    h(26mm) + utils.call-or-display(self, self.store.header)
    set text(size: 13pt)
    [#h(1fr) Embedded Linux and kernel engineering #h(1em)]
    v(0.1em)
    line(length: 100%, stroke: 2pt + bootlin-orange)
    v(4mm)
    place(top + left, dx: 6mm, dy: 4mm, box(
      image("logo-penguins.svg"),
      width: 18mm,
    ))
  }
  let footer(self) = {
    set text(size: 8pt)
    line(length: 100%, stroke: 0.2pt + black)
    v(-0.9em)
    (
      h(0.5em)
        + utils.call-or-display(self, self.store.footer)
        + h(1fr)
        + utils.call-or-display(self, self.store.footer-right)
        + h(0.5em)
    )
  }
  let slide-body = {
    box(width: 60%, height: 100%, stack(
      spacing: 3em,
      dir: ttb,
      text(size: 40pt, style: "normal", utils.display-current-heading(
        level: level,
        numbered: numbered,
      )),
      block(height: 2pt, width: 90%, spacing: 0pt, components.progress-bar(
        height: 2pt,
        bootlin-orange,
        luma(180),
      )),
      body,
      [#text(size: 10pt)[© Copyright 2004-#datetime.today().year(), Bootlin \
        Creative Commons BY-SA 3.0 \
        Corrections, suggestions, contributions and translations are welcome!]],
    ))
    box(width: 40%, height: 100%, image("logo-square-full.svg"))
  }
  self = utils.merge-dicts(
    self,
    config-page(
      margin: (x: 2em, top: 20mm, bottom: 1em),
      header: header,
      footer: footer,
    ),
  )
  touying-slide(self: self, config: config, slide-body)
})

#let new-subsection-slide(
  config: (:),
  level: 2,
  numbered: false,
  body,
) = touying-slide-wrapper(self => {
  let header(self) = {
    [#h(26mm) #utils.display-current-heading(level: 1, numbered: false)]
    set text(size: 13pt)
    [#h(1fr) Embedded Linux and kernel engineering #h(1em)]
    v(0.1em)
    line(length: 100%, stroke: 2pt + bootlin-orange)
    v(4mm)
    place(top + left, dx: 6mm, dy: 4mm, box(
      image("logo-penguins.svg"),
      width: 18mm,
    ))
  }
  let footer(self) = {
    set text(size: 8pt)
    line(length: 100%, stroke: 0.2pt + black)
    v(-0.9em)
    (
      h(0.5em)
        + utils.call-or-display(self, self.store.footer)
        + h(1fr)
        + utils.call-or-display(self, self.store.footer-right)
        + h(0.5em)
    )
  }
  let slide-body = {
    set align(center)
    stack(
      spacing: 3em,
      dir: ttb,
      text(size: 40pt, style: "normal", utils.display-current-heading(
        level: level,
        numbered: numbered,
      )),
      block(height: 2pt, width: 50%, spacing: 0pt, components.progress-bar(
        height: 2pt,
        bootlin-orange,
        luma(180),
      )),
      body,
    )
  }
  self = utils.merge-dicts(
    self,
    config-page(
      margin: (x: 2em, top: 20mm, bottom: 1em),
      header: header,
      footer: footer,
    ),
  )
  touying-slide(self: self, config: config, slide-body)
})

#let questions-slide(config: (:)) = touying-slide-wrapper(self => {
  let slide-body = {
    set align(center)
    stack(
      spacing: 3em,
      dir: ttb,
      text(size: 2.3em)[Questions? Suggestions? Comments?],
      v(4em),
      text(size: 1.7em, self.info.author),
      [Slides under CC-BY-SA 3.0],
    )
  }
  let footer(self) = {
    set text(size: 8pt)
    v(3pt)
    line(length: 100%, stroke: 0.2pt + black)
    v(-0.9em)
    (
      h(0.5em)
        + utils.call-or-display(self, self.store.footer)
        + h(1fr)
        + utils.call-or-display(self, self.store.footer-right)
        + h(0.5em)
    )
  }
  self = utils.merge-dicts(
    self,
    config-page(
      margin: (x: 2em, top: 20mm, bottom: 1em),
      footer: footer,
    ),
  )
  touying-slide(self: self, config: config, slide-body)
})

/* Frames */
#let frame(title, body) = [
  #block[
    #set text(size: 16pt, weight: "bold")
    #box(width: 100%, inset: 6pt, fill: white)[
      #image("logo-penguins.svg", width: 1cm)
      #h(1em)
      #title
    ]
    #line(length: 100%, stroke: (paint: bootlin-orange, thickness: 1pt))
  ]
  #v(1em)
  #body
  #v(1fr)
  #line(length: 100%, stroke: 0.5pt)
  #grid(
    columns: (1fr, auto),
    [#text(size: 8pt)[
      Kernel, drivers and embedded Linux —
      Development, consulting, training and support —
      https://bootlin.com
    ]],
  )
]

#let titleframe() = {
  heading(trainingtitle + " training", depth: 3)
  table(
    columns: (60%, 40%),
    stroke: none,
    [
      #text(size: 30pt)[#trainingtitle training]
      #v(2em)
      #text(size: 10pt)[
        © Copyright 2004-#datetime.today().year(), Bootlin \
        Creative Commons BY-SA 3.0 \
        Latest update: #last_update.display("[month repr:long] [day], [year].")
        #v(1em)
        Document updates and training details: \
        #link(
          "https://bootlin.com/training/"
            + sys.inputs.at("training", default: ""),
        )
        #v(1em)
        Corrections, suggestions, contributions and translations are welcome! \
        Send them to #text(fill: rgb("#4B6FA9"))[feedback\@bootlin.com]
      ]
    ],
    [#align(center)[#image("logo-square-full.svg", width: 100%)]],
  )
}

#let sectionframe(title) = {
  heading(title, depth: 3)
  grid(
    columns: 2,
    [#text(size: 24pt, weight: "bold")[#title]],
    [#align(center)[#image("logo-square.svg", scale: 45%)]],
  )
}

#let labframe(title, body) = {
  heading("Practical lab - " + title, depth: 3)
  grid(
    columns: (0.4fr, 0.6fr),
    [#image("lab-penguins.svg", width: 100%)], [#body],
  )
}

#let setuplabframe(title, body) = {
  heading("Practical lab - " + title, depth: 3)
  grid(
    columns: (0.4fr, 0.6fr),
    column-gutter: 1cm,
    align: horizon,
    [#image("lab-penguins.svg", width: 100%)], body,
  )
}

#let setupdemoframe(title, body) = {
  heading("Demo - " + title, depth: 3)
  grid(
    columns: (0.4fr, 0.6fr),
    column-gutter: 1cm,
    align: horizon,
    [#image("lab-penguins.svg", width: 100%)], body,
  )
}

/* Main Touying theme */
#let bootlin-theme(
  aspect-ratio: "16-9",
  header: self => utils.display-current-heading(depth: self.slide-level),
  ..args,
  body,
) = {
  set list(
    marker: (
      text(
        size: 1.5em,
        fill: bootlin-orange,
        stroke: bootlin-orange,
        [#v(-0.2em)‣],
      ),
      text(
        size: 1em,
        fill: bootlin-orange,
        stroke: bootlin-orange,
        [🞄],
      ),
      text(
        size: 0.5em,
        fill: bootlin-orange,
        stroke: bootlin-orange,
        [#v(0.2em)■],
      ),
    ),
    indent: 1em,
    spacing: 0.7em,
    tight: true,
    body-indent: 0.6em,
  )
  set par(spacing: 0.5em)
  set par(leading: 0.5em)
  set raw(syntaxes: "devicetree.sublime-syntax")
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (x: 1.5em, top: 20mm, bottom: 6mm),
      footer-descent: 0.5mm,
      header-ascent: 1mm,
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      new-subsection-slide-fn: new-subsection-slide,
      slide-level: 3,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(font: "Latin Modern Sans", size: 19pt)
        set align(horizon)
        let list-counter = counter("list")
        set enum(numbering: n => text(fill: bootlin-orange, numbering("1.", n)))
        show raw.where(block: false): set text(color-code)
        show raw.where(block: true): set block(
          fill: luma(240),
          inset: 1em,
          radius: 0.5em,
          width: 100%,
        )
        show raw.where(lang: "c", block: true): set block(
          fill: luma(240),
          inset: 0.4em,
          radius: 0.5em,
          width: 95%,
          breakable: true,
          above: 12pt,
          below: 12pt,
        )
        show raw.where(lang: "c", block: true): set text(11pt)
        show raw.where(lang: "console", block: true): set block(
          fill: luma(240),
          inset: 0.4em,
          radius: 0.5em,
          width: 95%,
          breakable: true,
          above: 6pt,
        )
        show raw.where(lang: "console", block: true): set text(11pt)
        show list: it => {
          list-counter.step()
          context {
            set list(spacing: 0.4em) if list-counter.get().first() >= 1
            set par(leading: 0.5em) if list-counter.get().first() >= 1
            set list(spacing: 0.5em) if list-counter.get().first() >= 2
            set par(leading: 0.4em, spacing: 0.4em) if (
              list-counter.get().first() >= 2
            )
            block(
              above: if list-counter.get().first() == 2 { 0.7em } else { 1em },
              it,
            )
          }
          list-counter.update(i => i - 1)
        }
        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: boldtext,
      primary-light: rgb("#2159A5"),
      primary-lightest: rgb("#F2F4F8"),
      neutral-lightest: rgb("#FFFFFF"),
    ),
    config-store(
      header: header,
      footer: box(pad(top: 0.55em, image("bootlin-logo.svg", height: 1.3em)))
        + [ \- Kernel, drivers and embedded Linux - Development, consulting, training and support - #link("https://bootlin.com")],
      footer-right: context utils.slide-counter.display()
        + "/"
        + utils.last-slide-number,
    ),
    ..args,
  )
  body
}
