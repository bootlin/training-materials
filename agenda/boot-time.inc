\usepackage{ifthen}
\def \training{boot-time}

% Title
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \trainingtitle{Formation optimisation du temps de démarrage de Linux embarqué}
}{
  \def \trainingtitle{Embedded Linux boot time optimization training}
}

% Duration
\ifthenelse{\equal{\trainingtype}{online}}{
  \def \trainingduration{4}
}{
  \def \trainingduration{3}
}
