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
\newdimen\@guia@voffsetdim

% Subrayado con texto en color normal (negro) y regla en color #1.
% Permite saltos de línea. Replica la estructura de \uline (de ulem) pero con
% \color{#1} explícito en la marca, sin tocar el color del texto.
% Subrayado sólido con texto en negro y regla en color #1.
%
% Estrategia:
%   – La capa exterior {\color{#1}...} establece el color del contexto,
%     que es el que hereda \leaders\hrule (la regla de subrayado).
%   – Dentro del grupo exterior se inyecta \color{black} en \UL@hook,
%     que ulem ejecuta al inicio de \UL@on, justo antes de procesar las
%     palabras. Así cada hbox de palabra se construye con texto negro.
%   – \UL@leaders se redefine localmente para que los líderes
%     entre palabras usen \color{#1} (azul) en lugar del negro que queda
%     activo tras el hook. Sin esto los líderes inter-palabra serían negros.
%   – Se usa \uline (no \ULon directo) para respetar su mecanismo
%     interno y no alterar la interacción con mdframed.
\newcommand{\@guia@coloruline}[2]{%
  {\color{#1}%
   \edef\@guia@ul@color{#1}%
   \UL@hook=\expandafter{\the\UL@hook\color{black}}%
   \def\UL@leaders{{\LA@hskip-\UL@pixel
     \advance\UL@skip\tw@\UL@pixel
     \color{\@guia@ul@color}%
     \UL@leadtype\LA@hskip\UL@skip
     \LA@hskip-\UL@pixel}}%
   \uline{#2}%
  }%
}

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
% Se usa un registro de tokens (\newtoks) en lugar de \gdef para evitar
% conflictos con \expandafter en el contexto de mdframed.
\newtoks\@guia@queue
\@guia@queue={}
\newif\if@guia@queuenonempty

% Agrega una anotación a la cola.
\newcommand{\@guia@enqueue}[4]{%
  % #1=color  #2=texto  #3=hoffset ya evaluado  #4=voffset ya evaluado (dim concreta)
  \global\@guia@queue=\expandafter{\the\@guia@queue\@guia@vlistnote{#1}{#2}{#3}{#4}}%
  \global\@guia@queuenonemptytrue
}

% Emite una anotación directamente en la lista vertical.
% #1=color  #2=texto  #3=hoffset (dim concreta)  #4=voffset (dim concreta)
\newcommand{\@guia@vlistnote}[4]{%
  \vbox to 0pt{%
    \vskip #4\relax
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
  \if@guia@queuenonempty
    \ifvmode
      \the\@guia@queue
    \else
      \vadjust{\the\@guia@queue}%
    \fi
    \global\@guia@queue={}%
    \global\@guia@queuenonemptyfalse
  \fi
}

% Coloca la anotación en el margen derecho.
% – Modo texto  : usa \vadjust (inmediato, posición exacta).
% – Modo matemático: encola para emitir tras el bloque display.
% – Pase de medición de amsmath (\ifmeasuring@): no hace nada, para no
%   consumir el flag antes del pase de salida.
\newcommand{\@guiamargnote}[3]{%
  % #1=color  #2=texto  #3=expresión de dimensión para voffset (default 0pt)
  \ifmeasuring@\else
    \if@guianewline
      \global\@guiaoffset=0pt
      \global\@guianewlinefalse
    \fi
    \edef\@guiacurroffset{\the\@guiaoffset}%
    \global\advance\@guiaoffset by 2em
    \ifmmode
      % Calcula el voffset como dimensión concreta aquí, fuera del contexto
      % de mdframed, para que \the\@guia@voffsetdim produzca un valor seguro
      % (p.ej. "-28.8pt") que se almacena en la cola.
      % #3 acepta cualquier expresión de dimensión, p.ej. -2\baselineskip.
      \edef\@guia@tmpvoff{#3}%
      \ifx\@guia@tmpvoff\@empty
        \@guia@voffsetdim=0pt
      \else
        \@guia@voffsetdim=#3\relax
      \fi
      \edef\@guia@tmp@enqueue{%
        \noexpand\@guia@enqueue
          {\unexpanded{#1}}%
          {\unexpanded{#2}}%
          {\@guiacurroffset}%
          {\the\@guia@voffsetdim}%
      }%
      \@guia@tmp@enqueue
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

% \guia[pts][voffset]{texto}
% pts     : puntos (opcional, default 0).
% voffset : desplazamiento vertical de la anotación en modo display (opcional,
%           default 0pt). Acepta cualquier expresión de dimensión de TeX.
%           Un valor negativo sube la anotación.
%           Ej.: \guia[1][-2\baselineskip]{fórmula}  →  sube 2 líneas
\newcommand{\guia}[1][0]{%
  \@ifnextchar[%
    {\@guia@ii{#1}}%
    {\@guia@ii{#1}[0pt]}%
}
\def\@guia@ii#1[#2]#3{%
  % #1=pts  #2=voffset  #3=contenido
  \ifmeasuring@\else
    \ifnum#1>0\relax
      \addtocounter{@guiaptsej}{#1}%
      \addtocounter{@guiaptssub}{#1}%
    \fi
  \fi
  \if@guia
    \ifnum#1>0\relax
      \ifmmode
        {\color{\guiacolorpositivo}\underline{{\normalcolor #3}}}%
        \@guiamargnote{\guiacolorpositivo}{$+$#1}{#2}%
      \else
        \@guia@coloruline{\guiacolorpositivo}{#3}\@guiamargnote{\guiacolorpositivo}{$+$#1}{#2}%
      \fi
    \else
      \ifnum#1<0\relax
        \ifmmode
          #3\@guiamargnote{\guiacolornegativo}{#1}{#2}%
        \else
          \@guiastrike{\guiacolornegativo}{#3}\@guiamargnote{\guiacolornegativo}{#1}{#2}%
        \fi
      \else
        #3%
      \fi
    \fi
  \else
    #3%
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
