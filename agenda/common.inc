\newcommand\defagendaitem[6]{
  \ifthenelse{\equal{\agendalanguage}{french}}{
    \expandafter\def\csname #1@#2@title\endcsname {#5}
    \expandafter\def\csname #1@#2@contents\endcsname {#6}
  }{
    \expandafter\def\csname #1@#2@title\endcsname {#3}
    \expandafter\def\csname #1@#2@contents\endcsname {#4}
  }
}

\newcommand\showagendaitem[2]{
  \feagendaonecolumn{
    \ifthenelse{\equal{\agendalanguage}{french}}{
      \ifthenelse{\equal{#2}{lecture}}
      {Cours -}
      {
        \ifthenelse{\equal{#2}{lab}}{
          \ifthenelse{\equal{\trainingtype}{online}}{Démo -}{TP -}
        }
        {}
      }
    }{
      \ifthenelse{\equal{#2}{lecture}}
      {Lecture -}
      {
        \ifthenelse{\equal{#2}{lab}}{
          \ifthenelse{\equal{\trainingtype}{online}}{Demo -}{Lab -}
        }
        {}
      }
    }
    \csname #1@#2@title\endcsname
  }{
    \csname #1@#2@contents\endcsname
  }
}

\newcommand\defboard[6]{
  \ifthenelse{\equal{\agendalanguage}{french}}{
    \expandafter\def\csname #1@title\endcsname {#4}
    \expandafter\def\csname #1@contents\endcsname {#5}
  }{
    \expandafter\def\csname #1@title\endcsname {#2}
    \expandafter\def\csname #1@contents\endcsname {#3}
  }
  \expandafter\def\csname #1@image\endcsname {#6}
}

\newcommand\showboarditem[1]{
  \feagendatwocolumn{
    \csname #1@title\endcsname
  }{
    \csname #1@contents\endcsname
  }
  {}
  {
    \csname #1@image\endcsname
  }
}

\newcommand\showagendaday[1]{
  \ifthenelse{\equal{\trainingtype}{online}}{
    \showonlineagendaday{#1}
  }{
    \pgfmathparse{int(mod(#1, 2))}
    \ifnum\pgfmathresult=1
      \pgfmathparse{int((#1 + 1) / 2)}
      \showonsiteagendaday{\pgfmathresult}{morning}
    \else
      \pgfmathparse{int(#1 / 2)}
      \showonsiteagendaday{\pgfmathresult}{afternoon}
    \fi
  }
}


\newcommand\showonlineagendaday[1]{
  \ifthenelse{\equal{\agendalanguage}{french}}{
    \section{#1 demi-journée}
  }{
    \section{Half day #1}
  }
}

\newcommand\showonsiteagendaday[2]{
  \ifthenelse{\equal{\agendalanguage}{french}}{
    \ifthenelse{\equal{#2}{morning}}{
      \section{Jour #1 - Matin}
    }{
      \section{Jour #1 - Après-midi}
    }
  }{
    \ifthenelse{\equal{#2}{morning}}{
      \section{Day #1 - Morning}
    }{
      \section{Day #1 - Afternoon}
    }
  }
}
