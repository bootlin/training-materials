\usepackage{ifthen}
\def \training{debugging}

% Title
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \trainingtitle{Formation debugging, profiling, tracing et analyse de performance sous Linux}
}{
  \def \trainingtitle{Linux debugging, profiling, tracing and performance analysis training}
}

% Duration
\ifthenelse{\equal{\trainingtype}{online}}{
  \def \trainingduration{4}
}{
  \def \trainingduration{3}
}
