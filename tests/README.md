# Tests de emate-ucr

Este directorio contiene una prueba de regresión para el sistema de
conteo de puntos de `emate-ucr.cls`.

## Qué se prueba

`\totalpuntos` y `\ptsguiaej` dependen de contadores que solo quedan
resueltos correctamente después de una segunda pasada de `pdflatex`
(el mismo mecanismo que usa LaTeX para referencias cruzadas y la tabla
de contenidos). Mientras el valor no está resuelto, la clase debe
emitir:

```
Package emate-ucr Warning: Rerun to get point totals right
```

y dejar de emitirlo una vez que el valor se estabiliza. `test_rerun.sh`
compila cada archivo de prueba varias veces y verifica que ese aviso
aparezca exactamente en las compilaciones donde se espera — ni de más
(quedaría un falso "todo bien" tras un cambio que rompe el conteo) ni
de menos (generaría avisos molestos e innecesarios en documentos
reales).

## Archivos

| Archivo | Qué ejercita | Avisos esperados |
|---------|-------------|-------------------|
| `test_rerun_totalpuntos.tex` | `\totalpuntos` | 1 de 2 compilaciones |
| `test_rerun_ptsguiaej.tex` | `\ptsguiaej` (modo `guia`) | 2 de 3 compilaciones |
| `test_rerun_stable.tex` | Documento sin `\totalpuntos` ni `\ptsguiaej` | 0 de 2 compilaciones |

## Cómo correrlo

```bash
cd tests
./test_rerun.sh
```

El script limpia los auxiliares de cada archivo antes de empezar,
compila con `pdflatex -synctex=1 -interaction=nonstopmode` y revisa el
`.log` resultante en busca del aviso. Sale con código distinto de cero
si alguna compilación no coincide con lo esperado (útil para CI).

Como `emate-ucr.cls`, `UCR.png` y `EMat.pdf` viven en el directorio
padre, el script exporta `TEXINPUTS=".:..:"` para que `pdflatex` los
encuentre sin necesidad de copiarlos aquí.

## Cuándo correrlo

Actualmente es manual: no hay hook de git ni GitHub Actions
configurado todavía que lo ejecute automáticamente. Conviene correrlo
a mano tras cualquier cambio a la lógica de conteo de puntos en
`emate-ucr.cls` (contador `puntos`, `\totalpuntos`, `\guia`,
`\ptsguiaej`, `\ptsguiasubej`) antes de hacer commit.
