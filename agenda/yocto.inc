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

% Training objectives
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \traininggoals{
    \begin{itemize}
    \item Être capable de comprendre le rôle et le principe d'un build
      system Linux embarqué, et comparer Yocto Project/OpenEmbedded aux
      autres outils offrant des fonctionnalités similaires.
    \item Être capable de configurer et de réaliser la compilation d'un
      système Linux embarqué simple avec Yocto, et d'installer le
      résultat sur une plateforme embarquée.
    \item Être capable d'écrire ou d'étendre des recettes de paquets,
      pour vos propres paquets ou personnalisations.
    \item Être capable d'utiliser des {\em layers} de recettes
      existants, et de créer votre propre nouveau {\em layer}.
    \item Être capable d'intégrer le support pour votre carte embarqué
      dans un {\em layer BSP}.
    \item Être capable de créer des images personnalisées.
    \item Être capable d'utiliser le SDK du Yocto Project pour développer
      des applications.
    \item Être capable d'utiliser devtool pour développer une recette.
    \end{itemize}
  }
}{
  \def \traininggoals{
    \begin{itemize}
    \item Be able to understand the role and principle of an embedded
      Linux build system, and compare Yocto Project/OpenEmbedded to
      other tools offering similar functionality.
    \item Be able to configure and build basic embedded Linux system
      with Yocto, and install the result on an embedded platform.
    \item Be able to write and extend recipes, for your own packages or
      customizations.
    \item Be able to use existing layers of recipes, and create your own
      new layers.
    \item Be able to integrate support for your own embedded board into
      a BSP layer.
    \item Be able to create custom images.
    \item Be able to use the Yocto Project SDK to develop applications.
    \item Be able to use devtool to generate and modify recipes.
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
    Sociétés et ingénieurs intéressés par l'utilisation de Yocto
    Project pour construire leur système Linux embarqué.
  }
}{
  \def \trainingaudience{
    Companies and engineers interested in using the Yocto Project to
    build their embedded Linux system.
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
\def \onsitelecturetimeratio{40}
\def \onsitelabtimeratio{60}

% Ubuntu version
\def \ubuntuversion{22.04 / 20.04}
