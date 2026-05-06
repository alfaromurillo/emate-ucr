%% emate-ucr.cls
%% Autor: Jorge Alfaro Murillo <jorge.alfaromurillo@ucr.ac.cr>
%% Escuela de Matemática, Universidad de Costa Rica
%% Licencia: LPPL 1.3c

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{emate-ucr}[2026/03/20 v2.0 UCR Escuela de Matematica - Jorge Alfaro Murillo]

% Opción: mostrar soluciones
\newif\if@soluciones\@solucionesfalse
\DeclareOption{soluciones}{\@solucionestrue}

% Opción: guía de calificación — implica soluciones
\newif\if@guia\@guiafalse
\DeclareOption{guia}{\@guiatrue\@solucionestrue}

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
\RequirePackage[normalem]{ulem}    % \uline y \sout para guía de calificación
\RequirePackage{transparent}       % opacidad del tachado en guía negativa

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
\newcommand{\pts}[1]{\hfill\normalfont\ifnum#1=1(#1 pt.)\else(#1 pts.)\fi}

%% ── Conteo automático de puntos ──────────────────────────────────────────────
% Acumula los puntos declarados en \begin{ejercicio}[N].
% \totalpuntos imprime el total final (requiere compilar dos veces:
% la primera compilación guarda el total en el .aux; la segunda lo lee).
\newcounter{totalpts}
\newcommand{\@totalpuntosfinal}{??}
\AtEndDocument{%
  \immediate\write\@auxout{%
    \string\gdef\string\@totalpuntosfinal{\arabic{totalpts}}%
  }%
}
\newcommand{\totalpuntos}{\@totalpuntosfinal}

%% ── Abecedario sin ñ ─────────────────────────────────────────────────────────
% babel/español redefine \@alph para incluir ñ; lo sobreescribimos en su propio hook
\addto\extrasspanish{%
  \renewcommand{\@alph}[1]{%
    \ifcase#1\or a\or b\or c\or d\or e\or f\or g\or h\or i\or j\or k\or
    l\or m\or n\or o\or p\or q\or r\or s\or t\or u\or v\or w\or x\or y\or z\fi%
  }%
}

%% ── Conteo automático de puntos por ejercicio y subejercicio ─────────────────
% \puntosejercicio   : suma de \guia[N] (N>0) en el ejercicio actual.
% \puntossubejercicio: suma de \guia[N] (N>0) en el ítem actual de subejercicios.
% Ambos requieren compilar dos veces (mismo mecanismo que \totalpuntos).
% Si además se usa \totalpuntos con \puntosejercicio, compilar tres veces.

\newcounter{@guiaptsej}   % acumulador para el ejercicio actual
\newcounter{@guiaptssub}  % acumulador para el subejercicio actual

\def\@ptsejstore#1#2{\expandafter\gdef\csname ptsej@#1\endcsname{#2}}
\def\@ptssubstore#1#2#3{\expandafter\gdef\csname ptssub@#1@#2\endcsname{#3}}

\newcommand{\ptsguiaej}{%
  \@ifundefined{ptsej@\arabic{ejercicio}}{0}%
    {\csname ptsej@\arabic{ejercicio}\endcsname}%
}
\newcommand{\ptsguiasubej}{%
  \@ifundefined{ptssub@\arabic{ejercicio}@\arabic{enumi}}{0}%
    {\csname ptssub@\arabic{ejercicio}@\arabic{enumi}\endcsname}%
}

%% ── Entorno subejercicios ────────────────────────────────────────────────────
\newenvironment{subejercicios}{%
  \setcounter{@guiaptssub}{0}%
  \begin{enumerate}[label=\alph*)]%
    % Gancho en \item: guarda el total del ítem anterior y reinicia el acumulador.
    \let\@guia@origitem\item
    \def\item{%
      \ifnum\value{enumi}>0\relax
        \protected@write\@auxout{}{%
          \string\@ptssubstore{\arabic{ejercicio}}{\arabic{enumi}}{\arabic{@guiaptssub}}%
        }%
        \setcounter{@guiaptssub}{0}%
      \fi
      \@guia@origitem
    }%
}{%
  % Guarda el total del último ítem.
  \protected@write\@auxout{}{%
    \string\@ptssubstore{\arabic{ejercicio}}{\arabic{enumi}}{\arabic{@guiaptssub}}%
  }%
  \end{enumerate}%
}

%% ── Entorno ejercicio ────────────────────────────────────────────────────────
\newcommand{\nombreejercicio}[1]{\def\@nombreejercicio{#1}}
\def\@nombreejercicio{Ejercicio}  % predeterminado

\newcounter{ejercicio}
\newenvironment{ejercicio}[1][]{%
  \setcounter{@guiaptsej}{0}%
  \refstepcounter{ejercicio}%
  \par\vspace{4mm}\noindent\textbf{\@nombreejercicio\ \arabic{ejercicio}.}%
  \ifx&#1&\else{ \normalfont(#1 pts.)}\addtocounter{totalpts}{#1}\fi\quad
}{%
  \protected@write\@auxout{}{%
    \string\@ptsejstore{\arabic{ejercicio}}{\arabic{@guiaptsej}}%
  }%
  \par\medskip
}

%% ── Guía de calificación ─────────────────────────────────────────────────────
% \guia[N]{texto}: marca fragmentos de la solución con valor en puntos.
%   N > 0 : subrayado en color positivo + "+N" en el margen derecho
%   N < 0 : tachado en color negativo   + "N"  en el margen derecho
%   N = 0 o sin argumento: muestra el texto sin decoración
% Sin la opción 'guia': muestra el texto sin decoración.
%
% Los colores se pueden cambiar en el preámbulo:
%   \renewcommand{\guiacolorpositivo}{blue}
%   \renewcommand{\guiacolornegativo}{red}
%   \renewcommand{\guiatransparencia}{0.4}   % 0 = invisible, 1 = opaco
\newcommand{\guiacolorpositivo}{blue}
\newcommand{\guiacolornegativo}{red}
\newcommand{\guiatransparencia}{0.3}

% Flag: indica que el próximo \guia debe reiniciar el offset (nueva línea visual).
% Se activa: al inicio del cuerpo de solucion, y después de cada \[...\].
% Se desactiva: después del primer \guia que lo consume.
\newif\if@guianewline\@guianewlinefalse

% Offset horizontal acumulado para anotaciones en la misma línea visual.
\newlength{\@guiaoffset}
\global\@guiaoffset=0pt

% Tachado con texto a opacidad plena y línea semi-transparente.
% Evita \sout (que colorea también el texto) dibujando la regla por separado.
\newlength{\@guiawd}
\newcommand{\@guiastrike}[2]{%
  % #1 = color de la línea, #2 = texto
  \settowidth{\@guiawd}{{\normalcolor #2}}%
  \makebox[\@guiawd][l]{%
    {\normalcolor #2}%
    \llap{%
      \transparent{\guiatransparencia}%
      \textcolor{#1}{\rule[4pt]{\@guiawd}{0.8pt}}%
    }%
  }%
}

% Cola de anotaciones diferidas desde modo matemático.
% Las celdas de \halign (align*, equation, etc.) atrapan \vadjust; en su lugar
% las anotaciones se encolan y se emiten en el gancho de \endalign / \].
\let\@guia@queue\@empty

% Agrega una anotación a la cola, guardando el offset en el momento de la llamada.
\newcommand{\@guia@enqueue}[3]{%
  % #1=color  #2=texto  #3=offset ya evaluado (string de dimensión)
  \expandafter\gdef\expandafter\@guia@queue\expandafter{%
    \@guia@queue
    \@guia@vlistnote{#1}{#2}{#3}%
  }%
}

% Emite una anotación directamente en la lista vertical (o dentro de \vadjust).
% El \hbox to 0pt parte del margen izquierdo del área de texto.
\newcommand{\@guia@vlistnote}[3]{%
  \vbox to 0pt{%
    \hbox to 0pt{%
      \hskip \dimexpr\textwidth+\marginparsep+6pt+#3\relax
      \normalfont\small\textcolor{#1}{#2}%
      \hss
    }%
    \vss
  }%
}

% Vacía la cola: en modo vertical la emite directamente; en horizontal, via \vadjust.
\newcommand{\@guia@flushqueue}{%
  \ifx\@guia@queue\@empty\else
    \ifvmode
      \@guia@queue
    \else
      \vadjust{\@guia@queue}%
    \fi
    \global\let\@guia@queue\@empty
  \fi
}

% Coloca la anotación en el margen derecho.
% – Modo texto  : usa \vadjust (inmediato, posición exacta).
% – Modo matemático: encola para emitir tras el bloque display.
% – Pase de medición de amsmath (\ifmeasuring@): no hace nada, para no
%   consumir el flag antes del pase de salida.
\newcommand{\@guiamargnote}[2]{%
  \ifmeasuring@\else
    \if@guianewline
      \global\@guiaoffset=0pt
      \global\@guianewlinefalse
    \fi
    \edef\@guiacurroffset{\the\@guiaoffset}%
    \global\advance\@guiaoffset by 2em
    \ifmmode
      \@guia@enqueue{#1}{#2}{\@guiacurroffset}%
    \else
      \vadjust{%
        \vbox to 0pt{%
          \vskip -\baselineskip
          \hbox to 0pt{%
            \hskip \dimexpr\textwidth+\marginparsep+6pt+\@guiacurroffset\relax
            \normalfont\small\textcolor{#1}{#2}%
            \hss
          }%
          \vss
        }%
      }%
    \fi
  \fi
}

\newcommand{\guia}[2][0]{%
  % Acumula puntos positivos siempre, pero solo en el pase de salida de amsmath.
  \ifmeasuring@\else
    \ifnum#1>0\relax
      \addtocounter{@guiaptsej}{#1}%
      \addtocounter{@guiaptssub}{#1}%
    \fi
  \fi
  \if@guia
    \ifnum#1>0\relax
      \ifmmode
        % En modo matemático: subrayado azul con \underline (text color normalcolor).
        {\color{\guiacolorpositivo}\underline{{\normalcolor #2}}}%
        \@guiamargnote{\guiacolorpositivo}{$+$#1}%
      \else
        {\color{\guiacolorpositivo}\uline{{\normalcolor #2}}}\@guiamargnote{\guiacolorpositivo}{$+$#1}%
      \fi
    \else
      \ifnum#1<0\relax
        \ifmmode
          #2\@guiamargnote{\guiacolornegativo}{#1}%
        \else
          \@guiastrike{\guiacolornegativo}{#2}\@guiamargnote{\guiacolornegativo}{#1}%
        \fi
      \else
        #2%
      \fi
    \fi
  \else
    #2%
  \fi
}

%% ── Caja solución ────────────────────────────────────────────────────────────
\mdfdefinestyle{estilosolucion}{%
  backgroundcolor=gray!20,
  roundcorner=5pt,
  linewidth=1pt,
  linecolor=black,
}

\mdfdefinestyle{estiloguia}{%
  backgroundcolor=gray!20,
  roundcorner=5pt,
  linewidth=1pt,
  linecolor=black,
}

% \guiasincaja : desactiva la caja en el entorno solucion con opción guia.
% Llamar en el preámbulo para obtener el comportamiento antiguo (sin caja).
\newif\if@guiacaja\@guiacajatrue
\newcommand{\guiasincaja}{\@guiacajafalse}

% Núcleo del contenido de la guía (reutilizado con y sin caja).
\newcommand{\@guiacuerpo}{%
  \noindent\textbf{Guía de calificación:}\par
  \begingroup
    \global\@guianewlinetrue  % el primer \guia siempre reinicia el offset
    % Resetea el flag al INICIO de cualquier display (cubre equation, align,
    % gather, \[...\], y cualquier otro entorno display de amsmath).
    \edef\@guia@savedevdisplay{\the\everydisplay}%
    \everydisplay{\@guia@savedevdisplay\global\@guianewlinetrue}%
    % Resetea el flag también al TERMINAR los entornos display comunes,
    % para que el texto que sigue al display empiece con offset=0.
    \let\@guia@saved@bracket\]
    \def\]{\@guia@saved@bracket\@guia@flushqueue\global\@guianewlinetrue}%
    \let\@guia@savedendalign\endalign
    \def\endalign{\@guia@savedendalign\@guia@flushqueue\global\@guianewlinetrue}%
    \let\@guia@savedendgather\endgather
    \def\endgather{\@guia@savedendgather\@guia@flushqueue\global\@guianewlinetrue}%
    \BODY
  \endgroup
}

\NewEnviron{solucion}{%
  \if@soluciones
    \if@guia
      \if@guiacaja
        \begin{mdframed}[style=estiloguia]
          \@guiacuerpo
        \end{mdframed}
      \else
        \par\vspace{4pt}%
        \@guiacuerpo
        \par\vspace{4pt}%
      \fi
    \else
      \begin{mdframed}[style=estilosolucion]
      \textbf{Solución:}
      \BODY
      \end{mdframed}
    \fi
  \fi
}
