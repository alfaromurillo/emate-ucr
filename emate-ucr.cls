%% emate-ucr.cls
%% Autor: Jorge Alfaro Murillo <jorge.alfaromurillo@ucr.ac.cr>
%% Escuela de Matemática, Universidad de Costa Rica
%% Licencia: LPPL 1.3c

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{emate-ucr}[2026/03/20 v2.0 UCR Escuela de Matematica - Jorge Alfaro Murillo]

% Opción: mostrar soluciones
\newif\if@soluciones\@solucionesfalse
\DeclareOption{soluciones}{\@solucionestrue}

% Opción: numpaginas — cuándo mostrar el número de página
%   numpaginas   : siempre
%   nonumpaginas : nunca
%   (ninguna)    : solo si el documento tiene 2 o más páginas (predeterminado)
\newif\if@numpaginasalways\@numpaginasalwaysfalse
\newif\if@numpaginasnever\@numpaginasneverfalse
\DeclareOption{numpaginas}{\@numpaginasalwaystrue}
\DeclareOption{nonumpaginas}{\@numpaginasnevertrue}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

\LoadClass[12pt]{article}

%% ── Paquetes ─────────────────────────────────────────────────────────────────
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}
\RequirePackage[left=3cm,right=3cm,top=1cm,bottom=3cm,includeheadfoot]{geometry}
\RequirePackage[spanish]{babel}
\RequirePackage{fancyhdr}
\RequirePackage{mathtools}   % carga amsmath + extensiones
\RequirePackage{amssymb}
\RequirePackage{graphicx}
\RequirePackage{mdframed}
\RequirePackage{environ}
\RequirePackage{xcolor}
\RequirePackage{enumitem}
\RequirePackage{hyperref}
\RequirePackage{lastpage}
\RequirePackage{refcount}

%% ── Metadatos obligatorios (deben definirse en el .tex) ──────────────────────
\newcommand{\curso}[1]{\def\@curso{#1}}
\newcommand{\encabezado}[1]{\def\@encabezado{#1}}

%% ── Metadatos opcionales de evaluación ───────────────────────────────────────
\def\@fecha{}
\def\@duracion{}
\def\@valor{}
\newcommand{\fecha}[1]{\def\@fecha{#1}}
\newcommand{\duracion}[1]{\def\@duracion{#1}}
\newcommand{\valor}[1]{\def\@valor{#1}}

%% ── Encabezado de página ─────────────────────────────────────────────────────
\setlength{\headheight}{90pt}
\pagestyle{fancy}
\fancyhf{}
\lhead{\includegraphics[width=4cm]{UCR}\vspace{3mm}}
\chead{\textsc{\@curso}\vspace{3mm}}
\rhead{\includegraphics[width=4.1cm]{EMat}\vspace{7mm}}
\cfoot{%
  \if@numpaginasnever\else
    \if@numpaginasalways
      \thepage
    \else
      \ifnum\getpagerefnumber{LastPage}>1\relax\thepage\fi
    \fi
  \fi
}

%% ── Título del documento ─────────────────────────────────────────────────────
\newcommand{\imprimirtitulo}{%
  \thispagestyle{fancy}%
  \begin{center}
    \textbf{\@ifundefined{@encabezado}{}{\@encabezado}}%
    % Línea de metadatos: solo si al menos uno está definido
    \newif\if@haymetadatos
    \@haymetadatosfalse
    \ifx\@fecha\empty\else\@haymetadatostrue\fi
    \ifx\@duracion\empty\else\@haymetadatostrue\fi
    \ifx\@valor\empty\else\@haymetadatostrue\fi
    \if@haymetadatos
      \par\smallskip\rule{\linewidth}{0.4pt}\par\smallskip
      \normalfont\small
      \ifx\@fecha\empty\else Fecha: \@fecha\fi
      \ifx\@duracion\empty\else
        \ifx\@fecha\empty\else\quad|\quad\fi
        Duración: \@duracion
      \fi
      \ifx\@valor\empty\else
        \ifx\@fecha\empty
          \ifx\@duracion\empty\else\quad|\quad\fi
        \else\quad|\quad\fi
        Valor: \@valor
      \fi
    \fi
  \end{center}
  \vspace{4mm}%
}

%% ── Datos del estudiante (opcional) ──────────────────────────────────────────
\newcommand{\datosestudiante}{%
  \par\noindent
  \makebox[0.65\linewidth]{Nombre:\enspace\hrulefill}\quad
  \makebox[0.25\linewidth]{Carné:\enspace\hrulefill}%
  \par\vspace{4mm}%
}

%% ── Entorno indicaciones ─────────────────────────────────────────────────────
\NewEnviron{indicaciones}{%
  \par\noindent\textbf{Indicaciones:} \BODY
  \par\vspace{2mm}%
}

%% ── Entorno instrucciones (evaluaciones formales) ────────────────────────────
\mdfdefinestyle{estiloinstrucciones}{%
  backgroundcolor=white,
  roundcorner=3pt,
  linewidth=1.5pt,
  linecolor=black,
  innertopmargin=6pt,
  innerbottommargin=6pt,
  innerleftmargin=8pt,
  innerrightmargin=8pt,
}

\NewEnviron{instrucciones}{%
  \begin{mdframed}[style=estiloinstrucciones]
    \textbf{Indicaciones:}
    \begin{enumerate}[leftmargin=*,label=\arabic*.]
      \BODY
    \end{enumerate}
  \end{mdframed}
  \vspace{2mm}%
}

%% ── Puntos por ítem ──────────────────────────────────────────────────────────
% \pts{N}: imprime "(N pts.)" alineado a la derecha. Útil para asignar puntos
% a incisos individuales dentro de subejercicios, p.ej.: \item \pts{3} Enunciado
\newcommand{\pts}[1]{\hfill\normalfont(#1 pts.)}

%% ── Conteo automático de puntos ──────────────────────────────────────────────
% Acumula los puntos declarados en \begin{ejercicio}[N].
% \totalpuntos imprime el total acumulado hasta ese punto del documento.
\newcounter{totalpts}
\newcommand{\totalpuntos}{\arabic{totalpts}}

%% ── Abecedario sin ñ ─────────────────────────────────────────────────────────
% babel/español redefine \@alph para incluir ñ; lo sobreescribimos en su propio hook
\addto\extrasspanish{%
  \renewcommand{\@alph}[1]{%
    \ifcase#1\or a\or b\or c\or d\or e\or f\or g\or h\or i\or j\or k\or
    l\or m\or n\or o\or p\or q\or r\or s\or t\or u\or v\or w\or x\or y\or z\fi%
  }%
}

%% ── Entorno subejercicios ────────────────────────────────────────────────────
\newenvironment{subejercicios}{\begin{enumerate}[label=\alph*)]}{\end{enumerate}}

%% ── Entorno ejercicio ────────────────────────────────────────────────────────
\newcommand{\nombreejercicio}[1]{\def\@nombreejercicio{#1}}
\def\@nombreejercicio{Ejercicio}  % predeterminado

\newcounter{ejercicio}
\newenvironment{ejercicio}[1][]{%
  \refstepcounter{ejercicio}%
  \par\vspace{4mm}\noindent\textbf{\@nombreejercicio\ \arabic{ejercicio}.}%
  \ifx&#1&\else{ \normalfont(#1 pts.)}\addtocounter{totalpts}{#1}\fi\quad
}{%
  \par\medskip
}

%% ── Caja solución ────────────────────────────────────────────────────────────
\mdfdefinestyle{estilosolucion}{%
  backgroundcolor=gray!20,
  roundcorner=5pt,
  linewidth=1pt,
  linecolor=black,
}

\NewEnviron{solucion}{%
  \if@soluciones
    \begin{mdframed}[style=estilosolucion]
    \textbf{Solución:}
    \BODY
    \end{mdframed}
  \fi
}
