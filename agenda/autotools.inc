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

% Training objectives
\def \traininggoals{
  \begin{itemize}
  \item Be able to understand the role of the {\em autotools}
  \item Be able to use the {\em autotools}
  \item Be able to set up a basic project with {\em autoconf} and {\em
      automake}
  \item Be able to use advanced {\em autoconf} features: configuration
    header, checking for functions, headers and libraries, writing
    custom tests, handling external software and optional features,
    pkg-config, etc.
  \item Be able to use advanced {\em automake} features:
    subdirectories, conditionals, shared libraries with {\em libtool},
    etc.
  \end{itemize}
}

% Training prerequisites
\def \trainingprerequisites{
  \begin{itemize}
    \prerequisitecommandline
  \end{itemize}
}