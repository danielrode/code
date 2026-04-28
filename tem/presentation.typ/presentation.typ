
// CONFIG
#set page(paper: "presentation-16-9")
#set text(
  font: "Liberation Sans",
  // font: "DejaVu Sans",
  size: 24pt, // Default body font size
)

// Set new headings to trigger a pagebreak
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  it
}

// Style in-text citations as superscript
#show cite: it => {
  show "[": none
  show "]": none
  super(it)
}


// DEFINITIONS
#let title_page(title, author, date) = {
  align(center + horizon)[
    #text(size: 36pt, weight: "bold")[#title]
    #v(1em)
    #text(size: 24pt)[#author]
    #v(1em)
    #text(size: 24pt)[#date]
    #pagebreak()
  ]
}

#let two_panes(col1, col2, col1_w: 1fr, col2_w: 1fr) = {
  grid(
    columns: (col1_w, col2_w),  // Column widths
    column-gutter: 2em,  // Space between columns
    col1, col2,
  )
}


// DOCUMENT
#title_page(
  [Using GIS to Reveal Hidden Mutualisms in Nature: Mycorrhizal Networks],
  [Daniel Rode],
  [27 Apr 2026],
)

= Introduction <intro>

#two_panes[
  - Consumer-Resource Interactions: Essentially resource economics
  - Trophic Control: Top-down vs bottom-up
][
  - These topics matter because without them, populations would grow infinitely
  - Ecological interventions often require determining the trophic control of a given community
]
)

= The Papers

- The Origins and Evolution of Predator-Prey Theory (Berryman, 1992)
- Recovery of a Marine Keystone Predator Transforms Terrestrial Predator-Prey Dynamics (Roffler et al., 2023)
- Graphical Representation and Stability Conditions of Predator-Prey Interactions (Rosenzweig & MacArthur, 1963)

= Berryman 1992

_The Origins and Evolution of Predator-Prey Theory_

- How does prey food supply fit into the density-dependent model?
- Is Berryman's argument for disregarding laws of conservation valid?
- How do Barryman's equations bridge the gap between short- and long-term variables?

= Rosenzweig 1963

_Graphical Representation and Stability Conditions of Predator-Prey Interactions_

- What are some examples of introducing prey refuges to stabilize a community?
- Why does a prey evolving stabilize predator-prey population dynamics while the predator evolving promotes instability?
- How does population birth-rate acceleration relate to stability?
- What conditions cause these graphs to be asymptotic vs oscillatory?

= Rosenzweig 1963 - Bonus Question

#grid(
  columns: (0.6fr, 0.4fr),
  column-gutter: 2em,
  image("./import/example.png"),
  [
    - Given technological advances, how might population dynamics between four interacting species be visualized?
  ],
)

= Roffler 2023

_Recovery of a Marine Keystone Predator Transforms Terrestrial Predator-Prey Dynamics_

- Wolves can swim?!!
- Why didn't sea otters becoming the wolves' new primary food source help the deer population bounce back?
- Might wolves preying on marine life be a historical behavior historical?
- Why did the wolves wipe out their food source (deer), while the sea otters did not wipe out theirs?


// CITATIONS
#bibliography("citations.bib")



// todo see /home/daniel/union/edu/E.../assignments/05-ignite-presentation/presentation.typ
