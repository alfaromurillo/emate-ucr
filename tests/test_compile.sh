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
    if echo "$text" | grep -qF -- "$needle"; then
      echo "  $base: PASS  ($desc)"
      PASS=$((PASS+1))
    else
      echo "  $base: FAIL  ($desc — no se encontró \"$needle\" en el PDF)"
      FAIL=$((FAIL+1))
    fi
  done
}

# Verifica que dos cadenas aparezcan en la MISMA página del PDF (busca la
# página que contiene $2 y cuenta ahí las ocurrencias de $3).
# $1 = archivo .tex (sin extensión)
# $2 = cadena ancla (p.ej. el texto justo antes del bloque display)
# $3 = cadena que debe acompañarla en esa misma página
# $4 = número esperado de ocurrencias de $3 en esa página
# $5 = descripción
check_same_page() {
  local base="$1" anchor="$2" needle="$3" expected="$4" desc="$5"
  local tex="${base}.tex"

  rm -f "${base}.aux" "${base}.log" "${base}.out" "${base}.pdf" \
        "${base}.synctex.gz"

  pdflatex -synctex=1 -interaction=nonstopmode "$tex" > /dev/null 2>&1 || true
  pdflatex -synctex=1 -interaction=nonstopmode "$tex" > /dev/null 2>&1 || true

  if [ ! -f "${base}.pdf" ]; then
    echo "  $base: FAIL  (no se generó ${base}.pdf)"
    FAIL=$((FAIL+1))
    return
  fi

  local npages
  npages="$(pdfinfo "${base}.pdf" 2>/dev/null | awk '/^Pages:/{print $2}')"

  local page count
  for page in $(seq 1 "$npages"); do
    if pdftotext -f "$page" -l "$page" "${base}.pdf" - 2>/dev/null \
        | grep -qF "$anchor"; then
      count=$(pdftotext -f "$page" -l "$page" "${base}.pdf" - 2>/dev/null \
        | grep -oF "$needle" | wc -l || true)
      if [ "$count" -eq "$expected" ]; then
        echo "  $base: PASS  ($desc)"
        PASS=$((PASS+1))
      else
        echo "  $base: FAIL  ($desc — página $page tiene $count de $expected)"
        FAIL=$((FAIL+1))
      fi
      return
    fi
  done
  echo "  $base: FAIL  ($desc — no se encontró \"$anchor\" en ninguna página)"
  FAIL=$((FAIL+1))
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
echo "=== test_guia_inline (\\guia dentro de matemática inline, modo guia) ==="
check_pdftext_contains test_guia_inline \
  "+1" 'anotación de \guia fuera de $...$' \
  "+2" 'anotación de \guia dentro de $...$'

echo ""
echo "=== test_guia_pagebreak (anotación de \\guia en bloque display al borde de página) ==="
check_same_page test_guia_pagebreak "Diferenciando" "+1" 2 \
  '"Diferenciando" y ambos "+1" en la misma página'

echo ""
echo "=== test_guia_math_strike_guia (\\guia[N<0] tachado en matemática, modo guia) ==="
check_no_error test_guia_math_strike_guia '^!' 'un error de LaTeX'
check_pdftext_contains test_guia_math_strike_guia \
  "-1" 'anotación de \guia negativo en matemática inline' \
  "-2" 'anotación de \guia negativo en matemática display'

echo ""
echo "=== test_guia_math_strike_soluciones (sin anotaciones de \\guia en modo soluciones) ==="
check_no_error test_guia_math_strike_soluciones '^!' 'un error de LaTeX'
if [ -f test_guia_math_strike_soluciones.pdf ] \
    && ! pdftotext test_guia_math_strike_soluciones.pdf - 2>/dev/null \
      | grep -qE -- '-1|-2'; then
  echo "  test_guia_math_strike_soluciones: PASS  (sin anotaciones -1/-2 en soluciones)"
  PASS=$((PASS+1))
else
  echo "  test_guia_math_strike_soluciones: FAIL  (anotación -1/-2 filtrada a soluciones)"
  FAIL=$((FAIL+1))
fi

echo ""
echo "=== test_guia_halign_guia (\\guia dentro de align/align*/gather/gather*) ==="
check_no_error test_guia_halign_guia '^!' 'un error de LaTeX'
check_pdftext_contains test_guia_halign_guia \
  "+1" 'anotación de \guia en align*' \
  "+2" 'anotación de \guia en align* (segunda línea)' \
  "+3" 'anotación de \guia en align' \
  "+4" 'anotación de \guia en gather' \
  "+5" 'anotación de \guia en gather*'

echo ""
echo "=== test_guia_halign_soluciones (sin anotaciones de \\guia en modo soluciones) ==="
check_no_error test_guia_halign_soluciones '^!' 'un error de LaTeX'
if [ -f test_guia_halign_soluciones.pdf ] \
    && ! pdftotext test_guia_halign_soluciones.pdf - 2>/dev/null \
      | grep -qE -- '\+1|\+2|\+3|\+4|\+5'; then
  echo "  test_guia_halign_soluciones: PASS  (sin anotaciones +1..+5 en soluciones)"
  PASS=$((PASS+1))
else
  echo "  test_guia_halign_soluciones: FAIL  (anotación +N filtrada a soluciones)"
  FAIL=$((FAIL+1))
fi

echo ""
echo "=== test_solosinsoluciones (comando y entorno, modo base) ==="
check_no_error test_solosinsoluciones '^!' 'un error de LaTeX'
check_pdftext_contains test_solosinsoluciones \
  "MARCACOMANDO" '\solosinsoluciones{...} se muestra en modo base' \
  "MARCAENTORNO" 'entorno solosinsolucionesbloque se muestra en modo base'
npages="$(pdfinfo test_solosinsoluciones.pdf 2>/dev/null \
  | awk '/^Pages:/{print $2}')"
if [ "$npages" -eq 2 ]; then
  echo "  test_solosinsoluciones: PASS  (\\newpage forzado: 2 páginas)"
  PASS=$((PASS+1))
else
  echo "  test_solosinsoluciones: FAIL  (se esperaban 2 páginas, hubo $npages)"
  FAIL=$((FAIL+1))
fi

echo ""
echo "=== test_solosinsoluciones_soluciones (se oculta en modo soluciones) ==="
check_no_error test_solosinsoluciones_soluciones '^!' 'un error de LaTeX'
if [ -f test_solosinsoluciones_soluciones.pdf ] \
    && ! pdftotext test_solosinsoluciones_soluciones.pdf - 2>/dev/null \
      | grep -qE 'MARCACOMANDO|MARCAENTORNO'; then
  echo "  test_solosinsoluciones_soluciones: PASS  (sin MARCACOMANDO/MARCAENTORNO)"
  PASS=$((PASS+1))
else
  echo "  test_solosinsoluciones_soluciones: FAIL  (contenido filtrado a soluciones)"
  FAIL=$((FAIL+1))
fi
npages="$(pdfinfo test_solosinsoluciones_soluciones.pdf 2>/dev/null \
  | awk '/^Pages:/{print $2}')"
if [ "$npages" -eq 1 ]; then
  echo "  test_solosinsoluciones_soluciones: PASS  (\\newpage suprimido: 1 página)"
  PASS=$((PASS+1))
else
  echo "  test_solosinsoluciones_soluciones: FAIL  (se esperaba 1 página, hubo $npages)"
  FAIL=$((FAIL+1))
fi

echo ""
echo "=== test_solosinsoluciones_guia (se oculta en modo guia) ==="
check_no_error test_solosinsoluciones_guia '^!' 'un error de LaTeX'
if [ -f test_solosinsoluciones_guia.pdf ] \
    && ! pdftotext test_solosinsoluciones_guia.pdf - 2>/dev/null \
      | grep -qE 'MARCACOMANDO|MARCAENTORNO'; then
  echo "  test_solosinsoluciones_guia: PASS  (sin MARCACOMANDO/MARCAENTORNO)"
  PASS=$((PASS+1))
else
  echo "  test_solosinsoluciones_guia: FAIL  (contenido filtrado a guia)"
  FAIL=$((FAIL+1))
fi
npages="$(pdfinfo test_solosinsoluciones_guia.pdf 2>/dev/null \
  | awk '/^Pages:/{print $2}')"
if [ "$npages" -eq 1 ]; then
  echo "  test_solosinsoluciones_guia: PASS  (\\newpage suprimido: 1 página)"
  PASS=$((PASS+1))
else
  echo "  test_solosinsoluciones_guia: FAIL  (se esperaba 1 página, hubo $npages)"
  FAIL=$((FAIL+1))
fi

echo ""
echo "========================================"
echo "Resultado: ${PASS} pasaron, ${FAIL} fallaron"
echo "========================================"

[ "$FAIL" -eq 0 ]
