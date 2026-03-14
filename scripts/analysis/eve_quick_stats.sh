#!/usr/bin/env bash

set -euo pipefail

# Usage: ./scripts/analysis/eve_quick_stats.sh <path_to_eve.json> [output_summary_path]

# Set the read arguments

EVE_PATH="${1:-}"
OUT_PATH="${2:-}"

# Check for valid input

if [[ -z "$EVE_PATH" ]]; then
	echo "Usage: $0 <path_to_eve.json> [output_summary_path]" 
	exit 1
fi

if [[ ! -f "$EVE_PATH" ]]; then
	echo "Error: eve.json not found at: $EVE_PATH"
	exit 1
fi


# Output logic path

if [[ -z "$OUT_PATH" ]]; then
	mkdir -p data/summaries
	TIME="$(date +%Y%m%d_%H%M%S)"
	OUT_PATH="data/summaries/eve_summary_${TIME}.md"
else
	mkdir -p "$(dirname "$OUT_PATH")"
fi


# Summary Output

{ 
  echo "=== Suricata EVE Quick Summary ===" 
  echo "Source: $EVE_PATH" 
  echo "Generated: $(date)"
  echo

  echo "[1] Total events:"
  wc -l < "$EVE_PATH"
  echo

  echo "[2] Event types breakdown (top 10):"
  grep -o '"event_type":"[^"]*"' "$EVE_PATH" | sort | uniq -c | sort -nr | head -n 10 || true
  echo

  echo "[3] Alert count:"
  grep -c '"event_type":"alert"' "$EVE_PATH" || true
  echo

  echo "[4] Top alert signatures (top 10):"
  grep '"event_type":"alert"' "$EVE_PATH" | grep -o '"signature":"[^"]*"' | sort | uniq -c | sort -nr | head -n 10 || true
  echo

  echo "[5] Top src_ip in alerts (top 10):"
  grep '"event_type":"alert"' "$EVE_PATH" | grep -o '"src_ip":"[^"]*"' | sort | uniq -c | sort -nr | head -n 10 || true
  echo

  echo "[6] Top dest_ip in alerts (top 10):"
  grep '"event_type":"alert"' "$EVE_PATH" | grep -o '"dest_ip":"[^"]*"' | sort | uniq -c | sort -nr | head -n 10 || true
  echo
 } > "$OUT_PATH"


# Script Success Confirmation

echo "[+] Wrote summary to: $OUT_PATH"
