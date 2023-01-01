\usepackage{ifthen}
\def \training{kernel}

% Title
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \trainingtitle{Formation développement noyau et pilotes Linux}
}{
  \def \trainingtitle{Embedded Linux kernel and driver development training}
}

% Duration
\ifthenelse{\equal{\trainingtype}{online}}{
  \def \trainingduration{7}
}{
  \def \trainingduration{5}
}
