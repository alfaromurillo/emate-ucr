#!/usr/bin/env bash
# test_compile.sh — verifica que los patrones documentados como
# "correctos" en README.md (sección "Notas de compatibilidad") sigan
# compilando sin los errores que documentan. Complementa a
# test_rerun.sh, que solo cubre el aviso de rerun.

set -euo pipefail
cd "$(dirname "$0")"
export TEXINPUTS=".:..:${TEXINPUTS:-}"

PASS=0
FAIL=0

# $1 = archivo .tex (sin extensión)
# $2 = patrón (grep -E) que NO debe aparecer en el .log
# $3 = descripción del error que se está evitando
check_no_error() {
  local base="$1"
  local pattern="$2"
  local desc="$3"
  local tex="${base}.tex"

  rm -f "${base}.aux" "${base}.log" "${base}.out" "${base}.pdf" \
        "${base}.synctex.gz"

  pdflatex -synctex=1 -interaction=nonstopmode "$tex" > /dev/null 2>&1 || true

  if [ ! -f "${base}.log" ]; then
    echo "  $base: FAIL  (no se generó ${base}.log)"
    FAIL=$((FAIL+1))
    return
  fi

  if grep -qE "$pattern" "${base}.log"; then
    echo "  $base: FAIL  ($desc apareció en el log)"
    FAIL=$((FAIL+1))
  else
    echo "  $base: PASS  (sin $desc)"
    PASS=$((PASS+1))
  fi
}

# $1 = archivo .tex (sin extensión)
# resto = pares "cadena esperada" "descripción"
check_pdftext_contains() {
  local base="$1"
  shift
  local tex="${base}.tex"

  rm -f "${base}.aux" "${base}.log" "${base}.out" "${base}.pdf" \
        "${base}.synctex.gz"

  pdflatex -synctex=1 -interaction=nonstopmode "$tex" > /dev/null 2>&1 || true

  if [ ! -f "${base}.pdf" ]; then
    echo "  $base: FAIL  (no se generó ${base}.pdf)"
    FAIL=$((FAIL+1))
    return
  fi

  local text
  text="$(pdftotext "${base}.pdf" - 2>/dev/null)"

  while [ "$#" -ge 2 ]; do
    local needle="$1"
    local desc="$2"
    shift 2
    if echo "$text" | grep -qF "$needle"; then
      echo "  $base: PASS  ($desc)"
      PASS=$((PASS+1))
    else
      echo "  $base: FAIL  ($desc — no se encontró \"$needle\" en el PDF)"
      FAIL=$((FAIL+1))
    fi
  done
}

echo "=== test_guia_puntuacion (puntuación fuera de \\guia{...}) ==="
check_no_error test_guia_puntuacion 'Extra \\endcsname|Extra \\fi' \
  '"Extra \endcsname"/"Extra \fi"'

echo ""
echo "=== test_guia_percent (% fuera de \\guia{...} en modo display) ==="
check_no_error test_guia_percent 'Incompatible glue units' \
  '"Incompatible glue units"'

echo ""
echo "=== test_tikz_solucion (TikZ con \\shorthandoff{>}, modo base) ==="
check_no_error test_tikz_solucion '^!' 'un error de LaTeX'

echo ""
echo "=== test_tikz_solucion_soluciones (TikZ con \\shorthandoff{>}, modo soluciones) ==="
check_no_error test_tikz_solucion_soluciones '^!' 'un error de LaTeX'

echo ""
echo "=== test_pts_format (\\pts no se parte entre líneas, singular) ==="
check_pdftext_contains test_pts_format \
  "(2 pts.)" '"(2 pts.)" no se partió entre líneas' \
  "(1 pt.)" '"(1 pt.)" en singular'
if pdftotext test_pts_format.pdf - 2>/dev/null | grep -qF "(1 pts.)"; then
  echo "  test_pts_format: FAIL  (\"(1 pts.)\" en plural, debería ser singular)"
  FAIL=$((FAIL+1))
else
  echo "  test_pts_format: PASS  (sin \"(1 pts.)\" en plural)"
  PASS=$((PASS+1))
fi

echo ""
echo "========================================"
echo "Resultado: ${PASS} pasaron, ${FAIL} fallaron"
echo "========================================"

[ "$FAIL" -eq 0 ]
