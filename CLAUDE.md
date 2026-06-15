# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**emate-ucr** is a custom LaTeX class (`emate-ucr.cls`) for the Escuela de Matemática at Universidad de Costa Rica. It generates standardized exercise sheets, quizzes (*pruebas cortas*), and exams with automatic dual-version support: one source file produces both a student version and an instructor version with solutions.

## Build Commands

Requires **pdflatex**. The class file, `UCR.png`, and `EMat.pdf` must be in the same directory as the document.

```bash
# Compile a document
pdflatex documento.tex

# When using \totalpuntos in the preamble, compile twice for correct totals
pdflatex documento.tex && pdflatex documento.tex
```

## Dual-Version Workflow

The key architectural pattern: the main `.tex` file is the student version. A companion `*_soluciones.tex` wrapper enables the solutions version:

```latex
% ejemplo_prueba_corta_soluciones.tex
\PassOptionsToClass{soluciones}{emate-ucr}
\input{ejemplo_prueba_corta}
```

`\begin{solucion}...\end{solucion}` blocks are hidden by default and only rendered when the `soluciones` class option is passed.

A third `*_guia.tex` wrapper enables a grading-guide version that adds colored score annotations to the solution text:

```latex
% ejemplo_examen_guia.tex
\PassOptionsToClass{guia}{emate-ucr}
\input{ejemplo_examen}
```

The `guia` option implies `soluciones` (solutions are always visible in the guide).

## Key Commands and Environments

**Preamble metadata** (defined before `\begin{document}`):
- `\curso{text}` — course info for page header
- `\encabezado{text}` — document title
- `\fecha{text}`, `\duracion{text}`, `\valor{text}` — optional evaluation metadata

**Document body**:
- `\imprimirtitulo` — renders the formatted title block
- `\datosestudiante` — adds fillable name/ID lines
- `\begin{instrucciones}...\end{instrucciones}` — boxed numbered instructions
- `\begin{indicaciones}...\end{indicaciones}` — unboxed instructions
- `\begin{ejercicio}[N]...\end{ejercicio}` — auto-numbered exercise worth N points
- `\begin{subejercicios}...\end{subejercicios}` — sub-items (a, b, c, ...)
- `\pts{N}` — right-aligned "(N pts.)" within a `\item`
- `\totalpuntos` — auto-sum of all exercise point values
- `\begin{solucion}...\end{solucion}` — instructor-only content
- `\guia[N]{text}` — marks gradeable text; colored underline with score in `guia` mode, plain text in `soluciones` mode
- `\ptsguiaej` / `\ptsguiasubej` — display accumulated `\guia` points for current exercise / sub-item
- `\nombreejercicio{text}` — overrides exercise label prefix (default: "Ejercicio")

## Example Files

The repo root contains worked examples that double as test cases:

| Base file | What it demonstrates |
|-----------|---------------------|
| `ejemplo_ejercicios.tex` + `_soluciones.tex` | Exercise sheet with `subejercicios`, `\pts`, solutions |
| `ejemplo_prueba_corta.tex` + `_soluciones.tex` | Short quiz (prueba corta) |
| `ejemplo_examen.tex` + `_soluciones.tex` + `_guia.tex` | Full exam with all three variants |

Real-world usage in `~/documents/projects/ma1022/`:
- `ejercicios/ejercicios_semana_XX.tex` — weekly exercise sheets
- `pruebas/` — partial exams (`cuarto_parcial.tex`, etc.) with `_soluciones` and `_guia` variants

`test_rerun.sh` verifies multi-pass compilation stability (runs
pdflatex twice and diffs the PDF checksums).

## Class Architecture (`emate-ucr.cls`)

The class extends `article` at 12pt. Point counting uses a LaTeX counter (`puntos`) incremented by each `ejercicio` environment. The `solucion` environment is implemented with the `environ` package: when the `soluciones` option is not set, `\BODY` is discarded; when set, it renders in a colored `mdframed` box.
