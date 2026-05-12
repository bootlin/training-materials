#import "@preview/touying:0.6.0": *

// ── Destinataire (lettres) ─────────────────────────────────────────
#let recipient = (
  name: [],
  address: [],
)

// ── Entrées système ────────────────────────────────────────────────
#let trainingtitle
#let trainer
#if sys.inputs.training == "embedded-linux"{
  trainingtitle="Embedded Linux system development"
}
#if sys.inputs.training == "audio"{
  trainingtitle="Audio with embedded Linux"
}
#if sys.inputs.training == "debugging"{
  trainingtitle="Linux debugging, profiling and tracing"
}
#if sys.inputs.training == "yocto"{
  trainingtitle="Yocto Project and OpenEmbedded system development"
}
#if sys.inputs.training == "linux-kernel"{
  trainingtitle="Linux kernel and driver development"
}
#if sys.inputs.training == "buildroot"{
  trainingtitle="Buildroot system development"
}
#if sys.inputs.training == "preempt-rt"{
  trainingtitle="Understanding Linux real-time with PREEMPT_RT"
}
#if sys.inputs.training == "networking"{
  trainingtitle="Embedded Linux networking"
}
#if sys.inputs.training == "security"{
  trainingtitle="Embedded Linux Security"
}
#let last_update = datetime.today()

// ── Couleurs ───────────────────────────────────────────────────────
#let bootlin-orange = rgb("#FF631A")
#let color-link     = rgb("#2c4cdb")
#let color-code     = rgb("#595959")

#let boldtext   = rgb("#000000")
#let blcode     = rgb("#595959")
#let blcodebg   = rgb("#E6E6E6")

// ── Fonctions utilitaires ──────────────────────────────────────────
#let link(dest, ..body) = {
  if body == none { body = dest }
  text(font: "DejaVu Sans Mono", size: 0.8em, fill: color-link, std.link(dest, ..body))
}

#let code(body) = text(
  font: "DejaVu Sans Mono",
  size: 0.8em,
  fill: color-code,
  body
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

// ── Slides Touying ─────────────────────────────────────────────────
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
    place(top + left, dx: 6mm, dy: 4mm, box(image("logo-penguins.svg"), width: 18mm))
  }
  let footer(self) = {
    set text(size: 8pt)
    line(length: 100%, stroke: 0.2pt + black)
    v(-0.9em)
    h(0.5em) + utils.call-or-display(self, self.store.footer) + h(1fr) + utils.call-or-display(self, self.store.footer-right) + h(0.5em)
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
  touying-slide(self: self, config: config, repeat: repeat, setting: new-setting, composer: composer, ..bodies)
})

#let lab-slide(config: (:), body) = touying-slide-wrapper(self => {
  let header(self) = {
    set text(size: 26pt)
    h(26mm) + utils.call-or-display(self, self.store.header)
    v(-0.8em)
    line(length: 100%, stroke: 2pt + bootlin-orange)
    v(4mm)
    place(top + left, dx: 6mm, dy: 4mm, box(image("logo-penguins.svg"), width: 18mm))
  }
  self = utils.merge-dicts(
    self,
    config,
    config-page(
      margin: (x: 2em, top: 20mm, bottom: 1em),
      header: header
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
    place(top + left, dx: 6mm, dy: 4mm, box(image("logo-penguins.svg"), width: 18mm))
  }
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(
      margin: (x: 2em, top: 20mm, bottom: 1em),
      header: header
    ),
  )
  let info = self.info + args.named()
  let body = {
    box(width: 60%, height: 100%,
      stack(spacing: 3em,
        if info.title != none { text(size: 40pt, info.title) },
        if info.author != none { text(size: 28pt, weight: "regular", info.author) },
        if info.date != none { text(size: 20pt, utils.display-info-date(self)) },
      ) + text(size: 8pt, [© Copyright 2004-#datetime.today().display("[year]"), Bootlin. \
        Creative Commons BY-SA 3.0 license. \
        Corrections, suggestions, contributions and translations are welcome!])
    )
    box(width: 40%, height: 100%, image("logo-square.svg"))
  }
  touying-slide(self: self, body)
})

#let new-section-slide(config: (:), level: 1, numbered: false, body) = touying-slide-wrapper(self => {
  let header(self) = {
    h(26mm) + utils.call-or-display(self, self.store.header)
    set text(size: 13pt)
    [#h(1fr) Embedded Linux and kernel engineering #h(1em)]
    v(0.1em)
    line(length: 100%, stroke: 2pt + bootlin-orange)
    v(4mm)
    place(top + left, dx: 6mm, dy: 4mm, box(image("logo-penguins.svg"), width: 18mm))
  }
  let footer(self) = {
    set text(size: 8pt)
    line(length: 100%, stroke: 0.2pt + black)
    v(-0.9em)
    (h(0.5em)
      + utils.call-or-display(self, self.store.footer)
      + h(1fr)
      + utils.call-or-display(self, self.store.footer-right)
      + h(0.5em))
  }
  let slide-body = {
    box(width: 60%, height: 100%,
      stack(spacing: 3em, dir: ttb,
        text(size: 40pt, style: "normal", utils.display-current-heading(level: level, numbered: numbered)),
        block(height: 2pt, width: 90%, spacing: 0pt,
          components.progress-bar(height: 2pt, bootlin-orange, luma(180)),
        ),
        body,
        [#text(size: 10pt)[© Copyright 2004-#datetime.today().year(), Bootlin \
          Creative Commons BY-SA 3.0 \
          Corrections, suggestions, contributions and translations are welcome!]]
      )
    )
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

#let new-subsection-slide(config: (:), level: 2, numbered: false, body) = touying-slide-wrapper(self => {
  let header(self) = {
    [#h(26mm) #utils.display-current-heading(level: 1, numbered: false)]
    set text(size: 13pt)
    [#h(1fr) Embedded Linux and kernel engineering #h(1em)]
    v(0.1em)
    line(length: 100%, stroke: 2pt + bootlin-orange)
    v(4mm)
    place(top + left, dx: 6mm, dy: 4mm, box(image("logo-penguins.svg"), width: 18mm))
  }
  let footer(self) = {
    set text(size: 8pt)
    line(length: 100%, stroke: 0.2pt + black)
    v(-0.9em)
    (h(0.5em)
      + utils.call-or-display(self, self.store.footer)
      + h(1fr)
      + utils.call-or-display(self, self.store.footer-right)
      + h(0.5em))
  }
  let slide-body = {
    set align(center)
    stack(spacing: 3em, dir: ttb,
      text(size: 40pt, style: "normal", utils.display-current-heading(level: level, numbered: numbered)),
      block(height: 2pt, width: 50%, spacing: 0pt,
        components.progress-bar(height: 2pt, bootlin-orange, luma(180)),
      ),
      body
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
    stack(spacing: 3em, dir: ttb,
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
    h(0.5em) + utils.call-or-display(self, self.store.footer) + h(1fr) + utils.call-or-display(self, self.store.footer-right) + h(0.5em)
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

// ── Frames (second fichier) ────────────────────────────────────────
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
    columns: (60%, 40%), stroke: none,
    [
      #text(size: 30pt)[#trainingtitle training]
      #v(2em)
      #text(size: 10pt)[
        © Copyright 2004-#datetime.today().year(), Bootlin \
        Creative Commons BY-SA 3.0 \
        Latest update: #last_update.display("[month repr:long] [day], [year].")
        #v(1em)
        Document updates and training details: \
        #link("https://bootlin.com/training/" + sys.inputs.at("training", default: ""))
        #v(1em)
        Corrections, suggestions, contributions and translations are welcome! \
        Send them to #text(fill: rgb("#4B6FA9"))[feedback\@bootlin.com]
      ]
    ],
    [#align(center)[#image("logo-square-full.svg", width: 100%)]]
  )
}

#let sectionframe(title) = {
  heading(title, depth: 3)
  grid(
    columns: 2,
    [#text(size: 24pt, weight: "bold")[#title]],
    [#align(center)[#image("logo-square.svg", scale: 45%)]]
  )
}

#let labframe(title, body) = {
  heading("Practical lab - " + title, depth: 3)
  grid(
    columns: (0.4fr, 0.6fr),
    [#image("lab-penguins.svg", width: 100%)],
    [#body]
  )
}

#let setuplabframe(title, body) = {
  heading("Practical lab - " + title, depth: 3)
  grid(
    columns: (0.4fr, 0.6fr),
    column-gutter: 1cm,
    align: horizon,
    [#image("lab-penguins.svg", width: 100%)],
    body
  )
}

#let setupdemoframe(title, body) = {
  heading("Demo - " + title, depth: 3)
  grid(
    columns: (0.4fr, 0.6fr),
    column-gutter: 1cm,
    align: horizon,
    [#image("lab-penguins.svg", width: 100%)],
    body
  )
}

// ── Documents (bootlin-doc, letter) ───────────────────────────────
#let bootlin-doc(
  title: [],
  author: (),
  date: [],
  doc
) = {
  show heading.where(level: 1): it => block(
    width: 100%,
    inset: (bottom: 0.5em),
    stroke: (bottom: 1pt + color-link),
    text(font: "DejaVu Sans", size: 1.2em, weight: "bold", fill: color-link)[#it]
  )
  set page(
    paper: "a4",
    margin: (top: 22mm, bottom: 16mm, left: 15mm, right: 15mm),
    header: context [
      #set text(8pt, font: "DejaVu Sans")
      #box(image("bootlin-logo.svg"), width: 38mm) #h(1fr) Embedded Linux and kernel engineering
      #line(length: 100%, stroke: 2pt + bootlin-orange)
    ],
    header-ascent: 2mm,
    footer: context [
      #set text(8pt, font: "DejaVu Sans")
      #line(length: 100%, stroke: 0.5pt)
      #v(-5pt)
      Bootlin SAS –
      #link("https://bootlin.com") – 9 avenue des Saules 69600 Oullins-Pierre-Bénite #if text.lang != "fr" [FRANCE] – +33 484 258 096\
      RCS Lyon No 483 248 399 – SIRET 48324839900105 – APE 6202A – TVA: FR87483248399 – Capital: 50 000 EUR
      #h(1fr)
      #counter(page).display("1/1", both: true)
    ],
    footer-descent: 2mm,
  )
  set document(title: title, author: author)
  set list(indent: 1em)
  set text(font: "DejaVu Sans")
  v(1cm)
  align(center)[
    #text(24pt)[#title]\
    #context {
      if text.lang == "fr" { author.join(", ", last: " et ") }
      else { author.join(", ", last: " and ") }
    }
    #text(14pt)[#date]
  ]
  v(1cm)
  set par(leading: 0.55em, justify: true)
  set text(12pt, font: "DejaVu Serif")
  doc
}

#let letter(
  recipient: recipient,
  subject: [],
  date: [],
  location: [],
  attachment: none,
  signature: none,
  doc,
) = {
  set text(12pt, font: "DejaVu Sans")
  set page(
    paper: "a4",
    margin: (top: 22mm, bottom: 16mm, left: 15mm, right: 15mm),
    header: context [
      #set text(8pt)
      #box(image("bootlin-logo.svg"), width: 38mm) #h(1fr) Embedded Linux and kernel engineering
      #line(length: 100%, stroke: 2pt + bootlin-orange)
    ],
    header-ascent: 2mm,
    footer: context [
      #set text(8pt)
      #line(length: 100%, stroke: 0.5pt)
      #v(-5pt)
      Bootlin SAS –
      #link("https://bootlin.com") – 9 avenue des Saules 69600 Oullins-Pierre-Bénite #if text.lang != "fr" [FRANCE] – +33 484 258 096\
      RCS Lyon No 483 248 399 – SIRET 48324839900105 – APE 6202A – TVA: FR87483248399 – Capital: 50 000 EUR
      #h(1fr)
      #counter(page).display("1/1", both: true)
    ],
    footer-descent: 2mm,
  )
  [
    Bootlin #h(1fr) #location, #date\
    9 avenue des Saules \
    69600 Oullins-Pierre-Bénite \
  ]
  context {
    if text.lang != "fr" [FRANCE]
  }
  link("mailto: administration@bootlin.com")[administration\@bootlin.com]
  place(top+left, dx: 90mm, dy: 26mm,
    box(width: 9cm, [#recipient.name \ #recipient.address])
  )
  place(top+left, dx: -15mm, dy: 78mm, float: true,
    line(length: 1cm, stroke: 0.5pt),
  )
  v(3.5cm)
  context {
    if text.lang == "fr" [*Objet : *] else [*Subject: *]
    [*#subject*]
  }
  v(0.7cm)
  set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)
  doc
  if signature != none { v(1cm); h(90mm); box(signature) }
  if attachment != none { [#v(1cm) P.J. : #attachment] }
}

// ── Thème Touying principal ────────────────────────────────────────
#let bootlin-theme(
  aspect-ratio: "16-9",
  header: self => utils.display-current-heading(depth: self.slide-level),
  ..args,
  body,
) = {
  set list(
    marker: (
      text(size: 1.5em, fill: bootlin-orange, stroke: bootlin-orange, [#v(-0.2em)‣]),
      text(size: 1em,   fill: bootlin-orange, stroke: bootlin-orange, [🞄]),
      text(size: 0.5em, fill: bootlin-orange, stroke: bootlin-orange, [#v(0.2em)■]),
    ),
    indent: 1em,
    spacing: 0.7em,
    tight: true,
    body-indent: 0.6em
  )
  set par(spacing: 0.5em)
  set par(leading: 0.5em)

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
        show raw.where(block: true): set block(fill: luma(240), inset: 1em, radius: 0.5em, width: 100%)
        show raw.where(lang: "c", block: true): set block(fill: luma(240), inset: 0.4em, radius: 0.5em, width: 95%, breakable: true, above: 12pt, below: 12pt)
        show raw.where(lang: "c", block: true): set text(11pt)
        show raw.where(lang: "console", block: true):set block(fill:luma(240), inset: 0.4em, radius: 0.5em, width: 95%, breakable: true, above: 6pt)
        show raw.where(lang:"console", block: true): set text(11pt)
        show list: it => {
          list-counter.step()
          context {
            set list(spacing: 0.4em) if list-counter.get().first() >= 1
            set par(leading: 0.5em) if list-counter.get().first() >= 1
            set list(spacing: 0.5em) if list-counter.get().first() >= 2
            set par(leading: 0.4em, spacing: 0.4em) if list-counter.get().first() >= 2
            block(above: if list-counter.get().first() == 2 { 0.7em } else { 1em }, it)
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
      neutral-lightest: rgb("#FFFFFF")
    ),
    config-store(
      header: header,
      footer: box(pad(top: 0.55em, image("bootlin-logo.svg", height: 1.3em))) + [ \- Kernel, drivers and embedded Linux - Development, consulting, training and support - #link("https://bootlin.com")],
      footer-right: context utils.slide-counter.display() + "/" + utils.last-slide-number,
    ),
    ..args,
  )
  body
}