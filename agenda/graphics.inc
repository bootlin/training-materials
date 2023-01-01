\usepackage{ifthen}
\def \training{graphics}

% Title
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \trainingtitle{Formation Comprendre la stack graphique sous Linux}
}{
  \def \trainingtitle{Understanding the Linux Graphics Stack training}
}

% Duration
\ifthenelse{\equal{\trainingtype}{online}}{
  \def \trainingduration{4}
}{
  \def \trainingduration{2}
}
