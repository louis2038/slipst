#import "../dist/lib.typ": *
#import "@preview/cetz:0.5.2"

#show: slipst

= Test CeTZ with alter override

#pause

#alter(3)

#context {
  let a = get-alter()
  let only = uncover.with(cover: body => { cetz.draw.hide(body) }, alter: a)
  align(center, cetz.canvas({
    import cetz.draw: *

    scope({
      set-style(content: (frame: "rect", padding: 5pt, fill: white))
      content((1, 0), [Alice], name: "alice")
      content((5, 0), [Bob], name: "bob")
    })

    scope({
      set-style(content: (frame: "circle", padding: 5pt, fill: white))
      content((0, -3), $a$, name: "a")
      content((2, -3), $a'$, name: "a'")
      content((4, -3), $b$, name: "b")
      content((6, -3), $b'$, name: "b'")
    })

    content((0, -4), $0$, name: "r_a")
    content((2, -4), $1$, name: "r_a'")
    content((4, -4), $1$, name: "r_b")
    content((6, -4), $1$, name: "r_b'")

    set-style(line: (mark: (end: ">")))
    line("a", "r_a")
    line("a'", "r_a'")
    line("b", "r_b")
    line("b'", "r_b'")

    only("1", line("alice", "a"))
    only("2", line("alice", "a'"))
    only("3", line("bob", "b"))
  }))
}

#pause#up(here)

And in CeTZ/fletcher diagrams. You need to customize the `cover` parameter of `#uncover` to work with diagrams. The `cover` parameter is a function that is used to cover the content that is not shown.
For technical reasons, you also need to set `raw: true` and wrap the diagram with `context` to make it work.

```typ
#let only = uncover.with(cover: fletcher.hide, raw: true)
#context diagram(
  node((0, 0), $⊢ A ∧ (B => C)$),
  only("2-", node((-0.6, 0.7), $⊢ A$)),
  // ...
)
```

#alter(3)
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#let only = uncover.with(cover: fletcher.hide, raw: true)
#context align(center, diagram(
  node-stroke: 0.5pt,
  node-corner-radius: 3pt,
  node-fill: oklch(95%, 0.02, 286deg),
  node((0, 0), $⊢ A ∧ (B => C)$),
  only("2-", edge("-|>")),
  only("2-", node((-0.6, 0.7), $⊢ A$)),
  only("2-", edge((0, 0), (0.6, 0.7), "-|>")),
  only("2-", node((0.6, 0.7), $A ⊢ B => C$)),
  only("3", edge("-|>")),
  only("3-", node((0.6, 1.5), $A, B ⊢ C$)),
))

= Done
