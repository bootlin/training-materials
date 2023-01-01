\usepackage{ifthen}
\def \training{embedded-linux}

% Title
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \trainingtitle{Formation développement de systèmes Linux embarqué}
}{
  \def \trainingtitle{Embedded Linux system development training}
}

% Duration
\ifthenelse{\equal{\trainingtype}{online}}{
  \def \trainingduration{7}
}{
  \def \trainingduration{5}
}
