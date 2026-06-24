#let INDENT = 1.4em

/// Manual override for indent (see https://github.com/typst/typst/issues/3206)
#let indent = h(INDENT)

#let csl_bib = ```xml
<?xml version="1.0" encoding="utf-8"?>
<style xmlns="http://purl.org/net/xbiblio/csl"
       class="in-text"
       version="1.0">

  <info>
    <title>Alphanumeric Full Names</title>
    <id>http://typst.org/csl/alphanumeric-fullnames</id>
    <category citation-format="label"/>
  </info>

  <citation collapse="citation-number"
            after-collapse-delimiter="; "
            disambiguate-add-year-suffix="true">
    <sort>
      <key variable="author"/>
      <key variable="issued"/>
    </sort>

    <layout prefix="[" suffix="]" delimiter=", ">
      <group delimiter=", ">
        <group>
          <text variable="citation-label"/>
          <text variable="year-suffix"/>
        </group>
        <text variable="locator"/>
      </group>
    </layout>
  </citation>

  <bibliography second-field-align="flush">
    <sort>
      <key variable="author"/>
      <key variable="issued"/>
    </sort>

    <layout>
      <group>
        <text variable="citation-label" prefix="[" suffix="]"/>
        <text variable="year-suffix"/>
      </group>

      <group delimiter=", " suffix=".">
        <names variable="author">
          <name and="text"
                delimiter=", "
                initialize="false"/>
        </names>

        <text variable="title" quotes="true" font-weight="bold"/>

        <text variable="container-title" font-style="italic"/>

        <group delimiter=" ">
          <text variable="volume" prefix="vol. "/>
          <text variable="issue" prefix="no. "/>
        </group>

        <text variable="page" prefix="pp. "/>

        <date variable="issued">
          <date-part name="year"/>
        </date>
      </group>

      <text variable="URL" prefix=" [Online]. Available: "/>
    </layout>
  </bibliography>

</style>```.text

#let book(
  title: none,
  author: none,
  footer: none,
  subtitle: none,
  subsubtitle: none,
  subsubsubtitle: none,
  epigraph: none,
  title-page-fct: none,
  body,
) = {
  // set text(font: "New Computer Modern", size: 10.5pt)
  set text(
    font: "STIX Two Text",
    weight: 350,
    size: 10pt,
    features: ("liga",),
  )

  show math.equation: set text(
    font: "STIX Two Math",
    features: ("cv04", "ss16"),
  )
  set par(first-line-indent: 0pt, justify: false, spacing: 0.55em + 1pt, leading: 0.5em + 1pt)
  set enum(indent: INDENT, numbering: "1.")
  set terms(hanging-indent: INDENT)

  set cite(style: "alphanumeric")
  set bibliography(style: bytes(csl_bib))

  show cite: it => text(fill: blue, it)

  // break block equations; don't break inline eqs
  show math.equation: set block(breakable: true)
  show math.equation.where(block: false): it => box(it)

  // offset the numbering by one because single star could be ambiguous in math, maybe
  set footnote(numbering: n => numbering("*", n + 1))

  set math.equation(numbering: "(1)")
  show math.equation: it => {
    // https://forum.typst.app/t/how-to-conditionally-enable-equation-numbering-for-labeled-equations/977
    if it.block and not it.has("label") [
      #counter(math.equation).update(v => v - 1)
      // since v0.14.0, https://typst.app/docs/changelog/0.14.0/
      // we can't just set #label("") anymore
      #math.equation(it.body, block: true, numbering: none)#label("___NOLABEL")
    ] else {
      it
    }
  }
  // show equation references as (1)
  // https://typst.app/docs/reference/model/ref/
  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      link(el.location(), numbering(el.numbering, ..counter(eq).at(el.location())))
    } else {
      it
    }
  }
  show math.qed: "▮"

  show link: it => {
    if type(it.dest) != str {
      // local link
      it
    } else if (it.body == [#it.dest]) {
      // URL (no custom text)
      set text(fill: blue)
      set text(font: "DejaVu Sans Mono", size: 0.8em)
      box(it)
    } else {
      // URL (custom text)
      set text(fill: blue)
      show text: underline
      box(it)
    }
  }

  set heading(numbering: "1.1.1a")

  let heading-func = (body-fmt: strong, use-line: false, it) => {
    block(
      sticky: true,
      (
        emph(text(size: 0.8em, counter(heading).display()))
          + "."
          + h(0.5em)
          + body-fmt(it.body)
          + if use-line {
            box(width: 1fr, align(right, line(length: 100% - 0.8em, start: (0%, -0.225em), stroke: (
              paint: black,
              cap: "round",
            ))))
          }
      ),
    )
  }

  show heading.where(level: 2): heading-func.with(body-fmt: emph, use-line: true)
  show heading.where(level: 2): set text(size: 1.1em)
  show heading.where(level: 2): it => {
    set block(above: 0em, below: 0em)
    v(2em, weak: true) + it + v(1em, weak: true)
  }

  show heading.where(level: 3): heading-func
  show heading.where(level: 3): it => {
    set block(above: 0em, below: 0em)
    v(1.25em, weak: true) + it + v(0.75em, weak: true)
  }

  show heading.where(level: 4): heading-func

  show heading.where(level: 1): set heading(supplement: [Chapter])
  show heading.where(level: 1): it => {
    set par(first-line-indent: 0.0em)
    counter(footnote).update(0)
    counter("moussethm-thmlike").update(0)
    counter("moussethm-example").update(0)
    counter(figure.where(kind: table)).update(0)
    align(center, {
      [
        #text(weight: 400, size: 0.8em)[#counter(heading).display().] #text(weight: 400, size: 2em, smallcaps(it.body))
      ]
    })
  }
  show enum: it => { v(0.9em, weak: true) + it + v(0.9em, weak: true) }

  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(gap: 1em)
  show figure.where(kind: table): it => { v(1.5em, weak: true) + it + v(2em, weak: true) }

  body
}


#let small(content) = {
  set text(
    font: "STIX Two Math",
    features: ("ss05", "ss06", "ss07"),
  )
  content
}

#let scr(it) = text(
  stylistic-set: 1,
  $cal(it)$,
)

#let italic-round(content) = {
  set text(
    font: "STIX Two Math",
    features: ("ss02",),
  )
  content
}


/// Theorem environment. Optionally can have a name, like "Rolle's" theorem.
#let thm-env(kind, fmt: it => it, body-fmt: it => it, numbered: true, counter-type: "thmlike") = {
  return (body, name: none, id: none, breakable: true) => {
    let ctr = counter("moussethm-" + counter-type)
    if numbered {
      ctr.step()
    }
    show figure: set align(start)
    show figure: it => it.body

    // un-italicize numbering in theorems
    set enum(numbering: (..nums) => {
      let content = numbering("(1)", ..nums)
      if body-fmt == emph {
        emph(content)
      } else {
        content
      }
    })

    v(weak: true, 1.5em)
    [
      #block(width: 100%, breakable: breakable, above: 0em, below: 0em, [
        #figure(
          kind: kind,
          supplement: kind,
          numbering: (..levels) => [#counter(heading).get().at(0).#ctr.display()],
          {
            let number = context [ #counter(heading).get().at(0).#ctr.display()]
            (fmt[#kind#if numbered { number }] + if name != none [ *(#name)*] + fmt[.] + h(0.1em) + body-fmt(body))
          },
        )#if id != none { label(id) }
      ])
    ]
    v(weak: true, 1.5em)
  }
}

#let fmt-line(content) = table(
  columns: (1pt, 1fr),
  stroke: none,
  table.vline(x: 0, stroke: 0.5pt + grey),
  [
    #h(1pt) // Space between line and text
  ],
  content,
)

#let fmt-proof(content) = block(
  breakable: true,
  above: 0.44em,
  below: 0.1em,
  inset: (left: 0.55em, right: 0pt, top: 0.12em, bottom: 0pt),
  stroke: (left: 0.6pt + gray),
)[
  #content
]

#let smallcaps-strong = it => {
  smallcaps(strong(it))
}

#let body-fmt(it) = [
  #emph(it)
]

#let theorem = thm-env("Theorem", fmt: smallcaps-strong, body-fmt: emph)
#let proposition = thm-env("Proposition", fmt: smallcaps-strong, body-fmt: emph)
#let lemma = thm-env("Lemma", fmt: smallcaps-strong, body-fmt: emph)
#let corollary = thm-env("Corollary", fmt: smallcaps-strong, body-fmt: emph)
#let definition = thm-env("Definition", fmt: smallcaps-strong, body-fmt: body-fmt)
#let solution = thm-env("Solution", fmt: emph, numbered: false)
#let proof = thm-env("Proof", fmt: emph, numbered: false, body-fmt: fmt-proof)
#let example = thm-env("Example", fmt: it => strong(emph(it)), counter-type: "example", body-fmt: fmt-proof)
#let remark = thm-env("Remark", fmt: it => strong(emph(it)), numbered: false, body-fmt: fmt-proof)

/// Quick macro to "glue" text to the next element.
//
// Use this on text before a math block so that the text doesn't get separated from it.
// Set `indent: false` when this is the first element after a heading.
#let glue(indent: true, body) = {
  block(sticky: true, (if indent { h(INDENT) }) + body)
}

/// Custom table function.
#let tablef(..args) = {
  set table.hline(stroke: 0.5pt)
  table(
    align: left,
    stroke: (x, y) => {
      if (y == 0) {
        (
          top: 1pt,
          bottom: 0.5pt,
        )
      }
    },
    ..args.named(),
    ..(args.pos() + (table.hline(stroke: 1pt),)),
  )
}
