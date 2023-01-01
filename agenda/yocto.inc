\usepackage{ifthen}
\def \training{yocto}

% Title
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \trainingtitle{Formation développement Linux embarqué avec Yocto Project et OpenEmbedded}
}{
  \def \trainingtitle{Yocto Project and OpenEmbedded development training}
}

% Duration
\ifthenelse{\equal{\trainingtype}{online}}{
  \def \trainingduration{4}
}{
  \def \trainingduration{3}
}
