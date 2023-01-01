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

% Training objectives
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \traininggoals{
    \begin{itemize}
      \vspace{-0.5cm}
    \item Être capable de comprendre et de maîtriser les
      caractéristiques d'un système d'exploitation temps-réel
    \item Être capable de télécharger, compiler et utiliser le patch
      {\em PREEMPT\_RT}
    \item Être capable d'identifier et de benchmarker la plateforme
      matérielle en terme de caractéristiques temps-réel
    \item Être capable de configurer le noyau Linux pour un comportement
      déterministe
    \item Être capable de développer, de tracer et de débugger des
      applications user-space temps-réel.
      \vspace{-0.5cm}
    \end{itemize}
  }
}{
  \def \traininggoals{
    \begin{itemize}
      \vspace{-0.5cm}
    \item Be able to understand the characteristics of a real-time
      operating system
    \item Be able to download, build and use the {\em PREEMPT\_RT} patch
    \item Be able to identify and benchmark the hardware platform in
      terms of real-time characteristics
    \item Be able to configure the Linux kernel for deterministic
      behavior.
    \item Be able to develop, trace and debug real-time user-space Linux
      applications.
      \vspace{-0.5cm}
    \end{itemize}
  }
}

% Training prerequisites
\def \trainingprerequisites{
  \begin{itemize}
    \prerequisitecommandline
    \prerequisiteembeddedlinux
    \prerequisiteenglish
  \end{itemize}
}

% Training audience
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \trainingaudience{
    Entreprises et ingénieurs intéressés dans le développement et le
    benchmarking d'applications et de drivers temps-réel pour un
    système Linux embarqué.
  }
}{
  \def \trainingaudience{
    Companies and engineers interested in writing and benchmarking
    real-time applications and drivers on an embedded Linux system.
  }
}
