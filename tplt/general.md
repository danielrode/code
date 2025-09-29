---
title: Sample Title for This Wonderful Template
author: Daniel Rode
date: 1 January 2022
geometry: margin=1in
# mainfont: Comic Neue
fontsize: 12pt
header-includes:
    # Include packages
    # - \usepackage{graphicx}

    # (Variably) pad some url characters
    - \Urlmuskip=0mu plus 3mu\relax

    # Double space lines
    - \usepackage{setspace}
    - \doublespacing

    # Indent paragraphs
    - \setlength{\parindent}{0.5in}

    # Neutralize vspace between paragraphs
    - \setlength{\parskip}{0pt}

    # Prevent figures from floating
    - \usepackage{float}
    - \let\origfigure\figure
    - \let\endorigfigure\endfigure
    - \renewenvironment{figure}[1][2]{\expandafter\origfigure\expandafter[H]}{\endorigfigure}

    # Don't stretch inter-sentence spaces more
    # - \frenchspacing

    # Define "changemargin" to allow change of left and right margin
    # for sections of document.
    # Use example: to add 0.5 cm to the margins on either side...
    ## \begin{changemargin}{0.5cm}{0.5cm} 
    ## %your text here
    ## \end{changemargin}
    - \def\changemargin#1#2{\list{}{\rightmargin#2\leftmargin#1}\item[]}
    - \let\endchangemargin=\endlist

    # Bold "Figure N" part of figure caption
    - \usepackage[labelfont=bf]{caption}

    # Italicize figure caption and bold "Figure N" part
    # - \usepackage[labelfont={bf,it},textfont=it]{caption}

    # Use period instead of colon for figure caption
    - \usepackage[labelsep=period]{caption}

    # Place thin black border around images/figures
    - \usepackage[export]{adjustbox}
    - \let\includegraphicsbak\includegraphics
    - \renewcommand*{\includegraphics}[2][]{\includegraphicsbak[frame,#1]{#2}}

    # Define warning symbol (which can be inserted with `\dangersign`)
    # Example: `\dangersign[5ex]` inserts the symbol with at a larger size
    - \usepackage{stackengine}
    - \usepackage{scalerel}
    - \usepackage{xcolor}
    - \newcommand\dangersign[1][2ex]{\renewcommand\stacktype{L}\scaleto{\stackon[1.3pt]{\color{red}$\triangle$}{\tiny !}}{#1}}

    # Set 'fancy' page style to include my name in page header
    # (Activate by invoking `\pagestyle{fancy}`)
    - \usepackage{fancyhdr}
    - \fancyfoot{}
    - \lhead{Daniel Rode}
    - \rhead{\thepage}

    # Set second-level enumerate list items to also use bullet symbol
    - \usepackage{enumitem}
    - \setlist[itemize,2]{label=\bullet}

    # Hide page numbers
    # - \pagenumbering{gobble}

# META
# compile: `pandoc --pdf-engine=lualatex -o export.pdf THIS_FILE_PATH`
# preview: `~/code/bin/preview THIS_FILE_PATH`
# compile via preview: `cp --dereference ~/.cache/daniel_rode_code/preview-cache.link/latest ./export.pdf`
---


<!-- DOCUMENT HEADER: Class & assignment information -->
\vspace{-0.1cm}
\begin{center}
APA 101-001 | Dr. Apa Writer | Spring 2022
\end{center}
\vspace{1cm}


<!-- DOCUMENT BODY: Essay/article -->
You shall find of the king a husband, madam; you,
sir, a father: he that so generally is at all times
good must of necessity hold his virtue to you; whose
worthiness would stir it up where it wanted rather
than lack it where there is such abundance.

This young gentlewoman had a father,--O, that
'had'! how sad a passage 'tis!--whose skill was
almost as great as his honesty; had it stretched so
far, would have made nature immortal, and death
should have play for lack of work. Would, for the
king's sake, he were living! I think it would be
the death of the king's disease.

<!-- Math -->
Look, it's the $\mu$ symbol.

\setstretch{1.5}  <!-- requires `\usepackage{setspace}` in preamble -->
\vspace{-6pt}
$S^2_x = \frac{1}{n-1} \sum^n_{i=1}(X_i-\bar{X})^2$ \newline
$= \frac{1}{n-1} 6290.92$ \newline
$= \frac{1}{12-1} 6290.92$ \newline
$= \frac{1}{11} 6290.92$ \newline
$= 572$

\vspace{-6pt}
$r_{xy} = \frac{Cov(X,Y)}{S_x*S_y}$ \newline
$= \frac{-1935}{S_x*S_y}$ \newline
$= \frac{-1935}{\sqrt{S_x^2}*\sqrt{S_y^2}}$ \newline
$= \frac{-1935}{\sqrt{572}*\sqrt{25108}}$ \newline
$= -0.51$

\singlespacing

<!-- URLs -->
<http://googlegoogle.com/the-verylongwebsiteofearth&youc-not-stop-this=youyou-you>

<!-- Hyperlinks -->
[Link text Here](https://link-url-here.org)
\color{blue} \href{https://link-url-here.org}{Link text Here} \color{black}

<!-- Images -->
![This figure *is* of **stuff**.](./image-path.png){ width=2in margin=auto }
<!-- Note, images without a caption are not treated as figures, but rather as paragraphs (and thus do not center align automatically). -->

\begin{center} 
\includegraphics[width=2in]{./image-path.png}
\end{center}
<!-- Requires `\usepackage{graphicx}` -->

<!-- Color -->
\color{blue}
<https://www.google.com/>
\color{black}

<!-- Alignment -->
\begin{center}
Centered text.
\end{center}

<!-- Bold, italic, etc... -->
\textbf{Bold}
**Bold**

<!-- Footnotes -->
You are note.[^1]

[^1]: This footnote is a footnote.

<!-- Newline -->
Use the backslash character to insert a newline.

<!-- Table -->
| Col 1        | Col 2      |
| ------------ | ---------- |
| row 1        | stuff      |
| row number 2 | more stuff |

Table: Table caption, blah blah.

Or you can use LaTeX to import a CSV: 
https://tex.stackexchange.com/questions/146716/importing-csv-file-into-latex-as-a-table

<!-- Use figure as table -->
|   |   |   |
| - | - | - |

Table: Caption for table. Note, leave the above table shell intact (it will allow the table caption to be created without generating any table).

![](./path/to/figuer-that-is-table.svg)

# Section Title

Behold this new section.


<!-- DOCUMENT SOURCES: References section heading -->
\newpage
\begin{center}
\textbf{References}
\end{center}

<!-- Set hanging indent -->
\noindent
\setlength{\parindent}{-0.5in}
\setlength{\leftskip}{0.5in}

Change, C. (2007). Climate change impacts, adaptation and vulnerability.
*Science of the Total Environment, 326*(1-3), 95-112.

Temin, P., Jackson, A., & Államok, A. E. (1969).
*The Jacksonian Economy* (p. 69). New York: Norton.

<!-- Disable hanging indent -->
\setlength{\parindent}{0.5in}
\setlength{\leftskip}{0in}
