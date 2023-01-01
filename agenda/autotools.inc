\usepackage{ifthen}
\def \training{autotools}

% Title
\def \trainingtitle{Autotools training}

% Duration
\ifthenelse{\equal{\trainingtype}{online}}{
  \def \trainingduration{2}
}{
  \def \trainingduration{1}
}
