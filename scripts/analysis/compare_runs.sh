#!/usr/bin/env bash
set -euo pipefail

# compare_runs.sh
# Purpose: Compare baseline vs brute-force runs using their summary.md files.
#
# Usage:
#   ./scripts/analysis/compare_runs.sh <baseline_run_id> <brute_run_id>

BASE_ID="${1:-}"
BRUTE_ID="${2:-}"

if [[ -z "$BASE_ID" || -z "$BRUTE_ID" ]]; then
  echo "Usage: $0 <baseline_run_id> <brute_run_id>"
  exit 1
fi

BASE_SUM="runs/$BASE_ID/summary.md"
BRUTE_SUM="runs/$BRUTE_ID/summary.md"

if [[ ! -f "$BASE_SUM" ]]; then
  echo "Error: baseline summary not found: $BASE_SUM"
  exit 1
fi
if [[ ! -f "$BRUTE_SUM" ]]; then
  echo "Error: brute summary not found: $BRUTE_SUM"
  exit 1
fi

# Return the first non-empty line AFTER a marker line.
get_next_value_line() {
  local file="$1"
  local marker="$2"

  # Print from marker line to the end, drop the first line (marker),
  # then return the first non-empty line.
  sed -n "/$marker/,\$p" "$file" \
    | sed '1d' \
    | grep -m1 -E '[^[:space:]]' \
    | tr -d '\r' \
    || true
}

# Return the first signature line AFTER the "Top alert signatures" section header.
get_top_signature_line() {
  local file="$1"

  sed -n "/^\[4\] Top alert signatures/,\$p" "$file" \
    | sed '1d' \
    | grep -m1 '"signature":"' \
    | tr -d '\r' \
    || true
}

# Extract numbers from lines like "140" or "     51 ..."
get_first_number() {
  echo "$1" | grep -Eo '[0-9]+' | head -n 1 || true
}

# Extract signature text from a line like: 38 "signature":"SURICATA SSH invalid banner"
get_signature_text() {
  echo "$1" | sed -n 's/.*"signature":"\([^"]\+\)".*/\1/p' || true
}

# Baseline metrics
BASE_TOTAL_LINE="$(get_next_value_line "$BASE_SUM" "^\[1\] Total events:")"
BASE_ALERT_LINE="$(get_next_value_line "$BASE_SUM" "^\[3\] Alert count:")"
BASE_SIG_LINE="$(get_top_signature_line "$BASE_SUM")"

BASE_TOTAL="$(get_first_number "$BASE_TOTAL_LINE")"
BASE_ALERTS="$(get_first_number "$BASE_ALERT_LINE")"
BASE_SIG="$(get_signature_text "$BASE_SIG_LINE")"

# Brute-force metrics
BRUTE_TOTAL_LINE="$(get_next_value_line "$BRUTE_SUM" "^\[1\] Total events:")"
BRUTE_ALERT_LINE="$(get_next_value_line "$BRUTE_SUM" "^\[3\] Alert count:")"
BRUTE_SIG_LINE="$(get_top_signature_line "$BRUTE_SUM")"

BRUTE_TOTAL="$(get_first_number "$BRUTE_TOTAL_LINE")"
BRUTE_ALERTS="$(get_first_number "$BRUTE_ALERT_LINE")"
BRUTE_SIG="$(get_signature_text "$BRUTE_SIG_LINE")"

# Fall back to N/A if empty
BASE_TOTAL="${BASE_TOTAL:-N/A}"
BRUTE_TOTAL="${BRUTE_TOTAL:-N/A}"
BASE_ALERTS="${BASE_ALERTS:-N/A}"
BRUTE_ALERTS="${BRUTE_ALERTS:-N/A}"
BASE_SIG="${BASE_SIG:-N/A}"
BRUTE_SIG="${BRUTE_SIG:-N/A}"

mkdir -p reports
OUT="reports/compare_${BASE_ID}_vs_${BRUTE_ID}.md"

cat > "$OUT" <<EOF
# Baseline vs SSH Brute-Force Comparison

## Runs Compared
- Baseline Run ID: \`$BASE_ID\` (summary: \`$BASE_SUM\`)
- Brute-Force Run ID: \`$BRUTE_ID\` (summary: \`$BRUTE_SUM\`)

## Metrics

| Metric | Baseline | Brute-force |
|---|---:|---:|
| Total events | $BASE_TOTAL | $BRUTE_TOTAL |
| Alert count | $BASE_ALERTS | $BRUTE_ALERTS |
| Top alert signature | $BASE_SIG | $BRUTE_SIG |
EOF

echo "[+] Wrote comparison report: $OUT"
