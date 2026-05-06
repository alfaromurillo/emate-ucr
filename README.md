# emate-ucr

Clase LaTeX para la Escuela de Matemática de la Universidad de Costa Rica.
Permite preparar hojas de ejercicios, pruebas cortas y exámenes con un formato
institucional uniforme, generando automáticamente una versión con soluciones a
partir del mismo archivo fuente.

**Autor:** Jorge Alfaro Murillo — Escuela de Matemática, UCR
**Licencia:** LPPL 1.3c

---

## Instalación

Copie los tres archivos siguientes en el mismo directorio donde esté su `.tex`:

```
emate-ucr.cls
UCR.png
EMat.pdf
```

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

Imprime: `Ejercicio 1.  (25 pts.)`

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
| `\guia[N]{texto}` | Marca un fragmento de solución con N puntos (ver sección Guía de calificación) |
| `\ptsguiaej` | Suma de `\guia[N]` (N > 0) en el ejercicio actual; usar como argumento de `ejercicio` |
| `\ptsguiasubej` | Suma de `\guia[N]` (N > 0) en el ítem actual de `subejercicios` |

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

```latex
\guia[N]{texto}
```

Dentro de un entorno `solucion`, marca `texto` con N puntos:

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

---

## Ejemplos

El directorio incluye tres ejemplos compilables con sus versiones de soluciones:

| Archivo | Descripción |
|---|---|
| `ejemplo_ejercicios.tex` | Hoja de ejercicios sencilla |
| `ejemplo_prueba_corta.tex` | Prueba corta con metadatos e instrucciones |
| `ejemplo_examen.tex` | Examen con todos los comandos disponibles |
| `ejemplo_examen_soluciones.tex` | Versión con soluciones del examen |
| `ejemplo_examen_guia.tex` | Versión de guía de calificación del examen |
