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
- `\solosinsoluciones{text}` / `\begin{solosinsolucionesbloque}...\end{solosinsolucionesbloque}` — mirror of `solucion`: content shown only in the base version (neither `soluciones` nor `guia`); e.g. for a `\newpage` that only makes sense on the printed copy
- `\guia[N]{text}` — marks gradeable text; colored underline with score in `guia` mode, plain text in `soluciones` mode
- `\ptsguiaej` / `\ptsguiasubej` — display accumulated `\guia` points for current exercise / sub-item
- `\nombreejercicio{text}` — overrides exercise label prefix (default: "Ejercicio")

## Example Files

`ejemplos/` contains worked examples that double as test cases.
`emate-ucr.cls`, `UCR.png`, and `EMat.pdf` stay in the repo root, so
compiling from `ejemplos/` needs `TEXINPUTS=".:..:"` (or copy/symlink
them in):

| Base file | What it demonstrates |
|-----------|---------------------|
| `ejemplos/ejemplo_ejercicios.tex` + `_soluciones.tex` | Exercise sheet with `subejercicios`, `\pts`, solutions |
| `ejemplos/ejemplo_prueba_corta.tex` + `_soluciones.tex` | Short quiz (prueba corta) |
| `ejemplos/ejemplo_examen.tex` + `_soluciones.tex` + `_guia.tex` | Full exam with all three variants |

Real-world usage in `~/documents/projects/ma1022/`:
- `ejercicios/ejercicios_semana_XX.tex` — weekly exercise sheets
- `pruebas/` — partial exams (`cuarto_parcial.tex`, etc.) with `_soluciones` and `_guia` variants

`tests/test_rerun.sh` verifies multi-pass compilation stability: it
recompiles `\totalpuntos`/`\ptsguiaej` fixtures several times and
checks the "Rerun to get point totals right" warning appears/disappears
on the expected passes. `tests/test_compile.sh` recompiles fixtures for
the bugs documented in README's "Notas de compatibilidad" (punctuation/
`%` inside `\guia{...}`, TikZ inside `solucion`, `\pts` line-breaking/
singular) and checks the documented-correct pattern still compiles
clean. See `tests/README.md`.

A `pre-push` git hook (`.githooks/pre-push`) runs both test suites
before every `git push` and aborts on failure. Each clone must enable
it once with `git config core.hooksPath .githooks` (hooks aren't
tracked by git and don't come along automatically).

`test_compile.sh` runs under `set -euo pipefail`: a `grep ... | wc -l`
where grep matches zero lines exits 1 and aborts the whole script
silently (even though `wc -l` itself succeeds). Append `|| true` to
any such pipeline when adding new checks.

## Class Architecture (`emate-ucr.cls`)

The class extends `article` at 12pt. Point counting uses a LaTeX counter (`puntos`) incremented by each `ejercicio` environment. The `solucion` environment is implemented with the `environ` package: when the `soluciones` option is not set, `\BODY` is discarded; when set, it renders in a colored `mdframed` box.

`\guia`'s margin annotation (`\@guiamargnote`) behaves differently by math context: inline (`$...$`) and `\[...\]` emit immediately via `\vadjust`; `align`/`align*`/`gather`/`gather*` must enqueue and flush at `\endalign`/`\endgather` (and their `*` counterparts) because their `\halign` internals truly trap `\vadjust` (confirmed empirically — content silently dropped, not just delayed). `\[...\]` doesn't need this because amsmath defines it as `equation*`, which has no `\halign`. Any future `\guia`-in-math-mode bug report is probably about this split; check which branch (`\ifmmode`/`\ifinner`/`\if@guiahalign`) it's landing in first.

Gotcha already hit once: `\ifinner` is **also** true inside `\halign` cells (restricted horizontal mode), not just in true inline math — so `\@guiamargnote` must check `\if@guiahalign` *before* `\ifinner`, or the halign branch is unreachable and the annotation silently drops instead of enqueueing. Relatedly, `align*`/`gather*` are separate control sequences from `\align`/`\gather` (`\csname align*\endcsname`, reached via `\expandafter`), so `\@guiacuerpo` must intercept all four names explicitly — patching `\align`/`\gather` alone leaves the starred variants uncovered. See `tests/test_guia_halign.tex`.

To debug a `\vadjust`/page-break placement bug: build a minimal repro, bisect the amount of filler text before the display block until `pdfinfo` shows the page count you're chasing, then use `pdftotext -f N -l N file.pdf -` to inspect what landed on each page.

`\solosinsoluciones`/`solosinsolucionesbloque` deliberately use two different names, not `\renewenvironment` tricks: `\begin{foo}` always expands to `\foo`, so a one-argument command and an environment can't share a control sequence name — `\NewEnviron{solosinsoluciones}` collides with `\newcommand{\solosinsoluciones}` and errors "already defined". Any future request to unify their names hits this same wall.
