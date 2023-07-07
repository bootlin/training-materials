\usepackage{ifthen}
\def \training{audio}

% Title
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \trainingtitle{Formation Comprendre la stack audio sous Linux embarqué}
}{
  \def \trainingtitle{Audio with embedded Linux training}
}

% Duration
\ifthenelse{\equal{\trainingtype}{online}}{
  \def \trainingduration{4}
}{
  \def \trainingduration{2}
}

% Training objectives
\ifthenelse{\equal{\agendalanguage}{french}}{
  \def \traininggoals{
    \begin{itemize}
    \item Être capable de comprendre les bases de la théorie audio:
      analogique vs. numérique, échantillonage, formats audio,
      composants matériels audio
    \item Être capable de comprendre l'architecture de ASoC, le
      sous-système du noyau Linux pour les périphériques audio des
      systèmes embarqués, le rôle des différents drivers et la
      représentation Device Tree correspondante
    \item Être capable d'écrire un Device Tree décrivant la topologie
      des composants matériels audio dans un système Linux embarqué
    \item Être capable d'utiliser des possibilités de routage audio
      avancées, la gestion de l'énergie audio et des composants audio
      complexes tels que les périphériques auxilliaires et les
      amplificateurs
    \item Être capable de configurer les composants ALSA en espace
      utilisateur et les widgets ALSA
    \item Être capable de mettre en oeuvre les différentes APIs en
      espace utilisateur pour la lecture et l'enregistrement audio,
      ainsi que le serveur audio PipeWire et le framework multimedia
      GStreamer
    \end{itemize}
  }
}{
  \def \traininggoals{
    \begin{itemize}
    \item Be able to understand the basics of audio theory: analog
      vs. digital, sampling theory, audio formats and audio hardware
    \item Be able to understand the architecture of ASoC, the Linux
      kernel subsystem for audio devices used in embedded systems, the
      role of the different drivers and the Device Tree representation
    \item Be able to write a Device Tree describing the topology of
      audio hardware on an embedded Linux system
    \item Be able to use complex audio routing capabilities, audio power
      management capabilities, and complex audio components such as
      auxiliary devices or amplifiers
    \item Be able to configure the ALSA user-space components and
      ALSA audio widgets
    \item Be able to use the available user-space APIs for playing and
    capturing audio, as well as the PipeWire audio server and the
    GStreamer multimedia pipeline library
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
    Ingénieurs qui ont besoin d'une compréhension en détail des
    concepts audio, des composants matériels utilisés pour l'audio
    dans les systèmes embarqués et du fonctionnement de la stack audio
    sous Linux.
  }
}{
  \def \trainingaudience{
    Engineers who need a detailed level of understanding of audio
    concepts, audio hardware components used in typical embedded
    systems and how the audio stack works in Linux.
  }
}

% Required equipment on-site
\ifthenelse{\equal{\trainingtype}{onsite}}{
  \ifthenelse{\equal{\agendalanguage}{french}}{
    \def \requiredequipment {
      {\bf Pour les sessions en présentiel dans les locaux de nos clients,
        notre client doit fournir}:
      \begin{itemize}
      \item Projecteur vidéo
      \item Un grand moniteur
      \item Un tableau pour écrire
      \end{itemize}
    }
  }{
    \def \requiredequipment {
      {\bf For on-site sessions at our customer location, the customer must provide}:
      \begin{itemize}
      \item Video projector
      \item Large monitor
      \item Drawing board
      \end{itemize}
    }
  }
}{}

% No labs in audio course
\def \haslabs{false}

% Time ratio
\def \onsitelecturetimeratio{75}
\def \onsitedemotimeratio{25}
