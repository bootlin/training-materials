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

% Training objectives
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \traininggoals{
    \begin{itemize}
    \item Être capable de comprendre le principe d'un build system Linux
      embarqué, et comparer Buildroot aux autres outils offrant des
      fonctionnalités similaires.
    \item Être capable de créer un système Linux embarqué simple avec
      Buildroot: créer une configuration, lancer la compilation,
      installer le résultat sur une plateforme embarquée.
    \item Être capable d'ajuster la configuration de Buildroot pour
      construire un système Linux embarqué adapté à des besoins
      spécifiques: choix de la chaîne de compilation croisée, gestion de
      la configuration du noyau Linux, personnalisation du système de
      fichiers racine.
    \item Être capable de créer de nouveaux paquets dans Buildroot pour
      intégrer des applications et bibliothèques supplémentaires dans le
      système Linux embarqué.
    \item Être capable d'utiliser les outils proposés par Buildroot pour
      gérer et analyser le build: suivi des vulnérabilités, comformité
      aux licences open-source, etc.
    \item Être capable de développer et débugger des applications
      user-space Linux dans un contexte où Buildroot est utilisé.
    \item Être capable d'interagir avec la communauté open-source du
      projet Buildroot et de comprendre le fonctionnement interne de
      Buildroot.
    \end{itemize}
  }
}{
  \def \traininggoals{
    \begin{itemize}
    \item Be able to understand the role and principle of an embedded
      Linux build system, and compare Buildroot to other tools offering
      similar functionality.
    \item Be able to create a simple embedded Linux system with
      Buildroot: create a configuration, run the build, install the
      result on an embedded platform.
    \item Be able to adjust the Buildroot configuration to build an
      embedded Linux system tailored to specific needs: choice of the
      cross-compilation toolchain, management of the Linux kernel
      configuration, customization of the root filesystem contents, etc.
    \item Be able to create new packages in Buildroot to integrate
      additional applications and libraries into the embedded Linux
      system.
    \item Be able to use the tools offered by Buildroot to manage and
      analyze the build: security vulnerability tracking, license
      compliance, etc.
    \item Be able to develop and debug Linux user-space applications in
      the context of Buildroot.
    \item Be able to interact with the Buildroot open-source community,
      and to understand the internals of Buildroot.
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
    Sociétés qui utilisent déjà Buildroot ou qui sont intéressées par
    l'utiliser pour construire leurs systèmes Linux embarqué.
  }
}{
  \def \trainingaudience{
    Companies already using or interested in using
    Buildroot to build their embedded Linux systems.
  }
}

% Time ratio
\def \onsitelecturetimeratio{40}
\def \onsitelabtimeratio{60}
