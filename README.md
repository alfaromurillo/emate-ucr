# emate-ucr

Clase LaTeX para la Escuela de Matemática de la Universidad de Costa Rica.
Permite preparar hojas de ejercicios, pruebas cortas y exámenes con un formato
institucional uniforme, generando automáticamente una versión con soluciones a
partir del mismo archivo fuente.

**Autor:** Jorge Alfaro Murillo — Escuela de Matemática, UCR
**Licencia:** LPPL 1.3c

---

## Instalación

Se necesitan tres archivos: `emate-ucr.cls`, `UCR.png` y `EMat.pdf`.

### Opción rápida: descargar los tres archivos

Descargue cada uno con el botón derecho → "Guardar enlace como..." (o
`wget`/`curl`) y colóquelos en el mismo directorio que su `.tex`:

- [emate-ucr.cls](https://raw.githubusercontent.com/alfaromurillo/emate-ucr/master/emate-ucr.cls)
- [UCR.png](https://raw.githubusercontent.com/alfaromurillo/emate-ucr/master/UCR.png)
- [EMat.pdf](https://raw.githubusercontent.com/alfaromurillo/emate-ucr/master/EMat.pdf)

Por terminal:

```bash
curl -O https://raw.githubusercontent.com/alfaromurillo/emate-ucr/master/emate-ucr.cls
curl -O https://raw.githubusercontent.com/alfaromurillo/emate-ucr/master/UCR.png
curl -O https://raw.githubusercontent.com/alfaromurillo/emate-ucr/master/EMat.pdf
```

Con esta opción los tres archivos deben copiarse manualmente a cada
directorio de proyecto donde se use la clase, y volver a copiarse si se
actualizan.

### Opción recomendada: clonar el repositorio e instalar con enlaces simbólicos

Clonar el repositorio y enlazar los archivos (en vez de copiarlos) al árbol
personal de LaTeX permite mantenerlos siempre actualizados con `git pull`,
sin repetir ningún paso de instalación después:

```bash
git clone https://github.com/alfaromurillo/emate-ucr.git
```

Luego enlace los tres archivos al árbol `texmf` según su sistema operativo
(instrucciones abajo). A partir de ahí, cada `git pull` dentro del
directorio `emate-ucr` deja los enlaces apuntando a la versión más reciente
automáticamente:

```bash
cd emate-ucr
git pull
```

### Instalación permanente en el árbol de LaTeX (`texmf`)

Instalar los archivos en el árbol personal de TeX evita copiarlos en cada
proyecto: quedan disponibles para cualquier documento del sistema. Se usan
enlaces simbólicos hacia la copia clonada del repositorio, de modo que un
`git pull` los actualiza sin más pasos.

**Linux**

```bash
mkdir -p ~/texmf/tex/latex/emate-ucr
cd ~/texmf/tex/latex/emate-ucr
ln -s /ruta/a/emate-ucr/emate-ucr.cls .
ln -s /ruta/a/emate-ucr/UCR.png .
ln -s /ruta/a/emate-ucr/EMat.pdf .
texhash ~/texmf 2>/dev/null || mktexlsr
```

(Reemplace `/ruta/a/emate-ucr` por la ruta donde clonó el repositorio. Si
`~/texmf` no está en la ruta de búsqueda de su distribución, verifíquelo con
`kpsewhich -var-value=TEXMFHOME` y use esa ruta en su lugar.)

**macOS** (con MacTeX)

```bash
mkdir -p ~/Library/texmf/tex/latex/emate-ucr
cd ~/Library/texmf/tex/latex/emate-ucr
ln -s /ruta/a/emate-ucr/emate-ucr.cls .
ln -s /ruta/a/emate-ucr/UCR.png .
ln -s /ruta/a/emate-ucr/EMat.pdf .
sudo texhash
```

**Windows** (con MiKTeX)

MiKTeX y NTFS sí soportan enlaces simbólicos, pero `mklink` requiere permisos
de administrador (o el "modo desarrollador" activado en Windows 10/11).
Desde una terminal (`cmd.exe`) como administrador:

```bat
mkdir "%USERPROFILE%\texmf\tex\latex\emate-ucr"
cd "%USERPROFILE%\texmf\tex\latex\emate-ucr"
mklink emate-ucr.cls C:\ruta\a\emate-ucr\emate-ucr.cls
mklink UCR.png C:\ruta\a\emate-ucr\UCR.png
mklink EMat.pdf C:\ruta\a\emate-ucr\EMat.pdf
```

Luego, en "MiKTeX Console" → "Refresh FNDB" (o `initexmf --update-fndb` desde
una terminal) para que MiKTeX detecte la clase. Si prefiere no usar enlaces
simbólicos en Windows, copie los tres archivos directamente a esa carpeta y
recuerde repetir la copia después de cada `git pull`.

Con TeX Live en Windows el procedimiento es análogo, usando
`%USERPROFILE%\texmf\tex\latex\emate-ucr` y `texhash` (o `mktexlsr`) desde la
terminal de TeX Live.

Después de instalar la clase de esta forma, puede compilar cualquier
documento que use `\documentclass{emate-ucr}` sin tener `emate-ucr.cls`,
`UCR.png` ni `EMat.pdf` en el mismo directorio, y los `git pull` posteriores
se reflejan automáticamente sin repetir la instalación.

---

## Compilación

La clase usa `inputenc` y `fontenc`, por lo que requiere **pdflatex**:

```bash
pdflatex documento.tex
```

---

## Uso básico

### Hoja de ejercicios

```latex
\documentclass{emate-ucr}

\curso{I Ciclo 2026\\MA-1022\\Cálculo para Ciencias Económicas II}
\encabezado{Ejercicios Semana 1}

\begin{document}
\imprimirtitulo

\begin{ejercicio}
  Ejercicio sin valor de puntos.
\end{ejercicio}

\begin{ejercicio}[10]
  Ejercicio con valor: imprime "Ejercicio 2. (10 pts.)".

  \begin{subejercicios}
    \item Inciso sin puntos.
    \item Inciso sin puntos.
  \end{subejercicios}
\end{ejercicio}

\end{document}
```

### Puntos en ejercicios y subejercicios

**Puntos por ejercicio** — pasar el valor como argumento opcional:

```latex
\begin{ejercicio}[25]
  Enunciado...
\end{ejercicio}
```

Imprime: `Ejercicio 1.  (25 pts.)`. Con `[1]` imprime `(1 pt.)` en
singular (igual que `\pts{N}`, ver abajo).

**Puntos por inciso** — usar `\pts{N}` al inicio de cada `\item`:

```latex
\begin{ejercicio}[25]
  Resuelva cada inciso.

  \begin{subejercicios}
    \item Primer inciso, vale 10 puntos.\pts{10}
    \item Segundo inciso, vale 15 puntos.\pts{15}
  \end{subejercicios}
\end{ejercicio}
```

`\pts{N}` imprime `(N pts.)` alineado a la derecha de la línea. El valor del
ejercicio (`[25]`) y los valores de los incisos (`\pts{}`) son independientes:
el primero aparece junto al número del ejercicio, los segundos al final de cada
inciso.

**Total automático de puntos** — `\totalpuntos` suma todos los valores
declarados en `\begin{ejercicio}[N]` y puede usarse en cualquier parte del
documento:

```latex
% En el preámbulo, se puede poner el total calculado en \valor{}:
\valor{\totalpuntos\ puntos}   % ← se evalúa al final; ver nota abajo

% O imprimirlo al final del documento:
Esta evaluación vale \totalpuntos\ puntos en total.
```

> **Nota:** `\totalpuntos` se calcula durante la compilación, por lo que
> si se usa en el preámbulo (dentro de `\valor{}`) el valor puede no estar
> disponible en el primer paso. Compilar **dos veces** resuelve esto.
> Para evitarlo, simplemente escribir el total manualmente en `\valor{}`.

Ejemplo completo con puntos automáticos:

```latex
\documentclass{emate-ucr}

\curso{I Ciclo 2026\\MA-1022\\Cálculo para Ciencias Económicas II}
\encabezado{Prueba Corta 1}
\fecha{20 de marzo de 2026}
\duracion{50 minutos}

\begin{document}
\imprimirtitulo
\datosestudiante

\begin{instrucciones}
  \item Justifique cada respuesta.
\end{instrucciones}

\begin{ejercicio}[10]
  Resuelva el sistema...
\end{ejercicio}

\begin{ejercicio}[15]
  Determine el rango...

  \begin{subejercicios}
    \item \pts{8}  Primer inciso.
    \item \pts{7}  Segundo inciso.
  \end{subejercicios}
\end{ejercicio}

Esta prueba vale \totalpuntos\ puntos en total.

\end{document}
```

### Versión con soluciones

Cree un archivo separado (p.ej. `ejercicios_semana_01_soluciones.tex`):

```latex
\PassOptionsToClass{soluciones}{emate-ucr}
\input{ejercicios_semana_01}
```

Dentro del archivo principal, escriba las soluciones en el entorno `solucion`.
Solo aparecen en el PDF cuando se compila con la opción `soluciones`:

```latex
\begin{ejercicio}[10]
  Enunciado...
  \begin{solucion}
    Desarrollo de la solución (visible solo en versión con soluciones).
  \end{solucion}
\end{ejercicio}
```

### Prueba corta o examen

Los siguientes comandos son **opcionales**. Si no se usan, el documento queda
igual que una hoja de ejercicios.

```latex
\documentclass{emate-ucr}

\curso{I Ciclo 2026\\MA-1022\\Cálculo para Ciencias Económicas II}
\encabezado{Prueba Corta 1}

% Metadatos opcionales: aparecen en una línea bajo el título.
% Se puede usar cualquier subconjunto de los tres.
\fecha{20 de marzo de 2026}
\duracion{50 minutos}
\valor{15 puntos}

\begin{document}
\imprimirtitulo

% Línea para nombre y carné del estudiante (opcional).
\datosestudiante

% Caja enmarcada de indicaciones con lista numerada (opcional).
% Alternativa más simple: \begin{indicaciones}...\end{indicaciones}
\begin{instrucciones}
  \item Esta prueba es individual y con libro cerrado.
  \item Justifique cada respuesta.
\end{instrucciones}

\begin{ejercicio}[15]
  Enunciado...
\end{ejercicio}

\end{document}
```

---

## Referencia de comandos

### Preámbulo

| Comando | Obligatorio | Descripción |
|---|---|---|
| `\curso{texto}` | Sí | Aparece en el encabezado de página (centro) |
| `\encabezado{texto}` | Sí | Título del documento |
| `\fecha{texto}` | No | Fecha de la evaluación |
| `\duracion{texto}` | No | Tiempo disponible |
| `\valor{texto}` | No | Puntaje total |
| `\nombreejercicio{texto}` | No | Palabra usada en el entorno `ejercicio` (predeterminado: `Ejercicio`) |

Por ejemplo, `\nombreejercicio{Problema}` produce `Problema 1.`, `Problema 2.`, etc.

### En el documento

| Comando / Entorno | Descripción |
|---|---|
| `\imprimirtitulo` | Imprime el título y metadatos. Llamar al inicio. |
| `\datosestudiante` | Línea para nombre y carné |
| `\begin{instrucciones}` | Caja enmarcada de indicaciones (items con `\item`) |
| `\begin{indicaciones}` | Indicaciones sin caja, texto libre |
| `\begin{ejercicio}[N]` | Ejercicio numerado automáticamente; N = puntos (opcional) |
| `\begin{subejercicios}` | Incisos a), b), c), ... |
| `\pts{N}` | Imprime `(N pts.)` alineado a la derecha; usar dentro de `\item` |
| `\totalpuntos` | Total acumulado de puntos de todos los `\begin{ejercicio}[N]` |
| `\begin{solucion}` | Solución (visible solo con opción `[soluciones]`) |
| `\guia[N][voffset][ulpad]{texto}` | Marca un fragmento de solución con N puntos (ver sección Guía de calificación) |
| `\ptsguiaej` | Suma de `\guia[N]` (N > 0) en el ejercicio actual; usar como argumento de `ejercicio` |
| `\ptsguiasubej` | Suma de `\guia[N]` (N > 0) en el ítem actual de `subejercicios` |
| `\guiaretorno` | Reinicia el offset horizontal acumulado de `\guia`; usar antes de `\guia` en modo texto dentro de `itemize` (ver Notas de compatibilidad) |

### Opciones de clase

| Opción | Descripción |
|---|---|
| `[soluciones]` | Muestra el contenido de los entornos `solucion` |
| `[guia]` | Versión de guía de calificación: implica `soluciones` y activa las decoraciones de `\guia` |
| `[numpaginas]` | Siempre imprime el número de página en el pie |
| `[nonumpaginas]` | Nunca imprime el número de página |
| (ninguna) | Imprime el número de página solo si el documento tiene 2 o más páginas (predeterminado) |

```latex
\documentclass[numpaginas]{emate-ucr}            % siempre
\documentclass[nonumpaginas]{emate-ucr}          % nunca
\documentclass{emate-ucr}                        % predeterminado: ≥ 2 páginas
\documentclass[soluciones,numpaginas]{emate-ucr} % varias opciones
\documentclass[guia]{emate-ucr}                  % guía de calificación
```

---

## Guía de calificación

La opción `[guia]` genera una versión del documento para uso del profesor, con
anotaciones visuales que indican cuántos puntos vale cada fragmento de la solución.

### Flujo de trabajo

Cree un archivo separado (p.ej. `examen_guia.tex`):

```latex
\PassOptionsToClass{guia}{emate-ucr}
\input{examen}
```

O directamente: `\documentclass[guia]{emate-ucr}`.

### Comando `\guia`

Sintaxis completa (los tres argumentos entre corchetes son opcionales):

```latex
\guia[N][voffset][ulpad]{texto}
```

| Argumento | Tipo | Predeterminado | Descripción |
|---|---|---|---|
| `N` | entero | `0` | Puntos del fragmento |
| `voffset` | dimensión | automático | Ajuste vertical de la anotación al margen en modo display |
| `ulpad` | dimensión | `0pt` | Ajuste de la profundidad del subrayado |

Comportamiento según el valor de `N`:

| N | Resultado (con opción `guia`) |
|---|---|
| N > 0 | Texto subrayado en azul; `+N` en el margen derecho |
| N < 0 | Texto tachado en rojo semi-transparente; `N` en el margen derecho |
| N = 0 o sin argumento | Texto sin decoración |
| Sin opción `guia` | Texto sin decoración (el contenido sigue visible en `soluciones`) |

En modo matemático (`$...$`, `\[...\]`, `align*`, etc.) el subrayado usa
`\underline` de LaTeX en lugar de `\uline`. Las anotaciones en el margen
dentro de entornos display aparecen al terminar el bloque.

Ejemplo de uso:

```latex
\begin{solucion}
  Aplicando \guia[1]{la regla de Cramer, $x_2 = \det(A_2)/\det(A)$}, donde
  $A_2$ es la matriz $A$ con la columna 2 reemplazada por $\mathbf{b}$:
  \[
    A_2 = \begin{pmatrix} 1 & 2 & 0 \\ 0 & k & 1 \\ 2 & 1 & 1 \end{pmatrix}.
  \]
  Por lo tanto,
  \[
    x_2 = \frac{\det(A_2)}{\det(A)} = \guia[1]{\frac{k+3}{5}}.
  \]
\end{solucion}
```

#### Ajuste vertical de la anotación al margen (`[voffset]`)

En entornos display math (`\[...\]`, `align*`, `gather*`, etc.), la anotación
al margen se emite al terminar el bloque. Por defecto se sube automáticamente
`\guiadisplayvoffset` (valor inicial: `-2\baselineskip`) para quedar junto a la
fórmula. En modo texto e inline math (`$...$`) el desplazamiento es `0pt`.

Usar `[voffset]` solo cuando la posición automática no es correcta:

```latex
\guia[1][-3\baselineskip]{formula larga}   % sube 3 líneas en lugar de 2
\guia[1][0pt]{formula}                     % sin desplazamiento
```

Para cambiar el desplazamiento predeterminado en todo el documento:

```latex
\renewcommand{\guiadisplayvoffset}{-1.5\baselineskip}
```

#### Ajuste del subrayado sobre fracciones (`[ulpad]`)

Cuando el contenido subrayado incluye una fracción con denominador (`\tfrac`,
`\frac`), el subrayado puede cruzar visualmente el denominador porque `\uline`
fija la profundidad del subrayado a ~3.4 pt (suficiente para descenders
normales, pero no para fracciones).

El argumento `[ulpad]` baja el subrayado la cantidad indicada:

```latex
\guia[1][][3pt]{$\theta = \tfrac{\pi}{2}$}   % baja el subrayado 3 pt
```

El segundo argumento se omite con `[]` para conservar el voffset automático.
Valores típicos: `2pt`–`4pt`. Un valor negativo sube el subrayado.

### Puntos automáticos con `\ptsguiaej` y `\ptsguiasubej`

`\ptsguiaej` calcula automáticamente la suma de todos los `\guia[N]` (con N > 0)
del ejercicio actual. Se puede usar como argumento de `\begin{ejercicio}` para
que el valor en el encabezado del ejercicio coincida con las anotaciones:

```latex
\begin{ejercicio}[\ptsguiaej]
  ...
  \begin{solucion}
    \guia[3]{Paso 1...}
    \guia[2]{Paso 2...}
    % El ejercicio valdrá 5 pts. automáticamente.
  \end{solucion}
\end{ejercicio}
```

`\ptsguiasubej` hace lo mismo para cada ítem dentro de `subejercicios`:

```latex
\begin{subejercicios}
  \item \pts{\ptsguiasubej} Enunciado a.
  \begin{solucion}
    \guia[4]{Resultado correcto.}
  \end{solucion}

  \item \pts{\ptsguiasubej} Enunciado b.
  \begin{solucion}
    \guia[6]{Resultado correcto.}
  \end{solucion}
\end{subejercicios}
```

Ambos comandos leen el total desde el `.aux` de la compilación anterior.
**Requieren compilar dos veces** (o tres si también se usa `\totalpuntos` con
`\ptsguiaej`).

### Personalización visual

Los colores y la transparencia se pueden cambiar en el preámbulo:

```latex
\renewcommand{\guiacolorpositivo}{blue}   % predeterminado
\renewcommand{\guiacolornegativo}{red}    % predeterminado
\renewcommand{\guiatransparencia}{0.3}    % 0 = invisible, 1 = opaco (predeterminado: 0.3)
```

Por defecto la solución en modo guía se muestra en una caja gris igual a la de
`soluciones`. Para desactivar la caja y mostrar el contenido sin recuadro:

```latex
\guiasincaja   % poner en el preámbulo
```

---

## Notas de compatibilidad

### TikZ dentro del entorno `solucion`

El entorno `solucion` usa el paquete `environ` (`\NewEnviron`), que tokeniza el
cuerpo del entorno en el momento de `\begin{solucion}`. Con `babel` en español,
el carácter `>` está activo como shorthand para `»`, lo que rompe la sintaxis de
TikZ (`->`, `>=latex`, etc.) antes de que `\usetikzlibrary{babel}` pueda
desactivarlo.

**Solución:** envolver el entorno `solucion` con `\shorthandoff{>}` y
`\shorthandon{>}`:

```latex
\shorthandoff{>}
\begin{solucion}
  \begin{tikzpicture}
    \draw[->] (0,0) -- (1,0);
  \end{tikzpicture}
\end{solucion}
\shorthandon{>}
```

Esto es necesario siempre que se use TikZ (u otro paquete que use `>`) dentro
de `\begin{solucion}...\end{solucion}`. Fuera del entorno `solucion`, el
problema no ocurre porque `\usetikzlibrary{babel}` maneja la desactivación
automáticamente.

### Puntuación al final de un argumento de `\guia`

El carácter `.` (punto) es activo en `babel-spanish` para el separador decimal.
Cuando la opción `soluciones` **no** está activa, `environ` re-expande el cuerpo
del entorno `solucion` en una caja invisible. Si el último carácter antes del `}`
de cierre de `\guia{...}` es un punto, babel intenta construir
`\csname system@active.\endcsname` para buscar el shorthand, lo cual desencadena
una expansión recursiva del punto activo y produce el error `Extra \endcsname`.

**Incorrecto** (punto dentro de las llaves):

```latex
\guia[1][-4\baselineskip]{f_y = \frac{1}{x}.}
```

**Correcto** (punto fuera de las llaves):

```latex
\guia[1][-4\baselineskip]{f_y = \frac{1}{x}}.
```

La misma regla aplica a cualquier signo de puntuación (`,`, `;`, `:`) al final
del argumento. El PDF se genera de todas formas (TeX recupera del error), pero el
log reporta `Extra \endcsname` / `Extra \fi` en la línea `\end{solucion}`.

### El carácter `%` dentro de un `\guia{...}` en modo display

Igual que con el punto decimal (sección anterior), `babel-spanish` mantiene
`%` activo (para el espaciado correcto antes del símbolo de porcentaje). Si
un `\guia{...}` que contiene `%` está dentro de un bloque `\[...\]` (modo
display) y el documento se compila **sin** la opción `soluciones`/`guia`,
`environ` vuelve a capturar el cuerpo de `solucion` en una caja de medición
para descartarlo. Esa recaptura dispara `\es@sppercent` fuera de su contexto
normal y produce `! Incompatible glue units.`, típicamente señalado en la
línea `\end{solucion}`.

**Incorrecto** (`%` dentro de `\guia{...}` en modo display):

```latex
\[
  \guia[1]{\%\Delta x \approx \varepsilon_{x,x}\cdot \%\Delta p_x}.
\]
```

**Correcto** — mover el `%` fuera de `\guia{...}`, o directamente sacar todo
el fragmento con `%` del modo display (usar texto normal o `$...$` inline en
vez de `\[...\]`):

```latex
$\%\Delta p_x = \guia[1]{0{,}01}$ (un aumento del $1\%$).
```

Este bug solo aparece en la compilación **base** (sin soluciones/guía), igual
que el del punto decimal — ambos son consecuencia del mismo mecanismo de
recaptura de `environ`.

### Acumulación del offset horizontal de `\guia` fuera de bloques display

La anotación al margen de `\guia` calcula su posición horizontal con un
offset que se acumula `+2em` cada vez que aparece un `\guia` en modo texto
(no display), para evitar que dos anotaciones en la misma línea visual se
sobrepongan. Ese offset **se reinicia automáticamente** al abrir o cerrar un
bloque `\[...\]`/`align`/`gather`, pero **no** al pasar de un `\item` a otro
dentro de `itemize`/`enumerate`/`subejercicios`.

Esto significa que varios `\guia` en modo texto repartidos en distintos
`\item` (sin ningún `\[...\]` entre ellos) heredan el offset acumulado del
`\item` anterior, y cada anotación sucesiva aparece más corrida hacia la
derecha que la anterior — hasta salirse de la página en listas de 3 o más
`\item`.

**Incorrecto** (offset acumulado entre `\item`, sin bloques display):

```latex
\begin{itemize}
  \item $x=0$: Máx \guia[1]{$1800$} en $(0,9)$.
  \item $y=0$: Máx \guia[1]{$4500$} en $(3,0)$.        % ya corrido +2em
  \item Parábola: \guia[1]{$x=3{,}75\notin[0,3]$}.     % ya corrido +4em
\end{itemize}
```

**Correcto** — usar `\guiaretorno` antes de cada `\guia` para reiniciar el
offset manualmente:

```latex
\begin{itemize}
  \item $x=0$: Máx \guiaretorno\guia[1]{$1800$} en $(0,9)$.
  \item $y=0$: Máx \guiaretorno\guia[1]{$4500$} en $(3,0)$.
  \item Parábola: \guiaretorno\guia[1]{$x=3{,}75\notin[0,3]$}.
\end{itemize}
```

### Matemática inline y `\guia` (corregido)

Antes de corregirse, un `\guia` invocado **dentro** de matemática inline
(`$...$`) nunca emitía su anotación al margen, sin ningún error de
compilación — la anotación desaparecía en silencio. La causa: `\guia`
en modo matemático encola su anotación para emitirla cuando cierra el
bloque display (`\]`, `\endalign`, `\endgather`), porque `align`/`gather`/
`equation` usan `\halign` internamente y atrapan `\vadjust` hasta que
cierra la fila. Pero `$...$` inline no pasa por `\halign` y no dispara
ningún "cierre de display", así que la anotación encolada nunca se
vaciaba.

Esto ya está corregido en la clase: `\guia` detecta matemática inline
(`\ifmmode` + `\ifinner`) y emite su anotación de inmediato con
`\vadjust`, igual que en modo texto, en vez de encolarla. Ambos patrones
son válidos ahora:

```latex
Patrón fuera de $...$:  \guia[1]{$k\neq 5$}.
Patrón dentro de $...$: $\guia[1]{k\neq 5}$.
```

Se recomienda seguir usando el primer patrón (`\guia` fuera de `$...$`,
con el contenido matemático como argumento) por ser el más usado en el
curso y el que se ve en todos los ejemplos de este README — pero el
segundo ya no pierde la anotación. Ver `tests/test_guia_inline.tex`
para el caso de regresión.

### Anotación de `\guia` en la página siguiente al bloque display (corregido en `\[...\]`)

Antes de corregirse, un `\guia` dentro de un bloque display (`\[...\]`,
`align`, `gather`) que caía justo al final de una página podía emitir su
anotación al margen en la página **siguiente**, separada del bloque que
anota — sin ningún error de compilación. La causa: `\guia` en modo
matemático display encolaba su anotación para emitirla recién al cerrar
el bloque (`\]`, `\endalign`, `\endgather`). Si ese cierre caía justo
donde TeX ya había decidido cortar la página (por ejemplo, porque no
quedaba más contenido visible después del bloque antes de
`\end{solucion}`), el material encolado terminaba adjunto a la página
siguiente, aunque el bloque display en sí cupiera en la página anterior.
Ajustar el `[voffset]` de `\guia` no arreglaba esto: ese ajuste es un
desplazamiento relativo dentro de una caja que TeX ya despachó a una
página — no puede traerla de vuelta.

**`\[...\]` ya está corregido**: amsmath define `\[...\]` como alias de
`equation*`, que —a diferencia de `align`/`gather`— no usa `\halign`
internamente, así que `\guia` ya no necesita encolar: emite su anotación
de inmediato con `\vadjust` en el punto exacto de la llamada, dentro del
mismo bloque display. Como la anotación queda dentro de la misma caja
que el bloque anota, viaja con ella a cualquier página donde termine.

```latex
\[
  \guia[1]{\frac{1}{z}\,\frac{\partial z}{\partial p_x} = \frac{3}{p_x}}
  \implies
  \frac{\partial z}{\partial p_x} = \frac{3z}{p_x}.
\]
```

**`align`/`gather` siguen en riesgo**: sus celdas de `\halign` atrapan
`\vadjust` por completo (se pierde, no solo se retrasa — confirmado
empíricamente), así que ahí `\guia` todavía debe encolar y emitir en
`\endalign`/`\endgather`, con el mismo riesgo de página descrito arriba.
Si un `\guia` dentro de `align`/`gather` cae justo al borde de una
página y su anotación aparece en la página equivocada, la solución más
simple es forzar el corte manualmente antes del bloque:

```latex
\clearpage % o \pagebreak, según el caso
\begin{align}
  ...
\end{align}
```

Ver `tests/test_guia_pagebreak.tex` para el caso de regresión (cubre
`\[...\]`, que es el caso ya corregido).

---

## Ejemplos

El directorio `ejemplos/` incluye tres ejemplos compilables con sus versiones de soluciones. Cada archivo `.tex` tiene su PDF compilado correspondiente:

| Archivo | Descripción |
|---|---|
| `ejemplos/ejemplo_ejercicios.tex` | Hoja de ejercicios sencilla |
| `ejemplos/ejemplo_ejercicios_soluciones.tex` | Versión con soluciones de la hoja de ejercicios |
| `ejemplos/ejemplo_prueba_corta.tex` | Prueba corta con metadatos e instrucciones |
| `ejemplos/ejemplo_prueba_corta_soluciones.tex` | Versión con soluciones de la prueba corta |
| `ejemplos/ejemplo_examen.tex` | Examen con todos los comandos disponibles |
| `ejemplos/ejemplo_examen_soluciones.tex` | Versión con soluciones del examen |
| `ejemplos/ejemplo_examen_guia.tex` | Versión de guía de calificación del examen |

`emate-ucr.cls`, `UCR.png` y `EMat.pdf` viven en la raíz del repositorio; para compilar un ejemplo desde `ejemplos/` hay que hacer que `pdflatex` los encuentre, por ejemplo:

```bash
cd ejemplos
TEXINPUTS=".:..:" pdflatex ejemplo_examen.tex
```
