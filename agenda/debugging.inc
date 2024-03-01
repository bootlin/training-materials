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

% Training objectives
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \traininggoals{
    \begin{itemize}
    \item Être capable de comprendre les principaux concepts de Linux
      qui sont liés à l'analyse de performance: processus, threads,
      gestion de la mémoire, mémoire virtuelle, contextes d'exécution,
      etc.
    \item Être capable d'analyser pourquoi un système est chargé et
      quels sont les éléments qui contribuent à cette charge avec les
      outils usuels d'observabilité sous Linux.
    \item Être capable de débugger une application espace utilisateur
      avec {\em gdb}, soit en direct soit {\em post-mortem} suite à un
      crash, et analyser le contenu de binaires ELF.
    \item Être capable d'utiliser le {\em tracing} et le {\em profiling}
      sur une application espace utilisateur et comprendre ses
      interactions avec le noyau Linux afin de corriger des bugs, en
      utilisant {\em strace}, {\em ltrace}, {\em perf} ou {\em
        Callgrind}
    \item Être capable d'utiliser le {\em tracing} et le {\em profiling}
      le système Linux complet, en utilisant {\em perf}, {\em ftrace},
      {\em kprobe}, les outils {\em eBPF}, {\em kernelshark} ou {\em
        LTTng}
    \item Être capable de débugger des problèmes au niveau du noyau
      Linux: debug de crash en direct ou post-mortem, analyse de
      problèmes mémoire au niveau noyau, analyse de problèmes de locks,
      utilisation de debuggers au niveau noyau.
    \end{itemize}
  }
}{
  \def \traininggoals{
    \begin{itemize}
      \vspace{-0.5cm}
    \item Be able to understand the main concepts of Linux that are
      relevant for performance analysis: process, threads, memory
      management, virtual memory, execution contexts, etc.
    \item Be able to analyze why a system is loaded and what are the
      elements that contributes to this load using common Linux
      observability tools.
    \item Be able to debug an userspace application using {\em gdb},
      either live or after a crash, and analyze the contents of ELF
      binaries.
    \item Be able to trace and profile a complete userspace application
      and its interactions with the Linux kernel in order to fix bugs
      using {\em strace}, {\em ltrace}, {\em perf} or {\em Callgrind}.
    \item Be able to understand classical memory issues and analyze them
      using {\em valgrind}, {\em libefence} or {\em Massif}.
    \item Be able to trace and profile the entire Linux system, using
      {\em perf}, {\em ftrace}, {\em kprobes}, {\em eBPF} tools, {\em
        kernelshark} or {\em LTTng}
    \item Be able to debug Linux kernel issues: debug kernel crashes
      live or post-mortem, analyze memory issues at the kernel level,
      analyze locking issues, use kernel-level debuggers.
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
    Sociétés et ingénieurs intéressés dans le debug, profiling et
    tracing de systèmes et d'applications Linux, afin d'analyser et
    résoudre des problèmes de performance ou de latence.
  }
}{
  \def \trainingaudience{
    Companies and engineers interested in debugging, profiling and
    tracing Linux systems and applications, to analyze and address
    performance or latency problems.
  }
}

% Time ratio
\def \onsitelecturetimeratio{40}
\def \onsitelabtimeratio{60}
