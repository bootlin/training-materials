\usepackage{ifthen}
\def \training{buildroot}

% Title
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \trainingtitle{Formation développemment Linux embarqué avec Buildroot}
}{
  \def \trainingtitle{Embedded Linux development with Buildroot training}
}

% Duration
\ifthenelse{\equal{\trainingtype}{online}}{
  \def \trainingduration{5}
}{
  \def \trainingduration{3}
}
