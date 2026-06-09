#!/usr/bin/env bash
# test_rerun.sh — verifica que emate-ucr emite "Rerun to get point totals right"
# exactamente el número de veces esperado.

set -euo pipefail
cd "$(dirname "$0")"

PASS=0
FAIL=0

# $1 = archivo .tex (sin extensión)
# $2 = compilaciones esperadas con aviso (las primeras N tendrán aviso)
# $3 = total de compilaciones a probar
check() {
  local base="$1"
  local warn_runs="$2"
  local total_runs="$3"
  local tex="${base}.tex"

  echo ""
  echo "=== $base (aviso esperado en ${warn_runs} de ${total_runs} compilaciones) ==="

  # Borra auxiliares para empezar limpio
  rm -f "${base}.aux" "${base}.log" "${base}.out" "${base}.pdf" \
        "${base}.synctex.gz"

  for i in $(seq 1 "$total_runs"); do
    pdflatex -synctex=1 -interaction=nonstopmode "$tex" > /dev/null 2>&1
    local log="${base}.log"

    if grep -q "Package emate-ucr Warning: Rerun to get point totals right" "$log"; then
      local got_warn=1
    else
      local got_warn=0
    fi

    if [ "$i" -le "$warn_runs" ]; then
      # Se esperaba aviso
      if [ "$got_warn" -eq 1 ]; then
        echo "  Compilación $i: PASS  (aviso presente, como se esperaba)"
        PASS=$((PASS+1))
      else
        echo "  Compilación $i: FAIL  (se esperaba aviso, pero no aparece)"
        FAIL=$((FAIL+1))
      fi
    else
      # No se esperaba aviso
      if [ "$got_warn" -eq 0 ]; then
        echo "  Compilación $i: PASS  (sin aviso, como se esperaba)"
        PASS=$((PASS+1))
      else
        echo "  Compilación $i: FAIL  (aviso inesperado)"
        FAIL=$((FAIL+1))
      fi
    fi
  done
}

check test_rerun_totalpuntos 1 2   # 1 aviso, luego estable
check test_rerun_ptsguiaej   2 3   # 2 avisos, luego estable
check test_rerun_stable      0 2   # nunca aviso

echo ""
echo "========================================"
echo "Resultado: ${PASS} pasaron, ${FAIL} fallaron"
echo "========================================"

[ "$FAIL" -eq 0 ]
