// author: Daniel Rode
// created: 11 mar 2026
// updated: -


// CONFIG & STYLE
#set page("us-letter")

// #set text(font: "New Computer Modern", size: 12pt)
#set text(font: "FreeSerif", size: 12pt)
// #show raw: set text(font: "New Computer Modern Mono")

#set table(stroke: 0.5pt + black)  // Give table cells black borders
#set heading(numbering: "1.")  // Number sections

#show figure.caption: set align(left)  // Left-align fig/table captions
#show figure.where(kind: table): set figure.caption(position: top)

// #set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)
// #show par: set block(spacing: 0.55em)
// #show heading: set block(above: 1.4em, below: 1em)


// TITLE PAGE
#let doc_title = "Document Title"
#{
  set page(numbering: {})  // Temporarily disable page numbering
  set document(  // Sets PDF metadata
    title: [#doc_title],
    author: (
      "Daniel Rode", "Jane Doe",
    ),
    keywords: ("document", "science", "math"),
    date: auto,
  )
  set align(horizon + left)
  text(24pt)[
    #doc_title
  ]
  v(2%)
  [
    Daniel Rode, Jane Doe
  ]
  v(1%)
  [
    Colorado State University
  ]
  v(1%)
  datetime.today().display()
  pagebreak()
}


// TABLES OF CONTENTS
#set page(numbering: "1")
#{
  counter(page).update(1)

  // Sections
  outline()  

  // Figures
  outline(title: "List of Figures", target: figure.where(kind: image))

  // Tables
  outline(title: "List of Tables", target: figure.where(kind: table))

  pagebreak()
}


// DOCUMENT BODY
= Section Title
<section1>

Hello world??

Bob said the world is flat @Knuth1997

#lorem(900)


// CITATIONS
#pagebreak()
#bibliography("./citations.bib", title: "References", style: "apa")

