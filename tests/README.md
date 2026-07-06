# Tests de emate-ucr

Este directorio contiene dos suites de regresión para `emate-ucr.cls`:
`test_rerun.sh` (conteo de puntos multi-pasada) y `test_compile.sh`
(patrones documentados en `README.md` que antes rompían la compilación).

## `test_rerun.sh` — qué se prueba

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

| Archivo | Qué ejercita | Avisos esperados |
|---------|-------------|-------------------|
| `test_rerun_totalpuntos.tex` | `\totalpuntos` | 1 de 2 compilaciones |
| `test_rerun_ptsguiaej.tex` | `\ptsguiaej` (modo `guia`) | 2 de 3 compilaciones |
| `test_rerun_stable.tex` | Documento sin `\totalpuntos` ni `\ptsguiaej` | 0 de 2 compilaciones |

## `test_compile.sh` — qué se prueba

Cada fixture reproduce un patrón que la sección "Notas de
compatibilidad" de `README.md` documenta como *correcto*, y verifica
que siga compilando sin el error que esa sección describe. Estos son
bugs reales que mordieron en documentos de `ma1022` antes de
documentarse el workaround — el objetivo es que un cambio futuro a
`emate-ucr.cls` no reintroduzca silenciosamente el problema.

| Archivo | Qué ejercita | Se verifica que NO aparezca |
|---------|-------------|-------------------------------|
| `test_guia_puntuacion.tex` | Puntuación fuera de `\guia{...}`, modo base | `Extra \endcsname` / `Extra \fi` |
| `test_guia_percent.tex` | `%` fuera de `\guia{...}` en modo display, modo base | `Incompatible glue units` |
| `test_tikz_solucion.tex` | TikZ en `solucion` con `\shorthandoff{>}`, modo base | cualquier error de LaTeX |
| `test_tikz_solucion_soluciones.tex` | Igual, modo `soluciones` | cualquier error de LaTeX |
| `test_pts_format.tex` | `\pts{2}` no se parte entre líneas (minipage angosto); `\pts{1}` usa singular | ausencia de `(2 pts.)`/`(1 pt.)` contiguos en el PDF, o presencia de `(1 pts.)` |

`test_pts_format.tex` usa `pdftotext` (parte de `poppler-utils`) para
extraer el texto del PDF en vez de grepear el `.log`, porque el bug que
prueba es de *layout* (un salto de línea en medio de la anotación), no
un error de compilación.

Importante: estos tests prueban el **patrón correcto/documentado**, no
que el patrón incorrecto siga fallando. Si algún día se arregla la
causa raíz en `babel`/`environ`, estos tests deberían seguir pasando
sin cambios — solo se rompen si algo deja de funcionar.

## Cómo correrlos

```bash
cd tests
./test_rerun.sh
./test_compile.sh
```

Ambos scripts limpian los auxiliares de cada archivo antes de empezar,
compilan con `pdflatex -synctex=1 -interaction=nonstopmode` y salen con
código distinto de cero si algo no coincide con lo esperado (útil para
CI). `test_compile.sh` además requiere `pdftotext` en el PATH.

Como `emate-ucr.cls`, `UCR.png` y `EMat.pdf` viven en el directorio
padre, ambos scripts exportan `TEXINPUTS=".:..:"` para que `pdflatex`
los encuentre sin necesidad de copiarlos aquí.

## Cuándo correrlos

Hay un hook de `pre-push` (`.githooks/pre-push`) que corre ambas
suites automáticamente antes de aceptar un `git push`, y aborta el
push si alguna falla. Los hooks de git no se clonan solos — hay que
activarlo una vez por clon del repositorio:

```bash
git config core.hooksPath .githooks
```

Para saltarlo puntualmente: `git push --no-verify`.

Si se prefiere correrlos a mano, por ejemplo tras cualquier cambio a
`emate-ucr.cls` que toque el conteo de puntos (`\totalpuntos`, `\guia`,
`\ptsguiaej`, `\ptsguiasubej`) o el manejo de `\guia`/TikZ/`\pts`, basta
con ejecutar los scripts directamente.
