\usepackage{ifthen}
\def \training{preempt-rt}

% Title
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \trainingtitle{Formation temps-réel sous Linux avec {\em PREEMPT\_RT}}
}{
  \def \trainingtitle{Real-Time Linux with {\em PREEMPT\_RT} training}
}

% Duration
\ifthenelse{\equal{\trainingtype}{online}}{
  \def \trainingduration{3}
}{
  \def \trainingduration{2}
}
