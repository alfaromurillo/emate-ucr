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
pdflatex -synctex=1 -interaction=nonstopmode documento.tex
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
  Enunciado del ejercicio sin valor de puntos.
\end{ejercicio}

\begin{ejercicio}[10]
  Enunciado del ejercicio con valor: muestra "(10 pts.)".

  \begin{subejercicios}
    \item Primer inciso.
    \item Segundo inciso.
  \end{subejercicios}
\end{ejercicio}

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

### En el documento

| Comando / Entorno | Descripción |
|---|---|
| `\imprimirtitulo` | Imprime el título y metadatos. Llamar al inicio. |
| `\datosestudiante` | Línea para nombre y carné |
| `\begin{instrucciones}` | Caja enmarcada de indicaciones (items con `\item`) |
| `\begin{indicaciones}` | Indicaciones sin caja, texto libre |
| `\begin{ejercicio}[N]` | Ejercicio numerado automáticamente; N = puntos (opcional) |
| `\begin{subejercicios}` | Incisos a), b), c), ... |
| `\begin{solucion}` | Solución (visible solo con opción `[soluciones]`) |

### Opción de clase

| Opción | Descripción |
|---|---|
| `[soluciones]` | Muestra el contenido de los entornos `solucion` |

---

## Ejemplos

El directorio incluye tres ejemplos compilables con sus versiones de soluciones:

| Archivo | Descripción |
|---|---|
| `ejemplo_ejercicios.tex` | Hoja de ejercicios sencilla |
| `ejemplo_prueba_corta.tex` | Prueba corta con metadatos e instrucciones |
| `ejemplo_examen.tex` | Examen con todos los comandos disponibles |
