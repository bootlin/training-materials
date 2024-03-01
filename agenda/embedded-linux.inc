\usepackage{ifthen}
\def \training{embedded-linux}

% Title
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \trainingtitle{Formation développement de systèmes Linux embarqué}
}{
  \def \trainingtitle{Embedded Linux system development training}
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
      \vspace{-0.5cm}
    \item Être capable d'appréhender l'architecture générale d'un
      système Linux embarqué.
    \item Être capable de sélectionner, construire, mettre en oeuvre et
      utiliser une chaîne de compilation croisée.
    \item Être capable de comprendre la séquence d'un démarrage d'un
      système Linux embarqué et de mettre en oeuvre et d'utiliser le
      chargeur de démarrage U-Boot.
    \item Être capable de sélectionner une version du noyau Linux, de
      configurer, de compiler et d'installer le noyau Linux sur un
      système embarqué.
    \item Être capable de créer à partir de zéro un système de fichiers
      racine Linux, en comprenant les différents éléments qui le
      composent: répertoires, applications, bibliothèques, fichiers de
      configuration.
    \item Être capable de choisir et de mettre en oeuvre les principaux
      systèmes de fichiers Linux pour périphérique de stockage en mode
      bloc et flash, et de connaître leurs principales caractéristiques.
    \item Être capable d'interagir avec les périphériques matériels, de
      configurer le noyau avec les pilotes de périphériques nécessaires
      et d'étendre le {\em Device Tree}
    \item Être capable de sélectionner, de cross-compiler et d'intégrer
      des composants logiciels open-source (bibliothèques, applications)
      dans un système Linux embarqué, et de traiter la mise en
      conformité avec les licences open-source.
    \item Être capable de mettre en oeuvre un système de build Linux
      embarqué, pour construire un système complet pour une plateforme
      embarquée.
    \item Être capable de développer et débugger des applications sur un
      système Linux embarqué.
      \vspace{-0.5cm}
    \end{itemize}
  }
}{
  \def \traininggoals{
    \begin{itemize}
      \vspace{-0.5cm}
    \item Be able to understand the overall architecture of Embedded
      Linux systems.
    \item Be able to choose, build, setup and use a cross-compilation
      toolchain.
    \item Be able to understand the booting sequence of an embedded
      Linux system, and to set up and use the U-Boot bootloader.
    \item Be able to select a Linux kernel version, to configure, build
      and install the Linux kernel on an embedded system.
    \item Be able to create from scratch a Linux root filesystem,
      including all its elements: directories, applications,
      configuration files, libraries.
    \item Be able to choose and setup the main Linux filesystems for
      block and flash storage devices, and understand their main
      characteristics.
    \item Be able to interact with hardware devices, configure the
      kernel with appropriate drivers and extend the {\em Device Tree}
    \item Be able to select, cross-compile and integrate open-source
      software components (libraries, applications) in an Embedded Linux
      system, and to handle license compliance.
    \item Be able to setup and use an embedded Linux build system, to
      build a complete system for an embedded platform.
    \item Be able to develop and debug applications on an embedded Linux
      system.
      \vspace{-0.5cm}
    \end{itemize}
  }
}

% Training prerequisites
\def \trainingprerequisites{
  \begin{itemize}
    \prerequisitecommandline
    \prerequisiteenglish
  \end{itemize}
}

% Training audience
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \trainingaudience{
    Ingénieurs développant des systèmes embarqués
    reposant sur Linux et des composants open-source.
  }
}{
  \def \trainingaudience{
    People developing devices using the Linux kernel
    \newline People supporting embedded Linux system developers.
  }
}

\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \traininglanguages{
    Présentations : Français
    \newline Supports : Anglais
  }
}{
  \def \traininglanguages{
    Oral lectures: English, French, Italian.
    \newline Materials: English.
  }
}

% Time ratio
\def \onsitelecturetimeratio{50}
\def \onsitelabtimeratio{50}
