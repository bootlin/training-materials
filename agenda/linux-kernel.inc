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

% Training objectives
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \traininggoals{
    \begin{itemize}
    \item Être capable de configurer, compiler et installer le noyau
      Linux sur un système embarqué.
    \item Être capable de comprendre l'architecture générale du noyau
      Linux, et comment les applications user-space Linux interagissent
      avec le noyau Linux.
    \item Être capable de développer des pilotes de périphériques
      simples mais complets dans le noyau Linux, au travers du
      développement à partir de zéro de deux drivers, pour deux
      périphériques différents, qui illustrent les principaux concepts
      de la formation.
    \item Être capable de naviguer dans les différents mécanismes du
      noyau Linux pour les pilotes de périphériques: Device Tree, device
      model, infrastructures de bus.
    \item Être capable de développer des pilotes de périphériques qui
      communiquent avec des périphériques matériels.
    \item Être capable de développer des pilotes de périphériques qui
      exposent les fonctionnalités du matériel aux applications Linux
      user-space: périphériques caractères, sous-systèmes du noyau Linux
      pour les périphériques.
    \item Être capable d'utiliser les principaux mécanismes du noyau
      Linux pour le développement de pilotes de périphériques: gestion
      mémoire, verrouillage, gestion des interruptions, mise en sommeil
      et réveil de threads, DMA.
    \item Être capable de débugger des problèmes dans le noyau Linux, en
      utilisant différents outils et mécanismes de debug.
    \end{itemize}
  }
}{
  \def \traininggoals{
    \begin{itemize}
    \item Be able to configure, build and install the Linux kernel on an
      embedded system.
    \item Be able to understand the overall architecture of the Linux
      kernel, and how user-space applications interact with the Linux
      kernel.
    \item Be able to develop simple but complete Linux kernel device
      drivers, thanks to the development from scratch of two drivers for
      two different hardware devices, that illustrate all the major
      concepts of the course.
    \item Be able to navigate through the device drivers mechanisms of
      the Linux kernel: Device Tree, device model, bus infrastructures.
    \item Be able to develop device drivers that communicate with
      hardware devices.
    \item Be able to develop drivers that expose functionality of
      hardware devices to Linux user-space applications: character
      devices, kernel subsystems.
    \item Be able to use the major kernel mechanisms needed for device
      driver development: memory management, locking, interrupt
      handling, sleeping, DMA.
    \item Be able to debug Linux kernel issues, using a variety of
      debugging techniques and mechanisms.
    \end{itemize}
  }
}

% Training prerequisites
\def \trainingprerequisites{
  \begin{itemize}
    \prerequisiteclanguage
    \prerequisitecommandline
    \prerequisiteembeddedlinux
    \prerequisiteenglish
  \end{itemize}
}

% Training audience
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \trainingaudience{
    Ingénieurs développant des systèmes reposant sur le noyau Linux.
    \newline Ingénieurs supportant des développeurs Linux embarqué.
  }
}{
  \def \trainingaudience{
    People developing devices using the Linux kernel
    \newline People supporting embedded Linux system developers.
  }
}

% Time ratio
\def \onsitelecturetimeratio{50}
\def \onsitelabtimeratio{50}
